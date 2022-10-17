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

impl From<pl::Expr> for Expr {
    fn from(expr: pl::Expr) -> Self {
        Expr(expr)
    }
}

#[extendr]
impl Expr {
    //constructors
    pub fn col(name: &str) -> Self {
        dsl::col(name).into()
    }

    //via col
    pub fn dtype_cols(dtypes: &DataTypeVector) -> Self {
        dsl::dtype_cols(dtv_to_vec(dtypes)).into()
    }

    //via col
    pub fn cols(names: Vec<String>) -> Self {
        dsl::cols(names).into()
    }

    //TODO expand usecases to series and datatime
    pub fn lit(robj: Robj) -> List {
        let rtype = robj.rtype();
        let rlen = robj.len();
        let err_msg = "NA not allowed use NULL";
        let expr_result = match (rtype, rlen) {
            (Rtype::Null, _) => Ok(dsl::lit(pl::NULL)),
            (Rtype::Integers, 1) => {
                let opt_val = robj.as_integer();
                if let Some(val) = opt_val.clone() {
                    Ok(dsl::lit(val))
                } else {
                    if robj.is_na() {
                        Ok(dsl::lit(pl::NULL).cast(pl::DataType::Int32))
                    } else {
                        Err(err_msg.into())
                    }
                }
            }
            (Rtype::Doubles, 1) => {
                let opt_val = robj.as_real();
                if let Some(val) = opt_val.clone() {
                    Ok(dsl::lit(val))
                } else {
                    if robj.is_na() {
                        Ok(dsl::lit(pl::NULL).cast(pl::DataType::Float64))
                    } else {
                        Err(err_msg.into())
                    }
                }
            }
            (Rtype::Strings, 1) => {
                let opt_val = robj.as_str();
                if let Some(val) = opt_val.clone() {
                    Ok(dsl::lit(val))
                } else {
                    if robj.is_na() {
                        Ok(dsl::lit(pl::NULL).cast(pl::DataType::Utf8))
                    } else {
                        Err(err_msg.into())
                    }
                }
            }
            (Rtype::Logicals, 1) => {
                let opt_val = robj.as_bool();
                if let Some(val) = opt_val.clone() {
                    Ok(dsl::lit(val))
                } else {
                    if robj.is_na() {
                        Ok(dsl::lit(pl::NULL).cast(pl::DataType::Boolean))
                    } else {
                        Err(err_msg.into())
                    }
                }
            }
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

        r_result_list(expr_result)
    }

    //expr binary comparisons
    pub fn gt(&self, other: &Expr) -> Self {
        self.0.clone().gt(other.0.clone()).into()
    }

    pub fn gt_eq(&self, other: &Expr) -> Self {
        self.0.clone().gt_eq(other.0.clone()).into()
    }

    pub fn lt(&self, other: &Expr) -> Self {
        self.0.clone().lt(other.0.clone()).into()
    }

    pub fn lt_eq(&self, other: &Expr) -> Self {
        self.0.clone().lt_eq(other.0.clone()).into()
    }

    pub fn neq(&self, other: &Expr) -> Self {
        self.0.clone().neq(other.0.clone()).into()
    }

    pub fn eq(&self, other: &Expr) -> Self {
        self.0.clone().eq(other.0.clone()).into()
    }

    //logical operators
    fn and(&self, other: &Expr) -> Self {
        self.0.clone().and(other.0.clone()).into()
    }

    fn or(&self, other: &Expr) -> Self {
        self.0.clone().or(other.0.clone()).into()
    }

    fn xor(&self, other: &Expr) -> Self {
        self.0.clone().xor(other.0.clone()).into()
    }

    fn is_in(&self, other: &Expr) -> Self {
        self.0.clone().is_in(other.0.clone()).into()
    }

    //any not translated expr from expr/expr.py
    pub fn to_physical(&self) -> Self {
        use polars::prelude::GetOutput;

        self.0
            .clone()
            .map(
                |s| Ok(s.to_physical_repr().into_owned()),
                GetOutput::map_dtype(|dt| dt.to_physical()),
            )
            .with_fmt("to_physical")
            .into()
    }

    pub fn cast(&self, data_type: &DataType, strict: bool) -> Self {
        let dt = data_type.0.clone();
        if strict {
            self.0.clone().strict_cast(dt)
        } else {
            self.0.clone().cast(dt)
        }
        .into()
    }

    pub fn pow(&self, exponent: &Expr) -> Self {
        self.0.clone().pow(exponent.0.clone()).into()
    }

    pub fn log10(&self) -> Self {
        self.0.clone().log(10.0).into()
    }

    // TODO contribute to polars
    // log/exp only takes float, whereas pow takes Into<Expr>
    // log takes a base value, whereas exp only is natural log

    pub fn log(&self, base: f64) -> Self {
        self.0.clone().log(base).into()
    }

    pub fn exp(&self) -> Self {
        self.0.clone().exp().into()
    }

    //in order

    pub fn alias(&self, s: &str) -> Self {
        self.0.clone().alias(s).into()
    }

    pub fn is_null(&self) -> Self {
        self.0.clone().is_null().into()
    }

    pub fn is_not_null(&self) -> Self {
        self.0.clone().is_not_null().into()
    }

    pub fn drop_nulls(&self) -> Self {
        self.0.clone().drop_nulls().into()
    }

    pub fn drop_nans(&self) -> Self {
        self.0.clone().drop_nans().into()
    }

    pub fn min(&self) -> Self {
        self.0.clone().min().into()
    }

    pub fn max(&self) -> Self {
        self.0.clone().max().into()
    }

    pub fn mean(&self) -> Self {
        self.0.clone().mean().into()
    }

    pub fn median(&self) -> Self {
        self.0.clone().median().into()
    }

    pub fn sum(&self) -> Self {
        self.0.clone().sum().into()
    }

    pub fn n_unique(&self) -> Self {
        self.0.clone().n_unique().into()
    }

    pub fn first(&self) -> Self {
        self.0.clone().first().into()
    }

    pub fn last(&self) -> Self {
        self.0.clone().last().into()
    }

    pub fn head(&self, n: i64) -> Self {
        self.0.clone().head(Some(n as usize)).into()
    }

    pub fn tail(&self, n: i64) -> Self {
        self.0.clone().tail(Some(n as usize)).into()
    }

    pub fn reverse(&self) -> Self {
        self.0.clone().reverse().into()
    }

    //chaining methods

    pub fn unique(&self) -> Self {
        self.0.clone().unique().into()
    }

    pub fn unique_stable(&self) -> Self {
        self.0.clone().unique_stable().into()
    }

    pub fn abs(&self) -> Self {
        self.0.clone().abs().into()
    }

    pub fn agg_groups(&self) -> Self {
        self.0.clone().agg_groups().into()
    }

    pub fn all(&self) -> Self {
        self.0.clone().all().into()
    }
    pub fn any(&self) -> Self {
        self.0.clone().any().into()
    }

    pub fn count(&self) -> Self {
        self.0.clone().count().into()
    }

    //binary arithmetic expressions
    pub fn add(&self, other: &Expr) -> Self {
        self.0.clone().add(other.0.clone()).into()
    }

    //binary arithmetic expressions
    pub fn sub(&self, other: &Expr) -> Self {
        self.0.clone().sub(other.0.clone()).into()
    }

    pub fn mul(&self, other: &Expr) -> Self {
        self.0.clone().mul(other.0.clone()).into()
    }

    pub fn div(&self, other: &Expr) -> Self {
        self.0.clone().div(other.0.clone()).into()
    }

    //unary
    pub fn not(&self) -> Self {
        self.0.clone().not().into()
    }

    //expr "funnies"
    pub fn over(&self, proto_exprs: &ProtoExprArray) -> Self {
        let ve = pra_to_vec(proto_exprs, "select");
        self.0.clone().over(ve).into()
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    pub fn map(&self, lambda: Robj, output_type: Nullable<&DataType>, agg_list: bool) -> Self {
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
            self.clone().0.map_list(f, output_map)
        } else {
            self.clone().0.map(f, output_map)
        }
        .into()
    }

    fn suffix(&self, suffix: String) -> Self {
        self.0.clone().suffix(suffix.as_str()).into()
    }

    fn prefix(&self, prefix: String) -> Self {
        self.0.clone().prefix(prefix.as_str()).into()
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
        rprintln!("{:#?}", self);
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
        rprintln!("{:#?}", self);
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
        rprintln!("{:#?}", self);
    }
}

extendr_module! {
    mod rexpr;
    impl Expr;
    impl ProtoExprArray;
    impl RexprArray;
}
