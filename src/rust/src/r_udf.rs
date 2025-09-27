// A module for converting functions defined on the R side.
// In the case of Python, it does not exist because there is a special feature in polars-plan.

use crate::{PlRDataFrame, PlRSeries, prelude::*, r_threads::ThreadCom};
use savvy::{FunctionArgs, FunctionSexp, LogicalSexp, Sexp, StringSexp, TypedSexp};
use state::InitCell;
use std::sync::RwLock;

struct UnsafeFunctionSexp(FunctionSexp);
unsafe impl Send for UnsafeFunctionSexp {}
unsafe impl Sync for UnsafeFunctionSexp {}

impl Clone for UnsafeFunctionSexp {
    fn clone(&self) -> Self {
        Self(FunctionSexp(self.0.inner()))
    }
}

#[derive(Clone)]
pub struct RUdf {
    function: UnsafeFunctionSexp,
}

impl RUdf {
    pub fn new(function: FunctionSexp) -> Self {
        Self {
            function: UnsafeFunctionSexp(function),
        }
    }
}

// define any possible signature of R lambdas
// Copied from https://github.com/pola-rs/r-polars/blob/9572aef7b3c067ffebe124e61d22279674c17871/src/rust/src/concurrent.rs
pub enum RUdfSignature {
    // function with input 1 Series mapped to output 1 Series
    SeriesToSeries(RUdf, Series),
    // function with input 1 Int32 mapped to output 1 String
    Int32ToString(RUdf, i32),
    // function with input 1 DataFrame mapped to output 1 Bool
    DataFrameToBool(RUdf, DataFrame),
}

#[derive(Debug)]
pub enum RUdfReturn {
    Series(Series),
    String(String),
    Bool(bool),
}

type ThreadComStorage = InitCell<RwLock<Option<ThreadCom<RUdfSignature, RUdfReturn>>>>;
// TODO: more appropriate name
pub static CONFIG: ThreadComStorage = InitCell::new();

impl RUdfSignature {
    pub fn eval(self) -> Result<RUdfReturn, Box<dyn std::error::Error>> {
        match self {
            Self::SeriesToSeries(r_udf, series) => {
                let r_udf = r_udf.function;
                let mut args = FunctionArgs::new();
                args.add("series", <PlRSeries>::from(series))?;
                let res = <Sexp>::from(r_udf.0.call(args)?);
                let s = match res.into_typed() {
                    TypedSexp::Environment(env) => <&PlRSeries>::from(env).series.clone(),
                    _ => {
                        return Err("Expected a Series".into());
                    }
                };
                Ok(RUdfReturn::Series(s))
            }
            Self::Int32ToString(r_udf, idx) => {
                let r_udf = r_udf.function;
                let mut args = FunctionArgs::new();
                args.add("idx", idx)?;
                let res: StringSexp = <Sexp>::from(r_udf.0.call(args)?).try_into()?;
                let out: String = res.iter().next().ok_or("Expected a string")?.into();
                Ok(RUdfReturn::String(out))
            }
            Self::DataFrameToBool(r_udf, df) => {
                let r_udf = r_udf.function;
                let mut args = FunctionArgs::new();
                args.add("df", <PlRDataFrame>::from(df))?;
                let res: LogicalSexp = <Sexp>::from(r_udf.0.call(args)?).try_into()?;
                let out: bool = res.iter().next().ok_or("Expected a bool")?;
                Ok(RUdfReturn::Bool(out))
            }
        }
    }
}

impl From<RUdf> for PlanCallback<usize, String> {
    fn from(r_udf: RUdf) -> Self {
        PlanCallback::new(move |idx: usize| {
            let thread_com = ThreadCom::try_from_global(&CONFIG)
                .map_err(|e| PolarsError::ComputeError(e.into()))?;
            thread_com.send(RUdfSignature::Int32ToString(r_udf.clone(), idx as i32));
            <String>::try_from(thread_com.recv()).map_err(|e| PolarsError::ComputeError(e.into()))
        })
    }
}

impl From<RUdf> for PlanCallback<DataFrame, bool> {
    fn from(r_udf: RUdf) -> Self {
        PlanCallback::new(move |df: DataFrame| {
            let thread_com = ThreadCom::try_from_global(&CONFIG)
                .map_err(|e| PolarsError::ComputeError(e.into()))?;
            thread_com.send(RUdfSignature::DataFrameToBool(r_udf.clone(), df));
            <bool>::try_from(thread_com.recv()).map_err(|e| PolarsError::ComputeError(e.into()))
        })
    }
}

impl TryFrom<RUdfReturn> for Series {
    type Error = String;

    fn try_from(value: RUdfReturn) -> Result<Self, Self::Error> {
        match value {
            RUdfReturn::Series(s) => Ok(s),
            _ => Err("Expected a Series".to_string()),
        }
    }
}

impl TryFrom<RUdfReturn> for String {
    type Error = String;

    fn try_from(value: RUdfReturn) -> Result<Self, Self::Error> {
        match value {
            RUdfReturn::String(s) => Ok(s),
            _ => Err("Expected a String".to_string()),
        }
    }
}

impl TryFrom<RUdfReturn> for bool {
    type Error = String;

    fn try_from(value: RUdfReturn) -> Result<Self, Self::Error> {
        match value {
            RUdfReturn::Bool(b) => Ok(b),
            _ => Err("Expected a Bool".to_string()),
        }
    }
}
