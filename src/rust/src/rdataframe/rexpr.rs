use extendr_api::{extendr, prelude::*, rprintln, Deref, DerefMut, Rinternals};
use polars::prelude::{self as pl};
use std::ops::{Add, Div, Mul, Sub};

use crate::utils::extendr_concurrent::{tc_from_global, ParRObj};
use crate::CONFIG;

use super::Rdatatype;

#[derive(Clone, Debug)]
#[extendr]
pub struct Rexpr(pub pl::Expr);

impl Deref for Rexpr {
    type Target = pl::Expr;
    fn deref(&self) -> &pl::Expr {
        &self.0
    }
}

impl DerefMut for Rexpr {
    fn deref_mut(&mut self) -> &mut pl::Expr {
        &mut self.0
    }
}

#[extendr]
impl Rexpr {
    pub fn debug(&self) {
        dbg!(&self);
    }
    //expr binary comparisons
    pub fn gt(&self, other: &Rexpr) -> Rexpr {
        Rexpr(self.0.clone().gt(other.0.clone()))
    }

    pub fn gt_eq(&self, other: &Rexpr) -> Rexpr {
        Rexpr(self.0.clone().gt_eq(other.0.clone()))
    }

    pub fn lt(&self, other: &Rexpr) -> Rexpr {
        Rexpr(self.0.clone().lt(other.0.clone()))
    }

    pub fn lt_eq(&self, other: &Rexpr) -> Rexpr {
        Rexpr(self.0.clone().lt_eq(other.0.clone()))
    }

    pub fn neq(&self, other: &Rexpr) -> Rexpr {
        Rexpr(self.0.clone().neq(other.0.clone()))
    }

    pub fn eq(&self, other: &Rexpr) -> Rexpr {
        Rexpr(self.0.clone().eq(other.0.clone()))
    }

    //in order

    pub fn alias(&self, s: &str) -> Rexpr {
        Rexpr(self.0.clone().alias(s))
    }

    pub fn is_null(&self) -> Rexpr {
        Rexpr(self.0.clone().is_null())
    }

    pub fn is_not_null(&self) -> Rexpr {
        Rexpr(self.0.clone().is_not_null())
    }

    pub fn drop_nulls(&self) -> Rexpr {
        Rexpr(self.0.clone().drop_nulls())
    }

    pub fn drop_nans(&self) -> Rexpr {
        Rexpr(self.0.clone().drop_nans())
    }

    pub fn min(&self) -> Rexpr {
        Rexpr(self.0.clone().min())
    }

    pub fn max(&self) -> Rexpr {
        Rexpr(self.0.clone().max())
    }

    pub fn mean(&self) -> Rexpr {
        Rexpr(self.0.clone().mean())
    }

    pub fn median(&self) -> Rexpr {
        Rexpr(self.0.clone().median())
    }

    pub fn sum(&self) -> Rexpr {
        Rexpr(self.0.clone().sum())
    }

    pub fn n_unique(&self) -> Rexpr {
        Rexpr(self.0.clone().n_unique())
    }

    pub fn first(&self) -> Rexpr {
        Rexpr(self.0.clone().first())
    }

    pub fn last(&self) -> Rexpr {
        Rexpr(self.0.clone().last())
    }

    //constructors
    pub fn col(name: &str) -> Self {
        Rexpr(pl::col(name))
    }

    //chaining methods

    pub fn unique(&self) -> Rexpr {
        Rexpr(self.0.clone().unique())
    }

    pub fn abs(&self) -> Rexpr {
        Rexpr(self.0.clone().abs())
    }

    pub fn agg_groups(&self) -> Rexpr {
        Rexpr(self.0.clone().agg_groups())
    }

    pub fn all(&self) -> Rexpr {
        Rexpr(self.0.clone().all())
    }
    pub fn any(&self) -> Rexpr {
        Rexpr(self.0.clone().any())
    }

    pub fn count(&self) -> Rexpr {
        Rexpr(self.0.clone().count())
    }

    //binary arithmetic expressions
    pub fn add(&self, other: &Rexpr) -> Rexpr {
        Rexpr(self.0.clone().add(other.0.clone()))
    }

    //binary arithmetic expressions
    pub fn sub(&self, other: &Rexpr) -> Rexpr {
        Rexpr(self.0.clone().sub(other.0.clone()))
    }

    pub fn mul(&self, other: &Rexpr) -> Rexpr {
        Rexpr(self.0.clone().mul(other.0.clone()))
    }

    pub fn div(&self, other: &Rexpr) -> Rexpr {
        Rexpr(self.0.clone().div(other.0.clone()))
    }

    //unary
    pub fn not(&self) -> Rexpr {
        Rexpr(self.0.clone().not())
    }

    //expr "funnies"
    pub fn over(&self, vs: Vec<String>) -> Rexpr {
        let vs2: Vec<&str> = vs.iter().map(|x| x.as_str()).collect();

        Rexpr(self.0.clone().over(vs2))
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    pub fn map(
        &self,
        lambda: Robj,
        output_type: Nullable<&Rdatatype>,
        _agg_list: Nullable<bool>,
    ) -> Rexpr {
        use crate::utils::wrappers::null_to_opt;

        //find a way not to push lambda everytime to main thread handler
        //unsafe { //safety only accessed in main thread
        let probj = ParRObj(lambda);
        //}

        let f = move |s: pl::Series| {
            //acquire channel to R via main thread handler
            let thread_com = tc_from_global(&CONFIG);

            //send request to run in R
            thread_com.send((probj.clone(), s));

            //recieve answer
            let s = thread_com.recv();

            //wrap as series
            Ok(s)
        };

        let ot = null_to_opt(output_type).map(|rdt| rdt.0.clone());

        let output_map = pl::GetOutput::map_field(move |fld| match ot {
            Some(ref dt) => pl::Field::new(fld.name(), dt.clone()),
            None => fld.clone(),
        });

        Rexpr(self.clone().0.map(f, output_map))
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
        rprintln!("{:?}", self);
    }
}

//and array of expression or proto expressions.
#[derive(Clone, Debug)]
#[extendr]
pub struct ProtoRexprArray(pub Vec<ProtoRexpr>);

#[extendr]
impl ProtoRexprArray {
    pub fn new() -> Self {
        ProtoRexprArray(Vec::new())
    }

    pub fn push_back_str(&mut self, s: &str) {
        self.0.push(ProtoRexpr::new_str(s));
    }

    pub fn push_back_rexpr(&mut self, r: &Rexpr) {
        self.0.push(ProtoRexpr::new_expr(r));
    }

    pub fn print(&self) {
        rprintln!("{:?}", self);
    }

    pub fn add_context(&self, context: &str) -> RexprArray {
        RexprArray(
            self.0
                .iter()
                .map(|re| re.to_rexpr(context))
                .collect::<Vec<Rexpr>>(),
        )
    }
}

//external function as extendr-api do not allow methods returning unwrapped structs
pub fn pra_to_vec(pra: &ProtoRexprArray, context: &str) -> Vec<pl::Expr> {
    pra.0.iter().map(|re| re.to_rexpr(context).0).collect()
}

#[derive(Clone, Debug)]
#[extendr]
pub struct RexprArray(pub Vec<Rexpr>);

#[extendr]
impl RexprArray {
    fn print(&self) {
        rprintln!("{:?}", self);
    }
}

#[extendr]
pub fn rlit(robj: Robj) -> Rexpr {
    let rtype = robj.rtype();
    let rlen = robj.len();
    let expr = match (rtype, rlen) {
        (Rtype::Integers, 1) => pl::lit(robj.as_integer().unwrap() as i64),
        (Rtype::Doubles, 1) => pl::lit(robj.as_real().unwrap()),
        (_, 1) => panic!("dunno what literal to make out of this"),
        (_, _) => panic!("literal length must currently be one, so no c(1,2,3) allowed yet"),
    };

    Rexpr(expr)
}

#[extendr]
pub fn rall() -> Rexpr {
    Rexpr(pl::all())
}

#[extendr]
pub fn rcol(name: &str) -> Rexpr {
    Rexpr(pl::col(name))
}

extendr_module! {
    mod rexpr;
    impl Rexpr;
    impl ProtoRexprArray;
    impl RexprArray;
    fn rlit;
    fn rall;
    fn rcol;
}
