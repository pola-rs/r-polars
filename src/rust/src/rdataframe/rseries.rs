use extendr_api::{extendr, prelude::*, rprintln, Rinternals};
use polars::prelude::{self as pl, NamedFrom};

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
        _ => pl::Series::new("dunno", &[0, 1, 3]),
    }
}

#[extendr]
impl Rseries {
    pub fn new(x: Robj, name: &str) -> Self {
        Rseries(robjname2series(&x, name))
    }

    pub fn rename(&mut self, name: &str) {
        self.0.rename(name);
    }

    pub fn name(&mut self) -> &str {
        self.0.name()
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    pub fn cumsum(&mut self) {
        self.0 = self.0.cumsum(false);
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
