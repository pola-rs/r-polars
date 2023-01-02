//use crate::apply;
use crate::apply_input;
use crate::apply_output;
use crate::handle_type;
use crate::make_r_na_fun;
use crate::rdatatype::DataType;
use crate::utils::{r_error_list, r_ok_list, r_result_list};

use super::DataFrame;
use crate::utils::wrappers::null_to_opt;

use crate::utils::try_f64_into_usize;
use extendr_api::{extendr, prelude::*, rprintln, Rinternals};
use pl::SeriesMethods;
use polars::datatypes::*;
use polars::prelude::IntoSeries;
use polars::prelude::{self as pl, NamedFrom};
pub const R_INT_NA_ENC: i32 = -2147483648;

#[extendr]
#[derive(Debug, Clone)]
pub struct Series(pub pl::Series);

pub fn inherits(x: &Robj, class: &str) -> bool {
    let opt_class_attr = x.class();
    if let Some(class_attr) = opt_class_attr {
        class_attr.collect::<Vec<&str>>().contains(&class)
    } else {
        false
    }
}

// fn factor_to_string_series(x: &Robj, name: &str) -> pl::Series {
//     let int_slice = x.as_integer_slice().unwrap();
//     let levels = x.get_attrib("levels").expect("factor has no levels");
//     let levels_vec = levels.as_str_vector().unwrap();

//     let v: Vec<&str> = int_slice
//         .iter()
//         .map(|x| {
//             let idx = (x - 1) as usize;
//             let x = levels_vec
//                 .get(idx)
//                 .expect("Corrupt R factor, level integer out of bound");
//             *x
//         })
//         .collect();
//     pl::Series::new(name, v.as_slice())
// }
//TODO remove unwraps
pub fn robjname2series(x: &Robj, name: &str) -> pl::PolarsResult<pl::Series> {
    let y = x.rtype();

    //used for string vector and factor
    fn robj_to_utf8_series(x: &Robj, name: &str) -> pl::Series {
        let rstrings: Strings = x.try_into().unwrap();

        //likely never real altrep, yields NA_Rbool, yields false
        if rstrings.no_na().is_true() {
            pl::Series::new(name, x.as_str_vector().unwrap())
        } else {
            //convert R NAs to rust options
            let s: Vec<Option<&str>> = rstrings
                .iter()
                .map(|x| if x.is_na() { None } else { Some(x.as_str()) })
                .collect();
            let s = pl::Series::new(name, s);
            s
        }
    }

    match y {
        Rtype::Integers if inherits(&x, "factor") => {
            Ok(robj_to_utf8_series(&x.as_character_factor(), name)
                .cast(&pl::DataType::Categorical(None))
                .unwrap())
        }
        Rtype::Integers => {
            let rints = x.as_integers().unwrap();
            if rints.no_na().is_true() {
                Ok(pl::Series::new(name, x.as_integer_slice().unwrap()))
            } else {
                //convert R NAs to rust options
                let mut s: pl::Series = rints
                    .iter()
                    .map(|x| if x.is_na() { None } else { Some(x.0) })
                    .collect();
                s.rename(name);
                Ok(s)
            }
        }
        Rtype::Doubles => {
            let rdouble: Doubles = x.try_into().unwrap();

            //likely never real altrep, yields NA_Rbool, yields false
            if rdouble.no_na().is_true() {
                Ok(pl::Series::new(name, x.as_real_slice().unwrap()))
            } else {
                //convert R NAs to rust options
                let mut s: pl::Series = rdouble
                    .iter()
                    .map(|x| if x.is_na() { None } else { Some(x.0) })
                    .collect();
                s.rename(name);
                Ok(s)
            }
        }
        Rtype::Strings => Ok(robj_to_utf8_series(x, name)),
        Rtype::Logicals => {
            let logicals: Logicals = x.try_into().unwrap();
            let s: Vec<Option<bool>> = logicals
                .iter()
                .map(|x| if x.is_na() { None } else { Some(x.is_true()) })
                .collect();
            Ok(pl::Series::new(name, s))
        }
        Rtype::List => {
            //remember
            //let mut first_opt_rtype: Option<Rtype> = None;
            //recursive collect elements list elements and check for same type (polars requirement)
            let result_series_vec: pl::PolarsResult<Vec<pl::Series>> = x
                .as_list()
                .unwrap()
                .iter()
                .map(|(name, robj)| robjname2series(&robj, name))
                .collect();
            let series_vec = result_series_vec?;

            //check all dtypes are the same as first
            let mut dtypes_iter = series_vec.iter().map(|s| s.0.dtype());
            let first_opt_dt = dtypes_iter.next();
            for i_dt in dtypes_iter {
                if let Some(first_dt) = first_opt_dt {
                    if first_dt != i_dt {
                        Err(pl::PolarsError::SchemaMisMatch(
                            polars::error::ErrString::Owned(format!(
                                "new series from rtype list: each nested level of subelements must be of same type\\
, however one type was {:?} and another was {:?}",first_dt, i_dt
                            )),
                        ))?
                    }
                }
            }

            if series_vec.len() == 0 {
                // construct series manually for the special case of the empty list
                //float64 is preffered inner type by py-polars for empty list
                let empty_list_series = pl::Series::new(name, [0f64; 0]).to_list()?.slice(0, 0);
                Ok(empty_list_series.into_series())
            } else {
                Ok(pl::Series::new(name, series_vec))
            }
        }
        _ => Err(pl::PolarsError::NotFound(polars::error::ErrString::Owned(
            format!("new series from rtype {:?} is not supported (yet)", y),
        ))),
    }
}

impl From<polars::prelude::Series> for Series {
    fn from(pls: polars::prelude::Series) -> Self {
        Series(pls)
    }
}
use super::Expr;
impl From<&Expr> for pl::PolarsResult<Series> {
    fn from(expr: &Expr) -> Self {
        DataFrame::new()
            .lazy()
            .0
            .select(&[expr.0.clone()])
            .collect()
            .map(|df| {
                df.select_at_idx(0)
                    .map(|ref_s| ref_s.clone())
                    .unwrap_or_else(|| pl::Series::new_empty("", &pl::DataType::Null))
                    .into()
            })
    }
}

#[extendr]
impl Series {
    //utility methods
    pub fn new(x: Robj, name: &str) -> List {
        let s_res = robjname2series(&x, name);
        match s_res {
            Ok(s) => r_ok_list(Series(s)),
            Err(s) => r_error_list(s),
        }
    }

    pub fn clone(&self) -> Series {
        Series(self.0.clone())
    }

    //function for debugging only
    pub fn sleep(&self, millis: i32) -> Series {
        std::thread::sleep(std::time::Duration::from_millis(millis as u64));
        Series(self.0.clone())
    }

    pub fn panic(&self) -> Series {
        panic!("somebody panicked on purpose");
    }

    pub fn to_r(&self) -> list::List {
        let robj_result = pl_series_to_list(&self.0, true);
        r_result_list(robj_result)
    }

    //any mut method exposed in R suffixed _mut
    pub fn rename_mut(&mut self, name: &str) {
        self.0.rename(name);
    }

    //any other method or trait method in alphabetical order

    //skip arr, cat, dt namespace methods

    pub fn dtype(&self) -> DataType {
        DataType(self.0.dtype().clone())
    }

    //wait inner_dtype until list supported

    pub fn name(&self) -> &str {
        self.0.name()
    }

    pub fn sort_mut(&mut self, reverse: bool) -> Self {
        Series(self.0.sort(reverse))
    }

    pub fn value_counts(&self, multithreaded: bool, sorted: bool) -> List {
        let res = self
            .0
            .value_counts(multithreaded, sorted)
            .map(|df| DataFrame(df));
        r_result_list(res)
    }

    pub fn arg_min(&self) -> Option<usize> {
        self.0.arg_min()
    }

    pub fn arg_max(&self) -> Option<usize> {
        self.0.arg_max()
    }

    pub fn is_sorted_flag(&self) -> bool {
        matches!(self.0.is_sorted_flag(), polars::series::IsSorted::Ascending)
    }
    pub fn is_sorted_reverse_flag(&self) -> bool {
        matches!(
            self.0.is_sorted_flag(),
            polars::series::IsSorted::Descending
        )
    }

    // pub fn is_sorted(&self, reverse: bool, nulls_last: Nullable<bool>) -> bool {
    //     let nulls_last = null_to_opt(nulls_last).unwrap_or(reverse);
    //     let options = pl::SortOptions {
    //         descending: reverse,
    //         nulls_last: nulls_last,
    //     };
    //     self.0.is_sorted(options)
    // }

    pub fn series_equal(&self, other: &Series, null_equal: bool, strict: bool) -> bool {
        if strict {
            self.0.eq(&other.0)
        } else if null_equal {
            self.0.series_equal_missing(&other.0)
        } else {
            self.0.series_equal(&other.0)
        }
    }

    pub fn compare(&self, other: &Series, op: String) -> List {
        //try cast other to self, downcast(dc) to chunkedarray and compare with operator(op) elementwise
        macro_rules! comp {
            ($self:expr, $other:expr, $dc:ident, $op:expr) => {{
                let dtype = self.0.dtype();
                let lhs = $self.0.$dc().unwrap().clone();
                let casted_series = $other.0.cast(dtype).map_err(|err| err.to_string())?;
                let rhs = casted_series.$dc().map_err(|err| err.to_string())?;

                let ca_bool = match $op.as_str() {
                    "equal" => lhs.equal(rhs),
                    "not_equal" => lhs.not_equal(rhs),
                    "gt" => lhs.gt(rhs),
                    "gt_eq" => lhs.gt_eq(rhs),
                    "lt" => lhs.lt(rhs),
                    "lt_eq" => lhs.lt_eq(rhs),
                    _ => panic!("not supported operator"),
                };
                Ok(Series(ca_bool.into_series()))
            }};
        }

        use polars::prelude::ChunkCompare;
        let dtype = self.0.dtype();
        use pl::DataType::*;
        let res = (|| match dtype {
            Int32 => comp!(self, other, i32, op),
            Int64 => comp!(self, other, i64, op),
            Float64 => comp!(self, other, f64, op),
            Boolean => comp!(self, other, bool, op),
            Utf8 => comp!(self, other, utf8, op),
            _ => Err(format!(
                "oups this type: {} is not supported yet, but easily could be",
                dtype
            )),
        })();
        r_result_list(res)
    }

    //names repeat_ as repeat is locked keyword in R
    pub fn rep(&self, n: f64, rechunk: bool) -> List {
        match try_f64_into_usize(n, false) {
            Ok(n) => r_result_list(self.rep_impl(n as usize, rechunk)),
            Err(err) => r_error_list(err),
        }
    }

    pub fn shape(&self) -> Robj {
        r!([self.0.len() as f64, 1.0])
    }

    pub fn len(&self) -> f64 {
        self.0.len() as f64
    }

    pub fn chunk_lengths(&self) -> Vec<f64> {
        self.0.chunk_lengths().map(|val| val as f64).collect()
    }

    pub fn abs(&self) -> list::List {
        let x = self.0.clone().abs().map(|x| Series(x));
        r_result_list(x)
    }

    pub fn alias(&self, name: &str) -> Series {
        let mut s = self.0.clone();
        s.rename(name);
        Series(s)
    }

    pub fn all(&self) -> List {
        let mut one_not_true = false;
        let result = || -> std::result::Result<bool, Box<dyn std::error::Error>> {
            for i in self.0.bool()?.into_iter() {
                if let Some(b) = i {
                    if b {
                        continue;
                    }
                }
                one_not_true = true;
                break;
            }
            Ok(!one_not_true)
        }();
        r_result_list(result)
    }

    pub fn any(&self) -> Result<bool> {
        use polars::prelude::*;
        if *self.0.dtype() == DataType::Boolean {
            let mut one_seen_true = false;

            let iter = self.0.bool().unwrap().into_iter();

            for i in iter {
                if let Some(b) = i {
                    if b {
                        one_seen_true = true;
                        break;
                    }
                }
            }

            Ok(one_seen_true)
        } else {
            Err(extendr_api::error::Error::Other("not a bool".to_string()))
        }
    }

    pub fn add(&self, other: &Series) -> Self {
        (&self.0 + &other.0).into()
    }

    pub fn sub(&self, other: &Series) -> Self {
        (&self.0 - &other.0).into()
    }

    pub fn mul(&self, other: &Series) -> Self {
        (&self.0 * &other.0).into()
    }

    pub fn div(&self, other: &Series) -> Self {
        (&self.0 / &other.0).into()
    }

    pub fn rem(&self, other: &Series) -> Self {
        (&self.0 % &other.0).into()
    }

    pub fn append_mut(&mut self, other: &Series) -> List {
        r_result_list(self.0.append(&other.0).map(|_| ()))
    }

    pub fn apply(
        &self,
        robj: Robj,
        rdatatype: Nullable<&DataType>,
        strict: bool,
        allow_fail_eval: bool,
    ) -> list::List {
        //prepare lamda function from R side

        let rfun = if let Some(rfun) = robj.as_function() {
            rfun
        } else {
            return r_error_list("fun arg must be a function");
        };

        //function to wrap lambda to only pass the appropiate R NA type when polars null
        #[allow(unused_assignments)] //is actually used via macros
        let mut na_fun = R!(
            "function(x) stop('wait im just a mut placeholder function to extend the lifetime')"
        ) // actual function is set with apply_input! calling make_r_na_fun!
        .unwrap()
        .as_function()
        .unwrap();

        let inp_type = self.0.dtype();
        let out_type = null_to_opt(rdatatype).map_or_else(|| self.0.dtype(), |rdt| &rdt.0);

        //handle any input type to lambda, make iterator which yields lambda returns as Robj's
        use pl::DataType::*;
        let r_iter: Box<dyn Iterator<Item = Option<Robj>>> = match inp_type {
            Float64 => apply_input!(self.0, f64, rfun, na_fun),
            Float32 => apply_input!(self.0, f32, rfun, na_fun),
            Int64 => apply_input!(self.0, i64, rfun, na_fun),
            Int32 => apply_input!(self.0, i32, rfun, na_fun),
            Int16 => apply_input!(self.0, i16, rfun, na_fun),
            Int8 => apply_input!(self.0, i8, rfun, na_fun),
            Utf8 => apply_input!(self.0, utf8, rfun, na_fun),
            Boolean => apply_input!(self.0, bool, rfun, na_fun),
            //List(..) => apply_input!(self.0, list, rfun, na_fun),
            List(..) => {
                let ca_list = self.0.list().unwrap();

                let y = ca_list.into_iter().map(|opt_ser| {
                    let opt_robj = if let Some(ser) = opt_ser {
                        let out = rfun.call(pairlist!(Series(ser))).ok();
                        out
                    } else {
                        unreachable!("internal error: oh it was possible to get a None Series");
                    };
                    opt_robj
                });

                Box::new(y)
            }
            x => {
                dbg!(x);
                todo!("this input type is not implemented")
            }
        };

        //handle any return type from R and collect into Series
        let s: Result<Series> = || -> Result<Series> {
            match out_type {
                Float64 => apply_output!(r_iter, strict, allow_fail_eval, Doubles, Float64Chunked),
                Int32 => apply_output!(r_iter, strict, allow_fail_eval, Integers, Int32Chunked),
                Utf8 => apply_output!(r_iter, strict, allow_fail_eval, Strings, Utf8Chunked),
                Boolean => apply_output!(r_iter, strict, allow_fail_eval, Logicals, BooleanChunked),
                List(..) => {
                    //ierate over R return values, opt if never run (no values), err if fail
                    let mut all_length_one = true;
                    let xx = r_iter.map(|opt_r| -> pl::PolarsResult<_> {
                        if let Some(robj) = opt_r {
                            //convert Robj of Series or something "into series" to pl Series
                            let s = Series::any_robj_to_pl_series_result(&robj)?;

                            if s.len() > 1 {
                                all_length_one = false;
                            }

                            Ok(Some(s)) //return Ok some polars series if success
                        } else {
                            Ok(None) //return Ok None if computation never took place
                        }
                    });

                    let lc_res: pl::PolarsResult<ListChunked> = xx.collect::<pl::PolarsResult<_>>();

                    let s: Result<Series> = lc_res
                        .map(|lc| lc.into_series())
                        .and_then(|s| if all_length_one { s.explode() } else { Ok(s) })
                        .map(|s| Series(s))
                        .map_err(|e| extendr_api::error::Error::Other(e.to_string()));

                    s
                }

                _ => todo!("this output type is not implemented"),
            }
        }();

        let s = s.map(move |mut x| {
            x.rename_mut(&format!("{}_apply", &self.name()));
            x
        });

        //if ok rename with prefix apply, convert Result<Series> in r_result_list
        r_result_list(s)
    }

    // pub fn mean(&self) -> Option<f64> {
    //     match self.series.dtype() {
    //         DataType::Boolean => {
    //             let s = self.series.cast(&DataType::UInt8).unwrap();
    //             s.mean()
    //         }
    //         _ => self.series.mean(),
    //     }
    // }

    // pub fn max(&self, py: Python) -> PyObject {
    //     Wrap(self.series.max_as_series().get(0)).into_py(py)
    // }

    // pub fn min(&self, py: Python) -> PyObject {
    //     Wrap(self.series.min_as_series().get(0)).into_py(py)
    // }

    pub fn min(&self) -> Series {
        self.0.min_as_series().into()
    }

    pub fn max(&self) -> Series {
        self.0.max_as_series().into()
    }

    pub fn sum(&self) -> Series {
        self.0.sum_as_series().into()
    }

    pub fn ceil(&self) -> List {
        r_result_list(self.0.ceil().map(|s| Series(s)))
    }

    pub fn floor(&self) -> List {
        r_result_list(self.0.floor().map(|s| Series(s)))
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    pub fn cumsum(&self, reverse: bool) -> Series {
        Series(self.0.cumsum(reverse))
    }

    pub fn is_unique(&self) -> List {
        let res_ser = self.0.is_unique().map(|ca| Series(ca.into_series()));
        r_result_list(res_ser)
    }

    pub fn to_frame(&self) -> DataFrame {
        let mut df = DataFrame::new_with_capacity(1);
        df.set_column_from_series(&self);

        df
    }

    pub fn set_sorted_mut(&mut self, reverse: bool) {
        if reverse {
            self.0.set_sorted_flag(polars::series::IsSorted::Descending)
        } else {
            self.0.set_sorted_flag(polars::series::IsSorted::Ascending)
        };
    }
}

//inner_from_robj only when used within Series
impl Series {
    pub fn inner_from_robj_clone(robj: &Robj) -> std::result::Result<Self, &'static str> {
        if robj.check_external_ptr("Series") {
            let x: Series = unsafe { &mut *robj.external_ptr_addr::<Series>() }.clone();
            Ok(x)
        } else {
            Err("expected Series")
        }
    }

    pub fn any_robj_to_pl_series_result(robj: &Robj) -> pl::PolarsResult<pl::Series> {
        let s = if !&robj.inherits("Series") {
            robjname2series(&robj, &"")?
        } else {
            Series::inner_from_robj_clone(&robj)
                .map_err(|err| {
                    //convert any error from R to a polars error
                    pl::PolarsError::ComputeError(polars::error::ErrString::Owned(err.to_string()))
                })?
                .0
        };
        Ok(s)
    }

    pub fn extend_expr(&self, value: &Expr, n: &Expr) -> pl::PolarsResult<Self> {
        //let expr = value.0.clone().repeat_by(n.clone().0);
        let s: pl::PolarsResult<Self> = value.into(); //(&Expr(expr)).into();
        let n_series_result: pl::PolarsResult<Series> = n.into();
        let s = s?.0.cast(self.0.dtype())?;

        let n_series = n_series_result.map_err(|err| {
            pl::PolarsError::InvalidOperation(polars::error::ErrString::Owned(format!(
                "extend_expr: when casting n as Uint64 [{}], n should be a non-negative integer",
                err
            )))
        })?;

        let opt_n_u64 = n_series.0.u64()?.into_iter().next().ok_or_else(|| {
            pl::PolarsError::InvalidOperation(polars::error::ErrString::Owned(format!(
                "extend_expr: expr n had no length"
            )))
        })?;

        let n_usize = opt_n_u64.ok_or_else(|| {
            pl::PolarsError::InvalidOperation(polars::error::ErrString::Owned(format!(
                "extend_expr: expr n cannot be a Null"
            )))
        })? as usize;
        let to_append = s.new_from_index(0, n_usize);
        let mut out = self.0.clone();
        out.append(&to_append)?;
        Ok(Series(out))
    }

    pub fn rep_impl(&self, n: usize, rechunk: bool) -> pl::PolarsResult<Self> {
        if n == 0 {
            return Ok(Series(self.clone().0.slice(0, 0)));
        }
        let mut s = self.0.clone();
        for _ in 1..n {
            s.append(&self.0)?;
        }
        if rechunk {
            s = s.rechunk();
        }
        Ok(Series(s))
    }

    pub fn into_frame(&self) -> DataFrame {
        DataFrame(pl::DataFrame::new_no_checks(vec![self.0.clone()]))
    }
}

//clone is needed, no known trivial way (to author) how to take ownership R side objects
impl From<&Series> for pl::Series {
    fn from(x: &Series) -> Self {
        x.clone().0
    }
}

//TODO throw a warning if i32 contains a lowerbound value which is the NA in R.
pub fn pl_series_to_list(series: &pl::Series, tag_structs: bool) -> pl::PolarsResult<Robj> {
    use pl::DataType::*;
    fn to_list_recursive(s: &pl::Series, tag_structs: bool) -> pl::PolarsResult<Robj> {
        match s.dtype() {
            Float64 => s.f64().map(|ca| ca.into_iter().collect_robj()),
            Float32 => s.f32().map(|ca| ca.into_iter().collect_robj()),

            Int8 => s.i8().map(|ca| ca.into_iter().collect_robj()),
            Int16 => s.i16().map(|ca| ca.into_iter().collect_robj()),
            Int32 => s.i32().map(|ca| ca.into_iter().collect_robj()),
            Int64 => s.i64().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as f64))
                    .collect_robj()
            }),
            UInt8 => s.u8().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as i32))
                    .collect_robj()
            }),
            UInt16 => s.u16().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as i32))
                    .collect_robj()
            }),
            UInt32 => s.u32().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as f64))
                    .collect_robj()
            }),
            UInt64 => s.u64().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as f64))
                    .collect_robj()
            }),
            Utf8 => s.utf8().map(|ca| ca.into_iter().collect_robj()),

            Boolean => s.bool().map(|ca| ca.into_iter().collect_robj()),
            Categorical(_) => s
                .categorical()
                .map(|ca| extendr_api::call!("factor", ca.iter_str().collect_robj()).unwrap()),
            List(_) => {
                let mut v: Vec<extendr_api::Robj> = Vec::with_capacity(s.len());
                let ca = s.list().unwrap();

                for opt_s in ca.amortized_iter() {
                    match opt_s {
                        Some(s) => {
                            let s_ref = s.as_ref();
                            let inner_val = to_list_recursive(s_ref, tag_structs)?;
                            v.push(inner_val);
                        }

                        None => {
                            v.push(r!(extendr_api::NULL));
                        }
                    }
                }
                //TODO let l = extendr_api::List::from_values(v); or see if possible to skip vec allocation
                //or take ownership of vector
                let l = extendr_api::List::from_iter(v.iter());
                Ok(l.into_robj())
            }
            Struct(_) => {
                let df = s.clone().into_frame().unnest(&[s.name()]).unwrap();
                let l = DataFrame(df).to_list_result()?;

                //TODO contribute extendr_api set_attrib mutates &self, change signature to surprise anyone
                if tag_structs {
                    l.set_attrib("is_struct", true).unwrap();
                } else {
                };

                Ok(l.into_robj())
            }
            _ => Err(pl::PolarsError::NotFound(polars::error::ErrString::Owned(
                format!(
                    "sorry rpolars has not yet implemented R conversion for Series.dtype: {}",
                    s.dtype()
                ),
            ))),
        }
    }

    to_list_recursive(series, tag_structs)
}

extendr_module! {
    mod rseries;
    impl Series;
}
