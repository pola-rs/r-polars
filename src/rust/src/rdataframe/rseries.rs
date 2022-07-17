use extendr_api::{extendr, prelude::*, rprintln, Rinternals};
use polars::prelude::{self as pl, NamedFrom};

#[extendr]
#[derive(Debug, Clone)]
pub struct Rseries(pub pl::Series);

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
        Rseries(robjname2series(x, name))
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
