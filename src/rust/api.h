SEXP savvy_col__ffi(SEXP name);
SEXP savvy_cols__ffi(SEXP names);
SEXP savvy_lit_from_bool__ffi(SEXP value);
SEXP savvy_lit_from_i32__ffi(SEXP value);
SEXP savvy_lit_from_f64__ffi(SEXP value);
SEXP savvy_lit_from_str__ffi(SEXP value);
SEXP savvy_lit_null__ffi(void);
SEXP savvy_lit_from_series__ffi(SEXP value);
SEXP savvy_when__ffi(SEXP condition);

// methods and associated functions for PlRChainedThen
SEXP savvy_PlRChainedThen_when__ffi(SEXP self__, SEXP condition);
SEXP savvy_PlRChainedThen_otherwise__ffi(SEXP self__, SEXP statement);

// methods and associated functions for PlRChainedWhen
SEXP savvy_PlRChainedWhen_then__ffi(SEXP self__, SEXP statement);

// methods and associated functions for PlRDataFrame
SEXP savvy_PlRDataFrame_init__ffi(SEXP columns);
SEXP savvy_PlRDataFrame_print__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_get_columns__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_shape__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_height__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_width__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_to_series__ffi(SEXP self__, SEXP index);
SEXP savvy_PlRDataFrame_equals__ffi(SEXP self__, SEXP other, SEXP null_equal);
SEXP savvy_PlRDataFrame_lazy__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_to_struct__ffi(SEXP self__, SEXP name);

// methods and associated functions for PlRDataType
SEXP savvy_PlRDataType_print__ffi(SEXP self__);
SEXP savvy_PlRDataType_new_from_name__ffi(SEXP name);
SEXP savvy_PlRDataType_new_categorical__ffi(SEXP ordering);
SEXP savvy_PlRDataType_new_datetime__ffi(SEXP time_unit, SEXP time_zone);
SEXP savvy_PlRDataType_new_duration__ffi(SEXP time_unit);
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
SEXP savvy_PlRExpr_dt_convert_time_zone__ffi(SEXP self__, SEXP time_zone);
SEXP savvy_PlRExpr_dt_replace_time_zone__ffi(SEXP self__, SEXP ambiguous, SEXP non_existent, SEXP time_zone);
SEXP savvy_PlRExpr_print__ffi(SEXP self__);
SEXP savvy_PlRExpr_add__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_sub__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_mul__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_div__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_rem__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_floor_div__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_neg__ffi(SEXP self__);
SEXP savvy_PlRExpr_eq__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_eq_missing__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_neq__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_neq_missing__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_gt__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_gt_eq__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_lt_eq__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_lt__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_alias__ffi(SEXP self__, SEXP name);
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
SEXP savvy_PlRExpr_cast__ffi(SEXP self__, SEXP data_type, SEXP strict);
SEXP savvy_PlRExpr_and__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_or__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_xor__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_reshape__ffi(SEXP self__, SEXP dimensions);
SEXP savvy_PlRExpr_any__ffi(SEXP self__, SEXP ignore_nulls);
SEXP savvy_PlRExpr_all__ffi(SEXP self__, SEXP ignore_nulls);
SEXP savvy_PlRExpr_meta_selector_add__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_meta_selector_and__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_meta_selector_sub__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRExpr_meta_as_selector__ffi(SEXP self__);
SEXP savvy_PlRExpr_struct_field_by_index__ffi(SEXP self__, SEXP index);
SEXP savvy_PlRExpr_struct_field_by_name__ffi(SEXP self__, SEXP name);

// methods and associated functions for PlRLazyFrame
SEXP savvy_PlRLazyFrame_select__ffi(SEXP self__, SEXP exprs);
SEXP savvy_PlRLazyFrame_group_by__ffi(SEXP self__, SEXP by, SEXP maintain_order);
SEXP savvy_PlRLazyFrame_collect__ffi(SEXP self__);

// methods and associated functions for PlRLazyGroupBy
SEXP savvy_PlRLazyGroupBy_agg__ffi(SEXP self__, SEXP aggs);
SEXP savvy_PlRLazyGroupBy_head__ffi(SEXP self__, SEXP n);
SEXP savvy_PlRLazyGroupBy_tail__ffi(SEXP self__, SEXP n);

// methods and associated functions for PlRSeries
SEXP savvy_PlRSeries_print__ffi(SEXP self__);
SEXP savvy_PlRSeries_struct_unnest__ffi(SEXP self__);
SEXP savvy_PlRSeries_struct_fields__ffi(SEXP self__);
SEXP savvy_PlRSeries_reshape__ffi(SEXP self__, SEXP dimensions);
SEXP savvy_PlRSeries_clone__ffi(SEXP self__);
SEXP savvy_PlRSeries_name__ffi(SEXP self__);
SEXP savvy_PlRSeries_rename__ffi(SEXP self__, SEXP name);
SEXP savvy_PlRSeries_dtype__ffi(SEXP self__);
SEXP savvy_PlRSeries_equals__ffi(SEXP self__, SEXP other, SEXP check_dtypes, SEXP check_names, SEXP null_equal);
SEXP savvy_PlRSeries_cast__ffi(SEXP self__, SEXP dtype, SEXP strict);
SEXP savvy_PlRSeries_add__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRSeries_sub__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRSeries_div__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRSeries_mul__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRSeries_rem__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRSeries_new_empty__ffi(SEXP name, SEXP dtype);
SEXP savvy_PlRSeries_new_f64__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_i32__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_bool__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_str__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_binary__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_series_list__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_to_r_vector__ffi(SEXP self__);

// methods and associated functions for PlRThen
SEXP savvy_PlRThen_when__ffi(SEXP self__, SEXP condition);
SEXP savvy_PlRThen_otherwise__ffi(SEXP self__, SEXP statement);

// methods and associated functions for PlRWhen
SEXP savvy_PlRWhen_then__ffi(SEXP self__, SEXP statement);