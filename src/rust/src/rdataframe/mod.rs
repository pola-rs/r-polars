use extendr_api::{extendr, prelude::*, rprintln, Error, List, Rinternals};
use polars::prelude::{self as pl, DataFrame, IntoLazy};
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
struct Rdataframe {
    pub d: pl::DataFrame,
}

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
    //obsolete
    // fn new_from_vectors(x: List) -> Result<Self, Error> {
    //     let s: Vec<pl::Series> = x
    //         .iter()
    //         .map(|(name, robj)| robjname2series(robj, name))
    //         .collect();
    //     let df = pl::DataFrame::new(s).map_err(wrap_error)?;
    //     Ok(Rdataframe { d: df })
    // }

    fn clone_extendr(&self) -> Rdataframe {
        self.clone()
    }

    // //obsolete
    // //hey wait what! ptr_adrs's are strings.
    // //Yeah R is 32bit friendly and 64bit integers are not available in R::base
    // fn new_from_series(ptr_adrs: Vec<String>, col_names: Vec<String>) -> Result<Self, Error> {
    //     let mut rsers = Vec::new();
    //     for (ptr, name) in ptr_adrs.iter().zip(col_names.iter()) {
    //         let without_prefix = ptr.trim_start_matches("0x");
    //         let z = usize::from_str_radix(without_prefix, 16).map_err(wrap_error)?;
    //         unsafe {
    //             let mut s = (&mut *(z as *mut Rseries)).0.clone();
    //             if name.len() > 0 {
    //                 s.rename(name);
    //             }
    //             rsers.push(s)
    //         };
    //     }

    //     let d = pl::DataFrame::new(rsers).map_err(wrap_error)?;
    //     Ok(Rdataframe { d })
    // }

    //obsolete
    // fn safe_from_series(x: &RseriesVector) -> Result<Self, Error> {
    //     let d = pl::DataFrame::new(x.clone().0).map_err(wrap_error)?;
    //     Ok(Rdataframe { d })
    // }

    fn new() -> Self {
        let empty_series: Vec<pl::Series> = Vec::new();
        Rdataframe {
            d: pl::DataFrame::new(empty_series).unwrap(),
        }
    }

    fn new_with_capacity(capacity: i32) -> Self {
        let empty_series: Vec<pl::Series> = Vec::with_capacity(capacity as usize);
        Rdataframe {
            d: pl::DataFrame::new(empty_series).unwrap(),
        }
    }

    fn set_column_from_robj(&mut self, robj: Robj, name: &str) -> Result<(), Error> {
        let new_series = robjname2series(robj, name);
        self.d.with_column(new_series).map_err(wrap_error)?;
        Ok(())
    }

    fn set_column_from_rseries(&mut self, x: &Rseries) -> Result<(), Error> {
        let s: pl::Series = x.into(); //implicit clone, cannot move R objects
        self.d.with_column(s).map_err(wrap_error)?;
        Ok(())
    }

    fn print(&self) {
        rprintln!("{:#?}", self.d);
    }

    fn name(&self) -> String {
        self.d.to_string()
    }

    fn colnames(&self) -> Vec<String> {
        self.d.get_column_names_owned()
    }

    fn as_rlist_of_vectors(&self) -> Result<Robj, Error> {
        let x: Result<Vec<Robj>, Error> = self
            .d
            .iter()
            .map(|x| {
                x.f64()
                    .map(|ca| ca.into_iter().collect_robj())
                    .map_err(|e| Error::from(wrap_error(e)))
            })
            .collect();

        let list = r!(List::from_values(x?));

        Ok(list)
    }

    fn select(&mut self, exprs: &ProtoRexprArray) -> Result<Rdataframe, Error> {
        let exprs: Vec<pl::Expr> = exprs
            .a
            .iter()
            .map(|protoexpr| protoexpr.to_rexpr("select").e)
            .collect();

        let new_df = self
            .clone()
            .d
            .lazy()
            .select(exprs)
            .collect()
            .map_err(wrap_error)?;

        Ok(Rdataframe { d: new_df })
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
