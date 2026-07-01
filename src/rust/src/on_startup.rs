use savvy::savvy_init;

#[savvy_init]
fn on_startup(_dll_info: *mut savvy::ffi::DllInfo) -> savvy::Result<()> {
    #[cfg(not(target_family = "wasm"))]
    polars_error::signals::register_polars_keyboard_interrupt_hook();
    polars_error::set_warning_function(crate::warn::warning_function);
    Ok(())
}
