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

    pub fn over(&self, vs: Vec<String>) -> Rexpr {
        let vs2: Vec<&str> = vs.iter().map(|x| x.as_str()).collect();

        Rexpr(self.0.clone().over(vs2))
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    pub fn sum(&self) -> Rexpr {
        Rexpr(self.0.clone().sum())
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
                .map(|re| re.clone().to_rexpr(context))
                .collect::<Vec<Rexpr>>(),
        )
    }
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

extendr_module! {
    mod rexpr;
    impl Rexpr;
    impl ProtoRexprArray;
    impl RexprArray;
}
