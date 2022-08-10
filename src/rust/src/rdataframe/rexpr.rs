use extendr_api::{extendr, prelude::*, rprintln, Deref, DerefMut, Rinternals};
use polars::prelude::{self as pl};

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
    //constructors
    pub fn col(name: &str) -> Self {
        Rexpr(pl::col(name))
    }

    //chaining methods
    pub fn abs(&self) -> Rexpr {
        Rexpr(self.0.clone().abs())
    }

    pub fn agg_groups(&self) -> Rexpr {
        Rexpr(self.0.clone().agg_groups())
    }

    pub fn alias(&self, s: &str) -> Rexpr {
        Rexpr(self.0.clone().alias(s))
    }

    pub fn all(&self) -> Rexpr {
        Rexpr(self.0.clone().all())
    }
    pub fn any(&self) -> Rexpr {
        Rexpr(self.0.clone().any())
    }

    pub fn sum(&self) -> Rexpr {
        Rexpr(self.0.clone().sum())
    }

    //unary
    pub fn not(&self) -> Rexpr {
        Rexpr(self.0.clone().not())
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

    //expr "funnies"
    pub fn over(&self, vs: Vec<String>) -> Rexpr {
        let vs2: Vec<&str> = vs.iter().map(|x| x.as_str()).collect();

        Rexpr(self.0.clone().over(vs2))
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
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
