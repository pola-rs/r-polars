pub use anyhow::Context;
use extendr_api::{extendr, extendr_module, symbol::class_symbol, Attributes, Rinternals, Robj};

#[derive(Debug)]
pub struct Rerr(anyhow::Error);
pub type RResult<T> = core::result::Result<T, Rerr>;

#[extendr]
impl Rerr {
    fn info(&self) -> String {
        format!("{:#}", self.0)
    }

    fn debug(&self) -> String {
        format!("{:?}", self.0)
    }

    fn chain(&self) -> Vec<String> {
        self.0.chain().map(|cause| format!("{:#}", cause)).collect()
    }
}

impl From<anyhow::Error> for Rerr {
    fn from(err: anyhow::Error) -> Self {
        Rerr(err)
    }
}

// Implementation for transition
impl From<String> for Rerr {
    fn from(err_msg: String) -> Self {
        Rerr(anyhow::anyhow!(err_msg))
    }
}

impl From<extendr_api::Error> for Rerr {
    fn from(extendr_err: extendr_api::Error) -> Self {
        use extendr_api::error::Error::*;
        let rdebug = |robj| anyhow::anyhow!("{:?}", robj);
        let anyhow_err = match extendr_err {
            Panic(robj) => rdebug(robj).context("Panic"),
            NotFound(robj) => rdebug(robj).context("NotFound"),
            EvalError(robj) => rdebug(robj).context("EvalError"),
            ParseError(robj) => rdebug(robj).context("ParseError"),
            NamesLengthMismatch(robj) => rdebug(robj).context("NamesLengthMismatch"),
            ExpectedNull(robj) => rdebug(robj).context("ExpectedNull"),
            ExpectedSymbol(robj) => rdebug(robj).context("ExpectedSymbol"),
            ExpectedPairlist(robj) => rdebug(robj).context("ExpectedPairlist"),
            ExpectedFunction(robj) => rdebug(robj).context("ExpectedFunction"),
            ExpectedEnvironment(robj) => rdebug(robj).context("ExpectedEnvironment"),
            ExpectedPromise(robj) => rdebug(robj).context("ExpectedPromise"),
            ExpectedLanguage(robj) => rdebug(robj).context("ExpectedLanguage"),
            ExpectedSpecial(robj) => rdebug(robj).context("ExpectedSpecial"),
            ExpectedBuiltin(robj) => rdebug(robj).context("ExpectedBuiltin"),
            ExpectedRstr(robj) => rdebug(robj).context("ExpectedRstr"),
            ExpectedLogical(robj) => rdebug(robj).context("ExpectedLogical"),
            ExpectedInteger(robj) => rdebug(robj).context("ExpectedInteger"),
            ExpectedReal(robj) => rdebug(robj).context("ExpectedReal"),
            ExpectedComplex(robj) => rdebug(robj).context("ExpectedComplex"),
            ExpectedString(robj) => rdebug(robj).context("ExpectedString"),
            ExpectedDot(robj) => rdebug(robj).context("ExpectedDot"),
            ExpectedAny(robj) => rdebug(robj).context("ExpectedAny"),
            ExpectedList(robj) => rdebug(robj).context("ExpectedList"),
            ExpectedExpression(robj) => rdebug(robj).context("ExpectedExpression"),
            ExpectedBytecode(robj) => rdebug(robj).context("ExpectedBytecode"),
            ExpectedExternalPtr(robj) => rdebug(robj).context("ExpectedExternalPtr"),
            ExpectedWeakRef(robj) => rdebug(robj).context("ExpectedWeakRef"),
            ExpectedRaw(robj) => rdebug(robj).context("ExpectedRaw"),
            ExpectedS4(robj) => rdebug(robj).context("ExpectedS4"),
            ExpectedPrimitive(robj) => rdebug(robj).context("ExpectedPrimitive"),
            ExpectedScalar(robj) => rdebug(robj).context("ExpectedScalar"),
            ExpectedVector(robj) => rdebug(robj).context("ExpectedVector"),
            ExpectedMatrix(robj) => rdebug(robj).context("ExpectedMatrix"),
            ExpectedMatrix3D(robj) => rdebug(robj).context("ExpectedMatrix3D"),
            ExpectedNumeric(robj) => rdebug(robj).context("ExpectedNumeric"),
            ExpectedAltrep(robj) => rdebug(robj).context("ExpectedAltrep"),
            ExpectedDataframe(robj) => rdebug(robj).context("ExpectedDataframe"),
            OutOfRange(robj) => rdebug(robj).context("OutOfRange"),
            MustNotBeNA(robj) => rdebug(robj).context("MustNotBeNA"),
            ExpectedNonZeroLength(robj) => rdebug(robj).context("ExpectedNonZeroLength"),
            ExpectedWholeNumber(robj) => rdebug(robj).context("ExpectedWholeNumber"),
            OutOfLimits(robj) => rdebug(robj).context("OutOfLimits"),
            TypeMismatch(robj) => rdebug(robj).context("TypeMismatch"),
            NamespaceNotFound(robj) => rdebug(robj).context("NamespaceNotFound"),
            NoGraphicsDevices(robj) => rdebug(robj).context("NoGraphicsDevices"),
            ExpectedExternalPtrType(robj, s) => {
                anyhow::anyhow!("s:{}, robj:{:?}", s, robj).context("ExpectedExternalPtrType")
            }
            Other(s) => anyhow::anyhow!(s).context("Other"),
        };
        anyhow_err.context("Extendr").into()
    }
}

impl std::fmt::Display for Rerr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:#}", self.0)
    }
}

impl std::error::Error for Rerr {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        self.0.source()
    }
}

extendr_module! {
    mod ranyhow;
    impl Rerr;
}
