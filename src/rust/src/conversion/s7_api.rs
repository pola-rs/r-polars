// Read S7 objects through the native API provided by S7 >= 1.0.0.

use savvy::{NullSexp, ObjSexp, OwnedStringSexp, Sexp, ffi::SEXP, savvy_err};
use std::{
    cell::Cell,
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

fn resolve() -> savvy::Result<S7Api> {
    let get_class = Cell::new(None);
    let get_prop = Cell::new(None);
    unsafe {
        savvy::unwind_protect(|| {
            get_class.set(R_GetCCallable(c"S7".as_ptr(), c"S7_get_class".as_ptr()));
            get_prop.set(R_GetCCallable(c"S7".as_ptr(), c"S7_get_prop".as_ptr()));
            NullSexp.into()
        })?;
    }
    let (Some(get_class), Some(get_prop)) = (get_class.get(), get_prop.get()) else {
        return Err(savvy_err!("S7 native API is unavailable."));
    };
    Ok(S7Api {
        get_class: unsafe {
            std::mem::transmute::<unsafe extern "C" fn() -> *mut c_void, S7GetClass>(get_class)
        },
        get_prop: unsafe {
            std::mem::transmute::<unsafe extern "C" fn() -> *mut c_void, S7GetProp>(get_prop)
        },
    })
}

static S7_API: OnceLock<S7Api> = OnceLock::new();

/// Returns the S7 native API. This resolves the API lazily
/// at the first call. S7 is imported by this package, so it is already loaded
/// at that time. This must be called from the R main thread.
pub(crate) fn api() -> savvy::Result<&'static S7Api> {
    if let Some(api) = S7_API.get() {
        return Ok(api);
    }
    // Resolve outside of `get_or_init()` so that, even if resolving is
    // interrupted by a longjmp, the cell is not left in the "initializing"
    // state.
    let resolved = resolve()?;
    Ok(S7_API.get_or_init(|| resolved))
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

fn string_attrib(sexp: &Sexp, attr: &str) -> savvy::Result<Option<String>> {
    Ok(sexp
        .get_attrib(attr)?
        .and_then(|value| <&str>::try_from(value).ok())
        .map(|s| s.to_string()))
}

/// Returns the class name and the package of the S7 class of `obj`, or `None`
/// if `obj` doesn't have an S7 class.
pub(crate) fn class_info(obj: &ObjSexp) -> savvy::Result<Option<S7ClassInfo>> {
    let class = api()?.get_class(obj.inner())?;
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
/// Like `S7::prop()`, this uses custom getters and errors for an undeclared
/// property or a non-S7 object.
///
/// The returned value is protected until the guard is dropped. Note that
/// borrowed data (e.g. `&str`) converted from the value must be copied before
/// the guard is dropped.
pub(crate) fn prop(obj: &ObjSexp, name: &str) -> savvy::Result<Option<ProtectedSexp>> {
    let value = api()?.get_prop(obj.inner(), name)?;

    if Sexp(value).is_null() {
        return Ok(None);
    }
    Ok(Some(ProtectedSexp::new(value)))
}
