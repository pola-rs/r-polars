use extendr_api::*;
pub mod dataframe;
pub mod dsl;
pub mod whenthen;

extendr_module! {
    mod lazy;
    use whenthen;
    use dsl;
    use dataframe;
}
