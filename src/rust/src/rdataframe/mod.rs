use extendr_api::{extendr, prelude::*, rprintln, Error, List, Rinternals};
use polars::prelude::{self as pl, IntoLazy};
use std::result::Result;

pub mod read_csv;
pub mod rexpr;
pub mod rseries;
pub mod wrap_errors;
pub use crate::rdatatype::*;

use read_csv::*;
use rexpr::*;
use rseries::*;
use wrap_errors::*;

#[extendr]
#[derive(Debug, Clone)]
struct Rdataframe(pub pl::DataFrame);

// //this function is also unsafe
// fn strpointer_to_rexpr(raw: &str) -> Result<&mut Rexpr, Error> {
//     let without_prefix = raw.trim_start_matches("0x");
//     let z = usize::from_str_radix(without_prefix, 16).map_err(|e| Error::Other(e.to_string()))?;

//     unsafe {
//         let y = &mut *(z as *mut Rexpr);
//         return Ok(y);
//     };
// }

#[extendr]
impl Rdataframe {
    fn clone_extendr(&self) -> Rdataframe {
        self.clone()
    }

    fn new() -> Self {
        let empty_series: Vec<pl::Series> = Vec::new();
        Rdataframe(pl::DataFrame::new(empty_series).unwrap())
    }

    fn new_with_capacity(capacity: i32) -> Self {
        let empty_series: Vec<pl::Series> = Vec::with_capacity(capacity as usize);
        Rdataframe(pl::DataFrame::new(empty_series).unwrap())
    }

    fn set_column_from_robj(&mut self, robj: Robj, name: &str) -> Result<(), Error> {
        let new_series = robjname2series(robj, name);
        self.0.with_column(new_series).map_err(wrap_error)?;
        Ok(())
    }

    fn set_column_from_rseries(&mut self, x: &Rseries) -> Result<(), Error> {
        let s: pl::Series = x.into(); //implicit clone, cannot move R objects
        self.0.with_column(s).map_err(wrap_error)?;
        Ok(())
    }

    fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    fn name(&self) -> String {
        self.0.to_string()
    }

    fn colnames(&self) -> Vec<String> {
        self.0.get_column_names_owned()
    }

    fn as_rlist_of_vectors(&self) -> Result<Robj, Error> {
        let x: Result<Vec<Robj>, Error> = self
            .0
            .iter()
            .map(|x| match x.dtype() {
                pl::DataType::Float64 => x
                    .f64()
                    .map(|ca| ca.into_iter().collect_robj())
                    .map_err(|e| Error::from(wrap_error(e))),
                _ => todo!("other types than float64 not implemeted so far"),
            })
            .collect();

        let list = r!(List::from_values(x?));

        Ok(list)
    }

    fn select(&mut self, exprs: &ProtoRexprArray) -> Result<Rdataframe, Error> {
        let exprs: Vec<pl::Expr> = exprs
            .0
            .iter()
            .map(|protoexpr| protoexpr.to_rexpr("select").0)
            .collect();

        let new_df = self
            .clone()
            .0
            .lazy()
            .select(exprs)
            .collect()
            .map_err(wrap_error)?;

        Ok(Rdataframe(new_df))
    }
}

extendr_module! {
    mod rdataframe;
    use rexpr;
    use rseries;
    use read_csv;
    use rdatatype;
    impl Rdataframe;
}
