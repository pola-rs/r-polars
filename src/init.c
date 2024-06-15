
#include <stdint.h>
#include <Rinternals.h>
#include <R_ext/Parse.h>

#include "rust/api.h"

static uintptr_t TAGGED_POINTER_MASK = (uintptr_t)1;

SEXP handle_result(SEXP res_) {
    uintptr_t res = (uintptr_t)res_;

    // An error is indicated by tag.
    if ((res & TAGGED_POINTER_MASK) == 1) {
        // Remove tag
        SEXP res_aligned = (SEXP)(res & ~TAGGED_POINTER_MASK);

        // Currently, there are two types of error cases:
        //
        //   1. Error from Rust code
        //   2. Error from R's C API, which is caught by R_UnwindProtect()
        //
        if (TYPEOF(res_aligned) == CHARSXP) {
            // In case 1, the result is an error message that can be passed to
            // Rf_errorcall() directly.
            Rf_errorcall(R_NilValue, "%s", CHAR(res_aligned));
        } else {
            // In case 2, the result is the token to restart the
            // cleanup process on R's side.
            R_ContinueUnwind(res_aligned);
        }
    }

    return (SEXP)res;
}


SEXP savvy_PlRDataFrame_init__impl(SEXP columns) {
    SEXP res = savvy_PlRDataFrame_init__ffi(columns);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_print__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_print__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_print__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_print__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_clone__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_clone__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_name__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_name__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_rename__impl(SEXP self__, SEXP name) {
    SEXP res = savvy_PlRSeries_rename__ffi(self__, name);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_empty__impl(SEXP name) {
    SEXP res = savvy_PlRSeries_new_empty__ffi(name);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_f64__impl(SEXP name, SEXP values) {
    SEXP res = savvy_PlRSeries_new_f64__ffi(name, values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_i32__impl(SEXP name, SEXP values) {
    SEXP res = savvy_PlRSeries_new_i32__ffi(name, values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_bool__impl(SEXP name, SEXP values) {
    SEXP res = savvy_PlRSeries_new_bool__ffi(name, values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_str__impl(SEXP name, SEXP values) {
    SEXP res = savvy_PlRSeries_new_str__ffi(name, values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_categorical__impl(SEXP name, SEXP values) {
    SEXP res = savvy_PlRSeries_new_categorical__ffi(name, values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_series_list__impl(SEXP name, SEXP values) {
    SEXP res = savvy_PlRSeries_new_series_list__ffi(name, values);
    return handle_result(res);
}


static const R_CallMethodDef CallEntries[] = {

    {"savvy_PlRDataFrame_init__impl", (DL_FUNC) &savvy_PlRDataFrame_init__impl, 1},
    {"savvy_PlRDataFrame_print__impl", (DL_FUNC) &savvy_PlRDataFrame_print__impl, 1},
    {"savvy_PlRSeries_print__impl", (DL_FUNC) &savvy_PlRSeries_print__impl, 1},
    {"savvy_PlRSeries_clone__impl", (DL_FUNC) &savvy_PlRSeries_clone__impl, 1},
    {"savvy_PlRSeries_name__impl", (DL_FUNC) &savvy_PlRSeries_name__impl, 1},
    {"savvy_PlRSeries_rename__impl", (DL_FUNC) &savvy_PlRSeries_rename__impl, 2},
    {"savvy_PlRSeries_new_empty__impl", (DL_FUNC) &savvy_PlRSeries_new_empty__impl, 1},
    {"savvy_PlRSeries_new_f64__impl", (DL_FUNC) &savvy_PlRSeries_new_f64__impl, 2},
    {"savvy_PlRSeries_new_i32__impl", (DL_FUNC) &savvy_PlRSeries_new_i32__impl, 2},
    {"savvy_PlRSeries_new_bool__impl", (DL_FUNC) &savvy_PlRSeries_new_bool__impl, 2},
    {"savvy_PlRSeries_new_str__impl", (DL_FUNC) &savvy_PlRSeries_new_str__impl, 2},
    {"savvy_PlRSeries_new_categorical__impl", (DL_FUNC) &savvy_PlRSeries_new_categorical__impl, 2},
    {"savvy_PlRSeries_new_series_list__impl", (DL_FUNC) &savvy_PlRSeries_new_series_list__impl, 2},
    {NULL, NULL, 0}
};

void R_init_neopolars(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);

    // Functions for initialzation, if any.

}
