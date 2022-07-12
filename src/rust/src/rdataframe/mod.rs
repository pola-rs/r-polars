use extendr_api::{extendr, prelude::*, Error, List, Rinternals};
use polars::prelude::{self as pl, IntoLazy};
use std::result::Result;

pub mod rexpr;
pub mod rseries;

use rexpr::{get_rexpr_metadata, Rexpr};
use rseries::{get_rseries_metadata, robjname2series, Rseries};

#[extendr]
#[derive(Debug, Clone)]
struct Rdataframe {
    pub d: pl::DataFrame,
}

//this function is also unsafe
fn strpointer_to_rexpr(raw: &str) -> Result<&mut Rexpr, Error> {
    let without_prefix = raw.trim_start_matches("0x");
    let z = usize::from_str_radix(without_prefix, 16).map_err(|e| Error::Other(e.to_string()))?;

    unsafe {
        let y = &mut *(z as *mut Rexpr);
        return Ok(y);
    };
}

#[extendr]
impl Rdataframe {
    fn new(x: List) -> Result<Self, Error> {
        let s: Vec<pl::Series> = x
            .iter()
            .map(|(name, robj)| robjname2series(robj, name))
            .collect();
        let df = pl::DataFrame::new(s).map_err(|e| Error::Other(e.to_string()))?;
        Ok(Rdataframe { d: df })
    }

    fn from_series(ptr_adrs: Vec<String>, col_names: Vec<String>) -> Result<Self, Error> {
        let mut rsers = Vec::new();
        for (ptr, name) in ptr_adrs.iter().zip(col_names.iter()) {
            let without_prefix = ptr.trim_start_matches("0x");
            let z = usize::from_str_radix(without_prefix, 16)
                .map_err(|e| Error::Other(e.to_string()))?;
            unsafe {
                let mut s = (&mut *(z as *mut Rseries)).s.clone();
                if name.len() > 0 {
                    s.rename(name);
                }
                rsers.push(s)
            };
        }

        pl::DataFrame::new(rsers)
            .map_err(|e| Error::Other(e.to_string()))
            .map(|df| Rdataframe { d: df })
    }

    fn print(&self) {
        println!("{:#?}", self.d);
    }

    fn name(&self) -> String {
        self.d.to_string()
    }

    fn select(&mut self, expr_strs: Vec<String>) -> Rdataframe {
        let exprs: Vec<pl::Expr> = expr_strs
            .iter()
            .map(|x| strpointer_to_rexpr(x).unwrap())
            .map(|x| x.e.clone())
            .collect();

        let new_df = self
            .clone()
            .d
            .lazy()
            .select(exprs)
            .collect()
            .expect("selct did not work");

        Rdataframe { d: new_df }
    }
}

extendr_module! {
    mod rdataframe;
    use rexpr;
    use rseries;
    impl Rdataframe;
}
