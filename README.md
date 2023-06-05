## when running `cargo expand` 
```rust

#![feature(prelude_import)]
#[prelude_import]
use std::prelude::rust_2021::*;
#[macro_use]
extern crate std;
use extendr_api::prelude::*;
/// Return string `"Hello world!"` to R.
/// @export
fn hello_world() -> &'static str {
    "Hello world!"
}
#[no_mangle]
#[allow(non_snake_case, clippy::not_unsafe_ptr_arg_deref)]
pub extern "C" fn wrap__hello_world() -> extendr_api::SEXP {
    use extendr_api::robj::*;
    let wrap_result_state: std::result::Result<
        std::result::Result<Robj, extendr_api::Error>,
        Box<dyn std::any::Any + Send>,
    > = unsafe {
        std::panic::catch_unwind(|| -> std::result::Result<Robj, extendr_api::Error> {
            Ok(extendr_api::Robj::from(hello_world()))
        })
    };
    match wrap_result_state {
        Ok(Ok(zz)) => {
            return unsafe { zz.get() };
        }
        Ok(Err(conversion_err)) => {
            let err_string = conversion_err.to_string();
            drop(conversion_err);
            extendr_api::throw_r_error(&err_string);
        }
        Err(unwind_err) => {
            drop(unwind_err);
            let err_string = {
                let res = ::alloc::fmt::format(
                    format_args!("user function panicked: {0}\0", "hello_world"),
                );
                res
            };
            extendr_api::handle_panic(
                err_string.as_str(),
                || ::core::panicking::panic("explicit panic"),
            );
        }
    }
    ::core::panicking::panic_fmt(
        format_args!(
            "internal error: entered unreachable code: {0}",
            format_args!("internal extendr error, this should never happen.")
        ),
    )
}
#[allow(non_snake_case)]
fn meta__hello_world(metadata: &mut Vec<extendr_api::metadata::Func>) {
    let mut args = ::alloc::vec::Vec::new();
    metadata
        .push(extendr_api::metadata::Func {
            doc: " Return string `\"Hello world!\"` to R.\n @export",
            rust_name: "hello_world",
            r_name: "hello_world",
            mod_name: "hello_world",
            args: args,
            return_type: "str",
            func_ptr: wrap__hello_world as *const u8,
            hidden: false,
        })
}
fn three_args(a: i32, b: String, c: f64) {
    print_r_output({
        let res = ::alloc::fmt::format(format_args!("a:{0}, b:{1}, c:{2}", a, b, c));
        res
    });
    print_r_output("\n");
}
#[no_mangle]
#[allow(non_snake_case, clippy::not_unsafe_ptr_arg_deref)]
pub extern "C" fn wrap__three_args(
    a: extendr_api::SEXP,
    b: extendr_api::SEXP,
    c: extendr_api::SEXP,
) -> extendr_api::SEXP {
    use extendr_api::robj::*;
    let wrap_result_state: std::result::Result<
        std::result::Result<Robj, extendr_api::Error>,
        Box<dyn std::any::Any + Send>,
    > = unsafe {
        let _a_robj = extendr_api::new_owned(a);
        let _b_robj = extendr_api::new_owned(b);
        let _c_robj = extendr_api::new_owned(c);
        std::panic::catch_unwind(|| -> std::result::Result<Robj, extendr_api::Error> {
            Ok(
                extendr_api::Robj::from(
                    three_args(
                        <i32>::from_robj(&_a_robj)?,
                        <String>::from_robj(&_b_robj)?,
                        <f64>::from_robj(&_c_robj)?,
                    ),
                ),
            )
        })
    };
    match wrap_result_state {
        Ok(Ok(zz)) => {
            return unsafe { zz.get() };
        }
        Ok(Err(conversion_err)) => {
            let err_string = conversion_err.to_string();
            drop(conversion_err);
            extendr_api::throw_r_error(&err_string);
        }
        Err(unwind_err) => {
            drop(unwind_err);
            let err_string = {
                let res = ::alloc::fmt::format(
                    format_args!("user function panicked: {0}\0", "three_args"),
                );
                res
            };
            extendr_api::handle_panic(
                err_string.as_str(),
                || ::core::panicking::panic("explicit panic"),
            );
        }
    }
    ::core::panicking::panic_fmt(
        format_args!(
            "internal error: entered unreachable code: {0}",
            format_args!("internal extendr error, this should never happen.")
        ),
    )
}
#[allow(non_snake_case)]
fn meta__three_args(metadata: &mut Vec<extendr_api::metadata::Func>) {
    let mut args = <[_]>::into_vec(
        #[rustc_box]
        ::alloc::boxed::Box::new([
            extendr_api::metadata::Arg {
                name: "a",
                arg_type: "i32",
                default: None,
            },
            extendr_api::metadata::Arg {
                name: "b",
                arg_type: "String",
                default: None,
            },
            extendr_api::metadata::Arg {
                name: "c",
                arg_type: "f64",
                default: None,
            },
        ]),
    );
    metadata
        .push(extendr_api::metadata::Func {
            doc: "",
            rust_name: "three_args",
            r_name: "three_args",
            mod_name: "three_args",
            args: args,
            return_type: "()",
            func_ptr: wrap__three_args as *const u8,
            hidden: false,
        })
}
fn three_args_use_try_from(a: i32, b: String, c: f64) {
    print_r_output({
        let res = ::alloc::fmt::format(format_args!("a:{0}, b:{1}, c:{2}", a, b, c));
        res
    });
    print_r_output("\n");
}
#[no_mangle]
#[allow(non_snake_case, clippy::not_unsafe_ptr_arg_deref)]
pub extern "C" fn wrap__three_args_use_try_from(
    a: extendr_api::SEXP,
    b: extendr_api::SEXP,
    c: extendr_api::SEXP,
) -> extendr_api::SEXP {
    use extendr_api::robj::*;
    let wrap_result_state: std::result::Result<
        std::result::Result<Robj, extendr_api::Error>,
        Box<dyn std::any::Any + Send>,
    > = unsafe {
        let _a_robj = extendr_api::new_owned(a);
        let _b_robj = extendr_api::new_owned(b);
        let _c_robj = extendr_api::new_owned(c);
        std::panic::catch_unwind(|| -> std::result::Result<Robj, extendr_api::Error> {
            Ok(
                extendr_api::Robj::from(
                    three_args_use_try_from(
                        _a_robj.try_into()?,
                        _b_robj.try_into()?,
                        _c_robj.try_into()?,
                    ),
                ),
            )
        })
    };
    match wrap_result_state {
        Ok(Ok(zz)) => {
            return unsafe { zz.get() };
        }
        Ok(Err(conversion_err)) => {
            let err_string = conversion_err.to_string();
            drop(conversion_err);
            extendr_api::throw_r_error(&err_string);
        }
        Err(unwind_err) => {
            drop(unwind_err);
            let err_string = {
                let res = ::alloc::fmt::format(
                    format_args!(
                        "user function panicked: {0}\0", "three_args_use_try_from"
                    ),
                );
                res
            };
            extendr_api::handle_panic(
                err_string.as_str(),
                || ::core::panicking::panic("explicit panic"),
            );
        }
    }
    ::core::panicking::panic_fmt(
        format_args!(
            "internal error: entered unreachable code: {0}",
            format_args!("internal extendr error, this should never happen.")
        ),
    )
}
#[allow(non_snake_case)]
fn meta__three_args_use_try_from(metadata: &mut Vec<extendr_api::metadata::Func>) {
    let mut args = <[_]>::into_vec(
        #[rustc_box]
        ::alloc::boxed::Box::new([
            extendr_api::metadata::Arg {
                name: "a",
                arg_type: "i32",
                default: None,
            },
            extendr_api::metadata::Arg {
                name: "b",
                arg_type: "String",
                default: None,
            },
            extendr_api::metadata::Arg {
                name: "c",
                arg_type: "f64",
                default: None,
            },
        ]),
    );
    metadata
        .push(extendr_api::metadata::Func {
            doc: "",
            rust_name: "three_args_use_try_from",
            r_name: "three_args_use_try_from",
            mod_name: "three_args_use_try_from",
            args: args,
            return_type: "()",
            func_ptr: wrap__three_args_use_try_from as *const u8,
            hidden: false,
        })
}
#[no_mangle]
#[allow(non_snake_case)]
pub fn get_helloextendr_metadata() -> extendr_api::metadata::Metadata {
    let mut functions = Vec::new();
    let mut impls = Vec::new();
    meta__hello_world(&mut functions);
    meta__three_args(&mut functions);
    meta__three_args_use_try_from(&mut functions);
    functions
        .push(extendr_api::metadata::Func {
            doc: "Metadata access function.",
            rust_name: "get_helloextendr_metadata",
            mod_name: "get_helloextendr_metadata",
            r_name: "get_helloextendr_metadata",
            args: Vec::new(),
            return_type: "Metadata",
            func_ptr: wrap__get_helloextendr_metadata as *const u8,
            hidden: true,
        });
    functions
        .push(extendr_api::metadata::Func {
            doc: "Wrapper generator.",
            rust_name: "make_helloextendr_wrappers",
            mod_name: "make_helloextendr_wrappers",
            r_name: "make_helloextendr_wrappers",
            args: <[_]>::into_vec(
                #[rustc_box]
                ::alloc::boxed::Box::new([
                    extendr_api::metadata::Arg {
                        name: "use_symbols",
                        arg_type: "bool",
                        default: None,
                    },
                    extendr_api::metadata::Arg {
                        name: "package_name",
                        arg_type: "&str",
                        default: None,
                    },
                ]),
            ),
            return_type: "String",
            func_ptr: wrap__make_helloextendr_wrappers as *const u8,
            hidden: true,
        });
    extendr_api::metadata::Metadata {
        name: "helloextendr",
        functions,
        impls,
    }
}
#[no_mangle]
#[allow(non_snake_case)]
pub extern "C" fn wrap__get_helloextendr_metadata() -> extendr_api::SEXP {
    use extendr_api::GetSexp;
    unsafe { extendr_api::Robj::from(get_helloextendr_metadata()).get() }
}
#[no_mangle]
#[allow(non_snake_case, clippy::not_unsafe_ptr_arg_deref)]
pub extern "C" fn wrap__make_helloextendr_wrappers(
    use_symbols_sexp: extendr_api::SEXP,
    package_name_sexp: extendr_api::SEXP,
) -> extendr_api::SEXP {
    unsafe {
        use extendr_api::robj::*;
        use extendr_api::GetSexp;
        let robj = new_owned(use_symbols_sexp);
        let use_symbols: bool = <bool>::from_robj(&robj).unwrap();
        let robj = new_owned(package_name_sexp);
        let package_name: &str = <&str>::from_robj(&robj).unwrap();
        extendr_api::Robj::from(
                get_helloextendr_metadata()
                    .make_r_wrappers(use_symbols, package_name)
                    .unwrap(),
            )
            .get()
    }
}
#[no_mangle]
#[allow(non_snake_case, clippy::not_unsafe_ptr_arg_deref)]
pub extern "C" fn R_init_helloextendr_extendr(info: *mut extendr_api::DllInfo) {
    unsafe { extendr_api::register_call_methods(info, get_helloextendr_metadata()) };
}

```