use extendr_api::prelude::*;
use polars::prelude::CompatLevel;
use smartstring::alias::String as SmartString;
pub(crate) fn strings_to_smartstrings<I, S>(container: I) -> Vec<SmartString>
where
    I: IntoIterator<Item = S>,
    S: AsRef<str>,
{
    container.into_iter().map(|s| s.as_ref().into()).collect()
}

#[derive(Debug, Copy, Clone)]
pub struct RCompatLevel(pub CompatLevel);

// TODO: dirty, just wanted to have something that compiles
impl<'a> FromRobj<'a> for RCompatLevel {
    fn from_robj(robj: &Robj) -> std::result::Result<Self, &'static str> {
        let out;
        if robj.inherits("integer") {
            if let Ok(compat_level) = CompatLevel::with_level(robj.as_integer().unwrap() as u16) {
                out = compat_level;
            } else {
                return Err("invalid compat level");
            }
        } else if robj.inherits("logical") {
            if robj.as_bool().unwrap() {
                out = CompatLevel::newest();
            } else {
                out = CompatLevel::oldest();
            }
        } else {
            return Err("'compat_level' argument accepts int or bool");
        }

        Ok(RCompatLevel(out))
    }
}
