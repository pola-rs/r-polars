# r-polars-plugin

A Python-independent runtime for authoring Polars expression plugins. It reuses
`pyo3-polars-derive` unchanged, without PyO3 or linking to Python. It is usable
without r-polars and exposes **no R APIs**.

## Write a plugin

Create a Rust package with this `Cargo.toml`, replacing the revision placeholder
with a full r-polars commit containing this crate:

```toml
[package]
name = "my-plugin"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib"]

[dependencies]
pyo3_polars = { package = "r-polars-plugin", git = "https://github.com/pola-rs/r-polars", rev = "<pinned-r-polars-commit>" }
```

Copy the relevant `[patch.crates-io]` entries from this crate's
[Cargo.toml](Cargo.toml) into your workspace root; Cargo does not inherit
patches from dependencies.

In `src/lib.rs`:

```rust
use pyo3_polars::derive::polars_expr;
use pyo3_polars::export::polars_core::prelude::*;

#[polars_expr(output_type = Int64)]
fn double(inputs: &[Series]) -> PolarsResult<Series> {
    Ok((inputs[0].i64()? * 2).into_series())
}
```

Build with `cargo build --release`, selecting the toolchain configured in
r-polars' `src/rust/rust-toolchain.toml`. The result is
`target/release/libmy_plugin.so` on Linux (`.dylib` on macOS, `.dll` on Windows).
Keep Cargo's default `panic = "unwind"` so plugin panics can be caught.

The **`pyo3_polars` alias is required**: the macro generates paths with that name,
which resolve to this runtime, not the Python binding crate. Use the `export`
module's Polars re-exports to avoid introducing mismatched dependencies.

The runtime is adapted from upstream under the MIT license; see [LICENSE](LICENSE).

## Updating

When r-polars updates Polars, copy the new Git revision from `src/rust/Cargo.toml`
into all Polars dependencies (including `pyo3-polars-derive`) in this crate's
`Cargo.toml`.

Check whether upstream `pyo3-polars/src/derive.rs` has changed, and update the shim
only if necessary. The existing Rust CI verifies that the example plugin compiles
and exports the required symbols without Python.
