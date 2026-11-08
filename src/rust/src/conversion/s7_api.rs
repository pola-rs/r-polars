// Compatibility layer for reading S7 objects from Rust.
//
// Newer versions of S7 store the class of an object in an implementation
// detail that may change (e.g. an environment of class `S7_class_ref` instead
// of the class closure), so reading the attributes directly is fragile. These
// versions expose a native API through `R_RegisterCCallable()`:
//
// - `SEXP S7_get_class(SEXP object)`
// - `SEXP S7_get_prop(SEXP object, SEXP name)`
//
// The API is not available in older S7 releases, and we cannot link to S7 at
// build time (`LinkingTo` would require the header, which older releases do
// not ship). So the function pointers are resolved at runtime with
// `R_GetCCallable()`, and the attribute-based implementation is used as a
// fallback when they are not found.
//
// TODO: Once S7 (>= the version providing the native API) is required, remove
// the fallback functions (`legacy_class()` and the `None` arms in
// `class_info()` and `prop()`), and make `api()` fail loudly instead.

use savvy::{NullSexp, ObjSexp, OwnedStringSexp, Sexp, ffi::SEXP};
use std::{
    ffi::{c_char, c_int, c_void},
    sync::OnceLock,
};

type S7GetClass = unsafe extern "C" fn(SEXP) -> SEXP;
type S7GetProp = unsafe extern "C" fn(SEXP, SEXP) -> SEXP;

// R's `DL_FUNC`: a nullable function pointer.
type DlFunc = Option<unsafe extern "C" fn() -> *mut c_void>;

unsafe extern "C" {
    // R_ext/Rdynload.h. This raises an R error if the package or the routine is
    // not registered.
    fn R_GetCCallable(package: *const c_char, name: *const c_char) -> DlFunc;

    // Rinternals.h
    fn R_tryCatchError(
        body: unsafe extern "C" fn(*mut c_void) -> SEXP,
        bdata: *mut c_void,
        handler: unsafe extern "C" fn(SEXP, *mut c_void) -> SEXP,
        hdata: *mut c_void,
    ) -> SEXP;
    fn Rf_protect(x: SEXP) -> SEXP;
    fn Rf_unprotect(n: c_int);
}

/// The function pointers of the S7 native API.
pub(crate) struct S7Api {
    get_class: S7GetClass,
    get_prop: S7GetProp,
}

impl S7Api {
    /// Returns the stored S7 class definition of `obj`, or `R_NilValue` if
    /// there is none.
    fn get_class(&self, obj: SEXP) -> savvy::Result<SEXP> {
        let f = self.get_class;
        // The API itself is not expected to raise errors for this call, but
        // wrap it anyway so that an R error can never longjmp over Rust frames.
        unsafe { savvy::unwind_protect(move || f(obj)) }
    }

    /// Reads the property `name` of `obj` in the same way as `S7::prop()`. The
    /// result is `R_NilValue` if the value is `NULL`. An R error (e.g. for an
    /// undeclared property or a non-S7 object) is returned as `Err`.
    ///
    /// The returned value is not protected from the garbage collector.
    fn get_prop(&self, obj: SEXP, name: &str) -> savvy::Result<SEXP> {
        // `name` keeps the string protected while it is alive.
        let name = OwnedStringSexp::try_from_scalar(name)?;
        let name_sexp = name.inner();
        let f = self.get_prop;
        let res = unsafe { savvy::unwind_protect(move || f(obj, name_sexp)) };
        drop(name);
        res
    }
}

struct Resolver {
    get_class: Option<S7GetClass>,
    get_prop: Option<S7GetProp>,
    failed: bool,
}

fn nil() -> SEXP {
    NullSexp.into()
}

unsafe extern "C" fn resolve_body(data: *mut c_void) -> SEXP {
    unsafe {
        let resolver = &mut *(data as *mut Resolver);

        // These raise an R error if S7 doesn't provide the API.
        let get_class = R_GetCCallable(c"S7".as_ptr(), c"S7_get_class".as_ptr());
        let get_prop = R_GetCCallable(c"S7".as_ptr(), c"S7_get_prop".as_ptr());

        match (get_class, get_prop) {
            (Some(get_class), Some(get_prop)) => {
                resolver.get_class = Some(std::mem::transmute::<
                    unsafe extern "C" fn() -> *mut c_void,
                    S7GetClass,
                >(get_class));
                resolver.get_prop = Some(std::mem::transmute::<
                    unsafe extern "C" fn() -> *mut c_void,
                    S7GetProp,
                >(get_prop));
            }
            _ => resolver.failed = true,
        }
    }
    nil()
}

unsafe extern "C" fn resolve_handler(_condition: SEXP, data: *mut c_void) -> SEXP {
    unsafe { (*(data as *mut Resolver)).failed = true };
    nil()
}

fn resolve() -> Option<S7Api> {
    let mut resolver = Resolver {
        get_class: None,
        get_prop: None,
        failed: false,
    };

    // `R_GetCCallable()` signals an R error when the routine is missing, which
    // is expected for old S7. `R_tryCatchError()` catches the error silently,
    // without leaving the Rust frames by a longjmp.
    unsafe {
        let data = &mut resolver as *mut Resolver as *mut c_void;
        R_tryCatchError(resolve_body, data, resolve_handler, data);
    }

    if resolver.failed {
        return None;
    }
    Some(S7Api {
        get_class: resolver.get_class?,
        get_prop: resolver.get_prop?,
    })
}

static S7_API: OnceLock<Option<S7Api>> = OnceLock::new();

/// Returns the S7 native API if it is available. This resolves the API lazily
/// at the first call. S7 is imported by this package, so it is already loaded
/// at that time. This must be called from the R main thread.
pub(crate) fn api() -> Option<&'static S7Api> {
    if let Some(api) = S7_API.get() {
        return api.as_ref();
    }
    // Resolve outside of `get_or_init()` so that, even if resolving is
    // interrupted by a longjmp, the cell is not left in the "initializing"
    // state.
    let resolved = resolve();
    S7_API.get_or_init(|| resolved).as_ref()
}

/// A SEXP protected from the garbage collector during the lifetime of this
/// guard.
pub(crate) struct ProtectedSexp(SEXP);

impl ProtectedSexp {
    fn new(sexp: SEXP) -> Self {
        unsafe { Rf_protect(sexp) };
        Self(sexp)
    }

    /// Returns the protected SEXP. Do not use the returned value after this
    /// guard is dropped.
    pub(crate) fn sexp(&self) -> Sexp {
        Sexp(self.0)
    }
}

impl Drop for ProtectedSexp {
    fn drop(&mut self) {
        unsafe { Rf_unprotect(1) };
    }
}

/// The name and the package of an S7 class.
pub(crate) struct S7ClassInfo {
    pub(crate) name: String,
    pub(crate) package: Option<String>,
}

// Reads the class definition from the attributes. "_S7_class" is used by
// recent versions of S7; older versions use "S7_class".
fn legacy_class(obj: &ObjSexp) -> savvy::Result<SEXP> {
    let class = match obj.get_attrib("_S7_class")? {
        Some(class) => Some(class),
        None => obj.get_attrib("S7_class")?,
    };
    Ok(class.map_or_else(nil, |class| class.0))
}

fn string_attrib(sexp: &Sexp, attr: &str) -> savvy::Result<Option<String>> {
    Ok(sexp
        .get_attrib(attr)?
        .and_then(|value| <&str>::try_from(value).ok())
        .map(|s| s.to_string()))
}

/// Returns the class name and the package of the S7 class of `obj`, or `None`
/// if `obj` doesn't have an S7 class.
pub(crate) fn class_info(obj: &ObjSexp) -> savvy::Result<Option<S7ClassInfo>> {
    let class = match api() {
        Some(api) => api.get_class(obj.inner())?,
        None => legacy_class(obj)?,
    };
    let class = Sexp(class);
    // The class definition is referenced from `obj` (or from the class
    // reference it holds), so it is kept alive by `obj`.
    if class.is_null() {
        return Ok(None);
    }

    let Some(name) = string_attrib(&class, "name")? else {
        return Ok(None);
    };
    let package = string_attrib(&class, "package")?;
    Ok(Some(S7ClassInfo { name, package }))
}

/// Returns the property `name` of `obj`, or `None` if the value is `NULL`.
///
/// If the S7 native API is available, this behaves like `S7::prop()`: custom
/// getters are used and an undeclared property or a non-S7 object results in
/// an error. Otherwise, the attribute is read directly.
///
/// The returned value is protected until the guard is dropped. Note that
/// borrowed data (e.g. `&str`) converted from the value must be copied before
/// the guard is dropped.
pub(crate) fn prop(obj: &ObjSexp, name: &str) -> savvy::Result<Option<ProtectedSexp>> {
    let value = match api() {
        Some(api) => api.get_prop(obj.inner(), name)?,
        None => match obj.get_attrib(name)? {
            Some(value) => value.0,
            None => return Ok(None),
        },
    };

    if Sexp(value).is_null() {
        return Ok(None);
    }
    Ok(Some(ProtectedSexp::new(value)))
}
