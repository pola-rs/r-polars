use crate::prelude::*;
use savvy::{OwnedIntegerSexp, OwnedLogicalSexp, Result, Sexp, savvy};

#[savvy]
fn feature_nightly_enabled() -> Result<Sexp> {
    OwnedLogicalSexp::try_from_scalar(cfg!(feature = "nightly")).map(Into::into)
}

#[savvy]
fn rust_polars_version() -> Result<Sexp> {
    polars::VERSION.try_into()
}

#[savvy]
fn thread_pool_size() -> Result<Sexp> {
    (polars_core::POOL.current_num_threads() as i32).try_into()
}

#[savvy]
fn compat_level_range() -> Result<Sexp> {
    let oldest: i32 = CompatLevel::oldest().get_level().into();
    let newest: i32 = CompatLevel::newest().get_level().into();
    OwnedIntegerSexp::try_from_slice([oldest, newest]).map(Into::into)
}
