
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

SEXP savvy_concat_df__impl(SEXP c_arg__dfs) {
    SEXP res = savvy_concat_df__ffi(c_arg__dfs);
    return handle_result(res);
}

SEXP savvy_as_struct__impl(SEXP c_arg__exprs) {
    SEXP res = savvy_as_struct__ffi(c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_field__impl(SEXP c_arg__names) {
    SEXP res = savvy_field__ffi(c_arg__names);
    return handle_result(res);
}

SEXP savvy_col__impl(SEXP c_arg__name) {
    SEXP res = savvy_col__ffi(c_arg__name);
    return handle_result(res);
}

SEXP savvy_cols__impl(SEXP c_arg__names) {
    SEXP res = savvy_cols__ffi(c_arg__names);
    return handle_result(res);
}

SEXP savvy_dtype_cols__impl(SEXP c_arg__dtypes) {
    SEXP res = savvy_dtype_cols__ffi(c_arg__dtypes);
    return handle_result(res);
}

SEXP savvy_lit_from_bool__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_bool__ffi(c_arg__value);
    return handle_result(res);
}

SEXP savvy_lit_from_i32__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_i32__ffi(c_arg__value);
    return handle_result(res);
}

SEXP savvy_lit_from_f64__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_f64__ffi(c_arg__value);
    return handle_result(res);
}

SEXP savvy_lit_from_str__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_str__ffi(c_arg__value);
    return handle_result(res);
}

SEXP savvy_lit_from_raw__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_raw__ffi(c_arg__value);
    return handle_result(res);
}

SEXP savvy_lit_null__impl(void) {
    SEXP res = savvy_lit_null__ffi();
    return handle_result(res);
}

SEXP savvy_lit_from_series__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_series__ffi(c_arg__value);
    return handle_result(res);
}

SEXP savvy_lit_from_series_first__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_series_first__ffi(c_arg__value);
    return handle_result(res);
}

SEXP savvy_when__impl(SEXP c_arg__condition) {
    SEXP res = savvy_when__ffi(c_arg__condition);
    return handle_result(res);
}

SEXP savvy_PlRChainedThen_when__impl(SEXP self__, SEXP c_arg__condition) {
    SEXP res = savvy_PlRChainedThen_when__ffi(self__, c_arg__condition);
    return handle_result(res);
}

SEXP savvy_PlRChainedThen_otherwise__impl(SEXP self__, SEXP c_arg__statement) {
    SEXP res = savvy_PlRChainedThen_otherwise__ffi(self__, c_arg__statement);
    return handle_result(res);
}

SEXP savvy_PlRChainedWhen_then__impl(SEXP self__, SEXP c_arg__statement) {
    SEXP res = savvy_PlRChainedWhen_then__ffi(self__, c_arg__statement);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_init__impl(SEXP c_arg__columns) {
    SEXP res = savvy_PlRDataFrame_init__ffi(c_arg__columns);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_print__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_print__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_get_columns__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_get_columns__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_slice__impl(SEXP self__, SEXP c_arg__offset, SEXP c_arg__length) {
    SEXP res = savvy_PlRDataFrame_slice__ffi(self__, c_arg__offset, c_arg__length);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_head__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRDataFrame_head__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_tail__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRDataFrame_tail__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_columns__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_columns__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_set_column_names__impl(SEXP self__, SEXP c_arg__names) {
    SEXP res = savvy_PlRDataFrame_set_column_names__ffi(self__, c_arg__names);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_dtypes__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_dtypes__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_shape__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_shape__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_height__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_height__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_width__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_width__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_to_series__impl(SEXP self__, SEXP c_arg__index) {
    SEXP res = savvy_PlRDataFrame_to_series__ffi(self__, c_arg__index);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_equals__impl(SEXP self__, SEXP c_arg__other, SEXP c_arg__null_equal) {
    SEXP res = savvy_PlRDataFrame_equals__ffi(self__, c_arg__other, c_arg__null_equal);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_clone__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_clone__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_lazy__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_lazy__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_to_struct__impl(SEXP self__, SEXP c_arg__name) {
    SEXP res = savvy_PlRDataFrame_to_struct__ffi(self__, c_arg__name);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_from_name__impl(SEXP c_arg__name) {
    SEXP res = savvy_PlRDataType_new_from_name__ffi(c_arg__name);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_decimal__impl(SEXP c_arg__scale, SEXP c_arg__precision) {
    SEXP res = savvy_PlRDataType_new_decimal__ffi(c_arg__scale, c_arg__precision);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_datetime__impl(SEXP c_arg__time_unit, SEXP c_arg__time_zone) {
    SEXP res = savvy_PlRDataType_new_datetime__ffi(c_arg__time_unit, c_arg__time_zone);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_duration__impl(SEXP c_arg__time_unit) {
    SEXP res = savvy_PlRDataType_new_duration__ffi(c_arg__time_unit);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_categorical__impl(SEXP c_arg__ordering) {
    SEXP res = savvy_PlRDataType_new_categorical__ffi(c_arg__ordering);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_enum__impl(SEXP c_arg__categories) {
    SEXP res = savvy_PlRDataType_new_enum__ffi(c_arg__categories);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_list__impl(SEXP c_arg__inner) {
    SEXP res = savvy_PlRDataType_new_list__ffi(c_arg__inner);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_array__impl(SEXP c_arg__inner, SEXP c_arg__shape) {
    SEXP res = savvy_PlRDataType_new_array__ffi(c_arg__inner, c_arg__shape);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_struct__impl(SEXP c_arg__fields) {
    SEXP res = savvy_PlRDataType_new_struct__ffi(c_arg__fields);
    return handle_result(res);
}

SEXP savvy_PlRDataType_print__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_print__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType__get_datatype_fields__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType__get_datatype_fields__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_eq__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRDataType_eq__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRDataType_ne__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRDataType_ne__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_array__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_array__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_binary__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_binary__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_bool__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_bool__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_categorical__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_categorical__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_date__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_date__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_enum__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_enum__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_float__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_float__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_integer__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_integer__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_known__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_known__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_list__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_list__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_logical__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_logical__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_nested__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_nested__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_nested_null__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_nested_null__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_null__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_null__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_numeric__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_numeric__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_ord__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_ord__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_primitive__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_primitive__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_signed_integer__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_signed_integer__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_string__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_string__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_struct__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_struct__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_temporal__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_temporal__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_is_unsigned_integer__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_is_unsigned_integer__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_contains__impl(SEXP self__, SEXP c_arg__literal) {
    SEXP res = savvy_PlRExpr_bin_contains__ffi(self__, c_arg__literal);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_ends_with__impl(SEXP self__, SEXP c_arg__suffix) {
    SEXP res = savvy_PlRExpr_bin_ends_with__ffi(self__, c_arg__suffix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_starts_with__impl(SEXP self__, SEXP c_arg__prefix) {
    SEXP res = savvy_PlRExpr_bin_starts_with__ffi(self__, c_arg__prefix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_hex_decode__impl(SEXP self__, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_bin_hex_decode__ffi(self__, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_base64_decode__impl(SEXP self__, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_bin_base64_decode__ffi(self__, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_hex_encode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bin_hex_encode__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_base64_encode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bin_base64_encode__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_size_bytes__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bin_size_bytes__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cat_get_categories__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_cat_get_categories__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cat_set_ordering__impl(SEXP self__, SEXP c_arg__ordering) {
    SEXP res = savvy_PlRExpr_cat_set_ordering__ffi(self__, c_arg__ordering);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_convert_time_zone__impl(SEXP self__, SEXP c_arg__time_zone) {
    SEXP res = savvy_PlRExpr_dt_convert_time_zone__ffi(self__, c_arg__time_zone);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_replace_time_zone__impl(SEXP self__, SEXP c_arg__ambiguous, SEXP c_arg__non_existent, SEXP c_arg__time_zone) {
    SEXP res = savvy_PlRExpr_dt_replace_time_zone__ffi(self__, c_arg__ambiguous, c_arg__non_existent, c_arg__time_zone);
    return handle_result(res);
}

SEXP savvy_PlRExpr_print__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_print__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_add__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_add__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sub__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_sub__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_mul__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_mul__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_div__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_div__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rem__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_rem__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_floor_div__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_floor_div__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_neg__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_neg__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_eq__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_eq__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_eq_missing__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_eq_missing__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_neq__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_neq__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_neq_missing__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_neq_missing__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_gt__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_gt__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_gt_eq__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_gt_eq__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_lt_eq__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_lt_eq__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_lt__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_lt__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_alias__impl(SEXP self__, SEXP c_arg__name) {
    SEXP res = savvy_PlRExpr_alias__ffi(self__, c_arg__name);
    return handle_result(res);
}

SEXP savvy_PlRExpr_not__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_not__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_null__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_null__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_not_null__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_not_null__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_infinite__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_infinite__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_finite__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_finite__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_nan__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_nan__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_not_nan__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_not_nan__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_min__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_max__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_max__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_nan_max__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_nan_max__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_nan_min__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_nan_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_mean__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_mean__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_median__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_median__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sum__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_sum__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cast__impl(SEXP self__, SEXP c_arg__dtype, SEXP c_arg__strict, SEXP c_arg__wrap_numerical) {
    SEXP res = savvy_PlRExpr_cast__ffi(self__, c_arg__dtype, c_arg__strict, c_arg__wrap_numerical);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sort_with__impl(SEXP self__, SEXP c_arg__descending, SEXP c_arg__nulls_last) {
    SEXP res = savvy_PlRExpr_sort_with__ffi(self__, c_arg__descending, c_arg__nulls_last);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arg_sort__impl(SEXP self__, SEXP c_arg__descending, SEXP c_arg__nulls_last) {
    SEXP res = savvy_PlRExpr_arg_sort__ffi(self__, c_arg__descending, c_arg__nulls_last);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sort_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__descending, SEXP c_arg__nulls_last, SEXP c_arg__multithreaded, SEXP c_arg__maintain_order) {
    SEXP res = savvy_PlRExpr_sort_by__ffi(self__, c_arg__by, c_arg__descending, c_arg__nulls_last, c_arg__multithreaded, c_arg__maintain_order);
    return handle_result(res);
}

SEXP savvy_PlRExpr_first__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_first__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_last__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_last__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_filter__impl(SEXP self__, SEXP c_arg__predicate) {
    SEXP res = savvy_PlRExpr_filter__ffi(self__, c_arg__predicate);
    return handle_result(res);
}

SEXP savvy_PlRExpr_reverse__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_reverse__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_slice__impl(SEXP self__, SEXP c_arg__offset, SEXP c_arg__length) {
    SEXP res = savvy_PlRExpr_slice__ffi(self__, c_arg__offset, c_arg__length);
    return handle_result(res);
}

SEXP savvy_PlRExpr_over__impl(SEXP self__, SEXP c_arg__partition_by, SEXP c_arg__order_by_descending, SEXP c_arg__order_by_nulls_last, SEXP c_arg__mapping_strategy, SEXP c_arg__order_by) {
    SEXP res = savvy_PlRExpr_over__ffi(self__, c_arg__partition_by, c_arg__order_by_descending, c_arg__order_by_nulls_last, c_arg__mapping_strategy, c_arg__order_by);
    return handle_result(res);
}

SEXP savvy_PlRExpr_and__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_and__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_or__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_or__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_xor__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_xor__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_pow__impl(SEXP self__, SEXP c_arg__exponent) {
    SEXP res = savvy_PlRExpr_pow__ffi(self__, c_arg__exponent);
    return handle_result(res);
}

SEXP savvy_PlRExpr_diff__impl(SEXP self__, SEXP c_arg__n, SEXP c_arg__null_behavior) {
    SEXP res = savvy_PlRExpr_diff__ffi(self__, c_arg__n, c_arg__null_behavior);
    return handle_result(res);
}

SEXP savvy_PlRExpr_reshape__impl(SEXP self__, SEXP c_arg__dimensions) {
    SEXP res = savvy_PlRExpr_reshape__ffi(self__, c_arg__dimensions);
    return handle_result(res);
}

SEXP savvy_PlRExpr_any__impl(SEXP self__, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_PlRExpr_any__ffi(self__, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_PlRExpr_all__impl(SEXP self__, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_PlRExpr_all__ffi(self__, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_PlRExpr_map_batches__impl(SEXP self__, SEXP c_arg__lambda, SEXP c_arg__agg_list, SEXP c_arg__output_type) {
    SEXP res = savvy_PlRExpr_map_batches__ffi(self__, c_arg__lambda, c_arg__agg_list, c_arg__output_type);
    return handle_result(res);
}

SEXP savvy_PlRExpr_meta_output_name__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_meta_output_name__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_meta_undo_aliases__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_meta_undo_aliases__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_meta_has_multiple_outputs__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_meta_has_multiple_outputs__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr__meta_selector_add__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr__meta_selector_add__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr__meta_selector_and__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr__meta_selector_and__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr__meta_selector_sub__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr__meta_selector_sub__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr__meta_as_selector__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr__meta_as_selector__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_name_keep__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_name_keep__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_name_prefix__impl(SEXP self__, SEXP c_arg__prefix) {
    SEXP res = savvy_PlRExpr_name_prefix__ffi(self__, c_arg__prefix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_name_suffix__impl(SEXP self__, SEXP c_arg__suffix) {
    SEXP res = savvy_PlRExpr_name_suffix__ffi(self__, c_arg__suffix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_name_to_lowercase__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_name_to_lowercase__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_name_to_uppercase__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_name_to_uppercase__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_name_prefix_fields__impl(SEXP self__, SEXP c_arg__prefix) {
    SEXP res = savvy_PlRExpr_name_prefix_fields__ffi(self__, c_arg__prefix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_name_suffix_fields__impl(SEXP self__, SEXP c_arg__suffix) {
    SEXP res = savvy_PlRExpr_name_suffix_fields__ffi(self__, c_arg__suffix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_serialize_binary__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_serialize_binary__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_serialize_json__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_serialize_json__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_deserialize_binary__impl(SEXP c_arg__data) {
    SEXP res = savvy_PlRExpr_deserialize_binary__ffi(c_arg__data);
    return handle_result(res);
}

SEXP savvy_PlRExpr_deserialize_json__impl(SEXP c_arg__data) {
    SEXP res = savvy_PlRExpr_deserialize_json__ffi(c_arg__data);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_len_bytes__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_len_bytes__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_len_chars__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_len_chars__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_join__impl(SEXP self__, SEXP c_arg__delimiter, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_PlRExpr_str_join__ffi(self__, c_arg__delimiter, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_to_uppercase__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_to_uppercase__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_to_lowercase__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_to_lowercase__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_strip_chars__impl(SEXP self__, SEXP c_arg__matches) {
    SEXP res = savvy_PlRExpr_str_strip_chars__ffi(self__, c_arg__matches);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_strip_chars_end__impl(SEXP self__, SEXP c_arg__matches) {
    SEXP res = savvy_PlRExpr_str_strip_chars_end__ffi(self__, c_arg__matches);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_strip_chars_start__impl(SEXP self__, SEXP c_arg__matches) {
    SEXP res = savvy_PlRExpr_str_strip_chars_start__ffi(self__, c_arg__matches);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_zfill__impl(SEXP self__, SEXP c_arg__alignment) {
    SEXP res = savvy_PlRExpr_str_zfill__ffi(self__, c_arg__alignment);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_pad_end__impl(SEXP self__, SEXP c_arg__width, SEXP c_arg__fillchar) {
    SEXP res = savvy_PlRExpr_str_pad_end__ffi(self__, c_arg__width, c_arg__fillchar);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_pad_start__impl(SEXP self__, SEXP c_arg__width, SEXP c_arg__fillchar) {
    SEXP res = savvy_PlRExpr_str_pad_start__ffi(self__, c_arg__width, c_arg__fillchar);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_contains__impl(SEXP self__, SEXP c_arg__pat, SEXP c_arg__literal, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_str_contains__ffi(self__, c_arg__pat, c_arg__literal, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_ends_with__impl(SEXP self__, SEXP c_arg__sub) {
    SEXP res = savvy_PlRExpr_str_ends_with__ffi(self__, c_arg__sub);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_starts_with__impl(SEXP self__, SEXP c_arg__sub) {
    SEXP res = savvy_PlRExpr_str_starts_with__ffi(self__, c_arg__sub);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_json_path_match__impl(SEXP self__, SEXP c_arg__pat) {
    SEXP res = savvy_PlRExpr_str_json_path_match__ffi(self__, c_arg__pat);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_hex_encode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_hex_encode__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_hex_decode__impl(SEXP self__, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_str_hex_decode__ffi(self__, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_base64_encode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_base64_encode__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_base64_decode__impl(SEXP self__, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_str_base64_decode__ffi(self__, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_extract__impl(SEXP self__, SEXP c_arg__pattern, SEXP c_arg__group_index) {
    SEXP res = savvy_PlRExpr_str_extract__ffi(self__, c_arg__pattern, c_arg__group_index);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_extract_all__impl(SEXP self__, SEXP c_arg__pattern) {
    SEXP res = savvy_PlRExpr_str_extract_all__ffi(self__, c_arg__pattern);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_extract_groups__impl(SEXP self__, SEXP c_arg__pattern) {
    SEXP res = savvy_PlRExpr_str_extract_groups__ffi(self__, c_arg__pattern);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_count_matches__impl(SEXP self__, SEXP c_arg__pat, SEXP c_arg__literal) {
    SEXP res = savvy_PlRExpr_str_count_matches__ffi(self__, c_arg__pat, c_arg__literal);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_split__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__inclusive) {
    SEXP res = savvy_PlRExpr_str_split__ffi(self__, c_arg__by, c_arg__inclusive);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_split_exact__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__n, SEXP c_arg__inclusive) {
    SEXP res = savvy_PlRExpr_str_split_exact__ffi(self__, c_arg__by, c_arg__n, c_arg__inclusive);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_splitn__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__n) {
    SEXP res = savvy_PlRExpr_str_splitn__ffi(self__, c_arg__by, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_replace__impl(SEXP self__, SEXP c_arg__pat, SEXP c_arg__value, SEXP c_arg__literal, SEXP c_arg__n) {
    SEXP res = savvy_PlRExpr_str_replace__ffi(self__, c_arg__pat, c_arg__value, c_arg__literal, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_replace_all__impl(SEXP self__, SEXP c_arg__pat, SEXP c_arg__value, SEXP c_arg__literal) {
    SEXP res = savvy_PlRExpr_str_replace_all__ffi(self__, c_arg__pat, c_arg__value, c_arg__literal);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_slice__impl(SEXP self__, SEXP c_arg__offset, SEXP c_arg__length) {
    SEXP res = savvy_PlRExpr_str_slice__ffi(self__, c_arg__offset, c_arg__length);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_to_integer__impl(SEXP self__, SEXP c_arg__base, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_str_to_integer__ffi(self__, c_arg__base, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_reverse__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_reverse__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_contains_any__impl(SEXP self__, SEXP c_arg__patterns, SEXP c_arg__ascii_case_insensitive) {
    SEXP res = savvy_PlRExpr_str_contains_any__ffi(self__, c_arg__patterns, c_arg__ascii_case_insensitive);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_replace_many__impl(SEXP self__, SEXP c_arg__patterns, SEXP c_arg__replace_with, SEXP c_arg__ascii_case_insensitive) {
    SEXP res = savvy_PlRExpr_str_replace_many__ffi(self__, c_arg__patterns, c_arg__replace_with, c_arg__ascii_case_insensitive);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_extract_many__impl(SEXP self__, SEXP c_arg__patterns, SEXP c_arg__ascii_case_insensitive, SEXP c_arg__overlapping) {
    SEXP res = savvy_PlRExpr_str_extract_many__ffi(self__, c_arg__patterns, c_arg__ascii_case_insensitive, c_arg__overlapping);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_find__impl(SEXP self__, SEXP c_arg__pat, SEXP c_arg__literal, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_str_find__ffi(self__, c_arg__pat, c_arg__literal, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_head__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRExpr_str_head__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_tail__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRExpr_str_tail__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRExpr_struct_field_by_index__impl(SEXP self__, SEXP c_arg__index) {
    SEXP res = savvy_PlRExpr_struct_field_by_index__ffi(self__, c_arg__index);
    return handle_result(res);
}

SEXP savvy_PlRExpr_struct_multiple_fields__impl(SEXP self__, SEXP c_arg__names) {
    SEXP res = savvy_PlRExpr_struct_multiple_fields__ffi(self__, c_arg__names);
    return handle_result(res);
}

SEXP savvy_PlRExpr_struct_rename_fields__impl(SEXP self__, SEXP c_arg__names) {
    SEXP res = savvy_PlRExpr_struct_rename_fields__ffi(self__, c_arg__names);
    return handle_result(res);
}

SEXP savvy_PlRExpr_struct_json_encode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_struct_json_encode__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_struct_with_fields__impl(SEXP self__, SEXP c_arg__fields) {
    SEXP res = savvy_PlRExpr_struct_with_fields__ffi(self__, c_arg__fields);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_describe_plan__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_describe_plan__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_describe_optimized_plan__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_describe_optimized_plan__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_describe_plan_tree__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_describe_plan_tree__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_describe_optimized_plan_tree__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_describe_optimized_plan_tree__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_optimization_toggle__impl(SEXP self__, SEXP c_arg__type_coercion, SEXP c_arg__predicate_pushdown, SEXP c_arg__projection_pushdown, SEXP c_arg__simplify_expression, SEXP c_arg__slice_pushdown, SEXP c_arg__comm_subplan_elim, SEXP c_arg__comm_subexpr_elim, SEXP c_arg__cluster_with_columns, SEXP c_arg__streaming, SEXP c_arg___eager) {
    SEXP res = savvy_PlRLazyFrame_optimization_toggle__ffi(self__, c_arg__type_coercion, c_arg__predicate_pushdown, c_arg__projection_pushdown, c_arg__simplify_expression, c_arg__slice_pushdown, c_arg__comm_subplan_elim, c_arg__comm_subexpr_elim, c_arg__cluster_with_columns, c_arg__streaming, c_arg___eager);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_filter__impl(SEXP self__, SEXP c_arg__predicate) {
    SEXP res = savvy_PlRLazyFrame_filter__ffi(self__, c_arg__predicate);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_select__impl(SEXP self__, SEXP c_arg__exprs) {
    SEXP res = savvy_PlRLazyFrame_select__ffi(self__, c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_group_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__maintain_order) {
    SEXP res = savvy_PlRLazyFrame_group_by__ffi(self__, c_arg__by, c_arg__maintain_order);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_collect__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_collect__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_slice__impl(SEXP self__, SEXP c_arg__offset, SEXP c_arg__len) {
    SEXP res = savvy_PlRLazyFrame_slice__ffi(self__, c_arg__offset, c_arg__len);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_tail__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRLazyFrame_tail__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_drop__impl(SEXP self__, SEXP c_arg__columns, SEXP c_arg__strict) {
    SEXP res = savvy_PlRLazyFrame_drop__ffi(self__, c_arg__columns, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_cast__impl(SEXP self__, SEXP c_arg__dtypes, SEXP c_arg__strict) {
    SEXP res = savvy_PlRLazyFrame_cast__ffi(self__, c_arg__dtypes, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_cast_all__impl(SEXP self__, SEXP c_arg__dtype, SEXP c_arg__strict) {
    SEXP res = savvy_PlRLazyFrame_cast_all__ffi(self__, c_arg__dtype, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_sort_by_exprs__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__descending, SEXP c_arg__nulls_last, SEXP c_arg__maintain_order, SEXP c_arg__multithreaded) {
    SEXP res = savvy_PlRLazyFrame_sort_by_exprs__ffi(self__, c_arg__by, c_arg__descending, c_arg__nulls_last, c_arg__maintain_order, c_arg__multithreaded);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_with_columns__impl(SEXP self__, SEXP c_arg__exprs) {
    SEXP res = savvy_PlRLazyFrame_with_columns__ffi(self__, c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_PlRLazyGroupBy_agg__impl(SEXP self__, SEXP c_arg__aggs) {
    SEXP res = savvy_PlRLazyGroupBy_agg__ffi(self__, c_arg__aggs);
    return handle_result(res);
}

SEXP savvy_PlRLazyGroupBy_head__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRLazyGroupBy_head__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRLazyGroupBy_tail__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRLazyGroupBy_tail__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRSeries_add__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRSeries_add__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRSeries_sub__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRSeries_sub__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRSeries_div__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRSeries_div__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRSeries_mul__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRSeries_mul__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRSeries_rem__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRSeries_rem__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_null__impl(SEXP c_arg__name, SEXP c_arg__length) {
    SEXP res = savvy_PlRSeries_new_null__ffi(c_arg__name, c_arg__length);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_f64__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_f64__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_i32__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_i32__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_i64__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_i64__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_bool__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_bool__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_str__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_str__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_single_binary__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_single_binary__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_binary__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_binary__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_series_list__impl(SEXP c_arg__name, SEXP c_arg__values, SEXP c_arg__strict) {
    SEXP res = savvy_PlRSeries_new_series_list__ffi(c_arg__name, c_arg__values, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_i64_from_clock_pair__impl(SEXP c_arg__name, SEXP c_arg__left, SEXP c_arg__right, SEXP c_arg__precision) {
    SEXP res = savvy_PlRSeries_new_i64_from_clock_pair__ffi(c_arg__name, c_arg__left, c_arg__right, c_arg__precision);
    return handle_result(res);
}

SEXP savvy_PlRSeries_to_r_vector__impl(SEXP self__, SEXP c_arg__ensure_vector, SEXP c_arg__int64, SEXP c_arg__date, SEXP c_arg__time, SEXP c_arg__struct, SEXP c_arg__decimal, SEXP c_arg__as_clock_class, SEXP c_arg__ambiguous, SEXP c_arg__non_existent, SEXP c_arg__local_time_zone) {
    SEXP res = savvy_PlRSeries_to_r_vector__ffi(self__, c_arg__ensure_vector, c_arg__int64, c_arg__date, c_arg__time, c_arg__struct, c_arg__decimal, c_arg__as_clock_class, c_arg__ambiguous, c_arg__non_existent, c_arg__local_time_zone);
    return handle_result(res);
}

SEXP savvy_PlRSeries_print__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_print__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_struct_unnest__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_struct_unnest__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_struct_fields__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_struct_fields__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_cat_uses_lexical_ordering__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_cat_uses_lexical_ordering__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_cat_is_local__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_cat_is_local__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_cat_to_local__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_cat_to_local__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_reshape__impl(SEXP self__, SEXP c_arg__dimensions) {
    SEXP res = savvy_PlRSeries_reshape__ffi(self__, c_arg__dimensions);
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

SEXP savvy_PlRSeries_rename__impl(SEXP self__, SEXP c_arg__name) {
    SEXP res = savvy_PlRSeries_rename__ffi(self__, c_arg__name);
    return handle_result(res);
}

SEXP savvy_PlRSeries_dtype__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_dtype__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_equals__impl(SEXP self__, SEXP c_arg__other, SEXP c_arg__check_dtypes, SEXP c_arg__check_names, SEXP c_arg__null_equal) {
    SEXP res = savvy_PlRSeries_equals__ffi(self__, c_arg__other, c_arg__check_dtypes, c_arg__check_names, c_arg__null_equal);
    return handle_result(res);
}

SEXP savvy_PlRSeries_len__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_len__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_cast__impl(SEXP self__, SEXP c_arg__dtype, SEXP c_arg__strict) {
    SEXP res = savvy_PlRSeries_cast__ffi(self__, c_arg__dtype, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRSeries_slice__impl(SEXP self__, SEXP c_arg__offset, SEXP c_arg__length) {
    SEXP res = savvy_PlRSeries_slice__ffi(self__, c_arg__offset, c_arg__length);
    return handle_result(res);
}

SEXP savvy_PlRThen_when__impl(SEXP self__, SEXP c_arg__condition) {
    SEXP res = savvy_PlRThen_when__ffi(self__, c_arg__condition);
    return handle_result(res);
}

SEXP savvy_PlRThen_otherwise__impl(SEXP self__, SEXP c_arg__statement) {
    SEXP res = savvy_PlRThen_otherwise__ffi(self__, c_arg__statement);
    return handle_result(res);
}

SEXP savvy_PlRWhen_then__impl(SEXP self__, SEXP c_arg__statement) {
    SEXP res = savvy_PlRWhen_then__ffi(self__, c_arg__statement);
    return handle_result(res);
}


static const R_CallMethodDef CallEntries[] = {
    {"savvy_concat_df__impl", (DL_FUNC) &savvy_concat_df__impl, 1},
    {"savvy_as_struct__impl", (DL_FUNC) &savvy_as_struct__impl, 1},
    {"savvy_field__impl", (DL_FUNC) &savvy_field__impl, 1},
    {"savvy_col__impl", (DL_FUNC) &savvy_col__impl, 1},
    {"savvy_cols__impl", (DL_FUNC) &savvy_cols__impl, 1},
    {"savvy_dtype_cols__impl", (DL_FUNC) &savvy_dtype_cols__impl, 1},
    {"savvy_lit_from_bool__impl", (DL_FUNC) &savvy_lit_from_bool__impl, 1},
    {"savvy_lit_from_i32__impl", (DL_FUNC) &savvy_lit_from_i32__impl, 1},
    {"savvy_lit_from_f64__impl", (DL_FUNC) &savvy_lit_from_f64__impl, 1},
    {"savvy_lit_from_str__impl", (DL_FUNC) &savvy_lit_from_str__impl, 1},
    {"savvy_lit_from_raw__impl", (DL_FUNC) &savvy_lit_from_raw__impl, 1},
    {"savvy_lit_null__impl", (DL_FUNC) &savvy_lit_null__impl, 0},
    {"savvy_lit_from_series__impl", (DL_FUNC) &savvy_lit_from_series__impl, 1},
    {"savvy_lit_from_series_first__impl", (DL_FUNC) &savvy_lit_from_series_first__impl, 1},
    {"savvy_when__impl", (DL_FUNC) &savvy_when__impl, 1},
    {"savvy_PlRChainedThen_when__impl", (DL_FUNC) &savvy_PlRChainedThen_when__impl, 2},
    {"savvy_PlRChainedThen_otherwise__impl", (DL_FUNC) &savvy_PlRChainedThen_otherwise__impl, 2},
    {"savvy_PlRChainedWhen_then__impl", (DL_FUNC) &savvy_PlRChainedWhen_then__impl, 2},
    {"savvy_PlRDataFrame_init__impl", (DL_FUNC) &savvy_PlRDataFrame_init__impl, 1},
    {"savvy_PlRDataFrame_print__impl", (DL_FUNC) &savvy_PlRDataFrame_print__impl, 1},
    {"savvy_PlRDataFrame_get_columns__impl", (DL_FUNC) &savvy_PlRDataFrame_get_columns__impl, 1},
    {"savvy_PlRDataFrame_slice__impl", (DL_FUNC) &savvy_PlRDataFrame_slice__impl, 3},
    {"savvy_PlRDataFrame_head__impl", (DL_FUNC) &savvy_PlRDataFrame_head__impl, 2},
    {"savvy_PlRDataFrame_tail__impl", (DL_FUNC) &savvy_PlRDataFrame_tail__impl, 2},
    {"savvy_PlRDataFrame_columns__impl", (DL_FUNC) &savvy_PlRDataFrame_columns__impl, 1},
    {"savvy_PlRDataFrame_set_column_names__impl", (DL_FUNC) &savvy_PlRDataFrame_set_column_names__impl, 2},
    {"savvy_PlRDataFrame_dtypes__impl", (DL_FUNC) &savvy_PlRDataFrame_dtypes__impl, 1},
    {"savvy_PlRDataFrame_shape__impl", (DL_FUNC) &savvy_PlRDataFrame_shape__impl, 1},
    {"savvy_PlRDataFrame_height__impl", (DL_FUNC) &savvy_PlRDataFrame_height__impl, 1},
    {"savvy_PlRDataFrame_width__impl", (DL_FUNC) &savvy_PlRDataFrame_width__impl, 1},
    {"savvy_PlRDataFrame_to_series__impl", (DL_FUNC) &savvy_PlRDataFrame_to_series__impl, 2},
    {"savvy_PlRDataFrame_equals__impl", (DL_FUNC) &savvy_PlRDataFrame_equals__impl, 3},
    {"savvy_PlRDataFrame_clone__impl", (DL_FUNC) &savvy_PlRDataFrame_clone__impl, 1},
    {"savvy_PlRDataFrame_lazy__impl", (DL_FUNC) &savvy_PlRDataFrame_lazy__impl, 1},
    {"savvy_PlRDataFrame_to_struct__impl", (DL_FUNC) &savvy_PlRDataFrame_to_struct__impl, 2},
    {"savvy_PlRDataType_new_from_name__impl", (DL_FUNC) &savvy_PlRDataType_new_from_name__impl, 1},
    {"savvy_PlRDataType_new_decimal__impl", (DL_FUNC) &savvy_PlRDataType_new_decimal__impl, 2},
    {"savvy_PlRDataType_new_datetime__impl", (DL_FUNC) &savvy_PlRDataType_new_datetime__impl, 2},
    {"savvy_PlRDataType_new_duration__impl", (DL_FUNC) &savvy_PlRDataType_new_duration__impl, 1},
    {"savvy_PlRDataType_new_categorical__impl", (DL_FUNC) &savvy_PlRDataType_new_categorical__impl, 1},
    {"savvy_PlRDataType_new_enum__impl", (DL_FUNC) &savvy_PlRDataType_new_enum__impl, 1},
    {"savvy_PlRDataType_new_list__impl", (DL_FUNC) &savvy_PlRDataType_new_list__impl, 1},
    {"savvy_PlRDataType_new_array__impl", (DL_FUNC) &savvy_PlRDataType_new_array__impl, 2},
    {"savvy_PlRDataType_new_struct__impl", (DL_FUNC) &savvy_PlRDataType_new_struct__impl, 1},
    {"savvy_PlRDataType_print__impl", (DL_FUNC) &savvy_PlRDataType_print__impl, 1},
    {"savvy_PlRDataType__get_datatype_fields__impl", (DL_FUNC) &savvy_PlRDataType__get_datatype_fields__impl, 1},
    {"savvy_PlRDataType_eq__impl", (DL_FUNC) &savvy_PlRDataType_eq__impl, 2},
    {"savvy_PlRDataType_ne__impl", (DL_FUNC) &savvy_PlRDataType_ne__impl, 2},
    {"savvy_PlRDataType_is_array__impl", (DL_FUNC) &savvy_PlRDataType_is_array__impl, 1},
    {"savvy_PlRDataType_is_binary__impl", (DL_FUNC) &savvy_PlRDataType_is_binary__impl, 1},
    {"savvy_PlRDataType_is_bool__impl", (DL_FUNC) &savvy_PlRDataType_is_bool__impl, 1},
    {"savvy_PlRDataType_is_categorical__impl", (DL_FUNC) &savvy_PlRDataType_is_categorical__impl, 1},
    {"savvy_PlRDataType_is_date__impl", (DL_FUNC) &savvy_PlRDataType_is_date__impl, 1},
    {"savvy_PlRDataType_is_enum__impl", (DL_FUNC) &savvy_PlRDataType_is_enum__impl, 1},
    {"savvy_PlRDataType_is_float__impl", (DL_FUNC) &savvy_PlRDataType_is_float__impl, 1},
    {"savvy_PlRDataType_is_integer__impl", (DL_FUNC) &savvy_PlRDataType_is_integer__impl, 1},
    {"savvy_PlRDataType_is_known__impl", (DL_FUNC) &savvy_PlRDataType_is_known__impl, 1},
    {"savvy_PlRDataType_is_list__impl", (DL_FUNC) &savvy_PlRDataType_is_list__impl, 1},
    {"savvy_PlRDataType_is_logical__impl", (DL_FUNC) &savvy_PlRDataType_is_logical__impl, 1},
    {"savvy_PlRDataType_is_nested__impl", (DL_FUNC) &savvy_PlRDataType_is_nested__impl, 1},
    {"savvy_PlRDataType_is_nested_null__impl", (DL_FUNC) &savvy_PlRDataType_is_nested_null__impl, 1},
    {"savvy_PlRDataType_is_null__impl", (DL_FUNC) &savvy_PlRDataType_is_null__impl, 1},
    {"savvy_PlRDataType_is_numeric__impl", (DL_FUNC) &savvy_PlRDataType_is_numeric__impl, 1},
    {"savvy_PlRDataType_is_ord__impl", (DL_FUNC) &savvy_PlRDataType_is_ord__impl, 1},
    {"savvy_PlRDataType_is_primitive__impl", (DL_FUNC) &savvy_PlRDataType_is_primitive__impl, 1},
    {"savvy_PlRDataType_is_signed_integer__impl", (DL_FUNC) &savvy_PlRDataType_is_signed_integer__impl, 1},
    {"savvy_PlRDataType_is_string__impl", (DL_FUNC) &savvy_PlRDataType_is_string__impl, 1},
    {"savvy_PlRDataType_is_struct__impl", (DL_FUNC) &savvy_PlRDataType_is_struct__impl, 1},
    {"savvy_PlRDataType_is_temporal__impl", (DL_FUNC) &savvy_PlRDataType_is_temporal__impl, 1},
    {"savvy_PlRDataType_is_unsigned_integer__impl", (DL_FUNC) &savvy_PlRDataType_is_unsigned_integer__impl, 1},
    {"savvy_PlRExpr_bin_contains__impl", (DL_FUNC) &savvy_PlRExpr_bin_contains__impl, 2},
    {"savvy_PlRExpr_bin_ends_with__impl", (DL_FUNC) &savvy_PlRExpr_bin_ends_with__impl, 2},
    {"savvy_PlRExpr_bin_starts_with__impl", (DL_FUNC) &savvy_PlRExpr_bin_starts_with__impl, 2},
    {"savvy_PlRExpr_bin_hex_decode__impl", (DL_FUNC) &savvy_PlRExpr_bin_hex_decode__impl, 2},
    {"savvy_PlRExpr_bin_base64_decode__impl", (DL_FUNC) &savvy_PlRExpr_bin_base64_decode__impl, 2},
    {"savvy_PlRExpr_bin_hex_encode__impl", (DL_FUNC) &savvy_PlRExpr_bin_hex_encode__impl, 1},
    {"savvy_PlRExpr_bin_base64_encode__impl", (DL_FUNC) &savvy_PlRExpr_bin_base64_encode__impl, 1},
    {"savvy_PlRExpr_bin_size_bytes__impl", (DL_FUNC) &savvy_PlRExpr_bin_size_bytes__impl, 1},
    {"savvy_PlRExpr_cat_get_categories__impl", (DL_FUNC) &savvy_PlRExpr_cat_get_categories__impl, 1},
    {"savvy_PlRExpr_cat_set_ordering__impl", (DL_FUNC) &savvy_PlRExpr_cat_set_ordering__impl, 2},
    {"savvy_PlRExpr_dt_convert_time_zone__impl", (DL_FUNC) &savvy_PlRExpr_dt_convert_time_zone__impl, 2},
    {"savvy_PlRExpr_dt_replace_time_zone__impl", (DL_FUNC) &savvy_PlRExpr_dt_replace_time_zone__impl, 4},
    {"savvy_PlRExpr_print__impl", (DL_FUNC) &savvy_PlRExpr_print__impl, 1},
    {"savvy_PlRExpr_add__impl", (DL_FUNC) &savvy_PlRExpr_add__impl, 2},
    {"savvy_PlRExpr_sub__impl", (DL_FUNC) &savvy_PlRExpr_sub__impl, 2},
    {"savvy_PlRExpr_mul__impl", (DL_FUNC) &savvy_PlRExpr_mul__impl, 2},
    {"savvy_PlRExpr_div__impl", (DL_FUNC) &savvy_PlRExpr_div__impl, 2},
    {"savvy_PlRExpr_rem__impl", (DL_FUNC) &savvy_PlRExpr_rem__impl, 2},
    {"savvy_PlRExpr_floor_div__impl", (DL_FUNC) &savvy_PlRExpr_floor_div__impl, 2},
    {"savvy_PlRExpr_neg__impl", (DL_FUNC) &savvy_PlRExpr_neg__impl, 1},
    {"savvy_PlRExpr_eq__impl", (DL_FUNC) &savvy_PlRExpr_eq__impl, 2},
    {"savvy_PlRExpr_eq_missing__impl", (DL_FUNC) &savvy_PlRExpr_eq_missing__impl, 2},
    {"savvy_PlRExpr_neq__impl", (DL_FUNC) &savvy_PlRExpr_neq__impl, 2},
    {"savvy_PlRExpr_neq_missing__impl", (DL_FUNC) &savvy_PlRExpr_neq_missing__impl, 2},
    {"savvy_PlRExpr_gt__impl", (DL_FUNC) &savvy_PlRExpr_gt__impl, 2},
    {"savvy_PlRExpr_gt_eq__impl", (DL_FUNC) &savvy_PlRExpr_gt_eq__impl, 2},
    {"savvy_PlRExpr_lt_eq__impl", (DL_FUNC) &savvy_PlRExpr_lt_eq__impl, 2},
    {"savvy_PlRExpr_lt__impl", (DL_FUNC) &savvy_PlRExpr_lt__impl, 2},
    {"savvy_PlRExpr_alias__impl", (DL_FUNC) &savvy_PlRExpr_alias__impl, 2},
    {"savvy_PlRExpr_not__impl", (DL_FUNC) &savvy_PlRExpr_not__impl, 1},
    {"savvy_PlRExpr_is_null__impl", (DL_FUNC) &savvy_PlRExpr_is_null__impl, 1},
    {"savvy_PlRExpr_is_not_null__impl", (DL_FUNC) &savvy_PlRExpr_is_not_null__impl, 1},
    {"savvy_PlRExpr_is_infinite__impl", (DL_FUNC) &savvy_PlRExpr_is_infinite__impl, 1},
    {"savvy_PlRExpr_is_finite__impl", (DL_FUNC) &savvy_PlRExpr_is_finite__impl, 1},
    {"savvy_PlRExpr_is_nan__impl", (DL_FUNC) &savvy_PlRExpr_is_nan__impl, 1},
    {"savvy_PlRExpr_is_not_nan__impl", (DL_FUNC) &savvy_PlRExpr_is_not_nan__impl, 1},
    {"savvy_PlRExpr_min__impl", (DL_FUNC) &savvy_PlRExpr_min__impl, 1},
    {"savvy_PlRExpr_max__impl", (DL_FUNC) &savvy_PlRExpr_max__impl, 1},
    {"savvy_PlRExpr_nan_max__impl", (DL_FUNC) &savvy_PlRExpr_nan_max__impl, 1},
    {"savvy_PlRExpr_nan_min__impl", (DL_FUNC) &savvy_PlRExpr_nan_min__impl, 1},
    {"savvy_PlRExpr_mean__impl", (DL_FUNC) &savvy_PlRExpr_mean__impl, 1},
    {"savvy_PlRExpr_median__impl", (DL_FUNC) &savvy_PlRExpr_median__impl, 1},
    {"savvy_PlRExpr_sum__impl", (DL_FUNC) &savvy_PlRExpr_sum__impl, 1},
    {"savvy_PlRExpr_cast__impl", (DL_FUNC) &savvy_PlRExpr_cast__impl, 4},
    {"savvy_PlRExpr_sort_with__impl", (DL_FUNC) &savvy_PlRExpr_sort_with__impl, 3},
    {"savvy_PlRExpr_arg_sort__impl", (DL_FUNC) &savvy_PlRExpr_arg_sort__impl, 3},
    {"savvy_PlRExpr_sort_by__impl", (DL_FUNC) &savvy_PlRExpr_sort_by__impl, 6},
    {"savvy_PlRExpr_first__impl", (DL_FUNC) &savvy_PlRExpr_first__impl, 1},
    {"savvy_PlRExpr_last__impl", (DL_FUNC) &savvy_PlRExpr_last__impl, 1},
    {"savvy_PlRExpr_filter__impl", (DL_FUNC) &savvy_PlRExpr_filter__impl, 2},
    {"savvy_PlRExpr_reverse__impl", (DL_FUNC) &savvy_PlRExpr_reverse__impl, 1},
    {"savvy_PlRExpr_slice__impl", (DL_FUNC) &savvy_PlRExpr_slice__impl, 3},
    {"savvy_PlRExpr_over__impl", (DL_FUNC) &savvy_PlRExpr_over__impl, 6},
    {"savvy_PlRExpr_and__impl", (DL_FUNC) &savvy_PlRExpr_and__impl, 2},
    {"savvy_PlRExpr_or__impl", (DL_FUNC) &savvy_PlRExpr_or__impl, 2},
    {"savvy_PlRExpr_xor__impl", (DL_FUNC) &savvy_PlRExpr_xor__impl, 2},
    {"savvy_PlRExpr_pow__impl", (DL_FUNC) &savvy_PlRExpr_pow__impl, 2},
    {"savvy_PlRExpr_diff__impl", (DL_FUNC) &savvy_PlRExpr_diff__impl, 3},
    {"savvy_PlRExpr_reshape__impl", (DL_FUNC) &savvy_PlRExpr_reshape__impl, 2},
    {"savvy_PlRExpr_any__impl", (DL_FUNC) &savvy_PlRExpr_any__impl, 2},
    {"savvy_PlRExpr_all__impl", (DL_FUNC) &savvy_PlRExpr_all__impl, 2},
    {"savvy_PlRExpr_map_batches__impl", (DL_FUNC) &savvy_PlRExpr_map_batches__impl, 4},
    {"savvy_PlRExpr_meta_output_name__impl", (DL_FUNC) &savvy_PlRExpr_meta_output_name__impl, 1},
    {"savvy_PlRExpr_meta_undo_aliases__impl", (DL_FUNC) &savvy_PlRExpr_meta_undo_aliases__impl, 1},
    {"savvy_PlRExpr_meta_has_multiple_outputs__impl", (DL_FUNC) &savvy_PlRExpr_meta_has_multiple_outputs__impl, 1},
    {"savvy_PlRExpr__meta_selector_add__impl", (DL_FUNC) &savvy_PlRExpr__meta_selector_add__impl, 2},
    {"savvy_PlRExpr__meta_selector_and__impl", (DL_FUNC) &savvy_PlRExpr__meta_selector_and__impl, 2},
    {"savvy_PlRExpr__meta_selector_sub__impl", (DL_FUNC) &savvy_PlRExpr__meta_selector_sub__impl, 2},
    {"savvy_PlRExpr__meta_as_selector__impl", (DL_FUNC) &savvy_PlRExpr__meta_as_selector__impl, 1},
    {"savvy_PlRExpr_name_keep__impl", (DL_FUNC) &savvy_PlRExpr_name_keep__impl, 1},
    {"savvy_PlRExpr_name_prefix__impl", (DL_FUNC) &savvy_PlRExpr_name_prefix__impl, 2},
    {"savvy_PlRExpr_name_suffix__impl", (DL_FUNC) &savvy_PlRExpr_name_suffix__impl, 2},
    {"savvy_PlRExpr_name_to_lowercase__impl", (DL_FUNC) &savvy_PlRExpr_name_to_lowercase__impl, 1},
    {"savvy_PlRExpr_name_to_uppercase__impl", (DL_FUNC) &savvy_PlRExpr_name_to_uppercase__impl, 1},
    {"savvy_PlRExpr_name_prefix_fields__impl", (DL_FUNC) &savvy_PlRExpr_name_prefix_fields__impl, 2},
    {"savvy_PlRExpr_name_suffix_fields__impl", (DL_FUNC) &savvy_PlRExpr_name_suffix_fields__impl, 2},
    {"savvy_PlRExpr_serialize_binary__impl", (DL_FUNC) &savvy_PlRExpr_serialize_binary__impl, 1},
    {"savvy_PlRExpr_serialize_json__impl", (DL_FUNC) &savvy_PlRExpr_serialize_json__impl, 1},
    {"savvy_PlRExpr_deserialize_binary__impl", (DL_FUNC) &savvy_PlRExpr_deserialize_binary__impl, 1},
    {"savvy_PlRExpr_deserialize_json__impl", (DL_FUNC) &savvy_PlRExpr_deserialize_json__impl, 1},
    {"savvy_PlRExpr_str_len_bytes__impl", (DL_FUNC) &savvy_PlRExpr_str_len_bytes__impl, 1},
    {"savvy_PlRExpr_str_len_chars__impl", (DL_FUNC) &savvy_PlRExpr_str_len_chars__impl, 1},
    {"savvy_PlRExpr_str_join__impl", (DL_FUNC) &savvy_PlRExpr_str_join__impl, 3},
    {"savvy_PlRExpr_str_to_uppercase__impl", (DL_FUNC) &savvy_PlRExpr_str_to_uppercase__impl, 1},
    {"savvy_PlRExpr_str_to_lowercase__impl", (DL_FUNC) &savvy_PlRExpr_str_to_lowercase__impl, 1},
    {"savvy_PlRExpr_str_strip_chars__impl", (DL_FUNC) &savvy_PlRExpr_str_strip_chars__impl, 2},
    {"savvy_PlRExpr_str_strip_chars_end__impl", (DL_FUNC) &savvy_PlRExpr_str_strip_chars_end__impl, 2},
    {"savvy_PlRExpr_str_strip_chars_start__impl", (DL_FUNC) &savvy_PlRExpr_str_strip_chars_start__impl, 2},
    {"savvy_PlRExpr_str_zfill__impl", (DL_FUNC) &savvy_PlRExpr_str_zfill__impl, 2},
    {"savvy_PlRExpr_str_pad_end__impl", (DL_FUNC) &savvy_PlRExpr_str_pad_end__impl, 3},
    {"savvy_PlRExpr_str_pad_start__impl", (DL_FUNC) &savvy_PlRExpr_str_pad_start__impl, 3},
    {"savvy_PlRExpr_str_contains__impl", (DL_FUNC) &savvy_PlRExpr_str_contains__impl, 4},
    {"savvy_PlRExpr_str_ends_with__impl", (DL_FUNC) &savvy_PlRExpr_str_ends_with__impl, 2},
    {"savvy_PlRExpr_str_starts_with__impl", (DL_FUNC) &savvy_PlRExpr_str_starts_with__impl, 2},
    {"savvy_PlRExpr_str_json_path_match__impl", (DL_FUNC) &savvy_PlRExpr_str_json_path_match__impl, 2},
    {"savvy_PlRExpr_str_hex_encode__impl", (DL_FUNC) &savvy_PlRExpr_str_hex_encode__impl, 1},
    {"savvy_PlRExpr_str_hex_decode__impl", (DL_FUNC) &savvy_PlRExpr_str_hex_decode__impl, 2},
    {"savvy_PlRExpr_str_base64_encode__impl", (DL_FUNC) &savvy_PlRExpr_str_base64_encode__impl, 1},
    {"savvy_PlRExpr_str_base64_decode__impl", (DL_FUNC) &savvy_PlRExpr_str_base64_decode__impl, 2},
    {"savvy_PlRExpr_str_extract__impl", (DL_FUNC) &savvy_PlRExpr_str_extract__impl, 3},
    {"savvy_PlRExpr_str_extract_all__impl", (DL_FUNC) &savvy_PlRExpr_str_extract_all__impl, 2},
    {"savvy_PlRExpr_str_extract_groups__impl", (DL_FUNC) &savvy_PlRExpr_str_extract_groups__impl, 2},
    {"savvy_PlRExpr_str_count_matches__impl", (DL_FUNC) &savvy_PlRExpr_str_count_matches__impl, 3},
    {"savvy_PlRExpr_str_split__impl", (DL_FUNC) &savvy_PlRExpr_str_split__impl, 3},
    {"savvy_PlRExpr_str_split_exact__impl", (DL_FUNC) &savvy_PlRExpr_str_split_exact__impl, 4},
    {"savvy_PlRExpr_str_splitn__impl", (DL_FUNC) &savvy_PlRExpr_str_splitn__impl, 3},
    {"savvy_PlRExpr_str_replace__impl", (DL_FUNC) &savvy_PlRExpr_str_replace__impl, 5},
    {"savvy_PlRExpr_str_replace_all__impl", (DL_FUNC) &savvy_PlRExpr_str_replace_all__impl, 4},
    {"savvy_PlRExpr_str_slice__impl", (DL_FUNC) &savvy_PlRExpr_str_slice__impl, 3},
    {"savvy_PlRExpr_str_to_integer__impl", (DL_FUNC) &savvy_PlRExpr_str_to_integer__impl, 3},
    {"savvy_PlRExpr_str_reverse__impl", (DL_FUNC) &savvy_PlRExpr_str_reverse__impl, 1},
    {"savvy_PlRExpr_str_contains_any__impl", (DL_FUNC) &savvy_PlRExpr_str_contains_any__impl, 3},
    {"savvy_PlRExpr_str_replace_many__impl", (DL_FUNC) &savvy_PlRExpr_str_replace_many__impl, 4},
    {"savvy_PlRExpr_str_extract_many__impl", (DL_FUNC) &savvy_PlRExpr_str_extract_many__impl, 4},
    {"savvy_PlRExpr_str_find__impl", (DL_FUNC) &savvy_PlRExpr_str_find__impl, 4},
    {"savvy_PlRExpr_str_head__impl", (DL_FUNC) &savvy_PlRExpr_str_head__impl, 2},
    {"savvy_PlRExpr_str_tail__impl", (DL_FUNC) &savvy_PlRExpr_str_tail__impl, 2},
    {"savvy_PlRExpr_struct_field_by_index__impl", (DL_FUNC) &savvy_PlRExpr_struct_field_by_index__impl, 2},
    {"savvy_PlRExpr_struct_multiple_fields__impl", (DL_FUNC) &savvy_PlRExpr_struct_multiple_fields__impl, 2},
    {"savvy_PlRExpr_struct_rename_fields__impl", (DL_FUNC) &savvy_PlRExpr_struct_rename_fields__impl, 2},
    {"savvy_PlRExpr_struct_json_encode__impl", (DL_FUNC) &savvy_PlRExpr_struct_json_encode__impl, 1},
    {"savvy_PlRExpr_struct_with_fields__impl", (DL_FUNC) &savvy_PlRExpr_struct_with_fields__impl, 2},
    {"savvy_PlRLazyFrame_describe_plan__impl", (DL_FUNC) &savvy_PlRLazyFrame_describe_plan__impl, 1},
    {"savvy_PlRLazyFrame_describe_optimized_plan__impl", (DL_FUNC) &savvy_PlRLazyFrame_describe_optimized_plan__impl, 1},
    {"savvy_PlRLazyFrame_describe_plan_tree__impl", (DL_FUNC) &savvy_PlRLazyFrame_describe_plan_tree__impl, 1},
    {"savvy_PlRLazyFrame_describe_optimized_plan_tree__impl", (DL_FUNC) &savvy_PlRLazyFrame_describe_optimized_plan_tree__impl, 1},
    {"savvy_PlRLazyFrame_optimization_toggle__impl", (DL_FUNC) &savvy_PlRLazyFrame_optimization_toggle__impl, 11},
    {"savvy_PlRLazyFrame_filter__impl", (DL_FUNC) &savvy_PlRLazyFrame_filter__impl, 2},
    {"savvy_PlRLazyFrame_select__impl", (DL_FUNC) &savvy_PlRLazyFrame_select__impl, 2},
    {"savvy_PlRLazyFrame_group_by__impl", (DL_FUNC) &savvy_PlRLazyFrame_group_by__impl, 3},
    {"savvy_PlRLazyFrame_collect__impl", (DL_FUNC) &savvy_PlRLazyFrame_collect__impl, 1},
    {"savvy_PlRLazyFrame_slice__impl", (DL_FUNC) &savvy_PlRLazyFrame_slice__impl, 3},
    {"savvy_PlRLazyFrame_tail__impl", (DL_FUNC) &savvy_PlRLazyFrame_tail__impl, 2},
    {"savvy_PlRLazyFrame_drop__impl", (DL_FUNC) &savvy_PlRLazyFrame_drop__impl, 3},
    {"savvy_PlRLazyFrame_cast__impl", (DL_FUNC) &savvy_PlRLazyFrame_cast__impl, 3},
    {"savvy_PlRLazyFrame_cast_all__impl", (DL_FUNC) &savvy_PlRLazyFrame_cast_all__impl, 3},
    {"savvy_PlRLazyFrame_sort_by_exprs__impl", (DL_FUNC) &savvy_PlRLazyFrame_sort_by_exprs__impl, 6},
    {"savvy_PlRLazyFrame_with_columns__impl", (DL_FUNC) &savvy_PlRLazyFrame_with_columns__impl, 2},
    {"savvy_PlRLazyGroupBy_agg__impl", (DL_FUNC) &savvy_PlRLazyGroupBy_agg__impl, 2},
    {"savvy_PlRLazyGroupBy_head__impl", (DL_FUNC) &savvy_PlRLazyGroupBy_head__impl, 2},
    {"savvy_PlRLazyGroupBy_tail__impl", (DL_FUNC) &savvy_PlRLazyGroupBy_tail__impl, 2},
    {"savvy_PlRSeries_add__impl", (DL_FUNC) &savvy_PlRSeries_add__impl, 2},
    {"savvy_PlRSeries_sub__impl", (DL_FUNC) &savvy_PlRSeries_sub__impl, 2},
    {"savvy_PlRSeries_div__impl", (DL_FUNC) &savvy_PlRSeries_div__impl, 2},
    {"savvy_PlRSeries_mul__impl", (DL_FUNC) &savvy_PlRSeries_mul__impl, 2},
    {"savvy_PlRSeries_rem__impl", (DL_FUNC) &savvy_PlRSeries_rem__impl, 2},
    {"savvy_PlRSeries_new_null__impl", (DL_FUNC) &savvy_PlRSeries_new_null__impl, 2},
    {"savvy_PlRSeries_new_f64__impl", (DL_FUNC) &savvy_PlRSeries_new_f64__impl, 2},
    {"savvy_PlRSeries_new_i32__impl", (DL_FUNC) &savvy_PlRSeries_new_i32__impl, 2},
    {"savvy_PlRSeries_new_i64__impl", (DL_FUNC) &savvy_PlRSeries_new_i64__impl, 2},
    {"savvy_PlRSeries_new_bool__impl", (DL_FUNC) &savvy_PlRSeries_new_bool__impl, 2},
    {"savvy_PlRSeries_new_str__impl", (DL_FUNC) &savvy_PlRSeries_new_str__impl, 2},
    {"savvy_PlRSeries_new_single_binary__impl", (DL_FUNC) &savvy_PlRSeries_new_single_binary__impl, 2},
    {"savvy_PlRSeries_new_binary__impl", (DL_FUNC) &savvy_PlRSeries_new_binary__impl, 2},
    {"savvy_PlRSeries_new_series_list__impl", (DL_FUNC) &savvy_PlRSeries_new_series_list__impl, 3},
    {"savvy_PlRSeries_new_i64_from_clock_pair__impl", (DL_FUNC) &savvy_PlRSeries_new_i64_from_clock_pair__impl, 4},
    {"savvy_PlRSeries_to_r_vector__impl", (DL_FUNC) &savvy_PlRSeries_to_r_vector__impl, 11},
    {"savvy_PlRSeries_print__impl", (DL_FUNC) &savvy_PlRSeries_print__impl, 1},
    {"savvy_PlRSeries_struct_unnest__impl", (DL_FUNC) &savvy_PlRSeries_struct_unnest__impl, 1},
    {"savvy_PlRSeries_struct_fields__impl", (DL_FUNC) &savvy_PlRSeries_struct_fields__impl, 1},
    {"savvy_PlRSeries_cat_uses_lexical_ordering__impl", (DL_FUNC) &savvy_PlRSeries_cat_uses_lexical_ordering__impl, 1},
    {"savvy_PlRSeries_cat_is_local__impl", (DL_FUNC) &savvy_PlRSeries_cat_is_local__impl, 1},
    {"savvy_PlRSeries_cat_to_local__impl", (DL_FUNC) &savvy_PlRSeries_cat_to_local__impl, 1},
    {"savvy_PlRSeries_reshape__impl", (DL_FUNC) &savvy_PlRSeries_reshape__impl, 2},
    {"savvy_PlRSeries_clone__impl", (DL_FUNC) &savvy_PlRSeries_clone__impl, 1},
    {"savvy_PlRSeries_name__impl", (DL_FUNC) &savvy_PlRSeries_name__impl, 1},
    {"savvy_PlRSeries_rename__impl", (DL_FUNC) &savvy_PlRSeries_rename__impl, 2},
    {"savvy_PlRSeries_dtype__impl", (DL_FUNC) &savvy_PlRSeries_dtype__impl, 1},
    {"savvy_PlRSeries_equals__impl", (DL_FUNC) &savvy_PlRSeries_equals__impl, 5},
    {"savvy_PlRSeries_len__impl", (DL_FUNC) &savvy_PlRSeries_len__impl, 1},
    {"savvy_PlRSeries_cast__impl", (DL_FUNC) &savvy_PlRSeries_cast__impl, 3},
    {"savvy_PlRSeries_slice__impl", (DL_FUNC) &savvy_PlRSeries_slice__impl, 3},
    {"savvy_PlRThen_when__impl", (DL_FUNC) &savvy_PlRThen_when__impl, 2},
    {"savvy_PlRThen_otherwise__impl", (DL_FUNC) &savvy_PlRThen_otherwise__impl, 2},
    {"savvy_PlRWhen_then__impl", (DL_FUNC) &savvy_PlRWhen_then__impl, 2},
    {NULL, NULL, 0}
};

void R_init_neopolars(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);

    // Functions for initialzation, if any.

}
