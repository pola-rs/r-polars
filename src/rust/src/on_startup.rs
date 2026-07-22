use savvy::savvy_init;

#[savvy_init]
fn on_startup(_dll_info: *mut savvy::ffi::DllInfo) -> savvy::Result<()> {
    #[cfg(not(target_family = "wasm"))]
    polars_error::abort::register_polars_abort_mechanism();
    polars_error::set_warning_function(crate::warn::warning_function);
    Ok(())
}
