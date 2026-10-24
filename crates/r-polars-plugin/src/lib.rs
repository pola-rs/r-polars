//! Python-independent runtime for the upstream `polars_expr` macro.
//!
//! Depend on this package under the name `pyo3_polars`; see the README.

pub mod derive;
pub mod export;

pub use derive::polars_expr;
