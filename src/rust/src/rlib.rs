use crate::lazy::dsl::Expr;
use crate::lazy::dsl::ProtoExprArray;
use crate::rdataframe::DataFrame;
use crate::robj_to;
use crate::rpolarserr::polars_to_rpolars_err;
use crate::rpolarserr::{rdbg, RResult};
use crate::series::Series;
use crate::{rdataframe::VecDataFrame, utils::r_result_list};
use extendr_api::prelude::*;
use polars::prelude as pl;
use polars_core::functions as pl_functions;
use std::result::Result;
#[extendr]
fn concat_df(vdf: &VecDataFrame) -> List {
    //-> PyResult<PyDataFrame> {

    use polars_core::error::PolarsResult;
    use polars_core::utils::rayon::prelude::*;

    let identity_df = (*vdf.0.iter().peekable().peek().unwrap())
        .clone()
        .slice(0, 0);
    let rdfs: Vec<pl::PolarsResult<pl::DataFrame>> =
        vdf.0.iter().map(|df| Ok(df.clone())).collect();
    let identity = || Ok(identity_df.clone());

    let result = polars_core::POOL
        .install(|| {
            rdfs.into_par_iter()
                .fold(identity, |acc: PolarsResult<pl::DataFrame>, df| {
                    let mut acc = acc?;
                    acc.vstack_mut(&df?)?;
                    Ok(acc)
                })
                .reduce(identity, |acc, df| {
                    let mut acc = acc?;
                    acc.vstack_mut(&df?)?;
                    Ok(acc)
                })
        })
        .map(DataFrame);

    r_result_list(result.map_err(|err| format!("{:?}", err)))
}

#[extendr]
fn diag_concat_df(dfs: &VecDataFrame) -> List {
    let df = pl_functions::diag_concat_df(&dfs.0[..]).map(DataFrame);
    r_result_list(df.map_err(|err| format!("{:?}", err)))
}

#[extendr]
pub fn hor_concat_df(dfs: &VecDataFrame) -> List {
    let df = pl_functions::hor_concat_df(&dfs.0[..]).map(DataFrame);
    r_result_list(df.map_err(|err| format!("{:?}", err)))
}

#[extendr]
pub fn mem_address(robj: Robj) -> String {
    let ptr_raw = unsafe { robj.external_ptr_addr::<usize>() };
    let ptr_val = ptr_raw as usize;
    format!("{:#012x}", ptr_val)
}

#[extendr]
fn min_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::min_horizontal(exprs).into()
}

#[extendr]
fn max_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::max_horizontal(exprs).into()
}

#[extendr]
fn coalesce_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs: Vec<pl::Expr> = exprs.to_vec("select");
    polars::lazy::dsl::coalesce(exprs.as_slice()).into()
}

#[extendr]
fn sum_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::sum_horizontal(exprs).into()
}

#[extendr]
fn concat_list(exprs: &ProtoExprArray) -> Result<Expr, String> {
    let exprs = exprs.to_vec("select");
    Ok(Expr(
        polars::lazy::dsl::concat_list(exprs).map_err(|err| err.to_string())?,
    ))
}

#[extendr]
fn r_date_range(
    start: Robj,
    stop: Robj,
    every: Robj,
    closed: Robj, //Wap<ClosedWindow>
    name: Robj,
    tu: Robj,
    tz: Robj,
) -> RResult<Series> {
    use pl::IntoSeries;
    Ok(Series(
        polars::time::date_range_impl(
            robj_to!(str, name)?,
            robj_to!(i64, start)?,
            robj_to!(i64, stop)?,
            pl::Duration::parse(robj_to!(str, every)?),
            robj_to!(new_closed_window, closed)?,
            robj_to!(timeunit, tu)?,
            robj_to!(Option, String, tz)?.as_ref(),
        )
        .map_err(polars_to_rpolars_err)?
        .into_series(),
    ))
}

#[extendr]
fn r_date_range_lazy(
    start: Robj,
    end: Robj,
    every: Robj,
    closed: Robj,
    time_unit: Robj,
    tz: Robj,
) -> RResult<Expr> {
    Ok(Expr(
        polars::lazy::dsl::functions::date_range(
            robj_to!(PLExpr, start)?,
            robj_to!(PLExpr, end)?,
            pl::Duration::parse(robj_to!(str, every)?),
            robj_to!(new_closed_window, closed)?,
            robj_to!(Option, timeunit, time_unit)?,
            robj_to!(Option, String, tz)?,
        )
        .explode(),
    ))
}

//TODO py-polars have some fancy transmute conversions TOExprs trait, maybe imple that too
//for now just use inner directly
#[extendr]
fn as_struct(exprs: Robj) -> Result<Expr, String> {
    Ok(polars::lazy::dsl::as_struct(
        crate::utils::list_expr_to_vec_pl_expr(exprs, true)?.as_slice(),
    )
    .into())
}

#[extendr]
fn struct_(exprs: Robj, eager: Robj, schema: Robj) -> Result<Robj, String> {
    use crate::rdatatype::RPolarsDataType;
    let struct_expr = as_struct(exprs)?;
    let eager = robj_to!(bool, eager)?;

    let struct_expr = if !schema.is_null() {
        let schema: Vec<RPolarsDataType> = robj_to!(Vec, RPolarsDataType, schema)?;
        dbg!(&schema);
        todo!()
    } else {
        struct_expr
    };

    if eager {
        use pl::*;
        let df = pl::DataFrame::empty()
            .lazy()
            .select(&[struct_expr.0])
            .collect()
            .map_err(|err| format!("during eager evaluation of struct: {}", err))?;
        Ok(crate::rdataframe::DataFrame(df).into())
    } else {
        Ok(struct_expr.into())
    }
}

// #[extendr]
// fn field_to_rust2(arrow_array: Robj) -> Result<Robj, String> {
//     let x = crate::arrow_interop::to_rust::arrow_array_to_rust(arrow_array)?;

//     rprintln!("hurray we read an arrow field {:?}", x);
//     Ok(extendr_api::NULL.into())
// }

#[extendr]
fn arrow_stream_to_rust(rbr: Robj) {
    let x = crate::arrow_interop::to_rust::arrow_array_stream_to_rust(rbr, None).unwrap();
    dbg!(x);
}

#[extendr]
fn rb_list_to_df(r_batches: List, names: Vec<String>) -> Result<DataFrame, String> {
    let mut iter = r_batches.into_iter().map(|(_, robj)| {
        let robj = call!(r"\(x) x$columns", robj)?;
        let l = robj.as_list().ok_or_else(|| "not a list!?".to_string())?;
        crate::arrow_interop::to_rust::rb_to_rust_df(l, &names)
    });
    let mut df_acc = iter
        .next()
        .unwrap_or_else(|| Ok(pl::DataFrame::default()))?;
    for df in iter {
        df_acc.vstack_mut(&df?).map_err(|err| err.to_string())?;
    }
    Ok(DataFrame(df_acc))
}

#[extendr]
pub fn dtype_str_repr(dtype: Robj) -> RResult<String> {
    let dtype = robj_to!(RPolarsDataType, dtype)?.0;
    Ok(dtype.to_string())
}

// pub fn series_from_arrow(name: &str, array: Robj) -> Result<Series, String> {
//     use polars::prelude::IntoSeries;
//     let arr = crate::arrow_interop::to_rust::arrow_array_to_rust(array)?;

//     match arr.data_type() {
//         pl::ArrowDataType::LargeList(_) => {
//             let array = arr.as_any().downcast_ref::<pl::LargeListArray>().unwrap();

//             let mut previous = 0;
//             let mut fast_explode = true;
//             for &o in array.offsets().as_slice()[1..].iter() {
//                 if o == previous {
//                     fast_explode = false;
//                     break;
//                 }
//                 previous = o;
//             }
//             let mut out = unsafe { pl::ListChunked::from_chunks(name, vec![arr]) };
//             if fast_explode {
//                 out.set_fast_explode()
//             }
//             Ok(Series(out.into_series()))
//         }
//         _ => {
//             let res_series: pl::PolarsResult<pl::Series> =
//                 std::convert::TryFrom::try_from((name, arr));
//             let series = res_series.map_err(|err| err.to_string())?;
//             Ok(Series(series))
//         }
//     }
// }

#[extendr]
fn test_robj_to_usize(robj: Robj) -> RResult<String> {
    robj_to!(usize, robj).map(rdbg)
}
#[extendr]
fn test_robj_to_i64(robj: Robj) -> RResult<String> {
    robj_to!(i64, robj).map(rdbg)
}

#[extendr]
fn test_robj_to_u32(robj: Robj) -> RResult<String> {
    robj_to!(u32, robj).map(rdbg)
}

#[extendr]
fn test_print_string(s: String) {
    rprintln!("{}", s);
}

extendr_module! {
    mod rlib;
    fn concat_df;
    fn hor_concat_df;
    fn diag_concat_df;
    fn min_exprs;
    fn max_exprs;
    fn coalesce_exprs;
    fn sum_exprs;
    fn mem_address;
    fn concat_list;
    fn r_date_range;
    fn r_date_range_lazy;
    fn as_struct;
    fn struct_;
    //fn field_to_rust2;
    //fn series_from_arrow;
    //fn rb_to_df;
    fn rb_list_to_df;
    fn arrow_stream_to_rust;
    fn dtype_str_repr;

    fn test_robj_to_usize;
    fn test_robj_to_i64;
    fn test_robj_to_u32;
    fn test_print_string;
}
