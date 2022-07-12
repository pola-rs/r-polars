use extendr_api::{extendr, prelude::*, Deref, DerefMut, Error, List, Rinternals};
use polars::prelude::{self as pl, IntoLazy, NamedFrom};
use std::result::Result;

#[extendr]
#[derive(Debug, Clone)]
pub struct Rseries {
    pub s: pl::Series,
}

//R garbage collect drops series
impl Drop for Rseries {
    fn drop(&mut self) {
        println!("> a series was dropped");
    }
}

pub fn robj2series(x: Robj) -> pl::Series {
    let y = x.rtype();
    match y {
        Rtype::Integers => pl::Series::new("sint", x.as_integer_slice().unwrap()),
        Rtype::Doubles => pl::Series::new("sreal", x.as_real_slice().unwrap()),
        Rtype::Strings => pl::Series::new("ser", x.as_str_vector().unwrap()),
        _ => pl::Series::new("dunno", &[0, 1, 3]),
    }
}

pub fn inherits(x: &Robj, class: &str) -> bool {
    let y = x.class().unwrap().collect::<Vec<&str>>();
    y.contains(&class)
}

pub fn robjname2series(x: Robj, name: &str) -> pl::Series {
    let y = x.rtype();
    match y {
        Rtype::Integers => {
            let int_slice = x.as_integer_slice().unwrap();

            if inherits(&x, "factor") {
                println!("it is a factor");
                let levels = x.get_attrib("levels").expect("factor has no levels");
                let levels_vec = levels.as_str_vector().unwrap();

                let v: Vec<&str> = int_slice
                    .iter()
                    .map(|x| {
                        let idx = (x - 1) as usize;
                        let x = levels_vec.get(idx).expect("factor int out of bound");
                        *x
                    })
                    .collect();

                pl::Series::new(name, v.as_slice())
            } else {
                pl::Series::new(name, int_slice)
            }
        }
        Rtype::Doubles => pl::Series::new(name, x.as_real_slice().unwrap()),
        Rtype::Strings => pl::Series::new(name, x.as_str_vector().unwrap()),
        _ => pl::Series::new("dunno", &[0, 1, 3]),
    }
}

#[extendr]
impl Rseries {
    pub fn new(x: Robj, name: &str) -> Self {
        Rseries {
            s: robjname2series(x, name),
        }
    }

    pub fn print(&self) {
        println!("{:#?}", self.s);
    }

    pub fn cumsum(&mut self) {
        self.s = self.s.cumsum(false);
    }

    pub fn cumsum123(&mut self) {
        self.s = self.s.cumsum(false);
    }
}

extendr_module! {
    mod rseries;
    impl Rseries;
}
