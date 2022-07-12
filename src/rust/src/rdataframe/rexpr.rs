use extendr_api::{extendr, prelude::*, Deref, DerefMut, Error, List, Rinternals};
use polars::prelude::{self as pl, IntoLazy, NamedFrom};
use std::{collections::VecDeque, result::Result};

#[derive(Clone, Debug)]
#[extendr]
pub struct Rexpr {
    pub e: pl::Expr,
}

//this struct only here to satisfy extendr
#[derive(Clone, Debug)]
#[extendr]
pub struct OptRexpr {
    pub e: Option<Rexpr>,
}

#[extendr]
impl OptRexpr {
    fn print(&self) {
        println!("{:?}", self);
    }
}

impl From<Option<Rexpr>> for OptRexpr {
    fn from(e: Option<Rexpr>) -> Self {
        OptRexpr { e }
    }
}

impl From<OptRexpr> for Option<Rexpr> {
    fn from(e: OptRexpr) -> Self {
        e.e
    }
}

impl Deref for Rexpr {
    type Target = pl::Expr;
    fn deref(&self) -> &pl::Expr {
        &self.e
    }
}

impl DerefMut for Rexpr {
    fn deref_mut(&mut self) -> &mut pl::Expr {
        &mut self.e
    }
}

#[extendr]
impl Rexpr {
    //constructors
    pub fn col(name: &str) -> Self {
        Rexpr { e: pl::col(name) }
    }

    //chaining methods
    pub fn abs(&self) -> Rexpr {
        Rexpr {
            e: self.e.clone().abs(),
        }
    }

    pub fn agg_groups(&self) -> Rexpr {
        Rexpr {
            e: self.e.clone().agg_groups(),
        }
    }

    pub fn alias(&self, s: &str) -> Rexpr {
        Rexpr {
            e: self.e.clone().alias(s),
        }
    }

    pub fn all(&self) -> Rexpr {
        Rexpr {
            e: self.e.clone().all(),
        }
    }
    pub fn any(&self) -> Rexpr {
        Rexpr {
            e: self.e.clone().any(),
        }
    }

    pub fn over(&self, vs: Vec<String>) -> Rexpr {
        let vs2: Vec<&str> = vs.iter().map(|x| x.as_str()).collect();

        Rexpr {
            e: self.e.clone().over(vs2),
        }
    }

    pub fn print(&self) {
        println!("{:#?}", self.e);
    }

    pub fn sum(&self) -> Rexpr {
        Rexpr {
            e: self.e.clone().sum(),
        }
    }
}

//allow proto expression that yet only are strings
//string expression will transformed into an actual expression in different contexts such as select
#[derive(Clone, Debug)]
#[extendr]
pub enum ProtoRexpr {
    Rexpr(Rexpr),
    String(String),
}

#[extendr]
impl ProtoRexpr {
    pub fn new_str(s: &str) -> Self {
        ProtoRexpr::String(s.to_owned())
    }

    pub fn new_expr(r: &Rexpr) -> Self {
        ProtoRexpr::Rexpr(r.clone())
    }

    pub fn to_rexpr(&self, context: &str) -> Rexpr {
        match self {
            ProtoRexpr::Rexpr(r) => r.clone(),
            ProtoRexpr::String(s) => match context {
                "select" => Rexpr::col(&s),
                _ => panic!("unknown context"),
            },
        }
    }

    fn print(&self) {
        println!("{:?}", self);
    }
}

//and array of expression or proto expressions.
#[derive(Clone, Debug)]
#[extendr]
pub struct ProtoRexprArray {
    pub a: VecDeque<ProtoRexpr>,
}

#[extendr]
impl ProtoRexprArray {
    pub fn new() -> Self {
        ProtoRexprArray { a: VecDeque::new() }
    }

    pub fn push_back_str(&mut self, s: &str) {
        self.a.push_back(ProtoRexpr::new_str(s));
    }

    pub fn push_back_rexpr(&mut self, r: &Rexpr) {
        self.a.push_back(ProtoRexpr::new_expr(r));
    }

    fn pop_front_rexpr(&mut self, context: &str) -> OptRexpr {
        self.a.pop_front().map(|re| re.to_rexpr(context)).into()
    }

    pub fn print(&self) {
        println!("{:?}", self)
    }

    pub fn add_context(&self, context: &str) -> RexprArray {
        RexprArray {
            a: self
                .a
                .iter()
                .map(|re| re.clone().to_rexpr(context))
                .collect::<VecDeque<Rexpr>>(),
        }
    }
}

#[derive(Clone, Debug)]
#[extendr]
pub struct RexprArray {
    pub a: VecDeque<Rexpr>,
}

#[extendr]
impl RexprArray {
    fn print(&self) {
        println!("{:?}", self);
    }
}

extendr_module! {
    mod rexpr;
    impl Rexpr;
    impl ProtoRexprArray;
    impl RexprArray;
}
