SEXP savvy_concat_df__ffi(SEXP c_arg__dfs);
SEXP savvy_field__ffi(SEXP c_arg__names);
SEXP savvy_col__ffi(SEXP c_arg__name);
SEXP savvy_cols__ffi(SEXP c_arg__names);
SEXP savvy_dtype_cols__ffi(SEXP c_arg__dtypes);
SEXP savvy_lit_from_bool__ffi(SEXP c_arg__value);
SEXP savvy_lit_from_i32__ffi(SEXP c_arg__value);
SEXP savvy_lit_from_f64__ffi(SEXP c_arg__value);
SEXP savvy_lit_from_str__ffi(SEXP c_arg__value);
SEXP savvy_lit_from_raw__ffi(SEXP c_arg__value);
SEXP savvy_lit_null__ffi(void);
SEXP savvy_lit_from_series__ffi(SEXP c_arg__value);
SEXP savvy_when__ffi(SEXP c_arg__condition);

// methods and associated functions for PlRChainedThen
SEXP savvy_PlRChainedThen_when__ffi(SEXP self__, SEXP c_arg__condition);
SEXP savvy_PlRChainedThen_otherwise__ffi(SEXP self__, SEXP c_arg__statement);

// methods and associated functions for PlRChainedWhen
SEXP savvy_PlRChainedWhen_then__ffi(SEXP self__, SEXP c_arg__statement);

// methods and associated functions for PlRDataFrame
SEXP savvy_PlRDataFrame_init__ffi(SEXP c_arg__columns);
SEXP savvy_PlRDataFrame_print__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_get_columns__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_columns__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_dtypes__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_shape__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_height__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_width__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_to_series__ffi(SEXP self__, SEXP c_arg__index);
SEXP savvy_PlRDataFrame_equals__ffi(SEXP self__, SEXP c_arg__other, SEXP c_arg__null_equal);
SEXP savvy_PlRDataFrame_lazy__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_to_struct__ffi(SEXP self__, SEXP c_arg__name);

// methods and associated functions for PlRDataType
SEXP savvy_PlRDataType_new_from_name__ffi(SEXP c_arg__name);
SEXP savvy_PlRDataType_new_decimal__ffi(SEXP c_arg__scale, SEXP c_arg__precision);
SEXP savvy_PlRDataType_new_datetime__ffi(SEXP c_arg__time_unit, SEXP c_arg__time_zone);
SEXP savvy_PlRDataType_new_duration__ffi(SEXP c_arg__time_unit);
SEXP savvy_PlRDataType_new_categorical__ffi(SEXP c_arg__ordering);
SEXP savvy_PlRDataType_new_enum__ffi(SEXP c_arg__categories);
SEXP savvy_PlRDataType_new_list__ffi(SEXP c_arg__inner);
SEXP savvy_PlRDataType_new_struct__ffi(SEXP c_arg__fields);
SEXP savvy_PlRDataType_print__ffi(SEXP self__);
SEXP savvy_PlRDataType__get_datatype_fields__ffi(SEXP self__);
SEXP savvy_PlRDataType_eq__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRDataType_ne__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRDataType_is_temporal__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_enum__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_categorical__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_string__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_logical__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_float__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_numeric__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_integer__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_signed_integer__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_unsigned_integer__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_null__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_binary__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_primitive__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_bool__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_array__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_list__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_nested__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_struct__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_ord__ffi(SEXP self__);
SEXP savvy_PlRDataType_is_known__ffi(SEXP self__);

// methods and associated functions for PlRExpr
SEXP savvy_PlRExpr_bin_contains__ffi(SEXP self__, SEXP c_arg__literal);
SEXP savvy_PlRExpr_bin_ends_with__ffi(SEXP self__, SEXP c_arg__suffix);
SEXP savvy_PlRExpr_bin_starts_with__ffi(SEXP self__, SEXP c_arg__prefix);
SEXP savvy_PlRExpr_bin_hex_decode__ffi(SEXP self__, SEXP c_arg__strict);
SEXP savvy_PlRExpr_bin_base64_decode__ffi(SEXP self__, SEXP c_arg__strict);
SEXP savvy_PlRExpr_bin_hex_encode__ffi(SEXP self__);
SEXP savvy_PlRExpr_bin_base64_encode__ffi(SEXP self__);
SEXP savvy_PlRExpr_cat_get_categories__ffi(SEXP self__);
SEXP savvy_PlRExpr_dt_convert_time_zone__ffi(SEXP self__, SEXP c_arg__time_zone);
SEXP savvy_PlRExpr_dt_replace_time_zone__ffi(SEXP self__, SEXP c_arg__ambiguous, SEXP c_arg__non_existent, SEXP c_arg__time_zone);
SEXP savvy_PlRExpr_print__ffi(SEXP self__);
SEXP savvy_PlRExpr_add__ffi(SEXP self__, SEXP c_arg__rhs);
SEXP savvy_PlRExpr_sub__ffi(SEXP self__, SEXP c_arg__rhs);
SEXP savvy_PlRExpr_mul__ffi(SEXP self__, SEXP c_arg__rhs);
SEXP savvy_PlRExpr_div__ffi(SEXP self__, SEXP c_arg__rhs);
SEXP savvy_PlRExpr_rem__ffi(SEXP self__, SEXP c_arg__rhs);
SEXP savvy_PlRExpr_floor_div__ffi(SEXP self__, SEXP c_arg__rhs);
SEXP savvy_PlRExpr_neg__ffi(SEXP self__);
SEXP savvy_PlRExpr_eq__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_eq_missing__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_neq__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_neq_missing__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_gt__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_gt_eq__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_lt_eq__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_lt__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_alias__ffi(SEXP self__, SEXP c_arg__name);
SEXP savvy_PlRExpr_not__ffi(SEXP self__);
SEXP savvy_PlRExpr_is_null__ffi(SEXP self__);
SEXP savvy_PlRExpr_is_not_null__ffi(SEXP self__);
SEXP savvy_PlRExpr_is_infinite__ffi(SEXP self__);
SEXP savvy_PlRExpr_is_finite__ffi(SEXP self__);
SEXP savvy_PlRExpr_is_nan__ffi(SEXP self__);
SEXP savvy_PlRExpr_is_not_nan__ffi(SEXP self__);
SEXP savvy_PlRExpr_min__ffi(SEXP self__);
SEXP savvy_PlRExpr_max__ffi(SEXP self__);
SEXP savvy_PlRExpr_nan_max__ffi(SEXP self__);
SEXP savvy_PlRExpr_nan_min__ffi(SEXP self__);
SEXP savvy_PlRExpr_mean__ffi(SEXP self__);
SEXP savvy_PlRExpr_median__ffi(SEXP self__);
SEXP savvy_PlRExpr_sum__ffi(SEXP self__);
SEXP savvy_PlRExpr_cast__ffi(SEXP self__, SEXP c_arg__data_type, SEXP c_arg__strict);
SEXP savvy_PlRExpr_sort_by__ffi(SEXP self__, SEXP c_arg__by, SEXP c_arg__descending, SEXP c_arg__nulls_last, SEXP c_arg__multithreaded, SEXP c_arg__maintain_order);
SEXP savvy_PlRExpr_first__ffi(SEXP self__);
SEXP savvy_PlRExpr_last__ffi(SEXP self__);
SEXP savvy_PlRExpr_filter__ffi(SEXP self__, SEXP c_arg__predicate);
SEXP savvy_PlRExpr_reverse__ffi(SEXP self__);
SEXP savvy_PlRExpr_over__ffi(SEXP self__, SEXP c_arg__partition_by, SEXP c_arg__order_by_descending, SEXP c_arg__order_by_nulls_last, SEXP c_arg__mapping_strategy, SEXP c_arg__order_by);
SEXP savvy_PlRExpr_and__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_or__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_xor__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_reshape__ffi(SEXP self__, SEXP c_arg__dimensions);
SEXP savvy_PlRExpr_any__ffi(SEXP self__, SEXP c_arg__ignore_nulls);
SEXP savvy_PlRExpr_all__ffi(SEXP self__, SEXP c_arg__ignore_nulls);
SEXP savvy_PlRExpr_meta_selector_add__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_meta_selector_and__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_meta_selector_sub__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRExpr_meta_as_selector__ffi(SEXP self__);
SEXP savvy_PlRExpr_name_keep__ffi(SEXP self__);
SEXP savvy_PlRExpr_name_prefix__ffi(SEXP self__, SEXP c_arg__prefix);
SEXP savvy_PlRExpr_name_suffix__ffi(SEXP self__, SEXP c_arg__suffix);
SEXP savvy_PlRExpr_name_to_lowercase__ffi(SEXP self__);
SEXP savvy_PlRExpr_name_to_uppercase__ffi(SEXP self__);
SEXP savvy_PlRExpr_name_prefix_fields__ffi(SEXP self__, SEXP c_arg__prefix);
SEXP savvy_PlRExpr_name_suffix_fields__ffi(SEXP self__, SEXP c_arg__suffix);
SEXP savvy_PlRExpr_serialize_binary__ffi(SEXP self__);
SEXP savvy_PlRExpr_serialize_json__ffi(SEXP self__);
SEXP savvy_PlRExpr_deserialize_binary__ffi(SEXP c_arg__data);
SEXP savvy_PlRExpr_deserialize_json__ffi(SEXP c_arg__data);
SEXP savvy_PlRExpr_struct_field_by_index__ffi(SEXP self__, SEXP c_arg__index);
SEXP savvy_PlRExpr_struct_multiple_fields__ffi(SEXP self__, SEXP c_arg__names);
SEXP savvy_PlRExpr_struct_rename_fields__ffi(SEXP self__, SEXP c_arg__names);
SEXP savvy_PlRExpr_struct_json_encode__ffi(SEXP self__);
SEXP savvy_PlRExpr_struct_with_fields__ffi(SEXP self__, SEXP c_arg__fields);

// methods and associated functions for PlRLazyFrame
SEXP savvy_PlRLazyFrame_select__ffi(SEXP self__, SEXP c_arg__exprs);
SEXP savvy_PlRLazyFrame_group_by__ffi(SEXP self__, SEXP c_arg__by, SEXP c_arg__maintain_order);
SEXP savvy_PlRLazyFrame_collect__ffi(SEXP self__);
SEXP savvy_PlRLazyFrame_cast__ffi(SEXP self__, SEXP c_arg__dtypes, SEXP c_arg__strict);
SEXP savvy_PlRLazyFrame_sort_by_exprs__ffi(SEXP self__, SEXP c_arg__by, SEXP c_arg__descending, SEXP c_arg__nulls_last, SEXP c_arg__maintain_order, SEXP c_arg__multithreaded);
SEXP savvy_PlRLazyFrame_with_columns__ffi(SEXP self__, SEXP c_arg__exprs);

// methods and associated functions for PlRLazyGroupBy
SEXP savvy_PlRLazyGroupBy_agg__ffi(SEXP self__, SEXP c_arg__aggs);
SEXP savvy_PlRLazyGroupBy_head__ffi(SEXP self__, SEXP c_arg__n);
SEXP savvy_PlRLazyGroupBy_tail__ffi(SEXP self__, SEXP c_arg__n);

// methods and associated functions for PlRSeries
SEXP savvy_PlRSeries_add__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRSeries_sub__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRSeries_div__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRSeries_mul__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRSeries_rem__ffi(SEXP self__, SEXP c_arg__other);
SEXP savvy_PlRSeries_new_null__ffi(SEXP c_arg__name, SEXP c_arg__length);
SEXP savvy_PlRSeries_new_f64__ffi(SEXP c_arg__name, SEXP c_arg__values);
SEXP savvy_PlRSeries_new_i32__ffi(SEXP c_arg__name, SEXP c_arg__values);
SEXP savvy_PlRSeries_new_i64__ffi(SEXP c_arg__name, SEXP c_arg__values);
SEXP savvy_PlRSeries_new_bool__ffi(SEXP c_arg__name, SEXP c_arg__values);
SEXP savvy_PlRSeries_new_str__ffi(SEXP c_arg__name, SEXP c_arg__values);
SEXP savvy_PlRSeries_new_single_binary__ffi(SEXP c_arg__name, SEXP c_arg__values);
SEXP savvy_PlRSeries_new_binary__ffi(SEXP c_arg__name, SEXP c_arg__values);
SEXP savvy_PlRSeries_new_series_list__ffi(SEXP c_arg__name, SEXP c_arg__values);
SEXP savvy_PlRSeries_new_i64_from_clock_pair__ffi(SEXP c_arg__name, SEXP c_arg__left, SEXP c_arg__right, SEXP c_arg__precision);
SEXP savvy_PlRSeries_to_r_vector__ffi(SEXP self__, SEXP c_arg__ensure_vector, SEXP c_arg__int64, SEXP c_arg__struct, SEXP c_arg__as_clock_class, SEXP c_arg__ambiguous, SEXP c_arg__non_existent, SEXP c_arg__local_time_zone);
SEXP savvy_PlRSeries_print__ffi(SEXP self__);
SEXP savvy_PlRSeries_struct_unnest__ffi(SEXP self__);
SEXP savvy_PlRSeries_struct_fields__ffi(SEXP self__);
SEXP savvy_PlRSeries_cat_uses_lexical_ordering__ffi(SEXP self__);
SEXP savvy_PlRSeries_cat_is_local__ffi(SEXP self__);
SEXP savvy_PlRSeries_cat_to_local__ffi(SEXP self__);
SEXP savvy_PlRSeries_reshape__ffi(SEXP self__, SEXP c_arg__dimensions);
SEXP savvy_PlRSeries_clone__ffi(SEXP self__);
SEXP savvy_PlRSeries_name__ffi(SEXP self__);
SEXP savvy_PlRSeries_rename__ffi(SEXP self__, SEXP c_arg__name);
SEXP savvy_PlRSeries_dtype__ffi(SEXP self__);
SEXP savvy_PlRSeries_equals__ffi(SEXP self__, SEXP c_arg__other, SEXP c_arg__check_dtypes, SEXP c_arg__check_names, SEXP c_arg__null_equal);
SEXP savvy_PlRSeries_len__ffi(SEXP self__);
SEXP savvy_PlRSeries_cast__ffi(SEXP self__, SEXP c_arg__dtype, SEXP c_arg__strict);
SEXP savvy_PlRSeries_slice__ffi(SEXP self__, SEXP c_arg__offset, SEXP c_arg__length);

// methods and associated functions for PlRThen
SEXP savvy_PlRThen_when__ffi(SEXP self__, SEXP c_arg__condition);
SEXP savvy_PlRThen_otherwise__ffi(SEXP self__, SEXP c_arg__statement);

// methods and associated functions for PlRWhen
SEXP savvy_PlRWhen_then__ffi(SEXP self__, SEXP c_arg__statement);