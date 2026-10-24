// Adapted from Polars' pyo3-polars/src/derive.rs.
// Distributed under the MIT license; see LICENSE.
// The Python-independent runtime does not install a process-wide panic hook.

use std::{cell::RefCell, ffi::CString};

use polars_error::{to_compute_err, PolarsError, PolarsResult};
pub use polars_ffi::version_0::CallerContext;
pub use pyo3_polars_derive::polars_expr;
use serde::Deserialize;

/// A default opaque kwargs type, using the upstream pickle wire format.
pub type DefaultKwargs = serde_pickle::Value;

thread_local! {
    static LAST_ERROR: RefCell<CString> = RefCell::new(CString::default());
}

#[doc(hidden)]
pub fn _parse_kwargs<'a, T: Deserialize<'a>>(kwargs: &'a [u8]) -> PolarsResult<T> {
    serde_pickle::from_slice(kwargs, Default::default()).map_err(to_compute_err)
}

#[doc(hidden)]
pub fn _update_last_error(err: PolarsError) {
    // C strings cannot contain NUL. Escaping it keeps even such errors from
    // panicking inside the macro's panic/error handler.
    let msg = CString::new(err.to_string().replace('\0', "\\0")).unwrap();
    LAST_ERROR.with(|prev| *prev.borrow_mut() = msg);
}

#[doc(hidden)]
pub fn _set_panic() {
    LAST_ERROR.with(|prev| *prev.borrow_mut() = CString::new("PANIC").unwrap());
}

/// Return the last error on this thread, borrowed until the next error update.
///
/// # Safety
/// The caller must not free the pointer, use it after a subsequent error update
/// or thread exit, or access it from another thread.
#[no_mangle]
pub unsafe extern "C" fn _polars_plugin_get_last_error_message() -> *const std::os::raw::c_char {
    LAST_ERROR.with(|prev| prev.borrow().as_ptr())
}

/// Return the upstream FFI major/minor version packed into a u32.
///
/// # Safety
/// This is an FFI entry point; it has no pointer preconditions.
#[no_mangle]
pub unsafe extern "C" fn _polars_plugin_get_version() -> u32 {
    let (major, minor) = polars_ffi::get_version();
    ((major as u32) << 16) + minor as u32
}
