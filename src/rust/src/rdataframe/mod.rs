use extendr_api::{extendr, prelude::*, rprintln, Error, List, Rinternals};
use polars::prelude::{self as pl, DataFrame, IntoLazy};
use std::result::Result;

pub mod read_csv;
pub mod rexpr;
pub mod rseries;
pub mod wrap_errors;

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
    fn new_from_vectors(x: List) -> Result<Self, Error> {
        let s: Vec<pl::Series> = x
            .iter()
            .map(|(name, robj)| robjname2series(robj, name))
            .collect();
        let df = pl::DataFrame::new(s).map_err(wrap_error)?;
        Ok(Rdataframe { d: df })
    }

    fn clone_extendr(&self) -> Rdataframe {
        self.clone()
    }

    //hey wait what! ptr_adrs's are strings.
    //Yeah R is 32bit friendly and 64bit integers are not available in R::base
    fn new_from_series(ptr_adrs: Vec<String>, col_names: Vec<String>) -> Result<Self, Error> {
        let mut rsers = Vec::new();
        for (ptr, name) in ptr_adrs.iter().zip(col_names.iter()) {
            let without_prefix = ptr.trim_start_matches("0x");
            let z = usize::from_str_radix(without_prefix, 16).map_err(wrap_error)?;
            unsafe {
                let mut s = (&mut *(z as *mut Rseries)).s.clone();
                if name.len() > 0 {
                    s.rename(name);
                }
                rsers.push(s)
            };
        }

        let d = pl::DataFrame::new(rsers).map_err(wrap_error)?;
        Ok(Rdataframe { d })
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

    // fn unsafe_select(&mut self, expr_strs: Vec<String>) -> Rdataframe {
    //     let exprs: Vec<pl::Expr> = expr_strs
    //         .iter()
    //         .map(|x| strpointer_to_rexpr(x).unwrap())
    //         .map(|x| x.e.clone())
    //         .collect();

    //     let new_df = self
    //         .clone()
    //         .d
    //         .lazy()
    //         .select(exprs)
    //         .collect()
    //         .expect("selct did not work");

    //     Rdataframe { d: new_df }
    // }

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
    impl Rdataframe;
}
