use crate::robj_to;
use crate::series::RPolarsSeries;
use crate::utils::collect_hinted_result;
use extendr_api::prelude::*;
/// this file implements any conversion from Robject to polars::Series
/// most other R to polars conversion uses the module only pub function robjname2series()
use polars::prelude as pl;
use polars::prelude::IntoSeries;
use polars::prelude::NamedFrom;
use polars_lazy::dsl::col;
use polars_lazy::frame::IntoLazy;
// Internal tree structure to contain Series of fully parsed nested Robject.
// It is easier to resolve concatenated datatype after all elements have been parsed
// because empty lists have no type in R, but the corrosponding polars type must be known before
// concatenation.
#[derive(Debug)]
enum SeriesTree {
    Series(pl::Series), // an R object likely some vector was converted into a plain Series
    SeriesVec(Vec<SeriesTree>), // an R object was converted into list of Series'
    SeriesEmptyVec, // likely an R NULL or list() delayed conversion as corrosponding polars is yet given
}

// Main module function: Convert any potentially nested R object handled in three steps
pub fn robjname2series(x: Robj, name: &str) -> pl::PolarsResult<pl::Series> {
    // 1 parse any (potentially) R structure, into a tree of Series, boubble any parse error
    let st = recursive_robjname2series_tree(&x, name)?;

    // 2 search for first leaf dtype, returns None for empty list or lists of empty lists and so on ...
    let first_leaf_dtype = find_first_leaf_datatype(&st);

    // 3 concat SeriesTree into one Series, boubble any type mismatch error
    concat_series_tree(st, &first_leaf_dtype, name)
}

// this function walks the SeriesTree to find the first leaf DataType
fn find_first_leaf_datatype(st: &SeriesTree) -> Option<pl::DataType> {
    match st {
        SeriesTree::Series(s) => Some(s.dtype().clone()), //an actual leaf type found, return as the answer
        SeriesTree::SeriesEmptyVec => None, //no type to be found here in this empty list return None from here
        SeriesTree::SeriesVec(sv) => sv //looking deeper in nested structure
            .iter()
            .map(find_first_leaf_datatype)
            .find(|x| x.is_some())
            .flatten(),
    }
}

// convert any Robj into a SeriesTree, or a nested SeriesTree if nested Robject
fn recursive_robjname2series_tree(x: &Robj, name: &str) -> pl::PolarsResult<SeriesTree> {
    let rtype = x.rtype();

    // preprocess types

    // handle any supported Robj
    let series_result = match rtype {
        Rtype::Null => Ok(SeriesTree::SeriesEmptyVec), // flag NULL with this enum, to resolve polars type later

        Rtype::ExternalPtr => match () {
            _ if x.inherits("RPolarsSeries") => {
                let s: RPolarsSeries =
                    unsafe { &mut *x.external_ptr_addr::<RPolarsSeries>() }.clone();

                let dtype = s.0.dtype().clone();
                match dtype {
                    pl::DataType::Null => Ok(SeriesTree::SeriesEmptyVec),
                    _ => Ok(SeriesTree::Series(s.0)),
                }
            }
            _ => Err(pl::PolarsError::InvalidOperation(
                "This externalPtr is currently not supported".into(),
            )),
        },
        Rtype::Doubles if x.inherits("integer64") => {
            let rdouble: Doubles = x.try_into().expect("as matched");
            if rdouble.no_na().is_true() {
                let real_slice = x.as_real_slice().unwrap();
                let i64_slice = unsafe { std::mem::transmute::<&[f64], &[i64]>(real_slice) };
                Ok(SeriesTree::Series(pl::Series::new(name.into(), i64_slice)))
            } else {
                let mut s: pl::Series = rdouble //convert R NAs to rust options
                    .iter()
                    .map(|x| {
                        //if x.is_na() { None } else { Some(x.0) }
                        let x = x.inner().to_bits() as i64;
                        if x == crate::utils::BIT64_NA_ENCODING {
                            None
                        } else {
                            Some(x)
                        }
                    })
                    .collect();
                s.rename(name.into());
                Ok(SeriesTree::Series(s))
            }
        }
        Rtype::Doubles => {
            let rdouble: Doubles = x.try_into().expect("as matched");
            if rdouble.no_na().is_true() {
                Ok(SeriesTree::Series(pl::Series::new(
                    name.into(),
                    x.as_real_slice().unwrap(),
                )))
            } else {
                let mut s: pl::Series = rdouble //convert R NAs to rust options
                    .iter()
                    .map(|x| if x.is_na() { None } else { Some(x.inner()) })
                    .collect();
                s.rename(name.into());
                Ok(SeriesTree::Series(s))
            }
        }

        Rtype::Strings => Ok(SeriesTree::Series(robj_to_utf8_series(
            x.try_into().expect("as matched"),
            name,
        ))),

        Rtype::Logicals => {
            let logicals: Logicals = x.try_into().unwrap();
            let s: Vec<Option<bool>> = logicals
                .iter()
                .map(|x| if x.is_na() { None } else { Some(x.is_true()) })
                .collect();
            Ok(SeriesTree::Series(pl::Series::new(name.into(), s)))
        }

        Rtype::Integers if x.inherits("factor") => Ok(SeriesTree::Series(
            robj_to_utf8_series(
                x.as_character_factor()
                    .try_into()
                    .expect("as_character_factor() enforces same type"),
                name,
            )
            .cast(&pl::DataType::Categorical(None, Default::default()))
            .expect("as matched"),
        )),

        Rtype::Integers => {
            let rints = x.as_integers().expect("as matched");
            let s = if rints.no_na().is_true() {
                pl::Series::new(name.into(), x.as_integer_slice().expect("as matched"))
            } else {
                //convert R NAs to rust options
                let mut s: pl::Series = rints
                    .iter()
                    .map(|x| if x.is_na() { None } else { Some(x.inner()) })
                    .collect();
                s.rename(name.into());
                s
            };

            Ok(SeriesTree::Series(s))
        }

        Rtype::Raw => {
            let rpolars_raw_list = list!(x)
                .set_class(["rpolars_raw_list", "list"])
                .map_err(|err| pl::polars_err!(ComputeError: err.to_string()))?;
            recursive_robjname2series_tree(&rpolars_raw_list, name)
        }

        Rtype::List if x.inherits("rpolars_raw_list") => {
            let l = x.as_list().expect("as_matched");
            use crate::utils::robj_to_binary_vec;
            let l_len = l.len();
            let iter = l.into_iter().map(|(_, robj)| {
                if robj.is_null() {
                    Ok(None)
                } else {
                    Some(robj_to_binary_vec(robj)).transpose()
                }
            });

            let binary_vec_vec_res: crate::rpolarserr::RResult<Vec<Option<Vec<u8>>>> =
                collect_hinted_result(l_len, iter);
            let binary_vec_vec =
                binary_vec_vec_res.map_err(|err| pl::polars_err!(ComputeError: err.to_string()))?;
            let binary_series = pl::Series::new(name.into(), binary_vec_vec.as_slice());
            Ok(SeriesTree::Series(binary_series))
        }

        Rtype::List => {
            // Recusively handle elements of list
            let result_series_vec: pl::PolarsResult<Vec<SeriesTree>> = collect_hinted_result(
                x.len(),
                x.as_list()
                    .unwrap()
                    .iter()
                    .map(|(name, robj)| recursive_robjname2series_tree(&robj, name)),
            );
            result_series_vec.map(|vst| {
                if vst.is_empty() {
                    SeriesTree::SeriesEmptyVec // flag empty list() with this enum, to resolve polars type later
                } else {
                    SeriesTree::SeriesVec(vst)
                }
            })
        }

        _ => Err(pl::PolarsError::InvalidOperation(
            format!("new series from rtype {:?} is not supported (yet)", rtype).into(),
        )),
    };

    //post process derived R types
    match series_result {
        Ok(SeriesTree::Series(s)) if x.inherits("POSIXct") => {
            let tz = x
                .get_attrib("tzone")
                .and_then(|robj| {
                    robj.as_str().map(|str| {
                        if str.is_empty() {
                            None
                        } else {
                            Some(str.to_string())
                        }
                    })
                })
                .flatten();
            //todo this could probably in fewer allocations
            match tz {
                // zoned time
                Some(tz) => {
                    Ok(SeriesTree::Series(
                        (s * 1_000f64).cast(&pl::DataType::Int64)?.cast(
                            &pl::DataType::Datetime(pl::TimeUnit::Milliseconds, Some(tz.into())),
                        )?,
                    ))
                }
                // sys time
                None => {
                    let sys_tz_robj = R!("Sys.timezone()")
                        .map_err(|err| pl::PolarsError::ComputeError(err.to_string().into()))?;
                    let sys_tz = robj_to!(String, sys_tz_robj)
                        .map_err(|err| pl::PolarsError::ComputeError(err.to_string().into()))?;
                    let s_name = s.name();
                    let utc_s = (s.clone() * 1_000f64).cast(&pl::DataType::Int64)?.cast(
                        &pl::DataType::Datetime(pl::TimeUnit::Milliseconds, Some("UTC".into())),
                    )?;
                    Ok(SeriesTree::Series(
                        pl::DataFrame::new(vec![utc_s.clone().into()])?
                            .lazy()
                            .select([col(s_name.clone())
                                .dt()
                                .convert_time_zone(sys_tz.into())
                                .dt()
                                .replace_time_zone(None, pl::lit("raise"), pl::NonExistent::Raise)])
                            .collect()?
                            .column(s_name)?
                            .as_materialized_series()
                            .clone(),
                    ))
                }
            }
        }
        Ok(SeriesTree::Series(s)) if x.inherits("Date") => {
            Ok(SeriesTree::Series(s.cast(&pl::DataType::Date)?))
        }
        // Ok(SeriesTree::Series(s)) if x.inherits("ITime")=> {
        //     let dt = pl::DataType::Datetime(pl::TimeUnit::Milliseconds,tz);
        //     Ok(SeriesTree::Series((s.cast(&pl::DataType::Int64)?*1_000i64).cast(&dt)?))
        // },
        Ok(SeriesTree::Series(s)) if x.inherits("PTime") => {
            let tu_str = x
                .get_attrib("tu")
                .and_then(|robj| robj.as_str())
                .ok_or_else(|| {
                    pl::PolarsError::SchemaMismatch(
                        "failure to convert class PTime as attribute tu is not a string or there"
                            .into(),
                    )
                })?;
            let i_conv: i64 = match tu_str {
                "ns" => 1,
                "us" => 1_000,
                "ms" => 1_000_000,
                "s" => 1_000_000_000,
                _ => Err(pl::PolarsError::SchemaMismatch(
                    "failure to convert class PTime as attribute tu 's' , 'ms', 'us', or 'ns'"
                        .into(),
                ))?,
            };
            Ok(SeriesTree::Series(
                (s.cast(&pl::DataType::Int64)? * i_conv).cast(&pl::DataType::Time)?,
            ))
        }

        //     Ok(SeriesTree::Series((s.cast(&pl::DataType::Int64)?*1_000i64).cast(&dt)?))
        // },
        _ => series_result,
    }
}

// consume nested SeriesTree and return concatenated Series or an appropriate Error
fn concat_series_tree(
    st: SeriesTree,
    leaf_dtype: &Option<pl::DataType>,
    name: &str,
) -> pl::PolarsResult<pl::Series> {
    match st {
        SeriesTree::Series(s) => Ok(s), // SeriesTree is just a regular Series, return as is
        SeriesTree::SeriesEmptyVec => { // Create Series of empty array and cast to the found leaf_dtype.
            use polars::prelude::ListBuilderTrait;
            let empty_list_series = pl::ListBinaryChunkedBuilder::new(name.into(), 0,0).finish().into_series();

            //cast to any discovered leaftype to allow concatenation without Error
            if let Some(leaf_dt_ref) = leaf_dtype {
                empty_list_series.cast(leaf_dt_ref)
            } else {
                // no other leaftype, use Null as py-polars
                empty_list_series.cast(&pl::DataType::Null)
            }
        },
        SeriesTree::SeriesVec(sv) if sv.is_empty() => unreachable!(
            "internal error: A series tree was built with a literal empty vector, instead of using the SeriesEmptyVec flag"
        ),
        SeriesTree::SeriesVec(sv) => {
            // concat any deeper nested parts of SeriesTree

            let series_vec_result: pl::PolarsResult<Vec<pl::Series>> =  collect_hinted_result(sv.len(), sv
                .into_iter()
                .map(|inner_st| concat_series_tree(inner_st, leaf_dtype, ""))
            );


            // boubble any errors
            let series_vec = series_vec_result?;

            //TODO cast leafs type to any shared see polars_core::utils::get_supertype()
            // check for any type mismatch to avoid polars panics
            let mut s_iter = series_vec.iter();
            let first_s = s_iter.next();
            for s_ref in s_iter {
                if s_ref.dtype() != first_s.expect("could not loop if none first_s").dtype() {
                    Err(pl::PolarsError::SchemaMismatch(format!(
                        "When building series from R list; some parsed sub-elements did not match: One element was {} and another was {}",
                        first_s.expect("dont worry about it").dtype(),s_ref.dtype()
                    ).into()))?;
                }
            }

            // use polars new method to concat concatenated series
            Ok(pl::Series::new(name.into(), series_vec))
        }
    }
}

//handle R character/strings to utf8
fn robj_to_utf8_series(rstrings: Strings, name: &str) -> pl::Series {
    if rstrings.no_na().is_true() {
        pl::Series::new(name.into(), rstrings.as_robj().as_str_vector().unwrap())
    } else {
        //convert R NAs to rust options
        let mut s: Vec<Option<&str>> = Vec::with_capacity(rstrings.len());
        s.extend(
            rstrings
                .iter()
                .map(|x| if x.is_na() { None } else { Some(x.as_str()) }),
        );

        pl::Series::new(name.into(), s)
    }
}
