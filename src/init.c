
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

SEXP savvy_all_horizontal__impl(SEXP c_arg__exprs) {
    SEXP res = savvy_all_horizontal__ffi(c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_any_horizontal__impl(SEXP c_arg__exprs) {
    SEXP res = savvy_any_horizontal__ffi(c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_arg_where__impl(SEXP c_arg__condition) {
    SEXP res = savvy_arg_where__ffi(c_arg__condition);
    return handle_result(res);
}

SEXP savvy_as_struct__impl(SEXP c_arg__exprs) {
    SEXP res = savvy_as_struct__ffi(c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_coalesce__impl(SEXP c_arg__exprs) {
    SEXP res = savvy_coalesce__ffi(c_arg__exprs);
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

SEXP savvy_concat_df__impl(SEXP c_arg__dfs) {
    SEXP res = savvy_concat_df__ffi(c_arg__dfs);
    return handle_result(res);
}

SEXP savvy_concat_df_diagonal__impl(SEXP c_arg__dfs) {
    SEXP res = savvy_concat_df_diagonal__ffi(c_arg__dfs);
    return handle_result(res);
}

SEXP savvy_concat_df_horizontal__impl(SEXP c_arg__dfs) {
    SEXP res = savvy_concat_df_horizontal__ffi(c_arg__dfs);
    return handle_result(res);
}

SEXP savvy_concat_lf__impl(SEXP c_arg__lfs, SEXP c_arg__rechunk, SEXP c_arg__parallel, SEXP c_arg__to_supertypes) {
    SEXP res = savvy_concat_lf__ffi(c_arg__lfs, c_arg__rechunk, c_arg__parallel, c_arg__to_supertypes);
    return handle_result(res);
}

SEXP savvy_concat_lf_diagonal__impl(SEXP c_arg__lfs, SEXP c_arg__rechunk, SEXP c_arg__parallel, SEXP c_arg__to_supertypes) {
    SEXP res = savvy_concat_lf_diagonal__ffi(c_arg__lfs, c_arg__rechunk, c_arg__parallel, c_arg__to_supertypes);
    return handle_result(res);
}

SEXP savvy_concat_lf_horizontal__impl(SEXP c_arg__lfs, SEXP c_arg__parallel) {
    SEXP res = savvy_concat_lf_horizontal__ffi(c_arg__lfs, c_arg__parallel);
    return handle_result(res);
}

SEXP savvy_concat_list__impl(SEXP c_arg__s) {
    SEXP res = savvy_concat_list__ffi(c_arg__s);
    return handle_result(res);
}

SEXP savvy_concat_series__impl(SEXP c_arg__series) {
    SEXP res = savvy_concat_series__ffi(c_arg__series);
    return handle_result(res);
}

SEXP savvy_concat_str__impl(SEXP c_arg__s, SEXP c_arg__separator, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_concat_str__ffi(c_arg__s, c_arg__separator, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_date_range__impl(SEXP c_arg__start, SEXP c_arg__end, SEXP c_arg__interval, SEXP c_arg__closed) {
    SEXP res = savvy_date_range__ffi(c_arg__start, c_arg__end, c_arg__interval, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_date_ranges__impl(SEXP c_arg__start, SEXP c_arg__end, SEXP c_arg__interval, SEXP c_arg__closed) {
    SEXP res = savvy_date_ranges__ffi(c_arg__start, c_arg__end, c_arg__interval, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_datetime__impl(SEXP c_arg__year, SEXP c_arg__month, SEXP c_arg__day, SEXP c_arg__time_unit, SEXP c_arg__ambiguous, SEXP c_arg__hour, SEXP c_arg__minute, SEXP c_arg__second, SEXP c_arg__microsecond, SEXP c_arg__time_zone) {
    SEXP res = savvy_datetime__ffi(c_arg__year, c_arg__month, c_arg__day, c_arg__time_unit, c_arg__ambiguous, c_arg__hour, c_arg__minute, c_arg__second, c_arg__microsecond, c_arg__time_zone);
    return handle_result(res);
}

SEXP savvy_datetime_range__impl(SEXP c_arg__start, SEXP c_arg__end, SEXP c_arg__every, SEXP c_arg__closed, SEXP c_arg__time_unit, SEXP c_arg__time_zone) {
    SEXP res = savvy_datetime_range__ffi(c_arg__start, c_arg__end, c_arg__every, c_arg__closed, c_arg__time_unit, c_arg__time_zone);
    return handle_result(res);
}

SEXP savvy_datetime_ranges__impl(SEXP c_arg__start, SEXP c_arg__end, SEXP c_arg__every, SEXP c_arg__closed, SEXP c_arg__time_unit, SEXP c_arg__time_zone) {
    SEXP res = savvy_datetime_ranges__ffi(c_arg__start, c_arg__end, c_arg__every, c_arg__closed, c_arg__time_unit, c_arg__time_zone);
    return handle_result(res);
}

SEXP savvy_dtype_cols__impl(SEXP c_arg__dtypes) {
    SEXP res = savvy_dtype_cols__ffi(c_arg__dtypes);
    return handle_result(res);
}

SEXP savvy_duration__impl(SEXP c_arg__time_unit, SEXP c_arg__weeks, SEXP c_arg__days, SEXP c_arg__hours, SEXP c_arg__minutes, SEXP c_arg__seconds, SEXP c_arg__milliseconds, SEXP c_arg__microseconds, SEXP c_arg__nanoseconds) {
    SEXP res = savvy_duration__ffi(c_arg__time_unit, c_arg__weeks, c_arg__days, c_arg__hours, c_arg__minutes, c_arg__seconds, c_arg__milliseconds, c_arg__microseconds, c_arg__nanoseconds);
    return handle_result(res);
}

SEXP savvy_field__impl(SEXP c_arg__names) {
    SEXP res = savvy_field__ffi(c_arg__names);
    return handle_result(res);
}

SEXP savvy_first__impl(void) {
    SEXP res = savvy_first__ffi();
    return handle_result(res);
}

SEXP savvy_index_cols__impl(SEXP c_arg__indices) {
    SEXP res = savvy_index_cols__ffi(c_arg__indices);
    return handle_result(res);
}

SEXP savvy_int_range__impl(SEXP c_arg__start, SEXP c_arg__end, SEXP c_arg__step, SEXP c_arg__dtype) {
    SEXP res = savvy_int_range__ffi(c_arg__start, c_arg__end, c_arg__step, c_arg__dtype);
    return handle_result(res);
}

SEXP savvy_int_ranges__impl(SEXP c_arg__start, SEXP c_arg__end, SEXP c_arg__step, SEXP c_arg__dtype) {
    SEXP res = savvy_int_ranges__ffi(c_arg__start, c_arg__end, c_arg__step, c_arg__dtype);
    return handle_result(res);
}

SEXP savvy_last__impl(void) {
    SEXP res = savvy_last__ffi();
    return handle_result(res);
}

SEXP savvy_len__impl(void) {
    SEXP res = savvy_len__ffi();
    return handle_result(res);
}

SEXP savvy_lit_from_bool__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_bool__ffi(c_arg__value);
    return handle_result(res);
}

SEXP savvy_lit_from_f64__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_f64__ffi(c_arg__value);
    return handle_result(res);
}

SEXP savvy_lit_from_i32__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_i32__ffi(c_arg__value);
    return handle_result(res);
}

SEXP savvy_lit_from_raw__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_raw__ffi(c_arg__value);
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

SEXP savvy_lit_from_str__impl(SEXP c_arg__value) {
    SEXP res = savvy_lit_from_str__ffi(c_arg__value);
    return handle_result(res);
}

SEXP savvy_lit_null__impl(void) {
    SEXP res = savvy_lit_null__ffi();
    return handle_result(res);
}

SEXP savvy_max_horizontal__impl(SEXP c_arg__exprs) {
    SEXP res = savvy_max_horizontal__ffi(c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_mean_horizontal__impl(SEXP c_arg__exprs, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_mean_horizontal__ffi(c_arg__exprs, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_min_horizontal__impl(SEXP c_arg__exprs) {
    SEXP res = savvy_min_horizontal__ffi(c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_repeat___impl(SEXP c_arg__value, SEXP c_arg__n, SEXP c_arg__dtype) {
    SEXP res = savvy_repeat___ffi(c_arg__value, c_arg__n, c_arg__dtype);
    return handle_result(res);
}

SEXP savvy_sum_horizontal__impl(SEXP c_arg__exprs, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_sum_horizontal__ffi(c_arg__exprs, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_time_range__impl(SEXP c_arg__start, SEXP c_arg__end, SEXP c_arg__every, SEXP c_arg__closed) {
    SEXP res = savvy_time_range__ffi(c_arg__start, c_arg__end, c_arg__every, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_time_ranges__impl(SEXP c_arg__start, SEXP c_arg__end, SEXP c_arg__every, SEXP c_arg__closed) {
    SEXP res = savvy_time_ranges__ffi(c_arg__start, c_arg__end, c_arg__every, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_when__impl(SEXP c_arg__condition) {
    SEXP res = savvy_when__ffi(c_arg__condition);
    return handle_result(res);
}

SEXP savvy_PlRChainedThen_otherwise__impl(SEXP self__, SEXP c_arg__statement) {
    SEXP res = savvy_PlRChainedThen_otherwise__ffi(self__, c_arg__statement);
    return handle_result(res);
}

SEXP savvy_PlRChainedThen_when__impl(SEXP self__, SEXP c_arg__condition) {
    SEXP res = savvy_PlRChainedThen_when__ffi(self__, c_arg__condition);
    return handle_result(res);
}

SEXP savvy_PlRChainedWhen_then__impl(SEXP self__, SEXP c_arg__statement) {
    SEXP res = savvy_PlRChainedWhen_then__ffi(self__, c_arg__statement);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_as_str__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_as_str__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_clear__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_clear__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_clone__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_clone__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_columns__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_columns__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_dtypes__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_dtypes__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_equals__impl(SEXP self__, SEXP c_arg__other, SEXP c_arg__null_equal) {
    SEXP res = savvy_PlRDataFrame_equals__ffi(self__, c_arg__other, c_arg__null_equal);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_get_column__impl(SEXP self__, SEXP c_arg__name) {
    SEXP res = savvy_PlRDataFrame_get_column__ffi(self__, c_arg__name);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_get_column_index__impl(SEXP self__, SEXP c_arg__name) {
    SEXP res = savvy_PlRDataFrame_get_column_index__ffi(self__, c_arg__name);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_get_columns__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_get_columns__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_head__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRDataFrame_head__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_height__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_height__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_init__impl(SEXP c_arg__columns) {
    SEXP res = savvy_PlRDataFrame_init__ffi(c_arg__columns);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_is_duplicated__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_is_duplicated__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_is_empty__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_is_empty__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_is_unique__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_is_unique__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_lazy__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_lazy__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_n_chunks__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_n_chunks__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_partition_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__maintain_order, SEXP c_arg__include_key) {
    SEXP res = savvy_PlRDataFrame_partition_by__ffi(self__, c_arg__by, c_arg__maintain_order, c_arg__include_key);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_pivot_expr__impl(SEXP self__, SEXP c_arg__on, SEXP c_arg__maintain_order, SEXP c_arg__sort_columns, SEXP c_arg__aggregate_expr, SEXP c_arg__separator, SEXP c_arg__index, SEXP c_arg__values) {
    SEXP res = savvy_PlRDataFrame_pivot_expr__ffi(self__, c_arg__on, c_arg__maintain_order, c_arg__sort_columns, c_arg__aggregate_expr, c_arg__separator, c_arg__index, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_read_ipc_stream__impl(SEXP c_arg__source, SEXP c_arg__row_index_offset, SEXP c_arg__rechunk, SEXP c_arg__columns, SEXP c_arg__projection, SEXP c_arg__n_rows, SEXP c_arg__row_index_name) {
    SEXP res = savvy_PlRDataFrame_read_ipc_stream__ffi(c_arg__source, c_arg__row_index_offset, c_arg__rechunk, c_arg__columns, c_arg__projection, c_arg__n_rows, c_arg__row_index_name);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_rechunk__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_rechunk__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_sample_frac__impl(SEXP self__, SEXP c_arg__frac, SEXP c_arg__with_replacement, SEXP c_arg__shuffle, SEXP c_arg__seed) {
    SEXP res = savvy_PlRDataFrame_sample_frac__ffi(self__, c_arg__frac, c_arg__with_replacement, c_arg__shuffle, c_arg__seed);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_sample_n__impl(SEXP self__, SEXP c_arg__n, SEXP c_arg__with_replacement, SEXP c_arg__shuffle, SEXP c_arg__seed) {
    SEXP res = savvy_PlRDataFrame_sample_n__ffi(self__, c_arg__n, c_arg__with_replacement, c_arg__shuffle, c_arg__seed);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_set_column_names__impl(SEXP self__, SEXP c_arg__names) {
    SEXP res = savvy_PlRDataFrame_set_column_names__ffi(self__, c_arg__names);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_shape__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_shape__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_slice__impl(SEXP self__, SEXP c_arg__offset, SEXP c_arg__length) {
    SEXP res = savvy_PlRDataFrame_slice__ffi(self__, c_arg__offset, c_arg__length);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_tail__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRDataFrame_tail__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_to_dummies__impl(SEXP self__, SEXP c_arg__drop_first, SEXP c_arg__columns, SEXP c_arg__separator) {
    SEXP res = savvy_PlRDataFrame_to_dummies__ffi(self__, c_arg__drop_first, c_arg__columns, c_arg__separator);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_to_series__impl(SEXP self__, SEXP c_arg__index) {
    SEXP res = savvy_PlRDataFrame_to_series__ffi(self__, c_arg__index);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_to_struct__impl(SEXP self__, SEXP c_arg__name) {
    SEXP res = savvy_PlRDataFrame_to_struct__ffi(self__, c_arg__name);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_transpose__impl(SEXP self__, SEXP c_arg__column_names, SEXP c_arg__keep_names_as) {
    SEXP res = savvy_PlRDataFrame_transpose__ffi(self__, c_arg__column_names, c_arg__keep_names_as);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_unpivot__impl(SEXP self__, SEXP c_arg__on, SEXP c_arg__index, SEXP c_arg__value_name, SEXP c_arg__variable_name) {
    SEXP res = savvy_PlRDataFrame_unpivot__ffi(self__, c_arg__on, c_arg__index, c_arg__value_name, c_arg__variable_name);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_width__impl(SEXP self__) {
    SEXP res = savvy_PlRDataFrame_width__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_with_row_index__impl(SEXP self__, SEXP c_arg__name, SEXP c_arg__offset) {
    SEXP res = savvy_PlRDataFrame_with_row_index__ffi(self__, c_arg__name, c_arg__offset);
    return handle_result(res);
}

SEXP savvy_PlRDataFrame_write_parquet__impl(SEXP self__, SEXP c_arg__path, SEXP c_arg__compression, SEXP c_arg__retries, SEXP c_arg__partition_chunk_size_bytes, SEXP c_arg__stat_min, SEXP c_arg__stat_max, SEXP c_arg__stat_distinct_count, SEXP c_arg__stat_null_count, SEXP c_arg__compression_level, SEXP c_arg__row_group_size, SEXP c_arg__data_page_size, SEXP c_arg__partition_by, SEXP c_arg__storage_options) {
    SEXP res = savvy_PlRDataFrame_write_parquet__ffi(self__, c_arg__path, c_arg__compression, c_arg__retries, c_arg__partition_chunk_size_bytes, c_arg__stat_min, c_arg__stat_max, c_arg__stat_distinct_count, c_arg__stat_null_count, c_arg__compression_level, c_arg__row_group_size, c_arg__data_page_size, c_arg__partition_by, c_arg__storage_options);
    return handle_result(res);
}

SEXP savvy_PlRDataType__get_datatype_fields__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType__get_datatype_fields__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType__get_dtype_names__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType__get_dtype_names__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_as_str__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_as_str__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_eq__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRDataType_eq__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRDataType_infer_supertype__impl(SEXP c_arg__dtypes, SEXP c_arg__strict) {
    SEXP res = savvy_PlRDataType_infer_supertype__ffi(c_arg__dtypes, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRDataType_max__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_max__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_min__impl(SEXP self__) {
    SEXP res = savvy_PlRDataType_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRDataType_ne__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRDataType_ne__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_array__impl(SEXP c_arg__inner, SEXP c_arg__shape) {
    SEXP res = savvy_PlRDataType_new_array__ffi(c_arg__inner, c_arg__shape);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_categorical__impl(SEXP c_arg__ordering) {
    SEXP res = savvy_PlRDataType_new_categorical__ffi(c_arg__ordering);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_datetime__impl(SEXP c_arg__time_unit, SEXP c_arg__time_zone) {
    SEXP res = savvy_PlRDataType_new_datetime__ffi(c_arg__time_unit, c_arg__time_zone);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_decimal__impl(SEXP c_arg__scale, SEXP c_arg__precision) {
    SEXP res = savvy_PlRDataType_new_decimal__ffi(c_arg__scale, c_arg__precision);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_duration__impl(SEXP c_arg__time_unit) {
    SEXP res = savvy_PlRDataType_new_duration__ffi(c_arg__time_unit);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_enum__impl(SEXP c_arg__categories) {
    SEXP res = savvy_PlRDataType_new_enum__ffi(c_arg__categories);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_from_name__impl(SEXP c_arg__name) {
    SEXP res = savvy_PlRDataType_new_from_name__ffi(c_arg__name);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_list__impl(SEXP c_arg__inner) {
    SEXP res = savvy_PlRDataType_new_list__ffi(c_arg__inner);
    return handle_result(res);
}

SEXP savvy_PlRDataType_new_struct__impl(SEXP c_arg__fields) {
    SEXP res = savvy_PlRDataType_new_struct__ffi(c_arg__fields);
    return handle_result(res);
}

SEXP savvy_PlRExpr__meta_as_selector__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr__meta_as_selector__ffi(self__);
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

SEXP savvy_PlRExpr__meta_selector_xor__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr__meta_selector_xor__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_abs__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_abs__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_add__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_add__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_agg_groups__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_agg_groups__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_alias__impl(SEXP self__, SEXP c_arg__name) {
    SEXP res = savvy_PlRExpr_alias__ffi(self__, c_arg__name);
    return handle_result(res);
}

SEXP savvy_PlRExpr_all__impl(SEXP self__, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_PlRExpr_all__ffi(self__, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_PlRExpr_and__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_and__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_any__impl(SEXP self__, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_PlRExpr_any__ffi(self__, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_PlRExpr_append__impl(SEXP self__, SEXP c_arg__other, SEXP c_arg__upcast) {
    SEXP res = savvy_PlRExpr_append__ffi(self__, c_arg__other, c_arg__upcast);
    return handle_result(res);
}

SEXP savvy_PlRExpr_approx_n_unique__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_approx_n_unique__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arccos__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arccos__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arccosh__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arccosh__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arcsin__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arcsin__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arcsinh__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arcsinh__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arctan__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arctan__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arctan2__impl(SEXP self__, SEXP c_arg__y) {
    SEXP res = savvy_PlRExpr_arctan2__ffi(self__, c_arg__y);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arctanh__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arctanh__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arg_max__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arg_max__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arg_min__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arg_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arg_sort__impl(SEXP self__, SEXP c_arg__descending, SEXP c_arg__nulls_last) {
    SEXP res = savvy_PlRExpr_arg_sort__ffi(self__, c_arg__descending, c_arg__nulls_last);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arg_unique__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arg_unique__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_all__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arr_all__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_any__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arr_any__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_arg_max__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arr_arg_max__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_arg_min__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arr_arg_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_contains__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_arr_contains__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_count_matches__impl(SEXP self__, SEXP c_arg__expr) {
    SEXP res = savvy_PlRExpr_arr_count_matches__ffi(self__, c_arg__expr);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_get__impl(SEXP self__, SEXP c_arg__index, SEXP c_arg__null_on_oob) {
    SEXP res = savvy_PlRExpr_arr_get__ffi(self__, c_arg__index, c_arg__null_on_oob);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_join__impl(SEXP self__, SEXP c_arg__separator, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_PlRExpr_arr_join__ffi(self__, c_arg__separator, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_max__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arr_max__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_median__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arr_median__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_min__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arr_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_n_unique__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arr_n_unique__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_reverse__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arr_reverse__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_shift__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRExpr_arr_shift__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_sort__impl(SEXP self__, SEXP c_arg__descending, SEXP c_arg__nulls_last) {
    SEXP res = savvy_PlRExpr_arr_sort__ffi(self__, c_arg__descending, c_arg__nulls_last);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_std__impl(SEXP self__, SEXP c_arg__ddof) {
    SEXP res = savvy_PlRExpr_arr_std__ffi(self__, c_arg__ddof);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_sum__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arr_sum__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_to_list__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_arr_to_list__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_unique__impl(SEXP self__, SEXP c_arg__maintain_order) {
    SEXP res = savvy_PlRExpr_arr_unique__ffi(self__, c_arg__maintain_order);
    return handle_result(res);
}

SEXP savvy_PlRExpr_arr_var__impl(SEXP self__, SEXP c_arg__ddof) {
    SEXP res = savvy_PlRExpr_arr_var__ffi(self__, c_arg__ddof);
    return handle_result(res);
}

SEXP savvy_PlRExpr_as_str__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_as_str__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_backward_fill__impl(SEXP self__, SEXP c_arg__limit) {
    SEXP res = savvy_PlRExpr_backward_fill__ffi(self__, c_arg__limit);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_base64_decode__impl(SEXP self__, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_bin_base64_decode__ffi(self__, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_base64_encode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bin_base64_encode__ffi(self__);
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

SEXP savvy_PlRExpr_bin_hex_decode__impl(SEXP self__, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_bin_hex_decode__ffi(self__, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_hex_encode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bin_hex_encode__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_size_bytes__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bin_size_bytes__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bin_starts_with__impl(SEXP self__, SEXP c_arg__prefix) {
    SEXP res = savvy_PlRExpr_bin_starts_with__ffi(self__, c_arg__prefix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bitwise_and__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bitwise_and__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bitwise_count_ones__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bitwise_count_ones__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bitwise_count_zeros__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bitwise_count_zeros__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bitwise_leading_ones__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bitwise_leading_ones__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bitwise_leading_zeros__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bitwise_leading_zeros__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bitwise_or__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bitwise_or__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bitwise_trailing_ones__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bitwise_trailing_ones__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bitwise_trailing_zeros__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bitwise_trailing_zeros__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bitwise_xor__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_bitwise_xor__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bottom_k__impl(SEXP self__, SEXP c_arg__k) {
    SEXP res = savvy_PlRExpr_bottom_k__ffi(self__, c_arg__k);
    return handle_result(res);
}

SEXP savvy_PlRExpr_bottom_k_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__k, SEXP c_arg__reverse) {
    SEXP res = savvy_PlRExpr_bottom_k_by__ffi(self__, c_arg__by, c_arg__k, c_arg__reverse);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cast__impl(SEXP self__, SEXP c_arg__dtype, SEXP c_arg__strict, SEXP c_arg__wrap_numerical) {
    SEXP res = savvy_PlRExpr_cast__ffi(self__, c_arg__dtype, c_arg__strict, c_arg__wrap_numerical);
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

SEXP savvy_PlRExpr_cbrt__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_cbrt__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_ceil__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_ceil__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_clip__impl(SEXP self__, SEXP c_arg__min, SEXP c_arg__max) {
    SEXP res = savvy_PlRExpr_clip__ffi(self__, c_arg__min, c_arg__max);
    return handle_result(res);
}

SEXP savvy_PlRExpr_compute_tree_format__impl(SEXP self__, SEXP c_arg__display_as_dot) {
    SEXP res = savvy_PlRExpr_compute_tree_format__ffi(self__, c_arg__display_as_dot);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cos__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_cos__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cosh__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_cosh__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cot__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_cot__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_count__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_count__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cum_count__impl(SEXP self__, SEXP c_arg__reverse) {
    SEXP res = savvy_PlRExpr_cum_count__ffi(self__, c_arg__reverse);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cum_max__impl(SEXP self__, SEXP c_arg__reverse) {
    SEXP res = savvy_PlRExpr_cum_max__ffi(self__, c_arg__reverse);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cum_min__impl(SEXP self__, SEXP c_arg__reverse) {
    SEXP res = savvy_PlRExpr_cum_min__ffi(self__, c_arg__reverse);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cum_prod__impl(SEXP self__, SEXP c_arg__reverse) {
    SEXP res = savvy_PlRExpr_cum_prod__ffi(self__, c_arg__reverse);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cum_sum__impl(SEXP self__, SEXP c_arg__reverse) {
    SEXP res = savvy_PlRExpr_cum_sum__ffi(self__, c_arg__reverse);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cumulative_eval__impl(SEXP self__, SEXP c_arg__expr, SEXP c_arg__min_periods, SEXP c_arg__parallel) {
    SEXP res = savvy_PlRExpr_cumulative_eval__ffi(self__, c_arg__expr, c_arg__min_periods, c_arg__parallel);
    return handle_result(res);
}

SEXP savvy_PlRExpr_cut__impl(SEXP self__, SEXP c_arg__breaks, SEXP c_arg__left_closed, SEXP c_arg__include_breaks, SEXP c_arg__labels) {
    SEXP res = savvy_PlRExpr_cut__ffi(self__, c_arg__breaks, c_arg__left_closed, c_arg__include_breaks, c_arg__labels);
    return handle_result(res);
}

SEXP savvy_PlRExpr_degrees__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_degrees__ffi(self__);
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

SEXP savvy_PlRExpr_diff__impl(SEXP self__, SEXP c_arg__n, SEXP c_arg__null_behavior) {
    SEXP res = savvy_PlRExpr_diff__ffi(self__, c_arg__n, c_arg__null_behavior);
    return handle_result(res);
}

SEXP savvy_PlRExpr_div__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_div__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dot__impl(SEXP self__, SEXP c_arg__expr) {
    SEXP res = savvy_PlRExpr_dot__ffi(self__, c_arg__expr);
    return handle_result(res);
}

SEXP savvy_PlRExpr_drop_nans__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_drop_nans__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_drop_nulls__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_drop_nulls__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_add_business_days__impl(SEXP self__, SEXP c_arg__n, SEXP c_arg__week_mask, SEXP c_arg__holidays, SEXP c_arg__roll) {
    SEXP res = savvy_PlRExpr_dt_add_business_days__ffi(self__, c_arg__n, c_arg__week_mask, c_arg__holidays, c_arg__roll);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_base_utc_offset__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_base_utc_offset__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_cast_time_unit__impl(SEXP self__, SEXP c_arg__time_unit) {
    SEXP res = savvy_PlRExpr_dt_cast_time_unit__ffi(self__, c_arg__time_unit);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_century__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_century__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_combine__impl(SEXP self__, SEXP c_arg__time, SEXP c_arg__time_unit) {
    SEXP res = savvy_PlRExpr_dt_combine__ffi(self__, c_arg__time, c_arg__time_unit);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_convert_time_zone__impl(SEXP self__, SEXP c_arg__time_zone) {
    SEXP res = savvy_PlRExpr_dt_convert_time_zone__ffi(self__, c_arg__time_zone);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_date__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_date__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_day__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_day__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_dst_offset__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_dst_offset__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_epoch_seconds__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_epoch_seconds__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_hour__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_hour__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_is_leap_year__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_is_leap_year__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_iso_year__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_iso_year__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_microsecond__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_microsecond__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_millisecond__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_millisecond__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_minute__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_minute__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_month__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_month__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_month_end__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_month_end__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_month_start__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_month_start__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_nanosecond__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_nanosecond__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_offset_by__impl(SEXP self__, SEXP c_arg__by) {
    SEXP res = savvy_PlRExpr_dt_offset_by__ffi(self__, c_arg__by);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_ordinal_day__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_ordinal_day__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_quarter__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_quarter__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_replace_time_zone__impl(SEXP self__, SEXP c_arg__ambiguous, SEXP c_arg__non_existent, SEXP c_arg__time_zone) {
    SEXP res = savvy_PlRExpr_dt_replace_time_zone__ffi(self__, c_arg__ambiguous, c_arg__non_existent, c_arg__time_zone);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_round__impl(SEXP self__, SEXP c_arg__every) {
    SEXP res = savvy_PlRExpr_dt_round__ffi(self__, c_arg__every);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_second__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_second__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_time__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_time__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_timestamp__impl(SEXP self__, SEXP c_arg__time_unit) {
    SEXP res = savvy_PlRExpr_dt_timestamp__ffi(self__, c_arg__time_unit);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_to_string__impl(SEXP self__, SEXP c_arg__format) {
    SEXP res = savvy_PlRExpr_dt_to_string__ffi(self__, c_arg__format);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_total_days__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_total_days__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_total_hours__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_total_hours__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_total_microseconds__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_total_microseconds__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_total_milliseconds__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_total_milliseconds__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_total_minutes__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_total_minutes__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_total_nanoseconds__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_total_nanoseconds__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_total_seconds__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_total_seconds__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_truncate__impl(SEXP self__, SEXP c_arg__every) {
    SEXP res = savvy_PlRExpr_dt_truncate__ffi(self__, c_arg__every);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_week__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_week__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_weekday__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_weekday__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_with_time_unit__impl(SEXP self__, SEXP c_arg__time_unit) {
    SEXP res = savvy_PlRExpr_dt_with_time_unit__ffi(self__, c_arg__time_unit);
    return handle_result(res);
}

SEXP savvy_PlRExpr_dt_year__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_dt_year__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_entropy__impl(SEXP self__, SEXP c_arg__base, SEXP c_arg__normalize) {
    SEXP res = savvy_PlRExpr_entropy__ffi(self__, c_arg__base, c_arg__normalize);
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

SEXP savvy_PlRExpr_ewm_mean__impl(SEXP self__, SEXP c_arg__alpha, SEXP c_arg__adjust, SEXP c_arg__min_periods, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_PlRExpr_ewm_mean__ffi(self__, c_arg__alpha, c_arg__adjust, c_arg__min_periods, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_PlRExpr_ewm_mean_by__impl(SEXP self__, SEXP c_arg__times, SEXP c_arg__half_life) {
    SEXP res = savvy_PlRExpr_ewm_mean_by__ffi(self__, c_arg__times, c_arg__half_life);
    return handle_result(res);
}

SEXP savvy_PlRExpr_ewm_std__impl(SEXP self__, SEXP c_arg__alpha, SEXP c_arg__adjust, SEXP c_arg__bias, SEXP c_arg__min_periods, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_PlRExpr_ewm_std__ffi(self__, c_arg__alpha, c_arg__adjust, c_arg__bias, c_arg__min_periods, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_PlRExpr_ewm_var__impl(SEXP self__, SEXP c_arg__alpha, SEXP c_arg__adjust, SEXP c_arg__bias, SEXP c_arg__min_periods, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_PlRExpr_ewm_var__ffi(self__, c_arg__alpha, c_arg__adjust, c_arg__bias, c_arg__min_periods, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_PlRExpr_exclude__impl(SEXP self__, SEXP c_arg__columns) {
    SEXP res = savvy_PlRExpr_exclude__ffi(self__, c_arg__columns);
    return handle_result(res);
}

SEXP savvy_PlRExpr_exclude_dtype__impl(SEXP self__, SEXP c_arg__dtypes) {
    SEXP res = savvy_PlRExpr_exclude_dtype__ffi(self__, c_arg__dtypes);
    return handle_result(res);
}

SEXP savvy_PlRExpr_exp__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_exp__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_explode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_explode__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_extend_constant__impl(SEXP self__, SEXP c_arg__value, SEXP c_arg__n) {
    SEXP res = savvy_PlRExpr_extend_constant__ffi(self__, c_arg__value, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRExpr_fill_nan__impl(SEXP self__, SEXP c_arg__expr) {
    SEXP res = savvy_PlRExpr_fill_nan__ffi(self__, c_arg__expr);
    return handle_result(res);
}

SEXP savvy_PlRExpr_fill_null__impl(SEXP self__, SEXP c_arg__expr) {
    SEXP res = savvy_PlRExpr_fill_null__ffi(self__, c_arg__expr);
    return handle_result(res);
}

SEXP savvy_PlRExpr_fill_null_with_strategy__impl(SEXP self__, SEXP c_arg__strategy, SEXP c_arg__limit) {
    SEXP res = savvy_PlRExpr_fill_null_with_strategy__ffi(self__, c_arg__strategy, c_arg__limit);
    return handle_result(res);
}

SEXP savvy_PlRExpr_filter__impl(SEXP self__, SEXP c_arg__predicate) {
    SEXP res = savvy_PlRExpr_filter__ffi(self__, c_arg__predicate);
    return handle_result(res);
}

SEXP savvy_PlRExpr_first__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_first__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_floor__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_floor__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_floor_div__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_floor_div__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_forward_fill__impl(SEXP self__, SEXP c_arg__limit) {
    SEXP res = savvy_PlRExpr_forward_fill__ffi(self__, c_arg__limit);
    return handle_result(res);
}

SEXP savvy_PlRExpr_gather__impl(SEXP self__, SEXP c_arg__idx) {
    SEXP res = savvy_PlRExpr_gather__ffi(self__, c_arg__idx);
    return handle_result(res);
}

SEXP savvy_PlRExpr_gather_every__impl(SEXP self__, SEXP c_arg__n, SEXP c_arg__offset) {
    SEXP res = savvy_PlRExpr_gather_every__ffi(self__, c_arg__n, c_arg__offset);
    return handle_result(res);
}

SEXP savvy_PlRExpr_get__impl(SEXP self__, SEXP c_arg__idx) {
    SEXP res = savvy_PlRExpr_get__ffi(self__, c_arg__idx);
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

SEXP savvy_PlRExpr_hash__impl(SEXP self__, SEXP c_arg__seed, SEXP c_arg__seed_1, SEXP c_arg__seed_2, SEXP c_arg__seed_3) {
    SEXP res = savvy_PlRExpr_hash__ffi(self__, c_arg__seed, c_arg__seed_1, c_arg__seed_2, c_arg__seed_3);
    return handle_result(res);
}

SEXP savvy_PlRExpr_hist__impl(SEXP self__, SEXP c_arg__include_category, SEXP c_arg__include_breakpoint, SEXP c_arg__bin_count, SEXP c_arg__bins) {
    SEXP res = savvy_PlRExpr_hist__ffi(self__, c_arg__include_category, c_arg__include_breakpoint, c_arg__bin_count, c_arg__bins);
    return handle_result(res);
}

SEXP savvy_PlRExpr_implode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_implode__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_interpolate__impl(SEXP self__, SEXP c_arg__method) {
    SEXP res = savvy_PlRExpr_interpolate__ffi(self__, c_arg__method);
    return handle_result(res);
}

SEXP savvy_PlRExpr_interpolate_by__impl(SEXP self__, SEXP c_arg__by) {
    SEXP res = savvy_PlRExpr_interpolate_by__ffi(self__, c_arg__by);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_between__impl(SEXP self__, SEXP c_arg__lower, SEXP c_arg__upper, SEXP c_arg__closed) {
    SEXP res = savvy_PlRExpr_is_between__ffi(self__, c_arg__lower, c_arg__upper, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_duplicated__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_duplicated__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_finite__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_finite__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_first_distinct__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_first_distinct__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_in__impl(SEXP self__, SEXP c_arg__expr) {
    SEXP res = savvy_PlRExpr_is_in__ffi(self__, c_arg__expr);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_infinite__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_infinite__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_last_distinct__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_last_distinct__ffi(self__);
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

SEXP savvy_PlRExpr_is_not_null__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_not_null__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_null__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_null__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_is_unique__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_is_unique__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_kurtosis__impl(SEXP self__, SEXP c_arg__fisher, SEXP c_arg__bias) {
    SEXP res = savvy_PlRExpr_kurtosis__ffi(self__, c_arg__fisher, c_arg__bias);
    return handle_result(res);
}

SEXP savvy_PlRExpr_last__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_last__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_len__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_len__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_all__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_all__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_any__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_any__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_arg_max__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_arg_max__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_arg_min__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_arg_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_contains__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_list_contains__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_count_matches__impl(SEXP self__, SEXP c_arg__expr) {
    SEXP res = savvy_PlRExpr_list_count_matches__ffi(self__, c_arg__expr);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_diff__impl(SEXP self__, SEXP c_arg__n, SEXP c_arg__null_behavior) {
    SEXP res = savvy_PlRExpr_list_diff__ffi(self__, c_arg__n, c_arg__null_behavior);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_drop_nulls__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_drop_nulls__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_eval__impl(SEXP self__, SEXP c_arg__expr, SEXP c_arg__parallel) {
    SEXP res = savvy_PlRExpr_list_eval__ffi(self__, c_arg__expr, c_arg__parallel);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_gather__impl(SEXP self__, SEXP c_arg__index, SEXP c_arg__null_on_oob) {
    SEXP res = savvy_PlRExpr_list_gather__ffi(self__, c_arg__index, c_arg__null_on_oob);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_gather_every__impl(SEXP self__, SEXP c_arg__n, SEXP c_arg__offset) {
    SEXP res = savvy_PlRExpr_list_gather_every__ffi(self__, c_arg__n, c_arg__offset);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_get__impl(SEXP self__, SEXP c_arg__index, SEXP c_arg__null_on_oob) {
    SEXP res = savvy_PlRExpr_list_get__ffi(self__, c_arg__index, c_arg__null_on_oob);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_join__impl(SEXP self__, SEXP c_arg__separator, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_PlRExpr_list_join__ffi(self__, c_arg__separator, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_len__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_len__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_max__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_max__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_mean__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_mean__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_median__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_median__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_min__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_n_unique__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_n_unique__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_reverse__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_reverse__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_sample_frac__impl(SEXP self__, SEXP c_arg__frac, SEXP c_arg__with_replacement, SEXP c_arg__shuffle, SEXP c_arg__seed) {
    SEXP res = savvy_PlRExpr_list_sample_frac__ffi(self__, c_arg__frac, c_arg__with_replacement, c_arg__shuffle, c_arg__seed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_sample_n__impl(SEXP self__, SEXP c_arg__n, SEXP c_arg__with_replacement, SEXP c_arg__shuffle, SEXP c_arg__seed) {
    SEXP res = savvy_PlRExpr_list_sample_n__ffi(self__, c_arg__n, c_arg__with_replacement, c_arg__shuffle, c_arg__seed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_set_operation__impl(SEXP self__, SEXP c_arg__other, SEXP c_arg__operation) {
    SEXP res = savvy_PlRExpr_list_set_operation__ffi(self__, c_arg__other, c_arg__operation);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_shift__impl(SEXP self__, SEXP c_arg__periods) {
    SEXP res = savvy_PlRExpr_list_shift__ffi(self__, c_arg__periods);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_slice__impl(SEXP self__, SEXP c_arg__offset, SEXP c_arg__length) {
    SEXP res = savvy_PlRExpr_list_slice__ffi(self__, c_arg__offset, c_arg__length);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_sort__impl(SEXP self__, SEXP c_arg__descending, SEXP c_arg__nulls_last) {
    SEXP res = savvy_PlRExpr_list_sort__ffi(self__, c_arg__descending, c_arg__nulls_last);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_std__impl(SEXP self__, SEXP c_arg__ddof) {
    SEXP res = savvy_PlRExpr_list_std__ffi(self__, c_arg__ddof);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_sum__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_list_sum__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_to_array__impl(SEXP self__, SEXP c_arg__width) {
    SEXP res = savvy_PlRExpr_list_to_array__ffi(self__, c_arg__width);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_unique__impl(SEXP self__, SEXP c_arg__maintain_order) {
    SEXP res = savvy_PlRExpr_list_unique__ffi(self__, c_arg__maintain_order);
    return handle_result(res);
}

SEXP savvy_PlRExpr_list_var__impl(SEXP self__, SEXP c_arg__ddof) {
    SEXP res = savvy_PlRExpr_list_var__ffi(self__, c_arg__ddof);
    return handle_result(res);
}

SEXP savvy_PlRExpr_log__impl(SEXP self__, SEXP c_arg__base) {
    SEXP res = savvy_PlRExpr_log__ffi(self__, c_arg__base);
    return handle_result(res);
}

SEXP savvy_PlRExpr_log1p__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_log1p__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_lower_bound__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_lower_bound__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_lt__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_lt__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_lt_eq__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_lt_eq__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_map_batches__impl(SEXP self__, SEXP c_arg__lambda, SEXP c_arg__agg_list, SEXP c_arg__output_type) {
    SEXP res = savvy_PlRExpr_map_batches__ffi(self__, c_arg__lambda, c_arg__agg_list, c_arg__output_type);
    return handle_result(res);
}

SEXP savvy_PlRExpr_max__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_max__ffi(self__);
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

SEXP savvy_PlRExpr_meta_eq__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_meta_eq__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_meta_has_multiple_outputs__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_meta_has_multiple_outputs__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_meta_is_column__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_meta_is_column__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_meta_is_column_selection__impl(SEXP self__, SEXP c_arg__allow_aliasing) {
    SEXP res = savvy_PlRExpr_meta_is_column_selection__ffi(self__, c_arg__allow_aliasing);
    return handle_result(res);
}

SEXP savvy_PlRExpr_meta_is_regex_projection__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_meta_is_regex_projection__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_meta_output_name__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_meta_output_name__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_meta_pop__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_meta_pop__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_meta_root_names__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_meta_root_names__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_meta_undo_aliases__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_meta_undo_aliases__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_min__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_mode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_mode__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_mul__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_mul__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_n_unique__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_n_unique__ffi(self__);
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

SEXP savvy_PlRExpr_name_prefix_fields__impl(SEXP self__, SEXP c_arg__prefix) {
    SEXP res = savvy_PlRExpr_name_prefix_fields__ffi(self__, c_arg__prefix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_name_suffix__impl(SEXP self__, SEXP c_arg__suffix) {
    SEXP res = savvy_PlRExpr_name_suffix__ffi(self__, c_arg__suffix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_name_suffix_fields__impl(SEXP self__, SEXP c_arg__suffix) {
    SEXP res = savvy_PlRExpr_name_suffix_fields__ffi(self__, c_arg__suffix);
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

SEXP savvy_PlRExpr_nan_max__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_nan_max__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_nan_min__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_nan_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_neg__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_neg__ffi(self__);
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

SEXP savvy_PlRExpr_not__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_not__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_null_count__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_null_count__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_or__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_or__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRExpr_over__impl(SEXP self__, SEXP c_arg__partition_by, SEXP c_arg__order_by_descending, SEXP c_arg__order_by_nulls_last, SEXP c_arg__mapping_strategy, SEXP c_arg__order_by) {
    SEXP res = savvy_PlRExpr_over__ffi(self__, c_arg__partition_by, c_arg__order_by_descending, c_arg__order_by_nulls_last, c_arg__mapping_strategy, c_arg__order_by);
    return handle_result(res);
}

SEXP savvy_PlRExpr_pct_change__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRExpr_pct_change__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRExpr_peak_max__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_peak_max__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_peak_min__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_peak_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_pow__impl(SEXP self__, SEXP c_arg__exponent) {
    SEXP res = savvy_PlRExpr_pow__ffi(self__, c_arg__exponent);
    return handle_result(res);
}

SEXP savvy_PlRExpr_product__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_product__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_qcut__impl(SEXP self__, SEXP c_arg__probs, SEXP c_arg__left_closed, SEXP c_arg__allow_duplicates, SEXP c_arg__include_breaks, SEXP c_arg__labels) {
    SEXP res = savvy_PlRExpr_qcut__ffi(self__, c_arg__probs, c_arg__left_closed, c_arg__allow_duplicates, c_arg__include_breaks, c_arg__labels);
    return handle_result(res);
}

SEXP savvy_PlRExpr_qcut_uniform__impl(SEXP self__, SEXP c_arg__n_bins, SEXP c_arg__left_closed, SEXP c_arg__allow_duplicates, SEXP c_arg__include_breaks, SEXP c_arg__labels) {
    SEXP res = savvy_PlRExpr_qcut_uniform__ffi(self__, c_arg__n_bins, c_arg__left_closed, c_arg__allow_duplicates, c_arg__include_breaks, c_arg__labels);
    return handle_result(res);
}

SEXP savvy_PlRExpr_quantile__impl(SEXP self__, SEXP c_arg__quantile, SEXP c_arg__interpolation) {
    SEXP res = savvy_PlRExpr_quantile__ffi(self__, c_arg__quantile, c_arg__interpolation);
    return handle_result(res);
}

SEXP savvy_PlRExpr_radians__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_radians__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rank__impl(SEXP self__, SEXP c_arg__method, SEXP c_arg__descending, SEXP c_arg__seed) {
    SEXP res = savvy_PlRExpr_rank__ffi(self__, c_arg__method, c_arg__descending, c_arg__seed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rechunk__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_rechunk__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_reinterpret__impl(SEXP self__, SEXP c_arg__signed) {
    SEXP res = savvy_PlRExpr_reinterpret__ffi(self__, c_arg__signed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rem__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_rem__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_repeat_by__impl(SEXP self__, SEXP c_arg__by) {
    SEXP res = savvy_PlRExpr_repeat_by__ffi(self__, c_arg__by);
    return handle_result(res);
}

SEXP savvy_PlRExpr_replace__impl(SEXP self__, SEXP c_arg__old, SEXP c_arg__new) {
    SEXP res = savvy_PlRExpr_replace__ffi(self__, c_arg__old, c_arg__new);
    return handle_result(res);
}

SEXP savvy_PlRExpr_replace_strict__impl(SEXP self__, SEXP c_arg__old, SEXP c_arg__new, SEXP c_arg__default, SEXP c_arg__return_dtype) {
    SEXP res = savvy_PlRExpr_replace_strict__ffi(self__, c_arg__old, c_arg__new, c_arg__default, c_arg__return_dtype);
    return handle_result(res);
}

SEXP savvy_PlRExpr_reshape__impl(SEXP self__, SEXP c_arg__dimensions) {
    SEXP res = savvy_PlRExpr_reshape__ffi(self__, c_arg__dimensions);
    return handle_result(res);
}

SEXP savvy_PlRExpr_reverse__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_reverse__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rle__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_rle__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rle_id__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_rle_id__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling__impl(SEXP self__, SEXP c_arg__index_column, SEXP c_arg__period, SEXP c_arg__offset, SEXP c_arg__closed) {
    SEXP res = savvy_PlRExpr_rolling__ffi(self__, c_arg__index_column, c_arg__period, c_arg__offset, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_max__impl(SEXP self__, SEXP c_arg__window_size, SEXP c_arg__center, SEXP c_arg__weights, SEXP c_arg__min_periods) {
    SEXP res = savvy_PlRExpr_rolling_max__ffi(self__, c_arg__window_size, c_arg__center, c_arg__weights, c_arg__min_periods);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_max_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__window_size, SEXP c_arg__min_periods, SEXP c_arg__closed) {
    SEXP res = savvy_PlRExpr_rolling_max_by__ffi(self__, c_arg__by, c_arg__window_size, c_arg__min_periods, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_mean__impl(SEXP self__, SEXP c_arg__window_size, SEXP c_arg__center, SEXP c_arg__weights, SEXP c_arg__min_periods) {
    SEXP res = savvy_PlRExpr_rolling_mean__ffi(self__, c_arg__window_size, c_arg__center, c_arg__weights, c_arg__min_periods);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_mean_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__window_size, SEXP c_arg__min_periods, SEXP c_arg__closed) {
    SEXP res = savvy_PlRExpr_rolling_mean_by__ffi(self__, c_arg__by, c_arg__window_size, c_arg__min_periods, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_median__impl(SEXP self__, SEXP c_arg__window_size, SEXP c_arg__center, SEXP c_arg__weights, SEXP c_arg__min_periods) {
    SEXP res = savvy_PlRExpr_rolling_median__ffi(self__, c_arg__window_size, c_arg__center, c_arg__weights, c_arg__min_periods);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_median_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__window_size, SEXP c_arg__min_periods, SEXP c_arg__closed) {
    SEXP res = savvy_PlRExpr_rolling_median_by__ffi(self__, c_arg__by, c_arg__window_size, c_arg__min_periods, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_min__impl(SEXP self__, SEXP c_arg__window_size, SEXP c_arg__center, SEXP c_arg__weights, SEXP c_arg__min_periods) {
    SEXP res = savvy_PlRExpr_rolling_min__ffi(self__, c_arg__window_size, c_arg__center, c_arg__weights, c_arg__min_periods);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_min_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__window_size, SEXP c_arg__min_periods, SEXP c_arg__closed) {
    SEXP res = savvy_PlRExpr_rolling_min_by__ffi(self__, c_arg__by, c_arg__window_size, c_arg__min_periods, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_quantile__impl(SEXP self__, SEXP c_arg__quantile, SEXP c_arg__interpolation, SEXP c_arg__window_size, SEXP c_arg__center, SEXP c_arg__weights, SEXP c_arg__min_periods) {
    SEXP res = savvy_PlRExpr_rolling_quantile__ffi(self__, c_arg__quantile, c_arg__interpolation, c_arg__window_size, c_arg__center, c_arg__weights, c_arg__min_periods);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_quantile_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__quantile, SEXP c_arg__interpolation, SEXP c_arg__window_size, SEXP c_arg__min_periods, SEXP c_arg__closed) {
    SEXP res = savvy_PlRExpr_rolling_quantile_by__ffi(self__, c_arg__by, c_arg__quantile, c_arg__interpolation, c_arg__window_size, c_arg__min_periods, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_skew__impl(SEXP self__, SEXP c_arg__window_size, SEXP c_arg__bias) {
    SEXP res = savvy_PlRExpr_rolling_skew__ffi(self__, c_arg__window_size, c_arg__bias);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_std__impl(SEXP self__, SEXP c_arg__window_size, SEXP c_arg__center, SEXP c_arg__ddof, SEXP c_arg__weights, SEXP c_arg__min_periods) {
    SEXP res = savvy_PlRExpr_rolling_std__ffi(self__, c_arg__window_size, c_arg__center, c_arg__ddof, c_arg__weights, c_arg__min_periods);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_std_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__window_size, SEXP c_arg__min_periods, SEXP c_arg__closed, SEXP c_arg__ddof) {
    SEXP res = savvy_PlRExpr_rolling_std_by__ffi(self__, c_arg__by, c_arg__window_size, c_arg__min_periods, c_arg__closed, c_arg__ddof);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_sum__impl(SEXP self__, SEXP c_arg__window_size, SEXP c_arg__center, SEXP c_arg__weights, SEXP c_arg__min_periods) {
    SEXP res = savvy_PlRExpr_rolling_sum__ffi(self__, c_arg__window_size, c_arg__center, c_arg__weights, c_arg__min_periods);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_sum_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__window_size, SEXP c_arg__min_periods, SEXP c_arg__closed) {
    SEXP res = savvy_PlRExpr_rolling_sum_by__ffi(self__, c_arg__by, c_arg__window_size, c_arg__min_periods, c_arg__closed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_var__impl(SEXP self__, SEXP c_arg__window_size, SEXP c_arg__center, SEXP c_arg__ddof, SEXP c_arg__weights, SEXP c_arg__min_periods) {
    SEXP res = savvy_PlRExpr_rolling_var__ffi(self__, c_arg__window_size, c_arg__center, c_arg__ddof, c_arg__weights, c_arg__min_periods);
    return handle_result(res);
}

SEXP savvy_PlRExpr_rolling_var_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__window_size, SEXP c_arg__min_periods, SEXP c_arg__closed, SEXP c_arg__ddof) {
    SEXP res = savvy_PlRExpr_rolling_var_by__ffi(self__, c_arg__by, c_arg__window_size, c_arg__min_periods, c_arg__closed, c_arg__ddof);
    return handle_result(res);
}

SEXP savvy_PlRExpr_round__impl(SEXP self__, SEXP c_arg__decimals) {
    SEXP res = savvy_PlRExpr_round__ffi(self__, c_arg__decimals);
    return handle_result(res);
}

SEXP savvy_PlRExpr_round_sig_figs__impl(SEXP self__, SEXP c_arg__digits) {
    SEXP res = savvy_PlRExpr_round_sig_figs__ffi(self__, c_arg__digits);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sample_frac__impl(SEXP self__, SEXP c_arg__frac, SEXP c_arg__with_replacement, SEXP c_arg__shuffle, SEXP c_arg__seed) {
    SEXP res = savvy_PlRExpr_sample_frac__ffi(self__, c_arg__frac, c_arg__with_replacement, c_arg__shuffle, c_arg__seed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sample_n__impl(SEXP self__, SEXP c_arg__n, SEXP c_arg__with_replacement, SEXP c_arg__shuffle, SEXP c_arg__seed) {
    SEXP res = savvy_PlRExpr_sample_n__ffi(self__, c_arg__n, c_arg__with_replacement, c_arg__shuffle, c_arg__seed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_search_sorted__impl(SEXP self__, SEXP c_arg__element, SEXP c_arg__side) {
    SEXP res = savvy_PlRExpr_search_sorted__ffi(self__, c_arg__element, c_arg__side);
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

SEXP savvy_PlRExpr_set_sorted_flag__impl(SEXP self__, SEXP c_arg__descending) {
    SEXP res = savvy_PlRExpr_set_sorted_flag__ffi(self__, c_arg__descending);
    return handle_result(res);
}

SEXP savvy_PlRExpr_shift__impl(SEXP self__, SEXP c_arg__n, SEXP c_arg__fill_value) {
    SEXP res = savvy_PlRExpr_shift__ffi(self__, c_arg__n, c_arg__fill_value);
    return handle_result(res);
}

SEXP savvy_PlRExpr_shrink_dtype__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_shrink_dtype__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_shuffle__impl(SEXP self__, SEXP c_arg__seed) {
    SEXP res = savvy_PlRExpr_shuffle__ffi(self__, c_arg__seed);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sign__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_sign__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sin__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_sin__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sinh__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_sinh__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_skew__impl(SEXP self__, SEXP c_arg__bias) {
    SEXP res = savvy_PlRExpr_skew__ffi(self__, c_arg__bias);
    return handle_result(res);
}

SEXP savvy_PlRExpr_slice__impl(SEXP self__, SEXP c_arg__offset, SEXP c_arg__length) {
    SEXP res = savvy_PlRExpr_slice__ffi(self__, c_arg__offset, c_arg__length);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sort_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__descending, SEXP c_arg__nulls_last, SEXP c_arg__multithreaded, SEXP c_arg__maintain_order) {
    SEXP res = savvy_PlRExpr_sort_by__ffi(self__, c_arg__by, c_arg__descending, c_arg__nulls_last, c_arg__multithreaded, c_arg__maintain_order);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sort_with__impl(SEXP self__, SEXP c_arg__descending, SEXP c_arg__nulls_last) {
    SEXP res = savvy_PlRExpr_sort_with__ffi(self__, c_arg__descending, c_arg__nulls_last);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sqrt__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_sqrt__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_std__impl(SEXP self__, SEXP c_arg__ddof) {
    SEXP res = savvy_PlRExpr_std__ffi(self__, c_arg__ddof);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_base64_decode__impl(SEXP self__, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_str_base64_decode__ffi(self__, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_base64_encode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_base64_encode__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_contains__impl(SEXP self__, SEXP c_arg__pat, SEXP c_arg__literal, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_str_contains__ffi(self__, c_arg__pat, c_arg__literal, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_contains_any__impl(SEXP self__, SEXP c_arg__patterns, SEXP c_arg__ascii_case_insensitive) {
    SEXP res = savvy_PlRExpr_str_contains_any__ffi(self__, c_arg__patterns, c_arg__ascii_case_insensitive);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_count_matches__impl(SEXP self__, SEXP c_arg__pat, SEXP c_arg__literal) {
    SEXP res = savvy_PlRExpr_str_count_matches__ffi(self__, c_arg__pat, c_arg__literal);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_ends_with__impl(SEXP self__, SEXP c_arg__suffix) {
    SEXP res = savvy_PlRExpr_str_ends_with__ffi(self__, c_arg__suffix);
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

SEXP savvy_PlRExpr_str_hex_decode__impl(SEXP self__, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_str_hex_decode__ffi(self__, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_hex_encode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_hex_encode__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_join__impl(SEXP self__, SEXP c_arg__delimiter, SEXP c_arg__ignore_nulls) {
    SEXP res = savvy_PlRExpr_str_join__ffi(self__, c_arg__delimiter, c_arg__ignore_nulls);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_json_decode__impl(SEXP self__, SEXP c_arg__dtype, SEXP c_arg__infer_schema_len) {
    SEXP res = savvy_PlRExpr_str_json_decode__ffi(self__, c_arg__dtype, c_arg__infer_schema_len);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_json_path_match__impl(SEXP self__, SEXP c_arg__pat) {
    SEXP res = savvy_PlRExpr_str_json_path_match__ffi(self__, c_arg__pat);
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

SEXP savvy_PlRExpr_str_pad_end__impl(SEXP self__, SEXP c_arg__length, SEXP c_arg__fill_char) {
    SEXP res = savvy_PlRExpr_str_pad_end__ffi(self__, c_arg__length, c_arg__fill_char);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_pad_start__impl(SEXP self__, SEXP c_arg__length, SEXP c_arg__fill_char) {
    SEXP res = savvy_PlRExpr_str_pad_start__ffi(self__, c_arg__length, c_arg__fill_char);
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

SEXP savvy_PlRExpr_str_replace_many__impl(SEXP self__, SEXP c_arg__patterns, SEXP c_arg__replace_with, SEXP c_arg__ascii_case_insensitive) {
    SEXP res = savvy_PlRExpr_str_replace_many__ffi(self__, c_arg__patterns, c_arg__replace_with, c_arg__ascii_case_insensitive);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_reverse__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_reverse__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_slice__impl(SEXP self__, SEXP c_arg__offset, SEXP c_arg__length) {
    SEXP res = savvy_PlRExpr_str_slice__ffi(self__, c_arg__offset, c_arg__length);
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

SEXP savvy_PlRExpr_str_starts_with__impl(SEXP self__, SEXP c_arg__prefix) {
    SEXP res = savvy_PlRExpr_str_starts_with__ffi(self__, c_arg__prefix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_strip_chars__impl(SEXP self__, SEXP c_arg__characters) {
    SEXP res = savvy_PlRExpr_str_strip_chars__ffi(self__, c_arg__characters);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_strip_chars_end__impl(SEXP self__, SEXP c_arg__characters) {
    SEXP res = savvy_PlRExpr_str_strip_chars_end__ffi(self__, c_arg__characters);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_strip_chars_start__impl(SEXP self__, SEXP c_arg__characters) {
    SEXP res = savvy_PlRExpr_str_strip_chars_start__ffi(self__, c_arg__characters);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_strip_prefix__impl(SEXP self__, SEXP c_arg__prefix) {
    SEXP res = savvy_PlRExpr_str_strip_prefix__ffi(self__, c_arg__prefix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_strip_suffix__impl(SEXP self__, SEXP c_arg__suffix) {
    SEXP res = savvy_PlRExpr_str_strip_suffix__ffi(self__, c_arg__suffix);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_tail__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRExpr_str_tail__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_to_date__impl(SEXP self__, SEXP c_arg__strict, SEXP c_arg__exact, SEXP c_arg__cache, SEXP c_arg__format) {
    SEXP res = savvy_PlRExpr_str_to_date__ffi(self__, c_arg__strict, c_arg__exact, c_arg__cache, c_arg__format);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_to_datetime__impl(SEXP self__, SEXP c_arg__strict, SEXP c_arg__exact, SEXP c_arg__cache, SEXP c_arg__ambiguous, SEXP c_arg__format, SEXP c_arg__time_unit, SEXP c_arg__time_zone) {
    SEXP res = savvy_PlRExpr_str_to_datetime__ffi(self__, c_arg__strict, c_arg__exact, c_arg__cache, c_arg__ambiguous, c_arg__format, c_arg__time_unit, c_arg__time_zone);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_to_decimal__impl(SEXP self__, SEXP c_arg__infer_len) {
    SEXP res = savvy_PlRExpr_str_to_decimal__ffi(self__, c_arg__infer_len);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_to_integer__impl(SEXP self__, SEXP c_arg__base, SEXP c_arg__strict) {
    SEXP res = savvy_PlRExpr_str_to_integer__ffi(self__, c_arg__base, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_to_lowercase__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_to_lowercase__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_to_time__impl(SEXP self__, SEXP c_arg__strict, SEXP c_arg__cache, SEXP c_arg__format) {
    SEXP res = savvy_PlRExpr_str_to_time__ffi(self__, c_arg__strict, c_arg__cache, c_arg__format);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_to_uppercase__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_str_to_uppercase__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_str_zfill__impl(SEXP self__, SEXP c_arg__length) {
    SEXP res = savvy_PlRExpr_str_zfill__ffi(self__, c_arg__length);
    return handle_result(res);
}

SEXP savvy_PlRExpr_struct_field_by_index__impl(SEXP self__, SEXP c_arg__index) {
    SEXP res = savvy_PlRExpr_struct_field_by_index__ffi(self__, c_arg__index);
    return handle_result(res);
}

SEXP savvy_PlRExpr_struct_json_encode__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_struct_json_encode__ffi(self__);
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

SEXP savvy_PlRExpr_struct_with_fields__impl(SEXP self__, SEXP c_arg__fields) {
    SEXP res = savvy_PlRExpr_struct_with_fields__ffi(self__, c_arg__fields);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sub__impl(SEXP self__, SEXP c_arg__rhs) {
    SEXP res = savvy_PlRExpr_sub__ffi(self__, c_arg__rhs);
    return handle_result(res);
}

SEXP savvy_PlRExpr_sum__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_sum__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_tan__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_tan__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_tanh__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_tanh__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_to_physical__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_to_physical__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_top_k__impl(SEXP self__, SEXP c_arg__k) {
    SEXP res = savvy_PlRExpr_top_k__ffi(self__, c_arg__k);
    return handle_result(res);
}

SEXP savvy_PlRExpr_top_k_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__k, SEXP c_arg__reverse) {
    SEXP res = savvy_PlRExpr_top_k_by__ffi(self__, c_arg__by, c_arg__k, c_arg__reverse);
    return handle_result(res);
}

SEXP savvy_PlRExpr_unique__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_unique__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_unique_counts__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_unique_counts__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_unique_stable__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_unique_stable__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_upper_bound__impl(SEXP self__) {
    SEXP res = savvy_PlRExpr_upper_bound__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRExpr_value_counts__impl(SEXP self__, SEXP c_arg__sort, SEXP c_arg__parallel, SEXP c_arg__name, SEXP c_arg__normalize) {
    SEXP res = savvy_PlRExpr_value_counts__ffi(self__, c_arg__sort, c_arg__parallel, c_arg__name, c_arg__normalize);
    return handle_result(res);
}

SEXP savvy_PlRExpr_var__impl(SEXP self__, SEXP c_arg__ddof) {
    SEXP res = savvy_PlRExpr_var__ffi(self__, c_arg__ddof);
    return handle_result(res);
}

SEXP savvy_PlRExpr_xor__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRExpr_xor__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_bottom_k__impl(SEXP self__, SEXP c_arg__k, SEXP c_arg__by, SEXP c_arg__reverse) {
    SEXP res = savvy_PlRLazyFrame_bottom_k__ffi(self__, c_arg__k, c_arg__by, c_arg__reverse);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_cache__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_cache__ffi(self__);
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

SEXP savvy_PlRLazyFrame_clone__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_clone__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_collect__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_collect__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_collect_schema__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_collect_schema__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_count__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_count__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_describe_optimized_plan__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_describe_optimized_plan__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_describe_optimized_plan_tree__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_describe_optimized_plan_tree__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_describe_plan__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_describe_plan__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_describe_plan_tree__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_describe_plan_tree__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_drop__impl(SEXP self__, SEXP c_arg__columns, SEXP c_arg__strict) {
    SEXP res = savvy_PlRLazyFrame_drop__ffi(self__, c_arg__columns, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_drop_nans__impl(SEXP self__, SEXP c_arg__subset) {
    SEXP res = savvy_PlRLazyFrame_drop_nans__ffi(self__, c_arg__subset);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_drop_nulls__impl(SEXP self__, SEXP c_arg__subset) {
    SEXP res = savvy_PlRLazyFrame_drop_nulls__ffi(self__, c_arg__subset);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_explode__impl(SEXP self__, SEXP c_arg__column) {
    SEXP res = savvy_PlRLazyFrame_explode__ffi(self__, c_arg__column);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_fill_nan__impl(SEXP self__, SEXP c_arg__fill_value) {
    SEXP res = savvy_PlRLazyFrame_fill_nan__ffi(self__, c_arg__fill_value);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_filter__impl(SEXP self__, SEXP c_arg__predicate) {
    SEXP res = savvy_PlRLazyFrame_filter__ffi(self__, c_arg__predicate);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_group_by__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__maintain_order) {
    SEXP res = savvy_PlRLazyFrame_group_by__ffi(self__, c_arg__by, c_arg__maintain_order);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_group_by_dynamic__impl(SEXP self__, SEXP c_arg__index_column, SEXP c_arg__every, SEXP c_arg__period, SEXP c_arg__offset, SEXP c_arg__label, SEXP c_arg__include_boundaries, SEXP c_arg__closed, SEXP c_arg__group_by, SEXP c_arg__start_by) {
    SEXP res = savvy_PlRLazyFrame_group_by_dynamic__ffi(self__, c_arg__index_column, c_arg__every, c_arg__period, c_arg__offset, c_arg__label, c_arg__include_boundaries, c_arg__closed, c_arg__group_by, c_arg__start_by);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_join__impl(SEXP self__, SEXP c_arg__other, SEXP c_arg__left_on, SEXP c_arg__right_on, SEXP c_arg__allow_parallel, SEXP c_arg__force_parallel, SEXP c_arg__join_nulls, SEXP c_arg__how, SEXP c_arg__suffix, SEXP c_arg__validate, SEXP c_arg__maintain_order, SEXP c_arg__coalesce) {
    SEXP res = savvy_PlRLazyFrame_join__ffi(self__, c_arg__other, c_arg__left_on, c_arg__right_on, c_arg__allow_parallel, c_arg__force_parallel, c_arg__join_nulls, c_arg__how, c_arg__suffix, c_arg__validate, c_arg__maintain_order, c_arg__coalesce);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_join_asof__impl(SEXP self__, SEXP c_arg__other, SEXP c_arg__left_on, SEXP c_arg__right_on, SEXP c_arg__allow_parallel, SEXP c_arg__force_parallel, SEXP c_arg__suffix, SEXP c_arg__coalesce, SEXP c_arg__strategy, SEXP c_arg__allow_eq, SEXP c_arg__check_sortedness, SEXP c_arg__left_by, SEXP c_arg__right_by, SEXP c_arg__tolerance, SEXP c_arg__tolerance_str) {
    SEXP res = savvy_PlRLazyFrame_join_asof__ffi(self__, c_arg__other, c_arg__left_on, c_arg__right_on, c_arg__allow_parallel, c_arg__force_parallel, c_arg__suffix, c_arg__coalesce, c_arg__strategy, c_arg__allow_eq, c_arg__check_sortedness, c_arg__left_by, c_arg__right_by, c_arg__tolerance, c_arg__tolerance_str);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_join_where__impl(SEXP self__, SEXP c_arg__other, SEXP c_arg__predicates, SEXP c_arg__suffix) {
    SEXP res = savvy_PlRLazyFrame_join_where__ffi(self__, c_arg__other, c_arg__predicates, c_arg__suffix);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_max__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_max__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_mean__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_mean__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_median__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_median__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_merge_sorted__impl(SEXP self__, SEXP c_arg__other, SEXP c_arg__key) {
    SEXP res = savvy_PlRLazyFrame_merge_sorted__ffi(self__, c_arg__other, c_arg__key);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_min__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_min__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_new_from_csv__impl(SEXP c_arg__source, SEXP c_arg__separator, SEXP c_arg__has_header, SEXP c_arg__ignore_errors, SEXP c_arg__skip_rows, SEXP c_arg__cache, SEXP c_arg__missing_utf8_is_empty_string, SEXP c_arg__low_memory, SEXP c_arg__rechunk, SEXP c_arg__skip_rows_after_header, SEXP c_arg__encoding, SEXP c_arg__try_parse_dates, SEXP c_arg__eol_char, SEXP c_arg__raise_if_empty, SEXP c_arg__truncate_ragged_lines, SEXP c_arg__decimal_comma, SEXP c_arg__glob, SEXP c_arg__retries, SEXP c_arg__row_index_offset, SEXP c_arg__comment_prefix, SEXP c_arg__quote_char, SEXP c_arg__null_values, SEXP c_arg__infer_schema_length, SEXP c_arg__row_index_name, SEXP c_arg__n_rows, SEXP c_arg__overwrite_dtype, SEXP c_arg__schema, SEXP c_arg__storage_options, SEXP c_arg__file_cache_ttl, SEXP c_arg__include_file_paths) {
    SEXP res = savvy_PlRLazyFrame_new_from_csv__ffi(c_arg__source, c_arg__separator, c_arg__has_header, c_arg__ignore_errors, c_arg__skip_rows, c_arg__cache, c_arg__missing_utf8_is_empty_string, c_arg__low_memory, c_arg__rechunk, c_arg__skip_rows_after_header, c_arg__encoding, c_arg__try_parse_dates, c_arg__eol_char, c_arg__raise_if_empty, c_arg__truncate_ragged_lines, c_arg__decimal_comma, c_arg__glob, c_arg__retries, c_arg__row_index_offset, c_arg__comment_prefix, c_arg__quote_char, c_arg__null_values, c_arg__infer_schema_length, c_arg__row_index_name, c_arg__n_rows, c_arg__overwrite_dtype, c_arg__schema, c_arg__storage_options, c_arg__file_cache_ttl, c_arg__include_file_paths);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_new_from_ipc__impl(SEXP c_arg__source, SEXP c_arg__cache, SEXP c_arg__rechunk, SEXP c_arg__try_parse_hive_dates, SEXP c_arg__retries, SEXP c_arg__row_index_offset, SEXP c_arg__n_rows, SEXP c_arg__row_index_name, SEXP c_arg__storage_options, SEXP c_arg__hive_partitioning, SEXP c_arg__hive_schema, SEXP c_arg__file_cache_ttl, SEXP c_arg__include_file_paths) {
    SEXP res = savvy_PlRLazyFrame_new_from_ipc__ffi(c_arg__source, c_arg__cache, c_arg__rechunk, c_arg__try_parse_hive_dates, c_arg__retries, c_arg__row_index_offset, c_arg__n_rows, c_arg__row_index_name, c_arg__storage_options, c_arg__hive_partitioning, c_arg__hive_schema, c_arg__file_cache_ttl, c_arg__include_file_paths);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_new_from_ndjson__impl(SEXP c_arg__source, SEXP c_arg__low_memory, SEXP c_arg__rechunk, SEXP c_arg__ignore_errors, SEXP c_arg__retries, SEXP c_arg__row_index_offset, SEXP c_arg__row_index_name, SEXP c_arg__infer_schema_length, SEXP c_arg__schema, SEXP c_arg__schema_overrides, SEXP c_arg__batch_size, SEXP c_arg__n_rows, SEXP c_arg__include_file_paths, SEXP c_arg__storage_options, SEXP c_arg__file_cache_ttl) {
    SEXP res = savvy_PlRLazyFrame_new_from_ndjson__ffi(c_arg__source, c_arg__low_memory, c_arg__rechunk, c_arg__ignore_errors, c_arg__retries, c_arg__row_index_offset, c_arg__row_index_name, c_arg__infer_schema_length, c_arg__schema, c_arg__schema_overrides, c_arg__batch_size, c_arg__n_rows, c_arg__include_file_paths, c_arg__storage_options, c_arg__file_cache_ttl);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_new_from_parquet__impl(SEXP c_arg__source, SEXP c_arg__cache, SEXP c_arg__parallel, SEXP c_arg__rechunk, SEXP c_arg__low_memory, SEXP c_arg__use_statistics, SEXP c_arg__try_parse_hive_dates, SEXP c_arg__retries, SEXP c_arg__glob, SEXP c_arg__allow_missing_columns, SEXP c_arg__row_index_offset, SEXP c_arg__storage_options, SEXP c_arg__n_rows, SEXP c_arg__row_index_name, SEXP c_arg__hive_partitioning, SEXP c_arg__schema, SEXP c_arg__hive_schema, SEXP c_arg__include_file_paths) {
    SEXP res = savvy_PlRLazyFrame_new_from_parquet__ffi(c_arg__source, c_arg__cache, c_arg__parallel, c_arg__rechunk, c_arg__low_memory, c_arg__use_statistics, c_arg__try_parse_hive_dates, c_arg__retries, c_arg__glob, c_arg__allow_missing_columns, c_arg__row_index_offset, c_arg__storage_options, c_arg__n_rows, c_arg__row_index_name, c_arg__hive_partitioning, c_arg__schema, c_arg__hive_schema, c_arg__include_file_paths);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_null_count__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_null_count__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_optimization_toggle__impl(SEXP self__, SEXP c_arg__type_coercion, SEXP c_arg___type_check, SEXP c_arg__predicate_pushdown, SEXP c_arg__projection_pushdown, SEXP c_arg__simplify_expression, SEXP c_arg__slice_pushdown, SEXP c_arg__comm_subplan_elim, SEXP c_arg__comm_subexpr_elim, SEXP c_arg__cluster_with_columns, SEXP c_arg__collapse_joins, SEXP c_arg__streaming, SEXP c_arg___eager, SEXP c_arg___check_order) {
    SEXP res = savvy_PlRLazyFrame_optimization_toggle__ffi(self__, c_arg__type_coercion, c_arg___type_check, c_arg__predicate_pushdown, c_arg__projection_pushdown, c_arg__simplify_expression, c_arg__slice_pushdown, c_arg__comm_subplan_elim, c_arg__comm_subexpr_elim, c_arg__cluster_with_columns, c_arg__collapse_joins, c_arg__streaming, c_arg___eager, c_arg___check_order);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_profile__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_profile__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_quantile__impl(SEXP self__, SEXP c_arg__quantile, SEXP c_arg__interpolation) {
    SEXP res = savvy_PlRLazyFrame_quantile__ffi(self__, c_arg__quantile, c_arg__interpolation);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_rename__impl(SEXP self__, SEXP c_arg__existing, SEXP c_arg__new, SEXP c_arg__strict) {
    SEXP res = savvy_PlRLazyFrame_rename__ffi(self__, c_arg__existing, c_arg__new, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_reverse__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_reverse__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_rolling__impl(SEXP self__, SEXP c_arg__index_column, SEXP c_arg__period, SEXP c_arg__offset, SEXP c_arg__closed, SEXP c_arg__by) {
    SEXP res = savvy_PlRLazyFrame_rolling__ffi(self__, c_arg__index_column, c_arg__period, c_arg__offset, c_arg__closed, c_arg__by);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_select__impl(SEXP self__, SEXP c_arg__exprs) {
    SEXP res = savvy_PlRLazyFrame_select__ffi(self__, c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_select_seq__impl(SEXP self__, SEXP c_arg__exprs) {
    SEXP res = savvy_PlRLazyFrame_select_seq__ffi(self__, c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_serialize__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_serialize__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_shift__impl(SEXP self__, SEXP c_arg__n, SEXP c_arg__fill_value) {
    SEXP res = savvy_PlRLazyFrame_shift__ffi(self__, c_arg__n, c_arg__fill_value);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_sink_csv__impl(SEXP self__, SEXP c_arg__path, SEXP c_arg__include_bom, SEXP c_arg__include_header, SEXP c_arg__separator, SEXP c_arg__line_terminator, SEXP c_arg__quote_char, SEXP c_arg__maintain_order, SEXP c_arg__batch_size, SEXP c_arg__retries, SEXP c_arg__datetime_format, SEXP c_arg__date_format, SEXP c_arg__time_format, SEXP c_arg__float_scientific, SEXP c_arg__float_precision, SEXP c_arg__null_value, SEXP c_arg__quote_style, SEXP c_arg__storage_options) {
    SEXP res = savvy_PlRLazyFrame_sink_csv__ffi(self__, c_arg__path, c_arg__include_bom, c_arg__include_header, c_arg__separator, c_arg__line_terminator, c_arg__quote_char, c_arg__maintain_order, c_arg__batch_size, c_arg__retries, c_arg__datetime_format, c_arg__date_format, c_arg__time_format, c_arg__float_scientific, c_arg__float_precision, c_arg__null_value, c_arg__quote_style, c_arg__storage_options);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_sink_parquet__impl(SEXP self__, SEXP c_arg__path, SEXP c_arg__compression, SEXP c_arg__maintain_order, SEXP c_arg__stat_min, SEXP c_arg__stat_max, SEXP c_arg__stat_distinct_count, SEXP c_arg__stat_null_count, SEXP c_arg__retries, SEXP c_arg__compression_level, SEXP c_arg__row_group_size, SEXP c_arg__data_page_size, SEXP c_arg__storage_options) {
    SEXP res = savvy_PlRLazyFrame_sink_parquet__ffi(self__, c_arg__path, c_arg__compression, c_arg__maintain_order, c_arg__stat_min, c_arg__stat_max, c_arg__stat_distinct_count, c_arg__stat_null_count, c_arg__retries, c_arg__compression_level, c_arg__row_group_size, c_arg__data_page_size, c_arg__storage_options);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_slice__impl(SEXP self__, SEXP c_arg__offset, SEXP c_arg__len) {
    SEXP res = savvy_PlRLazyFrame_slice__ffi(self__, c_arg__offset, c_arg__len);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_sort__impl(SEXP self__, SEXP c_arg__by_column, SEXP c_arg__descending, SEXP c_arg__nulls_last, SEXP c_arg__maintain_order, SEXP c_arg__multithreaded) {
    SEXP res = savvy_PlRLazyFrame_sort__ffi(self__, c_arg__by_column, c_arg__descending, c_arg__nulls_last, c_arg__maintain_order, c_arg__multithreaded);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_sort_by_exprs__impl(SEXP self__, SEXP c_arg__by, SEXP c_arg__descending, SEXP c_arg__nulls_last, SEXP c_arg__maintain_order, SEXP c_arg__multithreaded) {
    SEXP res = savvy_PlRLazyFrame_sort_by_exprs__ffi(self__, c_arg__by, c_arg__descending, c_arg__nulls_last, c_arg__maintain_order, c_arg__multithreaded);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_std__impl(SEXP self__, SEXP c_arg__ddof) {
    SEXP res = savvy_PlRLazyFrame_std__ffi(self__, c_arg__ddof);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_sum__impl(SEXP self__) {
    SEXP res = savvy_PlRLazyFrame_sum__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_tail__impl(SEXP self__, SEXP c_arg__n) {
    SEXP res = savvy_PlRLazyFrame_tail__ffi(self__, c_arg__n);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_to_dot__impl(SEXP self__, SEXP c_arg__optimized) {
    SEXP res = savvy_PlRLazyFrame_to_dot__ffi(self__, c_arg__optimized);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_top_k__impl(SEXP self__, SEXP c_arg__k, SEXP c_arg__by, SEXP c_arg__reverse) {
    SEXP res = savvy_PlRLazyFrame_top_k__ffi(self__, c_arg__k, c_arg__by, c_arg__reverse);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_unique__impl(SEXP self__, SEXP c_arg__maintain_order, SEXP c_arg__keep, SEXP c_arg__subset) {
    SEXP res = savvy_PlRLazyFrame_unique__ffi(self__, c_arg__maintain_order, c_arg__keep, c_arg__subset);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_unnest__impl(SEXP self__, SEXP c_arg__columns) {
    SEXP res = savvy_PlRLazyFrame_unnest__ffi(self__, c_arg__columns);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_unpivot__impl(SEXP self__, SEXP c_arg__on, SEXP c_arg__index, SEXP c_arg__value_name, SEXP c_arg__variable_name) {
    SEXP res = savvy_PlRLazyFrame_unpivot__ffi(self__, c_arg__on, c_arg__index, c_arg__value_name, c_arg__variable_name);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_var__impl(SEXP self__, SEXP c_arg__ddof) {
    SEXP res = savvy_PlRLazyFrame_var__ffi(self__, c_arg__ddof);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_with_columns__impl(SEXP self__, SEXP c_arg__exprs) {
    SEXP res = savvy_PlRLazyFrame_with_columns__ffi(self__, c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_with_columns_seq__impl(SEXP self__, SEXP c_arg__exprs) {
    SEXP res = savvy_PlRLazyFrame_with_columns_seq__ffi(self__, c_arg__exprs);
    return handle_result(res);
}

SEXP savvy_PlRLazyFrame_with_row_index__impl(SEXP self__, SEXP c_arg__name, SEXP c_arg__offset) {
    SEXP res = savvy_PlRLazyFrame_with_row_index__ffi(self__, c_arg__name, c_arg__offset);
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

SEXP savvy_PlRSeries_as_str__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_as_str__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_can_fast_explode_flag__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_can_fast_explode_flag__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_cast__impl(SEXP self__, SEXP c_arg__dtype, SEXP c_arg__strict) {
    SEXP res = savvy_PlRSeries_cast__ffi(self__, c_arg__dtype, c_arg__strict);
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

SEXP savvy_PlRSeries_cat_uses_lexical_ordering__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_cat_uses_lexical_ordering__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_clone__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_clone__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_div__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRSeries_div__ffi(self__, c_arg__other);
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

SEXP savvy_PlRSeries_is_sorted_ascending_flag__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_is_sorted_ascending_flag__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_is_sorted_descending_flag__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_is_sorted_descending_flag__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_len__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_len__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_mul__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRSeries_mul__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRSeries_n_chunks__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_n_chunks__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_name__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_name__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_binary__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_binary__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_bool__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_bool__ffi(c_arg__name, c_arg__values);
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

SEXP savvy_PlRSeries_new_i32_from_date__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_i32_from_date__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_i64__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_i64__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_i64_from_clock_pair__impl(SEXP c_arg__name, SEXP c_arg__left, SEXP c_arg__right, SEXP c_arg__precision) {
    SEXP res = savvy_PlRSeries_new_i64_from_clock_pair__ffi(c_arg__name, c_arg__left, c_arg__right, c_arg__precision);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_i64_from_numeric_and_multiplier__impl(SEXP c_arg__name, SEXP c_arg__values, SEXP c_arg__multiplier, SEXP c_arg__rounding) {
    SEXP res = savvy_PlRSeries_new_i64_from_numeric_and_multiplier__ffi(c_arg__name, c_arg__values, c_arg__multiplier, c_arg__rounding);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_null__impl(SEXP c_arg__name, SEXP c_arg__length) {
    SEXP res = savvy_PlRSeries_new_null__ffi(c_arg__name, c_arg__length);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_series_list__impl(SEXP c_arg__name, SEXP c_arg__values, SEXP c_arg__strict) {
    SEXP res = savvy_PlRSeries_new_series_list__ffi(c_arg__name, c_arg__values, c_arg__strict);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_single_binary__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_single_binary__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_new_str__impl(SEXP c_arg__name, SEXP c_arg__values) {
    SEXP res = savvy_PlRSeries_new_str__ffi(c_arg__name, c_arg__values);
    return handle_result(res);
}

SEXP savvy_PlRSeries_rem__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRSeries_rem__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRSeries_rename__impl(SEXP self__, SEXP c_arg__name) {
    SEXP res = savvy_PlRSeries_rename__ffi(self__, c_arg__name);
    return handle_result(res);
}

SEXP savvy_PlRSeries_reshape__impl(SEXP self__, SEXP c_arg__dimensions) {
    SEXP res = savvy_PlRSeries_reshape__ffi(self__, c_arg__dimensions);
    return handle_result(res);
}

SEXP savvy_PlRSeries_slice__impl(SEXP self__, SEXP c_arg__offset, SEXP c_arg__length) {
    SEXP res = savvy_PlRSeries_slice__ffi(self__, c_arg__offset, c_arg__length);
    return handle_result(res);
}

SEXP savvy_PlRSeries_struct_fields__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_struct_fields__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_struct_unnest__impl(SEXP self__) {
    SEXP res = savvy_PlRSeries_struct_unnest__ffi(self__);
    return handle_result(res);
}

SEXP savvy_PlRSeries_sub__impl(SEXP self__, SEXP c_arg__other) {
    SEXP res = savvy_PlRSeries_sub__ffi(self__, c_arg__other);
    return handle_result(res);
}

SEXP savvy_PlRSeries_to_r_vector__impl(SEXP self__, SEXP c_arg__ensure_vector, SEXP c_arg__int64, SEXP c_arg__date, SEXP c_arg__time, SEXP c_arg__struct, SEXP c_arg__decimal, SEXP c_arg__as_clock_class, SEXP c_arg__ambiguous, SEXP c_arg__non_existent, SEXP c_arg__local_time_zone) {
    SEXP res = savvy_PlRSeries_to_r_vector__ffi(self__, c_arg__ensure_vector, c_arg__int64, c_arg__date, c_arg__time, c_arg__struct, c_arg__decimal, c_arg__as_clock_class, c_arg__ambiguous, c_arg__non_existent, c_arg__local_time_zone);
    return handle_result(res);
}

SEXP savvy_PlRThen_otherwise__impl(SEXP self__, SEXP c_arg__statement) {
    SEXP res = savvy_PlRThen_otherwise__ffi(self__, c_arg__statement);
    return handle_result(res);
}

SEXP savvy_PlRThen_when__impl(SEXP self__, SEXP c_arg__condition) {
    SEXP res = savvy_PlRThen_when__ffi(self__, c_arg__condition);
    return handle_result(res);
}

SEXP savvy_PlRWhen_then__impl(SEXP self__, SEXP c_arg__statement) {
    SEXP res = savvy_PlRWhen_then__ffi(self__, c_arg__statement);
    return handle_result(res);
}


static const R_CallMethodDef CallEntries[] = {
    {"savvy_all_horizontal__impl", (DL_FUNC) &savvy_all_horizontal__impl, 1},
    {"savvy_any_horizontal__impl", (DL_FUNC) &savvy_any_horizontal__impl, 1},
    {"savvy_arg_where__impl", (DL_FUNC) &savvy_arg_where__impl, 1},
    {"savvy_as_struct__impl", (DL_FUNC) &savvy_as_struct__impl, 1},
    {"savvy_coalesce__impl", (DL_FUNC) &savvy_coalesce__impl, 1},
    {"savvy_col__impl", (DL_FUNC) &savvy_col__impl, 1},
    {"savvy_cols__impl", (DL_FUNC) &savvy_cols__impl, 1},
    {"savvy_concat_df__impl", (DL_FUNC) &savvy_concat_df__impl, 1},
    {"savvy_concat_df_diagonal__impl", (DL_FUNC) &savvy_concat_df_diagonal__impl, 1},
    {"savvy_concat_df_horizontal__impl", (DL_FUNC) &savvy_concat_df_horizontal__impl, 1},
    {"savvy_concat_lf__impl", (DL_FUNC) &savvy_concat_lf__impl, 4},
    {"savvy_concat_lf_diagonal__impl", (DL_FUNC) &savvy_concat_lf_diagonal__impl, 4},
    {"savvy_concat_lf_horizontal__impl", (DL_FUNC) &savvy_concat_lf_horizontal__impl, 2},
    {"savvy_concat_list__impl", (DL_FUNC) &savvy_concat_list__impl, 1},
    {"savvy_concat_series__impl", (DL_FUNC) &savvy_concat_series__impl, 1},
    {"savvy_concat_str__impl", (DL_FUNC) &savvy_concat_str__impl, 3},
    {"savvy_date_range__impl", (DL_FUNC) &savvy_date_range__impl, 4},
    {"savvy_date_ranges__impl", (DL_FUNC) &savvy_date_ranges__impl, 4},
    {"savvy_datetime__impl", (DL_FUNC) &savvy_datetime__impl, 10},
    {"savvy_datetime_range__impl", (DL_FUNC) &savvy_datetime_range__impl, 6},
    {"savvy_datetime_ranges__impl", (DL_FUNC) &savvy_datetime_ranges__impl, 6},
    {"savvy_dtype_cols__impl", (DL_FUNC) &savvy_dtype_cols__impl, 1},
    {"savvy_duration__impl", (DL_FUNC) &savvy_duration__impl, 9},
    {"savvy_field__impl", (DL_FUNC) &savvy_field__impl, 1},
    {"savvy_first__impl", (DL_FUNC) &savvy_first__impl, 0},
    {"savvy_index_cols__impl", (DL_FUNC) &savvy_index_cols__impl, 1},
    {"savvy_int_range__impl", (DL_FUNC) &savvy_int_range__impl, 4},
    {"savvy_int_ranges__impl", (DL_FUNC) &savvy_int_ranges__impl, 4},
    {"savvy_last__impl", (DL_FUNC) &savvy_last__impl, 0},
    {"savvy_len__impl", (DL_FUNC) &savvy_len__impl, 0},
    {"savvy_lit_from_bool__impl", (DL_FUNC) &savvy_lit_from_bool__impl, 1},
    {"savvy_lit_from_f64__impl", (DL_FUNC) &savvy_lit_from_f64__impl, 1},
    {"savvy_lit_from_i32__impl", (DL_FUNC) &savvy_lit_from_i32__impl, 1},
    {"savvy_lit_from_raw__impl", (DL_FUNC) &savvy_lit_from_raw__impl, 1},
    {"savvy_lit_from_series__impl", (DL_FUNC) &savvy_lit_from_series__impl, 1},
    {"savvy_lit_from_series_first__impl", (DL_FUNC) &savvy_lit_from_series_first__impl, 1},
    {"savvy_lit_from_str__impl", (DL_FUNC) &savvy_lit_from_str__impl, 1},
    {"savvy_lit_null__impl", (DL_FUNC) &savvy_lit_null__impl, 0},
    {"savvy_max_horizontal__impl", (DL_FUNC) &savvy_max_horizontal__impl, 1},
    {"savvy_mean_horizontal__impl", (DL_FUNC) &savvy_mean_horizontal__impl, 2},
    {"savvy_min_horizontal__impl", (DL_FUNC) &savvy_min_horizontal__impl, 1},
    {"savvy_repeat___impl", (DL_FUNC) &savvy_repeat___impl, 3},
    {"savvy_sum_horizontal__impl", (DL_FUNC) &savvy_sum_horizontal__impl, 2},
    {"savvy_time_range__impl", (DL_FUNC) &savvy_time_range__impl, 4},
    {"savvy_time_ranges__impl", (DL_FUNC) &savvy_time_ranges__impl, 4},
    {"savvy_when__impl", (DL_FUNC) &savvy_when__impl, 1},
    {"savvy_PlRChainedThen_otherwise__impl", (DL_FUNC) &savvy_PlRChainedThen_otherwise__impl, 2},
    {"savvy_PlRChainedThen_when__impl", (DL_FUNC) &savvy_PlRChainedThen_when__impl, 2},
    {"savvy_PlRChainedWhen_then__impl", (DL_FUNC) &savvy_PlRChainedWhen_then__impl, 2},
    {"savvy_PlRDataFrame_as_str__impl", (DL_FUNC) &savvy_PlRDataFrame_as_str__impl, 1},
    {"savvy_PlRDataFrame_clear__impl", (DL_FUNC) &savvy_PlRDataFrame_clear__impl, 1},
    {"savvy_PlRDataFrame_clone__impl", (DL_FUNC) &savvy_PlRDataFrame_clone__impl, 1},
    {"savvy_PlRDataFrame_columns__impl", (DL_FUNC) &savvy_PlRDataFrame_columns__impl, 1},
    {"savvy_PlRDataFrame_dtypes__impl", (DL_FUNC) &savvy_PlRDataFrame_dtypes__impl, 1},
    {"savvy_PlRDataFrame_equals__impl", (DL_FUNC) &savvy_PlRDataFrame_equals__impl, 3},
    {"savvy_PlRDataFrame_get_column__impl", (DL_FUNC) &savvy_PlRDataFrame_get_column__impl, 2},
    {"savvy_PlRDataFrame_get_column_index__impl", (DL_FUNC) &savvy_PlRDataFrame_get_column_index__impl, 2},
    {"savvy_PlRDataFrame_get_columns__impl", (DL_FUNC) &savvy_PlRDataFrame_get_columns__impl, 1},
    {"savvy_PlRDataFrame_head__impl", (DL_FUNC) &savvy_PlRDataFrame_head__impl, 2},
    {"savvy_PlRDataFrame_height__impl", (DL_FUNC) &savvy_PlRDataFrame_height__impl, 1},
    {"savvy_PlRDataFrame_init__impl", (DL_FUNC) &savvy_PlRDataFrame_init__impl, 1},
    {"savvy_PlRDataFrame_is_duplicated__impl", (DL_FUNC) &savvy_PlRDataFrame_is_duplicated__impl, 1},
    {"savvy_PlRDataFrame_is_empty__impl", (DL_FUNC) &savvy_PlRDataFrame_is_empty__impl, 1},
    {"savvy_PlRDataFrame_is_unique__impl", (DL_FUNC) &savvy_PlRDataFrame_is_unique__impl, 1},
    {"savvy_PlRDataFrame_lazy__impl", (DL_FUNC) &savvy_PlRDataFrame_lazy__impl, 1},
    {"savvy_PlRDataFrame_n_chunks__impl", (DL_FUNC) &savvy_PlRDataFrame_n_chunks__impl, 1},
    {"savvy_PlRDataFrame_partition_by__impl", (DL_FUNC) &savvy_PlRDataFrame_partition_by__impl, 4},
    {"savvy_PlRDataFrame_pivot_expr__impl", (DL_FUNC) &savvy_PlRDataFrame_pivot_expr__impl, 8},
    {"savvy_PlRDataFrame_read_ipc_stream__impl", (DL_FUNC) &savvy_PlRDataFrame_read_ipc_stream__impl, 7},
    {"savvy_PlRDataFrame_rechunk__impl", (DL_FUNC) &savvy_PlRDataFrame_rechunk__impl, 1},
    {"savvy_PlRDataFrame_sample_frac__impl", (DL_FUNC) &savvy_PlRDataFrame_sample_frac__impl, 5},
    {"savvy_PlRDataFrame_sample_n__impl", (DL_FUNC) &savvy_PlRDataFrame_sample_n__impl, 5},
    {"savvy_PlRDataFrame_set_column_names__impl", (DL_FUNC) &savvy_PlRDataFrame_set_column_names__impl, 2},
    {"savvy_PlRDataFrame_shape__impl", (DL_FUNC) &savvy_PlRDataFrame_shape__impl, 1},
    {"savvy_PlRDataFrame_slice__impl", (DL_FUNC) &savvy_PlRDataFrame_slice__impl, 3},
    {"savvy_PlRDataFrame_tail__impl", (DL_FUNC) &savvy_PlRDataFrame_tail__impl, 2},
    {"savvy_PlRDataFrame_to_dummies__impl", (DL_FUNC) &savvy_PlRDataFrame_to_dummies__impl, 4},
    {"savvy_PlRDataFrame_to_series__impl", (DL_FUNC) &savvy_PlRDataFrame_to_series__impl, 2},
    {"savvy_PlRDataFrame_to_struct__impl", (DL_FUNC) &savvy_PlRDataFrame_to_struct__impl, 2},
    {"savvy_PlRDataFrame_transpose__impl", (DL_FUNC) &savvy_PlRDataFrame_transpose__impl, 3},
    {"savvy_PlRDataFrame_unpivot__impl", (DL_FUNC) &savvy_PlRDataFrame_unpivot__impl, 5},
    {"savvy_PlRDataFrame_width__impl", (DL_FUNC) &savvy_PlRDataFrame_width__impl, 1},
    {"savvy_PlRDataFrame_with_row_index__impl", (DL_FUNC) &savvy_PlRDataFrame_with_row_index__impl, 3},
    {"savvy_PlRDataFrame_write_parquet__impl", (DL_FUNC) &savvy_PlRDataFrame_write_parquet__impl, 14},
    {"savvy_PlRDataType__get_datatype_fields__impl", (DL_FUNC) &savvy_PlRDataType__get_datatype_fields__impl, 1},
    {"savvy_PlRDataType__get_dtype_names__impl", (DL_FUNC) &savvy_PlRDataType__get_dtype_names__impl, 1},
    {"savvy_PlRDataType_as_str__impl", (DL_FUNC) &savvy_PlRDataType_as_str__impl, 1},
    {"savvy_PlRDataType_eq__impl", (DL_FUNC) &savvy_PlRDataType_eq__impl, 2},
    {"savvy_PlRDataType_infer_supertype__impl", (DL_FUNC) &savvy_PlRDataType_infer_supertype__impl, 2},
    {"savvy_PlRDataType_max__impl", (DL_FUNC) &savvy_PlRDataType_max__impl, 1},
    {"savvy_PlRDataType_min__impl", (DL_FUNC) &savvy_PlRDataType_min__impl, 1},
    {"savvy_PlRDataType_ne__impl", (DL_FUNC) &savvy_PlRDataType_ne__impl, 2},
    {"savvy_PlRDataType_new_array__impl", (DL_FUNC) &savvy_PlRDataType_new_array__impl, 2},
    {"savvy_PlRDataType_new_categorical__impl", (DL_FUNC) &savvy_PlRDataType_new_categorical__impl, 1},
    {"savvy_PlRDataType_new_datetime__impl", (DL_FUNC) &savvy_PlRDataType_new_datetime__impl, 2},
    {"savvy_PlRDataType_new_decimal__impl", (DL_FUNC) &savvy_PlRDataType_new_decimal__impl, 2},
    {"savvy_PlRDataType_new_duration__impl", (DL_FUNC) &savvy_PlRDataType_new_duration__impl, 1},
    {"savvy_PlRDataType_new_enum__impl", (DL_FUNC) &savvy_PlRDataType_new_enum__impl, 1},
    {"savvy_PlRDataType_new_from_name__impl", (DL_FUNC) &savvy_PlRDataType_new_from_name__impl, 1},
    {"savvy_PlRDataType_new_list__impl", (DL_FUNC) &savvy_PlRDataType_new_list__impl, 1},
    {"savvy_PlRDataType_new_struct__impl", (DL_FUNC) &savvy_PlRDataType_new_struct__impl, 1},
    {"savvy_PlRExpr__meta_as_selector__impl", (DL_FUNC) &savvy_PlRExpr__meta_as_selector__impl, 1},
    {"savvy_PlRExpr__meta_selector_add__impl", (DL_FUNC) &savvy_PlRExpr__meta_selector_add__impl, 2},
    {"savvy_PlRExpr__meta_selector_and__impl", (DL_FUNC) &savvy_PlRExpr__meta_selector_and__impl, 2},
    {"savvy_PlRExpr__meta_selector_sub__impl", (DL_FUNC) &savvy_PlRExpr__meta_selector_sub__impl, 2},
    {"savvy_PlRExpr__meta_selector_xor__impl", (DL_FUNC) &savvy_PlRExpr__meta_selector_xor__impl, 2},
    {"savvy_PlRExpr_abs__impl", (DL_FUNC) &savvy_PlRExpr_abs__impl, 1},
    {"savvy_PlRExpr_add__impl", (DL_FUNC) &savvy_PlRExpr_add__impl, 2},
    {"savvy_PlRExpr_agg_groups__impl", (DL_FUNC) &savvy_PlRExpr_agg_groups__impl, 1},
    {"savvy_PlRExpr_alias__impl", (DL_FUNC) &savvy_PlRExpr_alias__impl, 2},
    {"savvy_PlRExpr_all__impl", (DL_FUNC) &savvy_PlRExpr_all__impl, 2},
    {"savvy_PlRExpr_and__impl", (DL_FUNC) &savvy_PlRExpr_and__impl, 2},
    {"savvy_PlRExpr_any__impl", (DL_FUNC) &savvy_PlRExpr_any__impl, 2},
    {"savvy_PlRExpr_append__impl", (DL_FUNC) &savvy_PlRExpr_append__impl, 3},
    {"savvy_PlRExpr_approx_n_unique__impl", (DL_FUNC) &savvy_PlRExpr_approx_n_unique__impl, 1},
    {"savvy_PlRExpr_arccos__impl", (DL_FUNC) &savvy_PlRExpr_arccos__impl, 1},
    {"savvy_PlRExpr_arccosh__impl", (DL_FUNC) &savvy_PlRExpr_arccosh__impl, 1},
    {"savvy_PlRExpr_arcsin__impl", (DL_FUNC) &savvy_PlRExpr_arcsin__impl, 1},
    {"savvy_PlRExpr_arcsinh__impl", (DL_FUNC) &savvy_PlRExpr_arcsinh__impl, 1},
    {"savvy_PlRExpr_arctan__impl", (DL_FUNC) &savvy_PlRExpr_arctan__impl, 1},
    {"savvy_PlRExpr_arctan2__impl", (DL_FUNC) &savvy_PlRExpr_arctan2__impl, 2},
    {"savvy_PlRExpr_arctanh__impl", (DL_FUNC) &savvy_PlRExpr_arctanh__impl, 1},
    {"savvy_PlRExpr_arg_max__impl", (DL_FUNC) &savvy_PlRExpr_arg_max__impl, 1},
    {"savvy_PlRExpr_arg_min__impl", (DL_FUNC) &savvy_PlRExpr_arg_min__impl, 1},
    {"savvy_PlRExpr_arg_sort__impl", (DL_FUNC) &savvy_PlRExpr_arg_sort__impl, 3},
    {"savvy_PlRExpr_arg_unique__impl", (DL_FUNC) &savvy_PlRExpr_arg_unique__impl, 1},
    {"savvy_PlRExpr_arr_all__impl", (DL_FUNC) &savvy_PlRExpr_arr_all__impl, 1},
    {"savvy_PlRExpr_arr_any__impl", (DL_FUNC) &savvy_PlRExpr_arr_any__impl, 1},
    {"savvy_PlRExpr_arr_arg_max__impl", (DL_FUNC) &savvy_PlRExpr_arr_arg_max__impl, 1},
    {"savvy_PlRExpr_arr_arg_min__impl", (DL_FUNC) &savvy_PlRExpr_arr_arg_min__impl, 1},
    {"savvy_PlRExpr_arr_contains__impl", (DL_FUNC) &savvy_PlRExpr_arr_contains__impl, 2},
    {"savvy_PlRExpr_arr_count_matches__impl", (DL_FUNC) &savvy_PlRExpr_arr_count_matches__impl, 2},
    {"savvy_PlRExpr_arr_get__impl", (DL_FUNC) &savvy_PlRExpr_arr_get__impl, 3},
    {"savvy_PlRExpr_arr_join__impl", (DL_FUNC) &savvy_PlRExpr_arr_join__impl, 3},
    {"savvy_PlRExpr_arr_max__impl", (DL_FUNC) &savvy_PlRExpr_arr_max__impl, 1},
    {"savvy_PlRExpr_arr_median__impl", (DL_FUNC) &savvy_PlRExpr_arr_median__impl, 1},
    {"savvy_PlRExpr_arr_min__impl", (DL_FUNC) &savvy_PlRExpr_arr_min__impl, 1},
    {"savvy_PlRExpr_arr_n_unique__impl", (DL_FUNC) &savvy_PlRExpr_arr_n_unique__impl, 1},
    {"savvy_PlRExpr_arr_reverse__impl", (DL_FUNC) &savvy_PlRExpr_arr_reverse__impl, 1},
    {"savvy_PlRExpr_arr_shift__impl", (DL_FUNC) &savvy_PlRExpr_arr_shift__impl, 2},
    {"savvy_PlRExpr_arr_sort__impl", (DL_FUNC) &savvy_PlRExpr_arr_sort__impl, 3},
    {"savvy_PlRExpr_arr_std__impl", (DL_FUNC) &savvy_PlRExpr_arr_std__impl, 2},
    {"savvy_PlRExpr_arr_sum__impl", (DL_FUNC) &savvy_PlRExpr_arr_sum__impl, 1},
    {"savvy_PlRExpr_arr_to_list__impl", (DL_FUNC) &savvy_PlRExpr_arr_to_list__impl, 1},
    {"savvy_PlRExpr_arr_unique__impl", (DL_FUNC) &savvy_PlRExpr_arr_unique__impl, 2},
    {"savvy_PlRExpr_arr_var__impl", (DL_FUNC) &savvy_PlRExpr_arr_var__impl, 2},
    {"savvy_PlRExpr_as_str__impl", (DL_FUNC) &savvy_PlRExpr_as_str__impl, 1},
    {"savvy_PlRExpr_backward_fill__impl", (DL_FUNC) &savvy_PlRExpr_backward_fill__impl, 2},
    {"savvy_PlRExpr_bin_base64_decode__impl", (DL_FUNC) &savvy_PlRExpr_bin_base64_decode__impl, 2},
    {"savvy_PlRExpr_bin_base64_encode__impl", (DL_FUNC) &savvy_PlRExpr_bin_base64_encode__impl, 1},
    {"savvy_PlRExpr_bin_contains__impl", (DL_FUNC) &savvy_PlRExpr_bin_contains__impl, 2},
    {"savvy_PlRExpr_bin_ends_with__impl", (DL_FUNC) &savvy_PlRExpr_bin_ends_with__impl, 2},
    {"savvy_PlRExpr_bin_hex_decode__impl", (DL_FUNC) &savvy_PlRExpr_bin_hex_decode__impl, 2},
    {"savvy_PlRExpr_bin_hex_encode__impl", (DL_FUNC) &savvy_PlRExpr_bin_hex_encode__impl, 1},
    {"savvy_PlRExpr_bin_size_bytes__impl", (DL_FUNC) &savvy_PlRExpr_bin_size_bytes__impl, 1},
    {"savvy_PlRExpr_bin_starts_with__impl", (DL_FUNC) &savvy_PlRExpr_bin_starts_with__impl, 2},
    {"savvy_PlRExpr_bitwise_and__impl", (DL_FUNC) &savvy_PlRExpr_bitwise_and__impl, 1},
    {"savvy_PlRExpr_bitwise_count_ones__impl", (DL_FUNC) &savvy_PlRExpr_bitwise_count_ones__impl, 1},
    {"savvy_PlRExpr_bitwise_count_zeros__impl", (DL_FUNC) &savvy_PlRExpr_bitwise_count_zeros__impl, 1},
    {"savvy_PlRExpr_bitwise_leading_ones__impl", (DL_FUNC) &savvy_PlRExpr_bitwise_leading_ones__impl, 1},
    {"savvy_PlRExpr_bitwise_leading_zeros__impl", (DL_FUNC) &savvy_PlRExpr_bitwise_leading_zeros__impl, 1},
    {"savvy_PlRExpr_bitwise_or__impl", (DL_FUNC) &savvy_PlRExpr_bitwise_or__impl, 1},
    {"savvy_PlRExpr_bitwise_trailing_ones__impl", (DL_FUNC) &savvy_PlRExpr_bitwise_trailing_ones__impl, 1},
    {"savvy_PlRExpr_bitwise_trailing_zeros__impl", (DL_FUNC) &savvy_PlRExpr_bitwise_trailing_zeros__impl, 1},
    {"savvy_PlRExpr_bitwise_xor__impl", (DL_FUNC) &savvy_PlRExpr_bitwise_xor__impl, 1},
    {"savvy_PlRExpr_bottom_k__impl", (DL_FUNC) &savvy_PlRExpr_bottom_k__impl, 2},
    {"savvy_PlRExpr_bottom_k_by__impl", (DL_FUNC) &savvy_PlRExpr_bottom_k_by__impl, 4},
    {"savvy_PlRExpr_cast__impl", (DL_FUNC) &savvy_PlRExpr_cast__impl, 4},
    {"savvy_PlRExpr_cat_get_categories__impl", (DL_FUNC) &savvy_PlRExpr_cat_get_categories__impl, 1},
    {"savvy_PlRExpr_cat_set_ordering__impl", (DL_FUNC) &savvy_PlRExpr_cat_set_ordering__impl, 2},
    {"savvy_PlRExpr_cbrt__impl", (DL_FUNC) &savvy_PlRExpr_cbrt__impl, 1},
    {"savvy_PlRExpr_ceil__impl", (DL_FUNC) &savvy_PlRExpr_ceil__impl, 1},
    {"savvy_PlRExpr_clip__impl", (DL_FUNC) &savvy_PlRExpr_clip__impl, 3},
    {"savvy_PlRExpr_compute_tree_format__impl", (DL_FUNC) &savvy_PlRExpr_compute_tree_format__impl, 2},
    {"savvy_PlRExpr_cos__impl", (DL_FUNC) &savvy_PlRExpr_cos__impl, 1},
    {"savvy_PlRExpr_cosh__impl", (DL_FUNC) &savvy_PlRExpr_cosh__impl, 1},
    {"savvy_PlRExpr_cot__impl", (DL_FUNC) &savvy_PlRExpr_cot__impl, 1},
    {"savvy_PlRExpr_count__impl", (DL_FUNC) &savvy_PlRExpr_count__impl, 1},
    {"savvy_PlRExpr_cum_count__impl", (DL_FUNC) &savvy_PlRExpr_cum_count__impl, 2},
    {"savvy_PlRExpr_cum_max__impl", (DL_FUNC) &savvy_PlRExpr_cum_max__impl, 2},
    {"savvy_PlRExpr_cum_min__impl", (DL_FUNC) &savvy_PlRExpr_cum_min__impl, 2},
    {"savvy_PlRExpr_cum_prod__impl", (DL_FUNC) &savvy_PlRExpr_cum_prod__impl, 2},
    {"savvy_PlRExpr_cum_sum__impl", (DL_FUNC) &savvy_PlRExpr_cum_sum__impl, 2},
    {"savvy_PlRExpr_cumulative_eval__impl", (DL_FUNC) &savvy_PlRExpr_cumulative_eval__impl, 4},
    {"savvy_PlRExpr_cut__impl", (DL_FUNC) &savvy_PlRExpr_cut__impl, 5},
    {"savvy_PlRExpr_degrees__impl", (DL_FUNC) &savvy_PlRExpr_degrees__impl, 1},
    {"savvy_PlRExpr_deserialize_binary__impl", (DL_FUNC) &savvy_PlRExpr_deserialize_binary__impl, 1},
    {"savvy_PlRExpr_deserialize_json__impl", (DL_FUNC) &savvy_PlRExpr_deserialize_json__impl, 1},
    {"savvy_PlRExpr_diff__impl", (DL_FUNC) &savvy_PlRExpr_diff__impl, 3},
    {"savvy_PlRExpr_div__impl", (DL_FUNC) &savvy_PlRExpr_div__impl, 2},
    {"savvy_PlRExpr_dot__impl", (DL_FUNC) &savvy_PlRExpr_dot__impl, 2},
    {"savvy_PlRExpr_drop_nans__impl", (DL_FUNC) &savvy_PlRExpr_drop_nans__impl, 1},
    {"savvy_PlRExpr_drop_nulls__impl", (DL_FUNC) &savvy_PlRExpr_drop_nulls__impl, 1},
    {"savvy_PlRExpr_dt_add_business_days__impl", (DL_FUNC) &savvy_PlRExpr_dt_add_business_days__impl, 5},
    {"savvy_PlRExpr_dt_base_utc_offset__impl", (DL_FUNC) &savvy_PlRExpr_dt_base_utc_offset__impl, 1},
    {"savvy_PlRExpr_dt_cast_time_unit__impl", (DL_FUNC) &savvy_PlRExpr_dt_cast_time_unit__impl, 2},
    {"savvy_PlRExpr_dt_century__impl", (DL_FUNC) &savvy_PlRExpr_dt_century__impl, 1},
    {"savvy_PlRExpr_dt_combine__impl", (DL_FUNC) &savvy_PlRExpr_dt_combine__impl, 3},
    {"savvy_PlRExpr_dt_convert_time_zone__impl", (DL_FUNC) &savvy_PlRExpr_dt_convert_time_zone__impl, 2},
    {"savvy_PlRExpr_dt_date__impl", (DL_FUNC) &savvy_PlRExpr_dt_date__impl, 1},
    {"savvy_PlRExpr_dt_day__impl", (DL_FUNC) &savvy_PlRExpr_dt_day__impl, 1},
    {"savvy_PlRExpr_dt_dst_offset__impl", (DL_FUNC) &savvy_PlRExpr_dt_dst_offset__impl, 1},
    {"savvy_PlRExpr_dt_epoch_seconds__impl", (DL_FUNC) &savvy_PlRExpr_dt_epoch_seconds__impl, 1},
    {"savvy_PlRExpr_dt_hour__impl", (DL_FUNC) &savvy_PlRExpr_dt_hour__impl, 1},
    {"savvy_PlRExpr_dt_is_leap_year__impl", (DL_FUNC) &savvy_PlRExpr_dt_is_leap_year__impl, 1},
    {"savvy_PlRExpr_dt_iso_year__impl", (DL_FUNC) &savvy_PlRExpr_dt_iso_year__impl, 1},
    {"savvy_PlRExpr_dt_microsecond__impl", (DL_FUNC) &savvy_PlRExpr_dt_microsecond__impl, 1},
    {"savvy_PlRExpr_dt_millisecond__impl", (DL_FUNC) &savvy_PlRExpr_dt_millisecond__impl, 1},
    {"savvy_PlRExpr_dt_minute__impl", (DL_FUNC) &savvy_PlRExpr_dt_minute__impl, 1},
    {"savvy_PlRExpr_dt_month__impl", (DL_FUNC) &savvy_PlRExpr_dt_month__impl, 1},
    {"savvy_PlRExpr_dt_month_end__impl", (DL_FUNC) &savvy_PlRExpr_dt_month_end__impl, 1},
    {"savvy_PlRExpr_dt_month_start__impl", (DL_FUNC) &savvy_PlRExpr_dt_month_start__impl, 1},
    {"savvy_PlRExpr_dt_nanosecond__impl", (DL_FUNC) &savvy_PlRExpr_dt_nanosecond__impl, 1},
    {"savvy_PlRExpr_dt_offset_by__impl", (DL_FUNC) &savvy_PlRExpr_dt_offset_by__impl, 2},
    {"savvy_PlRExpr_dt_ordinal_day__impl", (DL_FUNC) &savvy_PlRExpr_dt_ordinal_day__impl, 1},
    {"savvy_PlRExpr_dt_quarter__impl", (DL_FUNC) &savvy_PlRExpr_dt_quarter__impl, 1},
    {"savvy_PlRExpr_dt_replace_time_zone__impl", (DL_FUNC) &savvy_PlRExpr_dt_replace_time_zone__impl, 4},
    {"savvy_PlRExpr_dt_round__impl", (DL_FUNC) &savvy_PlRExpr_dt_round__impl, 2},
    {"savvy_PlRExpr_dt_second__impl", (DL_FUNC) &savvy_PlRExpr_dt_second__impl, 1},
    {"savvy_PlRExpr_dt_time__impl", (DL_FUNC) &savvy_PlRExpr_dt_time__impl, 1},
    {"savvy_PlRExpr_dt_timestamp__impl", (DL_FUNC) &savvy_PlRExpr_dt_timestamp__impl, 2},
    {"savvy_PlRExpr_dt_to_string__impl", (DL_FUNC) &savvy_PlRExpr_dt_to_string__impl, 2},
    {"savvy_PlRExpr_dt_total_days__impl", (DL_FUNC) &savvy_PlRExpr_dt_total_days__impl, 1},
    {"savvy_PlRExpr_dt_total_hours__impl", (DL_FUNC) &savvy_PlRExpr_dt_total_hours__impl, 1},
    {"savvy_PlRExpr_dt_total_microseconds__impl", (DL_FUNC) &savvy_PlRExpr_dt_total_microseconds__impl, 1},
    {"savvy_PlRExpr_dt_total_milliseconds__impl", (DL_FUNC) &savvy_PlRExpr_dt_total_milliseconds__impl, 1},
    {"savvy_PlRExpr_dt_total_minutes__impl", (DL_FUNC) &savvy_PlRExpr_dt_total_minutes__impl, 1},
    {"savvy_PlRExpr_dt_total_nanoseconds__impl", (DL_FUNC) &savvy_PlRExpr_dt_total_nanoseconds__impl, 1},
    {"savvy_PlRExpr_dt_total_seconds__impl", (DL_FUNC) &savvy_PlRExpr_dt_total_seconds__impl, 1},
    {"savvy_PlRExpr_dt_truncate__impl", (DL_FUNC) &savvy_PlRExpr_dt_truncate__impl, 2},
    {"savvy_PlRExpr_dt_week__impl", (DL_FUNC) &savvy_PlRExpr_dt_week__impl, 1},
    {"savvy_PlRExpr_dt_weekday__impl", (DL_FUNC) &savvy_PlRExpr_dt_weekday__impl, 1},
    {"savvy_PlRExpr_dt_with_time_unit__impl", (DL_FUNC) &savvy_PlRExpr_dt_with_time_unit__impl, 2},
    {"savvy_PlRExpr_dt_year__impl", (DL_FUNC) &savvy_PlRExpr_dt_year__impl, 1},
    {"savvy_PlRExpr_entropy__impl", (DL_FUNC) &savvy_PlRExpr_entropy__impl, 3},
    {"savvy_PlRExpr_eq__impl", (DL_FUNC) &savvy_PlRExpr_eq__impl, 2},
    {"savvy_PlRExpr_eq_missing__impl", (DL_FUNC) &savvy_PlRExpr_eq_missing__impl, 2},
    {"savvy_PlRExpr_ewm_mean__impl", (DL_FUNC) &savvy_PlRExpr_ewm_mean__impl, 5},
    {"savvy_PlRExpr_ewm_mean_by__impl", (DL_FUNC) &savvy_PlRExpr_ewm_mean_by__impl, 3},
    {"savvy_PlRExpr_ewm_std__impl", (DL_FUNC) &savvy_PlRExpr_ewm_std__impl, 6},
    {"savvy_PlRExpr_ewm_var__impl", (DL_FUNC) &savvy_PlRExpr_ewm_var__impl, 6},
    {"savvy_PlRExpr_exclude__impl", (DL_FUNC) &savvy_PlRExpr_exclude__impl, 2},
    {"savvy_PlRExpr_exclude_dtype__impl", (DL_FUNC) &savvy_PlRExpr_exclude_dtype__impl, 2},
    {"savvy_PlRExpr_exp__impl", (DL_FUNC) &savvy_PlRExpr_exp__impl, 1},
    {"savvy_PlRExpr_explode__impl", (DL_FUNC) &savvy_PlRExpr_explode__impl, 1},
    {"savvy_PlRExpr_extend_constant__impl", (DL_FUNC) &savvy_PlRExpr_extend_constant__impl, 3},
    {"savvy_PlRExpr_fill_nan__impl", (DL_FUNC) &savvy_PlRExpr_fill_nan__impl, 2},
    {"savvy_PlRExpr_fill_null__impl", (DL_FUNC) &savvy_PlRExpr_fill_null__impl, 2},
    {"savvy_PlRExpr_fill_null_with_strategy__impl", (DL_FUNC) &savvy_PlRExpr_fill_null_with_strategy__impl, 3},
    {"savvy_PlRExpr_filter__impl", (DL_FUNC) &savvy_PlRExpr_filter__impl, 2},
    {"savvy_PlRExpr_first__impl", (DL_FUNC) &savvy_PlRExpr_first__impl, 1},
    {"savvy_PlRExpr_floor__impl", (DL_FUNC) &savvy_PlRExpr_floor__impl, 1},
    {"savvy_PlRExpr_floor_div__impl", (DL_FUNC) &savvy_PlRExpr_floor_div__impl, 2},
    {"savvy_PlRExpr_forward_fill__impl", (DL_FUNC) &savvy_PlRExpr_forward_fill__impl, 2},
    {"savvy_PlRExpr_gather__impl", (DL_FUNC) &savvy_PlRExpr_gather__impl, 2},
    {"savvy_PlRExpr_gather_every__impl", (DL_FUNC) &savvy_PlRExpr_gather_every__impl, 3},
    {"savvy_PlRExpr_get__impl", (DL_FUNC) &savvy_PlRExpr_get__impl, 2},
    {"savvy_PlRExpr_gt__impl", (DL_FUNC) &savvy_PlRExpr_gt__impl, 2},
    {"savvy_PlRExpr_gt_eq__impl", (DL_FUNC) &savvy_PlRExpr_gt_eq__impl, 2},
    {"savvy_PlRExpr_hash__impl", (DL_FUNC) &savvy_PlRExpr_hash__impl, 5},
    {"savvy_PlRExpr_hist__impl", (DL_FUNC) &savvy_PlRExpr_hist__impl, 5},
    {"savvy_PlRExpr_implode__impl", (DL_FUNC) &savvy_PlRExpr_implode__impl, 1},
    {"savvy_PlRExpr_interpolate__impl", (DL_FUNC) &savvy_PlRExpr_interpolate__impl, 2},
    {"savvy_PlRExpr_interpolate_by__impl", (DL_FUNC) &savvy_PlRExpr_interpolate_by__impl, 2},
    {"savvy_PlRExpr_is_between__impl", (DL_FUNC) &savvy_PlRExpr_is_between__impl, 4},
    {"savvy_PlRExpr_is_duplicated__impl", (DL_FUNC) &savvy_PlRExpr_is_duplicated__impl, 1},
    {"savvy_PlRExpr_is_finite__impl", (DL_FUNC) &savvy_PlRExpr_is_finite__impl, 1},
    {"savvy_PlRExpr_is_first_distinct__impl", (DL_FUNC) &savvy_PlRExpr_is_first_distinct__impl, 1},
    {"savvy_PlRExpr_is_in__impl", (DL_FUNC) &savvy_PlRExpr_is_in__impl, 2},
    {"savvy_PlRExpr_is_infinite__impl", (DL_FUNC) &savvy_PlRExpr_is_infinite__impl, 1},
    {"savvy_PlRExpr_is_last_distinct__impl", (DL_FUNC) &savvy_PlRExpr_is_last_distinct__impl, 1},
    {"savvy_PlRExpr_is_nan__impl", (DL_FUNC) &savvy_PlRExpr_is_nan__impl, 1},
    {"savvy_PlRExpr_is_not_nan__impl", (DL_FUNC) &savvy_PlRExpr_is_not_nan__impl, 1},
    {"savvy_PlRExpr_is_not_null__impl", (DL_FUNC) &savvy_PlRExpr_is_not_null__impl, 1},
    {"savvy_PlRExpr_is_null__impl", (DL_FUNC) &savvy_PlRExpr_is_null__impl, 1},
    {"savvy_PlRExpr_is_unique__impl", (DL_FUNC) &savvy_PlRExpr_is_unique__impl, 1},
    {"savvy_PlRExpr_kurtosis__impl", (DL_FUNC) &savvy_PlRExpr_kurtosis__impl, 3},
    {"savvy_PlRExpr_last__impl", (DL_FUNC) &savvy_PlRExpr_last__impl, 1},
    {"savvy_PlRExpr_len__impl", (DL_FUNC) &savvy_PlRExpr_len__impl, 1},
    {"savvy_PlRExpr_list_all__impl", (DL_FUNC) &savvy_PlRExpr_list_all__impl, 1},
    {"savvy_PlRExpr_list_any__impl", (DL_FUNC) &savvy_PlRExpr_list_any__impl, 1},
    {"savvy_PlRExpr_list_arg_max__impl", (DL_FUNC) &savvy_PlRExpr_list_arg_max__impl, 1},
    {"savvy_PlRExpr_list_arg_min__impl", (DL_FUNC) &savvy_PlRExpr_list_arg_min__impl, 1},
    {"savvy_PlRExpr_list_contains__impl", (DL_FUNC) &savvy_PlRExpr_list_contains__impl, 2},
    {"savvy_PlRExpr_list_count_matches__impl", (DL_FUNC) &savvy_PlRExpr_list_count_matches__impl, 2},
    {"savvy_PlRExpr_list_diff__impl", (DL_FUNC) &savvy_PlRExpr_list_diff__impl, 3},
    {"savvy_PlRExpr_list_drop_nulls__impl", (DL_FUNC) &savvy_PlRExpr_list_drop_nulls__impl, 1},
    {"savvy_PlRExpr_list_eval__impl", (DL_FUNC) &savvy_PlRExpr_list_eval__impl, 3},
    {"savvy_PlRExpr_list_gather__impl", (DL_FUNC) &savvy_PlRExpr_list_gather__impl, 3},
    {"savvy_PlRExpr_list_gather_every__impl", (DL_FUNC) &savvy_PlRExpr_list_gather_every__impl, 3},
    {"savvy_PlRExpr_list_get__impl", (DL_FUNC) &savvy_PlRExpr_list_get__impl, 3},
    {"savvy_PlRExpr_list_join__impl", (DL_FUNC) &savvy_PlRExpr_list_join__impl, 3},
    {"savvy_PlRExpr_list_len__impl", (DL_FUNC) &savvy_PlRExpr_list_len__impl, 1},
    {"savvy_PlRExpr_list_max__impl", (DL_FUNC) &savvy_PlRExpr_list_max__impl, 1},
    {"savvy_PlRExpr_list_mean__impl", (DL_FUNC) &savvy_PlRExpr_list_mean__impl, 1},
    {"savvy_PlRExpr_list_median__impl", (DL_FUNC) &savvy_PlRExpr_list_median__impl, 1},
    {"savvy_PlRExpr_list_min__impl", (DL_FUNC) &savvy_PlRExpr_list_min__impl, 1},
    {"savvy_PlRExpr_list_n_unique__impl", (DL_FUNC) &savvy_PlRExpr_list_n_unique__impl, 1},
    {"savvy_PlRExpr_list_reverse__impl", (DL_FUNC) &savvy_PlRExpr_list_reverse__impl, 1},
    {"savvy_PlRExpr_list_sample_frac__impl", (DL_FUNC) &savvy_PlRExpr_list_sample_frac__impl, 5},
    {"savvy_PlRExpr_list_sample_n__impl", (DL_FUNC) &savvy_PlRExpr_list_sample_n__impl, 5},
    {"savvy_PlRExpr_list_set_operation__impl", (DL_FUNC) &savvy_PlRExpr_list_set_operation__impl, 3},
    {"savvy_PlRExpr_list_shift__impl", (DL_FUNC) &savvy_PlRExpr_list_shift__impl, 2},
    {"savvy_PlRExpr_list_slice__impl", (DL_FUNC) &savvy_PlRExpr_list_slice__impl, 3},
    {"savvy_PlRExpr_list_sort__impl", (DL_FUNC) &savvy_PlRExpr_list_sort__impl, 3},
    {"savvy_PlRExpr_list_std__impl", (DL_FUNC) &savvy_PlRExpr_list_std__impl, 2},
    {"savvy_PlRExpr_list_sum__impl", (DL_FUNC) &savvy_PlRExpr_list_sum__impl, 1},
    {"savvy_PlRExpr_list_to_array__impl", (DL_FUNC) &savvy_PlRExpr_list_to_array__impl, 2},
    {"savvy_PlRExpr_list_unique__impl", (DL_FUNC) &savvy_PlRExpr_list_unique__impl, 2},
    {"savvy_PlRExpr_list_var__impl", (DL_FUNC) &savvy_PlRExpr_list_var__impl, 2},
    {"savvy_PlRExpr_log__impl", (DL_FUNC) &savvy_PlRExpr_log__impl, 2},
    {"savvy_PlRExpr_log1p__impl", (DL_FUNC) &savvy_PlRExpr_log1p__impl, 1},
    {"savvy_PlRExpr_lower_bound__impl", (DL_FUNC) &savvy_PlRExpr_lower_bound__impl, 1},
    {"savvy_PlRExpr_lt__impl", (DL_FUNC) &savvy_PlRExpr_lt__impl, 2},
    {"savvy_PlRExpr_lt_eq__impl", (DL_FUNC) &savvy_PlRExpr_lt_eq__impl, 2},
    {"savvy_PlRExpr_map_batches__impl", (DL_FUNC) &savvy_PlRExpr_map_batches__impl, 4},
    {"savvy_PlRExpr_max__impl", (DL_FUNC) &savvy_PlRExpr_max__impl, 1},
    {"savvy_PlRExpr_mean__impl", (DL_FUNC) &savvy_PlRExpr_mean__impl, 1},
    {"savvy_PlRExpr_median__impl", (DL_FUNC) &savvy_PlRExpr_median__impl, 1},
    {"savvy_PlRExpr_meta_eq__impl", (DL_FUNC) &savvy_PlRExpr_meta_eq__impl, 2},
    {"savvy_PlRExpr_meta_has_multiple_outputs__impl", (DL_FUNC) &savvy_PlRExpr_meta_has_multiple_outputs__impl, 1},
    {"savvy_PlRExpr_meta_is_column__impl", (DL_FUNC) &savvy_PlRExpr_meta_is_column__impl, 1},
    {"savvy_PlRExpr_meta_is_column_selection__impl", (DL_FUNC) &savvy_PlRExpr_meta_is_column_selection__impl, 2},
    {"savvy_PlRExpr_meta_is_regex_projection__impl", (DL_FUNC) &savvy_PlRExpr_meta_is_regex_projection__impl, 1},
    {"savvy_PlRExpr_meta_output_name__impl", (DL_FUNC) &savvy_PlRExpr_meta_output_name__impl, 1},
    {"savvy_PlRExpr_meta_pop__impl", (DL_FUNC) &savvy_PlRExpr_meta_pop__impl, 1},
    {"savvy_PlRExpr_meta_root_names__impl", (DL_FUNC) &savvy_PlRExpr_meta_root_names__impl, 1},
    {"savvy_PlRExpr_meta_undo_aliases__impl", (DL_FUNC) &savvy_PlRExpr_meta_undo_aliases__impl, 1},
    {"savvy_PlRExpr_min__impl", (DL_FUNC) &savvy_PlRExpr_min__impl, 1},
    {"savvy_PlRExpr_mode__impl", (DL_FUNC) &savvy_PlRExpr_mode__impl, 1},
    {"savvy_PlRExpr_mul__impl", (DL_FUNC) &savvy_PlRExpr_mul__impl, 2},
    {"savvy_PlRExpr_n_unique__impl", (DL_FUNC) &savvy_PlRExpr_n_unique__impl, 1},
    {"savvy_PlRExpr_name_keep__impl", (DL_FUNC) &savvy_PlRExpr_name_keep__impl, 1},
    {"savvy_PlRExpr_name_prefix__impl", (DL_FUNC) &savvy_PlRExpr_name_prefix__impl, 2},
    {"savvy_PlRExpr_name_prefix_fields__impl", (DL_FUNC) &savvy_PlRExpr_name_prefix_fields__impl, 2},
    {"savvy_PlRExpr_name_suffix__impl", (DL_FUNC) &savvy_PlRExpr_name_suffix__impl, 2},
    {"savvy_PlRExpr_name_suffix_fields__impl", (DL_FUNC) &savvy_PlRExpr_name_suffix_fields__impl, 2},
    {"savvy_PlRExpr_name_to_lowercase__impl", (DL_FUNC) &savvy_PlRExpr_name_to_lowercase__impl, 1},
    {"savvy_PlRExpr_name_to_uppercase__impl", (DL_FUNC) &savvy_PlRExpr_name_to_uppercase__impl, 1},
    {"savvy_PlRExpr_nan_max__impl", (DL_FUNC) &savvy_PlRExpr_nan_max__impl, 1},
    {"savvy_PlRExpr_nan_min__impl", (DL_FUNC) &savvy_PlRExpr_nan_min__impl, 1},
    {"savvy_PlRExpr_neg__impl", (DL_FUNC) &savvy_PlRExpr_neg__impl, 1},
    {"savvy_PlRExpr_neq__impl", (DL_FUNC) &savvy_PlRExpr_neq__impl, 2},
    {"savvy_PlRExpr_neq_missing__impl", (DL_FUNC) &savvy_PlRExpr_neq_missing__impl, 2},
    {"savvy_PlRExpr_not__impl", (DL_FUNC) &savvy_PlRExpr_not__impl, 1},
    {"savvy_PlRExpr_null_count__impl", (DL_FUNC) &savvy_PlRExpr_null_count__impl, 1},
    {"savvy_PlRExpr_or__impl", (DL_FUNC) &savvy_PlRExpr_or__impl, 2},
    {"savvy_PlRExpr_over__impl", (DL_FUNC) &savvy_PlRExpr_over__impl, 6},
    {"savvy_PlRExpr_pct_change__impl", (DL_FUNC) &savvy_PlRExpr_pct_change__impl, 2},
    {"savvy_PlRExpr_peak_max__impl", (DL_FUNC) &savvy_PlRExpr_peak_max__impl, 1},
    {"savvy_PlRExpr_peak_min__impl", (DL_FUNC) &savvy_PlRExpr_peak_min__impl, 1},
    {"savvy_PlRExpr_pow__impl", (DL_FUNC) &savvy_PlRExpr_pow__impl, 2},
    {"savvy_PlRExpr_product__impl", (DL_FUNC) &savvy_PlRExpr_product__impl, 1},
    {"savvy_PlRExpr_qcut__impl", (DL_FUNC) &savvy_PlRExpr_qcut__impl, 6},
    {"savvy_PlRExpr_qcut_uniform__impl", (DL_FUNC) &savvy_PlRExpr_qcut_uniform__impl, 6},
    {"savvy_PlRExpr_quantile__impl", (DL_FUNC) &savvy_PlRExpr_quantile__impl, 3},
    {"savvy_PlRExpr_radians__impl", (DL_FUNC) &savvy_PlRExpr_radians__impl, 1},
    {"savvy_PlRExpr_rank__impl", (DL_FUNC) &savvy_PlRExpr_rank__impl, 4},
    {"savvy_PlRExpr_rechunk__impl", (DL_FUNC) &savvy_PlRExpr_rechunk__impl, 1},
    {"savvy_PlRExpr_reinterpret__impl", (DL_FUNC) &savvy_PlRExpr_reinterpret__impl, 2},
    {"savvy_PlRExpr_rem__impl", (DL_FUNC) &savvy_PlRExpr_rem__impl, 2},
    {"savvy_PlRExpr_repeat_by__impl", (DL_FUNC) &savvy_PlRExpr_repeat_by__impl, 2},
    {"savvy_PlRExpr_replace__impl", (DL_FUNC) &savvy_PlRExpr_replace__impl, 3},
    {"savvy_PlRExpr_replace_strict__impl", (DL_FUNC) &savvy_PlRExpr_replace_strict__impl, 5},
    {"savvy_PlRExpr_reshape__impl", (DL_FUNC) &savvy_PlRExpr_reshape__impl, 2},
    {"savvy_PlRExpr_reverse__impl", (DL_FUNC) &savvy_PlRExpr_reverse__impl, 1},
    {"savvy_PlRExpr_rle__impl", (DL_FUNC) &savvy_PlRExpr_rle__impl, 1},
    {"savvy_PlRExpr_rle_id__impl", (DL_FUNC) &savvy_PlRExpr_rle_id__impl, 1},
    {"savvy_PlRExpr_rolling__impl", (DL_FUNC) &savvy_PlRExpr_rolling__impl, 5},
    {"savvy_PlRExpr_rolling_max__impl", (DL_FUNC) &savvy_PlRExpr_rolling_max__impl, 5},
    {"savvy_PlRExpr_rolling_max_by__impl", (DL_FUNC) &savvy_PlRExpr_rolling_max_by__impl, 5},
    {"savvy_PlRExpr_rolling_mean__impl", (DL_FUNC) &savvy_PlRExpr_rolling_mean__impl, 5},
    {"savvy_PlRExpr_rolling_mean_by__impl", (DL_FUNC) &savvy_PlRExpr_rolling_mean_by__impl, 5},
    {"savvy_PlRExpr_rolling_median__impl", (DL_FUNC) &savvy_PlRExpr_rolling_median__impl, 5},
    {"savvy_PlRExpr_rolling_median_by__impl", (DL_FUNC) &savvy_PlRExpr_rolling_median_by__impl, 5},
    {"savvy_PlRExpr_rolling_min__impl", (DL_FUNC) &savvy_PlRExpr_rolling_min__impl, 5},
    {"savvy_PlRExpr_rolling_min_by__impl", (DL_FUNC) &savvy_PlRExpr_rolling_min_by__impl, 5},
    {"savvy_PlRExpr_rolling_quantile__impl", (DL_FUNC) &savvy_PlRExpr_rolling_quantile__impl, 7},
    {"savvy_PlRExpr_rolling_quantile_by__impl", (DL_FUNC) &savvy_PlRExpr_rolling_quantile_by__impl, 7},
    {"savvy_PlRExpr_rolling_skew__impl", (DL_FUNC) &savvy_PlRExpr_rolling_skew__impl, 3},
    {"savvy_PlRExpr_rolling_std__impl", (DL_FUNC) &savvy_PlRExpr_rolling_std__impl, 6},
    {"savvy_PlRExpr_rolling_std_by__impl", (DL_FUNC) &savvy_PlRExpr_rolling_std_by__impl, 6},
    {"savvy_PlRExpr_rolling_sum__impl", (DL_FUNC) &savvy_PlRExpr_rolling_sum__impl, 5},
    {"savvy_PlRExpr_rolling_sum_by__impl", (DL_FUNC) &savvy_PlRExpr_rolling_sum_by__impl, 5},
    {"savvy_PlRExpr_rolling_var__impl", (DL_FUNC) &savvy_PlRExpr_rolling_var__impl, 6},
    {"savvy_PlRExpr_rolling_var_by__impl", (DL_FUNC) &savvy_PlRExpr_rolling_var_by__impl, 6},
    {"savvy_PlRExpr_round__impl", (DL_FUNC) &savvy_PlRExpr_round__impl, 2},
    {"savvy_PlRExpr_round_sig_figs__impl", (DL_FUNC) &savvy_PlRExpr_round_sig_figs__impl, 2},
    {"savvy_PlRExpr_sample_frac__impl", (DL_FUNC) &savvy_PlRExpr_sample_frac__impl, 5},
    {"savvy_PlRExpr_sample_n__impl", (DL_FUNC) &savvy_PlRExpr_sample_n__impl, 5},
    {"savvy_PlRExpr_search_sorted__impl", (DL_FUNC) &savvy_PlRExpr_search_sorted__impl, 3},
    {"savvy_PlRExpr_serialize_binary__impl", (DL_FUNC) &savvy_PlRExpr_serialize_binary__impl, 1},
    {"savvy_PlRExpr_serialize_json__impl", (DL_FUNC) &savvy_PlRExpr_serialize_json__impl, 1},
    {"savvy_PlRExpr_set_sorted_flag__impl", (DL_FUNC) &savvy_PlRExpr_set_sorted_flag__impl, 2},
    {"savvy_PlRExpr_shift__impl", (DL_FUNC) &savvy_PlRExpr_shift__impl, 3},
    {"savvy_PlRExpr_shrink_dtype__impl", (DL_FUNC) &savvy_PlRExpr_shrink_dtype__impl, 1},
    {"savvy_PlRExpr_shuffle__impl", (DL_FUNC) &savvy_PlRExpr_shuffle__impl, 2},
    {"savvy_PlRExpr_sign__impl", (DL_FUNC) &savvy_PlRExpr_sign__impl, 1},
    {"savvy_PlRExpr_sin__impl", (DL_FUNC) &savvy_PlRExpr_sin__impl, 1},
    {"savvy_PlRExpr_sinh__impl", (DL_FUNC) &savvy_PlRExpr_sinh__impl, 1},
    {"savvy_PlRExpr_skew__impl", (DL_FUNC) &savvy_PlRExpr_skew__impl, 2},
    {"savvy_PlRExpr_slice__impl", (DL_FUNC) &savvy_PlRExpr_slice__impl, 3},
    {"savvy_PlRExpr_sort_by__impl", (DL_FUNC) &savvy_PlRExpr_sort_by__impl, 6},
    {"savvy_PlRExpr_sort_with__impl", (DL_FUNC) &savvy_PlRExpr_sort_with__impl, 3},
    {"savvy_PlRExpr_sqrt__impl", (DL_FUNC) &savvy_PlRExpr_sqrt__impl, 1},
    {"savvy_PlRExpr_std__impl", (DL_FUNC) &savvy_PlRExpr_std__impl, 2},
    {"savvy_PlRExpr_str_base64_decode__impl", (DL_FUNC) &savvy_PlRExpr_str_base64_decode__impl, 2},
    {"savvy_PlRExpr_str_base64_encode__impl", (DL_FUNC) &savvy_PlRExpr_str_base64_encode__impl, 1},
    {"savvy_PlRExpr_str_contains__impl", (DL_FUNC) &savvy_PlRExpr_str_contains__impl, 4},
    {"savvy_PlRExpr_str_contains_any__impl", (DL_FUNC) &savvy_PlRExpr_str_contains_any__impl, 3},
    {"savvy_PlRExpr_str_count_matches__impl", (DL_FUNC) &savvy_PlRExpr_str_count_matches__impl, 3},
    {"savvy_PlRExpr_str_ends_with__impl", (DL_FUNC) &savvy_PlRExpr_str_ends_with__impl, 2},
    {"savvy_PlRExpr_str_extract__impl", (DL_FUNC) &savvy_PlRExpr_str_extract__impl, 3},
    {"savvy_PlRExpr_str_extract_all__impl", (DL_FUNC) &savvy_PlRExpr_str_extract_all__impl, 2},
    {"savvy_PlRExpr_str_extract_groups__impl", (DL_FUNC) &savvy_PlRExpr_str_extract_groups__impl, 2},
    {"savvy_PlRExpr_str_extract_many__impl", (DL_FUNC) &savvy_PlRExpr_str_extract_many__impl, 4},
    {"savvy_PlRExpr_str_find__impl", (DL_FUNC) &savvy_PlRExpr_str_find__impl, 4},
    {"savvy_PlRExpr_str_head__impl", (DL_FUNC) &savvy_PlRExpr_str_head__impl, 2},
    {"savvy_PlRExpr_str_hex_decode__impl", (DL_FUNC) &savvy_PlRExpr_str_hex_decode__impl, 2},
    {"savvy_PlRExpr_str_hex_encode__impl", (DL_FUNC) &savvy_PlRExpr_str_hex_encode__impl, 1},
    {"savvy_PlRExpr_str_join__impl", (DL_FUNC) &savvy_PlRExpr_str_join__impl, 3},
    {"savvy_PlRExpr_str_json_decode__impl", (DL_FUNC) &savvy_PlRExpr_str_json_decode__impl, 3},
    {"savvy_PlRExpr_str_json_path_match__impl", (DL_FUNC) &savvy_PlRExpr_str_json_path_match__impl, 2},
    {"savvy_PlRExpr_str_len_bytes__impl", (DL_FUNC) &savvy_PlRExpr_str_len_bytes__impl, 1},
    {"savvy_PlRExpr_str_len_chars__impl", (DL_FUNC) &savvy_PlRExpr_str_len_chars__impl, 1},
    {"savvy_PlRExpr_str_pad_end__impl", (DL_FUNC) &savvy_PlRExpr_str_pad_end__impl, 3},
    {"savvy_PlRExpr_str_pad_start__impl", (DL_FUNC) &savvy_PlRExpr_str_pad_start__impl, 3},
    {"savvy_PlRExpr_str_replace__impl", (DL_FUNC) &savvy_PlRExpr_str_replace__impl, 5},
    {"savvy_PlRExpr_str_replace_all__impl", (DL_FUNC) &savvy_PlRExpr_str_replace_all__impl, 4},
    {"savvy_PlRExpr_str_replace_many__impl", (DL_FUNC) &savvy_PlRExpr_str_replace_many__impl, 4},
    {"savvy_PlRExpr_str_reverse__impl", (DL_FUNC) &savvy_PlRExpr_str_reverse__impl, 1},
    {"savvy_PlRExpr_str_slice__impl", (DL_FUNC) &savvy_PlRExpr_str_slice__impl, 3},
    {"savvy_PlRExpr_str_split__impl", (DL_FUNC) &savvy_PlRExpr_str_split__impl, 3},
    {"savvy_PlRExpr_str_split_exact__impl", (DL_FUNC) &savvy_PlRExpr_str_split_exact__impl, 4},
    {"savvy_PlRExpr_str_splitn__impl", (DL_FUNC) &savvy_PlRExpr_str_splitn__impl, 3},
    {"savvy_PlRExpr_str_starts_with__impl", (DL_FUNC) &savvy_PlRExpr_str_starts_with__impl, 2},
    {"savvy_PlRExpr_str_strip_chars__impl", (DL_FUNC) &savvy_PlRExpr_str_strip_chars__impl, 2},
    {"savvy_PlRExpr_str_strip_chars_end__impl", (DL_FUNC) &savvy_PlRExpr_str_strip_chars_end__impl, 2},
    {"savvy_PlRExpr_str_strip_chars_start__impl", (DL_FUNC) &savvy_PlRExpr_str_strip_chars_start__impl, 2},
    {"savvy_PlRExpr_str_strip_prefix__impl", (DL_FUNC) &savvy_PlRExpr_str_strip_prefix__impl, 2},
    {"savvy_PlRExpr_str_strip_suffix__impl", (DL_FUNC) &savvy_PlRExpr_str_strip_suffix__impl, 2},
    {"savvy_PlRExpr_str_tail__impl", (DL_FUNC) &savvy_PlRExpr_str_tail__impl, 2},
    {"savvy_PlRExpr_str_to_date__impl", (DL_FUNC) &savvy_PlRExpr_str_to_date__impl, 5},
    {"savvy_PlRExpr_str_to_datetime__impl", (DL_FUNC) &savvy_PlRExpr_str_to_datetime__impl, 8},
    {"savvy_PlRExpr_str_to_decimal__impl", (DL_FUNC) &savvy_PlRExpr_str_to_decimal__impl, 2},
    {"savvy_PlRExpr_str_to_integer__impl", (DL_FUNC) &savvy_PlRExpr_str_to_integer__impl, 3},
    {"savvy_PlRExpr_str_to_lowercase__impl", (DL_FUNC) &savvy_PlRExpr_str_to_lowercase__impl, 1},
    {"savvy_PlRExpr_str_to_time__impl", (DL_FUNC) &savvy_PlRExpr_str_to_time__impl, 4},
    {"savvy_PlRExpr_str_to_uppercase__impl", (DL_FUNC) &savvy_PlRExpr_str_to_uppercase__impl, 1},
    {"savvy_PlRExpr_str_zfill__impl", (DL_FUNC) &savvy_PlRExpr_str_zfill__impl, 2},
    {"savvy_PlRExpr_struct_field_by_index__impl", (DL_FUNC) &savvy_PlRExpr_struct_field_by_index__impl, 2},
    {"savvy_PlRExpr_struct_json_encode__impl", (DL_FUNC) &savvy_PlRExpr_struct_json_encode__impl, 1},
    {"savvy_PlRExpr_struct_multiple_fields__impl", (DL_FUNC) &savvy_PlRExpr_struct_multiple_fields__impl, 2},
    {"savvy_PlRExpr_struct_rename_fields__impl", (DL_FUNC) &savvy_PlRExpr_struct_rename_fields__impl, 2},
    {"savvy_PlRExpr_struct_with_fields__impl", (DL_FUNC) &savvy_PlRExpr_struct_with_fields__impl, 2},
    {"savvy_PlRExpr_sub__impl", (DL_FUNC) &savvy_PlRExpr_sub__impl, 2},
    {"savvy_PlRExpr_sum__impl", (DL_FUNC) &savvy_PlRExpr_sum__impl, 1},
    {"savvy_PlRExpr_tan__impl", (DL_FUNC) &savvy_PlRExpr_tan__impl, 1},
    {"savvy_PlRExpr_tanh__impl", (DL_FUNC) &savvy_PlRExpr_tanh__impl, 1},
    {"savvy_PlRExpr_to_physical__impl", (DL_FUNC) &savvy_PlRExpr_to_physical__impl, 1},
    {"savvy_PlRExpr_top_k__impl", (DL_FUNC) &savvy_PlRExpr_top_k__impl, 2},
    {"savvy_PlRExpr_top_k_by__impl", (DL_FUNC) &savvy_PlRExpr_top_k_by__impl, 4},
    {"savvy_PlRExpr_unique__impl", (DL_FUNC) &savvy_PlRExpr_unique__impl, 1},
    {"savvy_PlRExpr_unique_counts__impl", (DL_FUNC) &savvy_PlRExpr_unique_counts__impl, 1},
    {"savvy_PlRExpr_unique_stable__impl", (DL_FUNC) &savvy_PlRExpr_unique_stable__impl, 1},
    {"savvy_PlRExpr_upper_bound__impl", (DL_FUNC) &savvy_PlRExpr_upper_bound__impl, 1},
    {"savvy_PlRExpr_value_counts__impl", (DL_FUNC) &savvy_PlRExpr_value_counts__impl, 5},
    {"savvy_PlRExpr_var__impl", (DL_FUNC) &savvy_PlRExpr_var__impl, 2},
    {"savvy_PlRExpr_xor__impl", (DL_FUNC) &savvy_PlRExpr_xor__impl, 2},
    {"savvy_PlRLazyFrame_bottom_k__impl", (DL_FUNC) &savvy_PlRLazyFrame_bottom_k__impl, 4},
    {"savvy_PlRLazyFrame_cache__impl", (DL_FUNC) &savvy_PlRLazyFrame_cache__impl, 1},
    {"savvy_PlRLazyFrame_cast__impl", (DL_FUNC) &savvy_PlRLazyFrame_cast__impl, 3},
    {"savvy_PlRLazyFrame_cast_all__impl", (DL_FUNC) &savvy_PlRLazyFrame_cast_all__impl, 3},
    {"savvy_PlRLazyFrame_clone__impl", (DL_FUNC) &savvy_PlRLazyFrame_clone__impl, 1},
    {"savvy_PlRLazyFrame_collect__impl", (DL_FUNC) &savvy_PlRLazyFrame_collect__impl, 1},
    {"savvy_PlRLazyFrame_collect_schema__impl", (DL_FUNC) &savvy_PlRLazyFrame_collect_schema__impl, 1},
    {"savvy_PlRLazyFrame_count__impl", (DL_FUNC) &savvy_PlRLazyFrame_count__impl, 1},
    {"savvy_PlRLazyFrame_describe_optimized_plan__impl", (DL_FUNC) &savvy_PlRLazyFrame_describe_optimized_plan__impl, 1},
    {"savvy_PlRLazyFrame_describe_optimized_plan_tree__impl", (DL_FUNC) &savvy_PlRLazyFrame_describe_optimized_plan_tree__impl, 1},
    {"savvy_PlRLazyFrame_describe_plan__impl", (DL_FUNC) &savvy_PlRLazyFrame_describe_plan__impl, 1},
    {"savvy_PlRLazyFrame_describe_plan_tree__impl", (DL_FUNC) &savvy_PlRLazyFrame_describe_plan_tree__impl, 1},
    {"savvy_PlRLazyFrame_drop__impl", (DL_FUNC) &savvy_PlRLazyFrame_drop__impl, 3},
    {"savvy_PlRLazyFrame_drop_nans__impl", (DL_FUNC) &savvy_PlRLazyFrame_drop_nans__impl, 2},
    {"savvy_PlRLazyFrame_drop_nulls__impl", (DL_FUNC) &savvy_PlRLazyFrame_drop_nulls__impl, 2},
    {"savvy_PlRLazyFrame_explode__impl", (DL_FUNC) &savvy_PlRLazyFrame_explode__impl, 2},
    {"savvy_PlRLazyFrame_fill_nan__impl", (DL_FUNC) &savvy_PlRLazyFrame_fill_nan__impl, 2},
    {"savvy_PlRLazyFrame_filter__impl", (DL_FUNC) &savvy_PlRLazyFrame_filter__impl, 2},
    {"savvy_PlRLazyFrame_group_by__impl", (DL_FUNC) &savvy_PlRLazyFrame_group_by__impl, 3},
    {"savvy_PlRLazyFrame_group_by_dynamic__impl", (DL_FUNC) &savvy_PlRLazyFrame_group_by_dynamic__impl, 10},
    {"savvy_PlRLazyFrame_join__impl", (DL_FUNC) &savvy_PlRLazyFrame_join__impl, 12},
    {"savvy_PlRLazyFrame_join_asof__impl", (DL_FUNC) &savvy_PlRLazyFrame_join_asof__impl, 15},
    {"savvy_PlRLazyFrame_join_where__impl", (DL_FUNC) &savvy_PlRLazyFrame_join_where__impl, 4},
    {"savvy_PlRLazyFrame_max__impl", (DL_FUNC) &savvy_PlRLazyFrame_max__impl, 1},
    {"savvy_PlRLazyFrame_mean__impl", (DL_FUNC) &savvy_PlRLazyFrame_mean__impl, 1},
    {"savvy_PlRLazyFrame_median__impl", (DL_FUNC) &savvy_PlRLazyFrame_median__impl, 1},
    {"savvy_PlRLazyFrame_merge_sorted__impl", (DL_FUNC) &savvy_PlRLazyFrame_merge_sorted__impl, 3},
    {"savvy_PlRLazyFrame_min__impl", (DL_FUNC) &savvy_PlRLazyFrame_min__impl, 1},
    {"savvy_PlRLazyFrame_new_from_csv__impl", (DL_FUNC) &savvy_PlRLazyFrame_new_from_csv__impl, 30},
    {"savvy_PlRLazyFrame_new_from_ipc__impl", (DL_FUNC) &savvy_PlRLazyFrame_new_from_ipc__impl, 13},
    {"savvy_PlRLazyFrame_new_from_ndjson__impl", (DL_FUNC) &savvy_PlRLazyFrame_new_from_ndjson__impl, 15},
    {"savvy_PlRLazyFrame_new_from_parquet__impl", (DL_FUNC) &savvy_PlRLazyFrame_new_from_parquet__impl, 18},
    {"savvy_PlRLazyFrame_null_count__impl", (DL_FUNC) &savvy_PlRLazyFrame_null_count__impl, 1},
    {"savvy_PlRLazyFrame_optimization_toggle__impl", (DL_FUNC) &savvy_PlRLazyFrame_optimization_toggle__impl, 14},
    {"savvy_PlRLazyFrame_profile__impl", (DL_FUNC) &savvy_PlRLazyFrame_profile__impl, 1},
    {"savvy_PlRLazyFrame_quantile__impl", (DL_FUNC) &savvy_PlRLazyFrame_quantile__impl, 3},
    {"savvy_PlRLazyFrame_rename__impl", (DL_FUNC) &savvy_PlRLazyFrame_rename__impl, 4},
    {"savvy_PlRLazyFrame_reverse__impl", (DL_FUNC) &savvy_PlRLazyFrame_reverse__impl, 1},
    {"savvy_PlRLazyFrame_rolling__impl", (DL_FUNC) &savvy_PlRLazyFrame_rolling__impl, 6},
    {"savvy_PlRLazyFrame_select__impl", (DL_FUNC) &savvy_PlRLazyFrame_select__impl, 2},
    {"savvy_PlRLazyFrame_select_seq__impl", (DL_FUNC) &savvy_PlRLazyFrame_select_seq__impl, 2},
    {"savvy_PlRLazyFrame_serialize__impl", (DL_FUNC) &savvy_PlRLazyFrame_serialize__impl, 1},
    {"savvy_PlRLazyFrame_shift__impl", (DL_FUNC) &savvy_PlRLazyFrame_shift__impl, 3},
    {"savvy_PlRLazyFrame_sink_csv__impl", (DL_FUNC) &savvy_PlRLazyFrame_sink_csv__impl, 18},
    {"savvy_PlRLazyFrame_sink_parquet__impl", (DL_FUNC) &savvy_PlRLazyFrame_sink_parquet__impl, 13},
    {"savvy_PlRLazyFrame_slice__impl", (DL_FUNC) &savvy_PlRLazyFrame_slice__impl, 3},
    {"savvy_PlRLazyFrame_sort__impl", (DL_FUNC) &savvy_PlRLazyFrame_sort__impl, 6},
    {"savvy_PlRLazyFrame_sort_by_exprs__impl", (DL_FUNC) &savvy_PlRLazyFrame_sort_by_exprs__impl, 6},
    {"savvy_PlRLazyFrame_std__impl", (DL_FUNC) &savvy_PlRLazyFrame_std__impl, 2},
    {"savvy_PlRLazyFrame_sum__impl", (DL_FUNC) &savvy_PlRLazyFrame_sum__impl, 1},
    {"savvy_PlRLazyFrame_tail__impl", (DL_FUNC) &savvy_PlRLazyFrame_tail__impl, 2},
    {"savvy_PlRLazyFrame_to_dot__impl", (DL_FUNC) &savvy_PlRLazyFrame_to_dot__impl, 2},
    {"savvy_PlRLazyFrame_top_k__impl", (DL_FUNC) &savvy_PlRLazyFrame_top_k__impl, 4},
    {"savvy_PlRLazyFrame_unique__impl", (DL_FUNC) &savvy_PlRLazyFrame_unique__impl, 4},
    {"savvy_PlRLazyFrame_unnest__impl", (DL_FUNC) &savvy_PlRLazyFrame_unnest__impl, 2},
    {"savvy_PlRLazyFrame_unpivot__impl", (DL_FUNC) &savvy_PlRLazyFrame_unpivot__impl, 5},
    {"savvy_PlRLazyFrame_var__impl", (DL_FUNC) &savvy_PlRLazyFrame_var__impl, 2},
    {"savvy_PlRLazyFrame_with_columns__impl", (DL_FUNC) &savvy_PlRLazyFrame_with_columns__impl, 2},
    {"savvy_PlRLazyFrame_with_columns_seq__impl", (DL_FUNC) &savvy_PlRLazyFrame_with_columns_seq__impl, 2},
    {"savvy_PlRLazyFrame_with_row_index__impl", (DL_FUNC) &savvy_PlRLazyFrame_with_row_index__impl, 3},
    {"savvy_PlRLazyGroupBy_agg__impl", (DL_FUNC) &savvy_PlRLazyGroupBy_agg__impl, 2},
    {"savvy_PlRLazyGroupBy_head__impl", (DL_FUNC) &savvy_PlRLazyGroupBy_head__impl, 2},
    {"savvy_PlRLazyGroupBy_tail__impl", (DL_FUNC) &savvy_PlRLazyGroupBy_tail__impl, 2},
    {"savvy_PlRSeries_add__impl", (DL_FUNC) &savvy_PlRSeries_add__impl, 2},
    {"savvy_PlRSeries_as_str__impl", (DL_FUNC) &savvy_PlRSeries_as_str__impl, 1},
    {"savvy_PlRSeries_can_fast_explode_flag__impl", (DL_FUNC) &savvy_PlRSeries_can_fast_explode_flag__impl, 1},
    {"savvy_PlRSeries_cast__impl", (DL_FUNC) &savvy_PlRSeries_cast__impl, 3},
    {"savvy_PlRSeries_cat_is_local__impl", (DL_FUNC) &savvy_PlRSeries_cat_is_local__impl, 1},
    {"savvy_PlRSeries_cat_to_local__impl", (DL_FUNC) &savvy_PlRSeries_cat_to_local__impl, 1},
    {"savvy_PlRSeries_cat_uses_lexical_ordering__impl", (DL_FUNC) &savvy_PlRSeries_cat_uses_lexical_ordering__impl, 1},
    {"savvy_PlRSeries_clone__impl", (DL_FUNC) &savvy_PlRSeries_clone__impl, 1},
    {"savvy_PlRSeries_div__impl", (DL_FUNC) &savvy_PlRSeries_div__impl, 2},
    {"savvy_PlRSeries_dtype__impl", (DL_FUNC) &savvy_PlRSeries_dtype__impl, 1},
    {"savvy_PlRSeries_equals__impl", (DL_FUNC) &savvy_PlRSeries_equals__impl, 5},
    {"savvy_PlRSeries_is_sorted_ascending_flag__impl", (DL_FUNC) &savvy_PlRSeries_is_sorted_ascending_flag__impl, 1},
    {"savvy_PlRSeries_is_sorted_descending_flag__impl", (DL_FUNC) &savvy_PlRSeries_is_sorted_descending_flag__impl, 1},
    {"savvy_PlRSeries_len__impl", (DL_FUNC) &savvy_PlRSeries_len__impl, 1},
    {"savvy_PlRSeries_mul__impl", (DL_FUNC) &savvy_PlRSeries_mul__impl, 2},
    {"savvy_PlRSeries_n_chunks__impl", (DL_FUNC) &savvy_PlRSeries_n_chunks__impl, 1},
    {"savvy_PlRSeries_name__impl", (DL_FUNC) &savvy_PlRSeries_name__impl, 1},
    {"savvy_PlRSeries_new_binary__impl", (DL_FUNC) &savvy_PlRSeries_new_binary__impl, 2},
    {"savvy_PlRSeries_new_bool__impl", (DL_FUNC) &savvy_PlRSeries_new_bool__impl, 2},
    {"savvy_PlRSeries_new_f64__impl", (DL_FUNC) &savvy_PlRSeries_new_f64__impl, 2},
    {"savvy_PlRSeries_new_i32__impl", (DL_FUNC) &savvy_PlRSeries_new_i32__impl, 2},
    {"savvy_PlRSeries_new_i32_from_date__impl", (DL_FUNC) &savvy_PlRSeries_new_i32_from_date__impl, 2},
    {"savvy_PlRSeries_new_i64__impl", (DL_FUNC) &savvy_PlRSeries_new_i64__impl, 2},
    {"savvy_PlRSeries_new_i64_from_clock_pair__impl", (DL_FUNC) &savvy_PlRSeries_new_i64_from_clock_pair__impl, 4},
    {"savvy_PlRSeries_new_i64_from_numeric_and_multiplier__impl", (DL_FUNC) &savvy_PlRSeries_new_i64_from_numeric_and_multiplier__impl, 4},
    {"savvy_PlRSeries_new_null__impl", (DL_FUNC) &savvy_PlRSeries_new_null__impl, 2},
    {"savvy_PlRSeries_new_series_list__impl", (DL_FUNC) &savvy_PlRSeries_new_series_list__impl, 3},
    {"savvy_PlRSeries_new_single_binary__impl", (DL_FUNC) &savvy_PlRSeries_new_single_binary__impl, 2},
    {"savvy_PlRSeries_new_str__impl", (DL_FUNC) &savvy_PlRSeries_new_str__impl, 2},
    {"savvy_PlRSeries_rem__impl", (DL_FUNC) &savvy_PlRSeries_rem__impl, 2},
    {"savvy_PlRSeries_rename__impl", (DL_FUNC) &savvy_PlRSeries_rename__impl, 2},
    {"savvy_PlRSeries_reshape__impl", (DL_FUNC) &savvy_PlRSeries_reshape__impl, 2},
    {"savvy_PlRSeries_slice__impl", (DL_FUNC) &savvy_PlRSeries_slice__impl, 3},
    {"savvy_PlRSeries_struct_fields__impl", (DL_FUNC) &savvy_PlRSeries_struct_fields__impl, 1},
    {"savvy_PlRSeries_struct_unnest__impl", (DL_FUNC) &savvy_PlRSeries_struct_unnest__impl, 1},
    {"savvy_PlRSeries_sub__impl", (DL_FUNC) &savvy_PlRSeries_sub__impl, 2},
    {"savvy_PlRSeries_to_r_vector__impl", (DL_FUNC) &savvy_PlRSeries_to_r_vector__impl, 11},
    {"savvy_PlRThen_otherwise__impl", (DL_FUNC) &savvy_PlRThen_otherwise__impl, 2},
    {"savvy_PlRThen_when__impl", (DL_FUNC) &savvy_PlRThen_when__impl, 2},
    {"savvy_PlRWhen_then__impl", (DL_FUNC) &savvy_PlRWhen_then__impl, 2},
    {NULL, NULL, 0}
};

void R_init_neopolars(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);

    // Functions for initialzation, if any.

}
