use smartstring::alias::String as SmartString;
pub(crate) fn strings_to_smartstrings<I, S>(container: I) -> Vec<SmartString>
where
    I: IntoIterator<Item = S>,
    S: AsRef<str>,
{
    container.into_iter().map(|s| s.as_ref().into()).collect()
}
