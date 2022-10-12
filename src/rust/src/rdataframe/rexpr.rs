use super::DataFrame;
use crate::rdatatype::{dtv_to_vec, DataType, DataTypeVector};
use crate::utils::extendr_concurrent::{ParRObj, ThreadCom};
use crate::CONFIG;
use extendr_api::{extendr, prelude::*, rprintln, Deref, DerefMut, Rinternals};
use polars::lazy::dsl;
use polars::prelude::{self as pl};
use std::ops::{Add, Div, Mul, Sub};

use crate::utils::r_result_list;

#[derive(Clone, Debug)]
#[extendr]
pub struct Expr(pub pl::Expr);

impl Deref for Expr {
    type Target = pl::Expr;
    fn deref(&self) -> &pl::Expr {
        &self.0
    }
}

impl DerefMut for Expr {
    fn deref_mut(&mut self) -> &mut pl::Expr {
        &mut self.0
    }
}

#[extendr]
impl Expr {
    //constructors

    pub fn col(name: &str) -> Self {
        Expr(pl::col(name))
    }

    //TODO expand usecases to series and datatime
    pub fn lit(robj: Robj) -> List {
        let rtype = robj.rtype();
        let rlen = robj.len();

        fn lit_no_none<T>(x: Option<T>) -> std::result::Result<pl::Expr, String>
        where
            T: pl::Literal,
        {
            x.ok_or("NA not allowed use NULL".into())
                .map(|ok| pl::lit(ok))
        }

        let expr = match (rtype, rlen) {
            (Rtype::Null, _) => Ok(pl::lit(pl::NULL)),
            (Rtype::Integers, 1) => lit_no_none(robj.as_integer()),
            (Rtype::Doubles, 1) => lit_no_none(robj.as_real()),
            (Rtype::Strings, 1) => {
                if robj.is_na() {
                    let none_str: Option<&str> = None;
                    lit_no_none(none_str)
                } else {
                    lit_no_none(robj.as_str())
                }
            }
            (Rtype::Logicals, 1) => lit_no_none(robj.as_bool()),
            (x, 1) => Err(format!(
                "$lit(val): minipolars not yet support rtype {:?}",
                x
            )),
            (_, n) => Err(format!(
                "$lit(val), literals mush have length one, not length: {:?}",
                n
            )),
        }
        .map(|ok| Expr(ok));

        r_result_list(expr)
    }

    //expr binary comparisons
    pub fn gt(&self, other: &Expr) -> Expr {
        Expr(self.0.clone().gt(other.0.clone()))
    }

    pub fn gt_eq(&self, other: &Expr) -> Expr {
        Expr(self.0.clone().gt_eq(other.0.clone()))
    }

    pub fn lt(&self, other: &Expr) -> Expr {
        Expr(self.0.clone().lt(other.0.clone()))
    }

    pub fn lt_eq(&self, other: &Expr) -> Expr {
        Expr(self.0.clone().lt_eq(other.0.clone()))
    }

    pub fn neq(&self, other: &Expr) -> Expr {
        Expr(self.0.clone().neq(other.0.clone()))
    }

    pub fn eq(&self, other: &Expr) -> Expr {
        Expr(self.0.clone().eq(other.0.clone()))
    }

    //in order

    pub fn alias(&self, s: &str) -> Expr {
        Expr(self.0.clone().alias(s))
    }

    pub fn is_null(&self) -> Expr {
        Expr(self.0.clone().is_null())
    }

    pub fn is_not_null(&self) -> Expr {
        Expr(self.0.clone().is_not_null())
    }

    pub fn drop_nulls(&self) -> Expr {
        Expr(self.0.clone().drop_nulls())
    }

    pub fn drop_nans(&self) -> Expr {
        Expr(self.0.clone().drop_nans())
    }

    pub fn min(&self) -> Expr {
        Expr(self.0.clone().min())
    }

    pub fn max(&self) -> Expr {
        Expr(self.0.clone().max())
    }

    pub fn mean(&self) -> Expr {
        Expr(self.0.clone().mean())
    }

    pub fn median(&self) -> Expr {
        Expr(self.0.clone().median())
    }

    pub fn sum(&self) -> Expr {
        Expr(self.0.clone().sum())
    }

    pub fn n_unique(&self) -> Expr {
        Expr(self.0.clone().n_unique())
    }

    pub fn first(&self) -> Expr {
        Expr(self.0.clone().first())
    }

    pub fn last(&self) -> Expr {
        Expr(self.0.clone().last())
    }

    pub fn head(&self, n: i64) -> Expr {
        Expr(self.0.clone().head(Some(n as usize)))
    }

    pub fn tail(&self, n: i64) -> Expr {
        Expr(self.0.clone().tail(Some(n as usize)))
    }

    pub fn reverse(&self) -> Expr {
        Expr(self.0.clone().reverse())
    }

    //chaining methods

    pub fn unique(&self) -> Expr {
        Expr(self.0.clone().unique())
    }

    pub fn unique_stable(&self) -> Expr {
        Expr(self.0.clone().unique_stable())
    }

    pub fn abs(&self) -> Expr {
        Expr(self.0.clone().abs())
    }

    pub fn agg_groups(&self) -> Expr {
        Expr(self.0.clone().agg_groups())
    }

    pub fn all(&self) -> Expr {
        Expr(self.0.clone().all())
    }
    pub fn any(&self) -> Expr {
        Expr(self.0.clone().any())
    }

    pub fn count(&self) -> Expr {
        Expr(self.0.clone().count())
    }

    //binary arithmetic expressions
    pub fn add(&self, other: &Expr) -> Expr {
        Expr(self.0.clone().add(other.0.clone()))
    }

    //binary arithmetic expressions
    pub fn sub(&self, other: &Expr) -> Expr {
        Expr(self.0.clone().sub(other.0.clone()))
    }

    pub fn mul(&self, other: &Expr) -> Expr {
        Expr(self.0.clone().mul(other.0.clone()))
    }

    pub fn div(&self, other: &Expr) -> Expr {
        Expr(self.0.clone().div(other.0.clone()))
    }

    //unary
    pub fn not(&self) -> Expr {
        Expr(self.0.clone().not())
    }

    //expr "funnies"
    pub fn over(&self, proto_exprs: &ProtoExprArray) -> Expr {
        let ve = pra_to_vec(proto_exprs, "select");
        Expr(self.0.clone().over(ve))
    }

    pub fn dtype_cols(dtypes: &DataTypeVector) -> Expr {
        Expr(dsl::dtype_cols(dtv_to_vec(dtypes)))
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    pub fn map(&self, lambda: Robj, output_type: Nullable<&DataType>, agg_list: bool) -> Expr {
        use crate::utils::wrappers::null_to_opt;

        //find a way not to push lambda everytime to main thread handler
        //safety only accessed in main thread, can be temp owned by other threads
        let probj = ParRObj(lambda);
        //}

        let f = move |s: pl::Series| {
            //acquire channel to R via main thread handler
            let thread_com = ThreadCom::from_global(&CONFIG);

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

        if agg_list {
            Expr(self.clone().0.map_list(f, output_map))
        } else {
            Expr(self.clone().0.map(f, output_map))
        }
    }

    fn suffix(&self, suffix: String) -> Expr {
        Expr(self.0.clone().suffix(suffix.as_str()))
    }

    fn prefix(&self, prefix: String) -> Expr {
        Expr(self.0.clone().prefix(prefix.as_str()))
    }

    fn to_field(&self, df: &DataFrame) {
        let ctxt = polars::prelude::Context::Default;
        let res = self.0.to_field(&df.0.schema(), ctxt);
        res.unwrap();
    }
}

//allow proto expression that yet only are strings
//string expression will transformed into an actual expression in different contexts such as select
#[derive(Clone, Debug)]
#[extendr]
pub enum ProtoRexpr {
    Expr(Expr),
    String(String),
}

#[extendr]
impl ProtoRexpr {
    pub fn new_str(s: &str) -> Self {
        ProtoRexpr::String(s.to_owned())
    }

    pub fn new_expr(r: &Expr) -> Self {
        ProtoRexpr::Expr(r.clone())
    }

    pub fn to_rexpr(&self, context: &str) -> Expr {
        match self {
            ProtoRexpr::Expr(r) => r.clone(),
            ProtoRexpr::String(s) => match context {
                "select" => Expr::col(&s),
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
pub struct ProtoExprArray(pub Vec<ProtoRexpr>);

#[extendr]
impl ProtoExprArray {
    pub fn new() -> Self {
        ProtoExprArray(Vec::new())
    }

    pub fn push_back_str(&mut self, s: &str) {
        self.0.push(ProtoRexpr::new_str(s));
    }

    pub fn push_back_rexpr(&mut self, r: &Expr) {
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
                .collect::<Vec<Expr>>(),
        )
    }
}

//external function as extendr-api do not allow methods returning unwrapped structs
pub fn pra_to_vec(pra: &ProtoExprArray, context: &str) -> Vec<pl::Expr> {
    pra.0.iter().map(|re| re.to_rexpr(context).0).collect()
}

#[derive(Clone, Debug)]
#[extendr]
pub struct RexprArray(pub Vec<Expr>);

#[extendr]
impl RexprArray {
    fn print(&self) {
        rprintln!("{:?}", self);
    }
}

extendr_module! {
    mod rexpr;
    impl Expr;
    impl ProtoExprArray;
    impl RexprArray;
}
