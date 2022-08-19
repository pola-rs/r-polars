//use crate::apply;
use crate::apply_input;
use crate::apply_output;
use crate::make_r_na_fun;
use crate::rdataframe::wrap_error;
use crate::rdatatype::Rdatatype;

use crate::utils::wrappers::null_to_opt;
use extendr_api::{extendr, prelude::*, rprintln, Rinternals};
use polars::datatypes::*;
use polars::prelude::IntoSeries;
use polars::prelude::{self as pl, NamedFrom};

const R_INT_NA_ENC: i32 = -2147483648;

#[extendr]
#[derive(Debug, Clone)]
pub struct Rseries(pub pl::Series);

pub fn inherits(x: &Robj, class: &str) -> bool {
    let opt_class_attr = x.class();
    if let Some(class_attr) = opt_class_attr {
        class_attr.collect::<Vec<&str>>().contains(&class)
    } else {
        false
    }
}

fn factor_to_string_series(x: &Robj, name: &str) -> pl::Series {
    let int_slice = x.as_integer_slice().unwrap();
    let levels = x.get_attrib("levels").expect("factor has no levels");
    let levels_vec = levels.as_str_vector().unwrap();

    let v: Vec<&str> = int_slice
        .iter()
        .map(|x| {
            let idx = (x - 1) as usize;
            let x = levels_vec
                .get(idx)
                .expect("Corrupt R factor, level integer out of bound");
            *x
        })
        .collect();
    pl::Series::new(name, v.as_slice())
}

pub fn robjname2series(x: &Robj, name: &str) -> pl::Series {
    let y = x.rtype();
    match y {
        Rtype::Integers if inherits(&x, "factor") => factor_to_string_series(x, name),
        Rtype::Integers => {
            let rints = x.as_integers().unwrap();
            if rints.no_na().is_true() {
                pl::Series::new(name, x.as_integer_slice().unwrap())
            } else {
                //convert R NAs to rust options
                let mut s: pl::Series = rints
                    .iter()
                    .map(|x| if x.is_na() { None } else { Some(x.0) })
                    .collect();
                s.rename(name);
                s
            }
        }
        Rtype::Doubles => {
            let rdouble: Doubles = x.clone().try_into().unwrap();

            //likely never real altrep, yields NA_Rbool, yields false
            if rdouble.no_na().is_true() {
                pl::Series::new(name, x.as_real_slice().unwrap())
            } else {
                //convert R NAs to rust options
                let mut s: pl::Series = rdouble
                    .iter()
                    .map(|x| if x.is_na() { None } else { Some(x.0) })
                    .collect();
                s.rename(name);
                s
            }
        }
        Rtype::Strings => {
            let rstrings: Strings = x.clone().try_into().unwrap();

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
        Rtype::Logicals => {
            let logicals: Logicals = x.clone().try_into().unwrap();
            let s: Vec<Option<bool>> = logicals
                .iter()
                .map(|x| if x.is_na() { None } else { Some(x.is_true()) })
                .collect();
            pl::Series::new(name, s)
        }
        _ => todo!("this input type is not implemented yet"),
    }
}

pub fn series_to_r_vector_pl_result(s: &pl::Series) -> pl::Result<Robj> {
    use pl::DataType::*;
    match s.dtype() {
        Float64 => s.f64().map(|ca| ca.into_iter().collect_robj()),
        Int32 => s.i32().map(|ca| ca.into_iter().collect_robj()),
        Int64 => s.i64().map(|ca| ca.into_iter().collect_robj()),
        Utf8 => s.utf8().map(|ca| ca.into_iter().collect_robj()),
        //TODO, how to handle u32->i32 overflow? extendr converts to real which will yield a unique psedo int for all u32
        //alternatively try i32, handle overflow?, or convert to bit64
        UInt32 => s.u32().map(|ca| ca.into_iter().collect_robj()),
        Boolean => s.bool().map(|ca| ca.into_iter().collect_robj()),
        _ => {
            todo!("hey only exports so far, f32/64,u32,i32/64,utf8 {:?}", s);
        }
    }
}
use std::result::Result;

#[extendr]
impl Rseries {
    pub fn new(x: Robj, name: &str) -> Self {
        Rseries(robjname2series(&x, name))
    }

    pub fn to_r_vector(&self) -> Result<Robj, Error> {
        series_to_r_vector_pl_result(&self.0).map_err(|e| Error::from(wrap_error(e)))
    }

    //any mut method exposed in R suffixed _mut
    pub fn rename_mut(&mut self, name: &str) {
        self.0.rename(name);
    }

    pub fn rename(&self, name: &str) -> Rseries {
        let mut s = self.0.clone();
        s.rename(name);
        Rseries(s)
    }

    pub fn name(&self) -> &str {
        self.0.name()
    }

    //tried to auto implement methods with macros
    //but this is expanded after #extendr macro, so will not be exported to R
    //pub fn $name(&$self) -> Rseries {...}
    //Rseries_chain_methods![self, mean_as_series sum_as_series];

    pub fn mean_as_series(&self) -> Rseries {
        Rseries(self.0.clone().mean_as_series())
    }
    pub fn sum_as_series(&self) -> Rseries {
        Rseries(self.0.clone().sum_as_series())
    }

    pub fn ceil(&self) -> Rseries {
        Rseries(self.0.clone().ceil().unwrap())
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    pub fn cumsum(&self, reverse: bool) -> Rseries {
        Rseries(self.0.clone().cumsum(reverse))
    }

    pub fn apply(&self, robj: Robj, rdatatype: Nullable<&Rdatatype>, strict: bool) -> Rseries {
        //prepare lamda function from R side
        let rfun = robj
            .as_function()
            .unwrap_or_else(|| panic!("hey you promised me a function!!"));

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
        let r_iter: Box<dyn Iterator<Item = Robj>> = match inp_type {
            Float64 => apply_input!(self.0, f64, rfun, na_fun),
            Float32 => apply_input!(self.0, f32, rfun, na_fun),
            Int64 => apply_input!(self.0, i64, rfun, na_fun),
            Int32 => apply_input!(self.0, i32, rfun, na_fun),
            Int16 => apply_input!(self.0, i16, rfun, na_fun),
            Int8 => apply_input!(self.0, i8, rfun, na_fun),
            Utf8 => apply_input!(self.0, utf8, rfun, na_fun),
            Boolean => apply_input!(self.0, bool, rfun, na_fun),
            _ => todo!("this input type is not implemented"),
        };

        //handle any return type from R and collect into Series
        let mut s = match out_type {
            Boolean => apply_output!(r_iter, BooleanChunked, as_bool, strict),
            Float64 => apply_output!(float_special: r_iter, Float64Chunked, strict),
            Int32 => apply_output!(int_special: r_iter, Int32Chunked, strict), //handle R special NA encoding
            Utf8 => apply_output!(string_special: r_iter, Utf8Chunked, strict),
            _ => todo!("this output type is not implemented"),
        };

        //name new series
        s.0.rename(&format!("{}_apply", self.0.name()));
        s
    }
}

//clone is needed, no known trivial way (to author) how to take ownership R side objects
impl From<&Rseries> for pl::Series {
    fn from(x: &Rseries) -> Self {
        x.clone().0
    }
}

extendr_module! {
    mod rseries;
    impl Rseries;
}
