//use crate::apply;
use crate::apply_input;
use crate::apply_opt_cast;
use crate::make_r_na_fun;
use crate::rdatatype::Rdatatype;

use crate::utils::wrappers::null_to_opt;
use extendr_api::{extendr, prelude::*, rprintln, Rinternals};
use polars::datatypes::*;
use polars::prelude::IntoSeries;
use polars::prelude::{self as pl, ChunkApply, NamedFrom};

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
        _ => todo!("this input type is not implemented yet"),
    }
}

#[extendr]
impl Rseries {
    pub fn new(x: Robj, name: &str) -> Self {
        Rseries(robjname2series(&x, name))
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

    //apply fun to each element of series, experiemental
    //handle input/out type with one HUGE match statement
    pub fn apply(&self, robj: Robj, rdatatype: Nullable<&Rdatatype>) -> Rseries {
        //input/output types and the r-function
        let rfun = robj
            .as_function()
            .unwrap_or_else(|| panic!("hey you promised me a function!!"));
        let inp_type = self.0.dtype().clone();
        let out_type = null_to_opt(rdatatype.clone())
            .map_or_else(|| self.0.dtype().clone(), |rdt| rdt.0.clone());

        //match type case, and perform apply
        let s = match (inp_type, out_type) {
            (pl::DataType::Float64, pl::DataType::Float64) => {
                let f = |y: f64| -> f64 {
                    rfun.call(pairlist!(x = y))
                        .expect("rfun failed evaluation")
                        .as_real()
                        .expect("rfun failed to yield a f64, set output datatype")
                };

                Rseries(self.0.f64().unwrap().apply(f).into_series())
            }
            (pl::DataType::Int32, pl::DataType::Int32) => {
                let f = |y: Option<i32>| -> Option<i32> {
                    let y = y.or_else(|| Some(R_INT_NA_ENC)).unwrap();
                    let robj = rfun
                        .call(pairlist!(x = y))
                        .expect("R function failed evaluation");

                    let x = robj.as_integers().expect("only returning int allowed");
                    let val = x.iter().next().expect("zero length int not allowed").0;

                    if val == R_INT_NA_ENC {
                        None
                    } else {
                        Some(val)
                    }
                };
                Rseries(self.0.i32().unwrap().apply_on_opt(f).into_series())
            }
            (pl::DataType::Float64, pl::DataType::Int32) => {
                let f = |y: f64| -> i32 {
                    rfun.call(pairlist!(x = y))
                        .expect("rfun failed evaluation")
                        .as_integer()
                        .expect("rfun failed to yield an i32, set output datatype")
                };
                Rseries(
                    self.0
                        .f64()
                        .unwrap()
                        .apply_cast_numeric::<_, pl::datatypes::Int32Type>(f)
                        .into_series(),
                )
            }
            (pl::DataType::Int32, pl::DataType::Float64) => {
                let f = |y: i32| -> f64 {
                    rfun.call(pairlist!(x = y))
                        .expect("rfun failed evaluation")
                        .as_real()
                        .expect("rfun failed to yield an f64, set output datatype")
                };
                Rseries(
                    self.0
                        .i32()
                        .unwrap()
                        .apply_cast_numeric::<_, pl::datatypes::Float64Type>(f)
                        .into_series(),
                )
            }
            (_, _) => panic!("dont know what to do here"),
        };

        s
    }

    pub fn apply_mac(&self, robj: Robj, rdatatype: Nullable<&Rdatatype>) -> Rseries {
        let rfun = robj
            .as_function()
            .unwrap_or_else(|| panic!("hey you promised me a function!!"));
        let inp_type = self.0.dtype().clone();
        let out_type = null_to_opt(rdatatype.clone())
            .map_or_else(|| self.0.dtype().clone(), |rdt| rdt.0.clone());

        let s = match (&inp_type, &out_type) {
            (pl::DataType::Float64, pl::DataType::Float64) => {
                apply_opt_cast!(self.0, f64, Float64Chunked, f64, rfun, as_real)
            }
            (pl::DataType::Int32, pl::DataType::Int32) => {
                apply_opt_cast!(integer_in_out, self.0, rfun)
            }
            (pl::DataType::Int32, pl::DataType::Float64) => {
                apply_opt_cast!(integer_in, self.0, Float64Chunked, f64, rfun, as_real)
            }
            (pl::DataType::Float64, pl::DataType::Int32) => {
                apply_opt_cast!(integer_out, self.0, f64, rfun)
            }
            (_, _) => todo!("not all type handled"),
        };

        s
    }

    pub fn apply_mac2(&self, robj: Robj, rdatatype: Nullable<&Rdatatype>) -> Rseries {
        let rfun = robj
            .as_function()
            .unwrap_or_else(|| panic!("hey you promised me a function!!"));

        let mut na_fun = R!("function(x) x #placeholder function")
            .unwrap()
            .as_function()
            .unwrap();

        let inp_type = self.0.dtype();
        let out_type = null_to_opt(rdatatype).map_or_else(|| self.0.dtype(), |rdt| &rdt.0);

        let r_iter: Box<dyn Iterator<Item = Robj>> = match (inp_type) {
            (pl::DataType::Float64) => Box::new(apply_input!(self.0, f64, rfun, na_fun)),
            (pl::DataType::Float32) => Box::new(apply_input!(self.0, f32, rfun, na_fun)),
            (pl::DataType::Int64) => Box::new(apply_input!(self.0, i64, rfun, na_fun)),
            (pl::DataType::Int32) => Box::new(apply_input!(self.0, i32, rfun, na_fun)),
            (pl::DataType::Int16) => Box::new(apply_input!(self.0, i16, rfun, na_fun)),
            (pl::DataType::Int8) => Box::new(apply_input!(self.0, i8, rfun, na_fun)),
            (pl::DataType::Utf8) => Box::new(apply_input!(self.0, utf8, rfun, na_fun)),
            (_) => todo!("not all type handled"),
        };

        // let s: Series = match (out_type) {
        //     (pl::DataType::Float64) => {}
        //     (_) => todo!("not all type handled"),
        // };

        todo!()
    }
}
//fn _get_supertype polars_core/utils/mod.rs.html#331
// table of what to cast each type to

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
