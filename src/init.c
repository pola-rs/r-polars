
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

SEXP savvy_to_upper__impl(SEXP x) {
    SEXP res = savvy_to_upper__ffi(x);
    return handle_result(res);
}

SEXP savvy_int_times_int__impl(SEXP x, SEXP y) {
    SEXP res = savvy_int_times_int__ffi(x, y);
    return handle_result(res);
}

SEXP savvy_Person_new__impl(void) {
    SEXP res = savvy_Person_new__ffi();
    return handle_result(res);
}

SEXP savvy_Person_set_name__impl(SEXP self__, SEXP name) {
    SEXP res = savvy_Person_set_name__ffi(self__, name);
    return handle_result(res);
}

SEXP savvy_Person_name__impl(SEXP self__) {
    SEXP res = savvy_Person_name__ffi(self__);
    return handle_result(res);
}

SEXP savvy_Person_associated_function__impl(void) {
    SEXP res = savvy_Person_associated_function__ffi();
    return handle_result(res);
}


static const R_CallMethodDef CallEntries[] = {
    {"savvy_to_upper__impl", (DL_FUNC) &savvy_to_upper__impl, 1},
    {"savvy_int_times_int__impl", (DL_FUNC) &savvy_int_times_int__impl, 2},
    {"savvy_Person_new__impl", (DL_FUNC) &savvy_Person_new__impl, 0},
    {"savvy_Person_set_name__impl", (DL_FUNC) &savvy_Person_set_name__impl, 2},
    {"savvy_Person_name__impl", (DL_FUNC) &savvy_Person_name__impl, 1},
    {"savvy_Person_associated_function__impl", (DL_FUNC) &savvy_Person_associated_function__impl, 0},
    {NULL, NULL, 0}
};

void R_init_neopolars(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);

    // Functions for initialzation, if any.

}
