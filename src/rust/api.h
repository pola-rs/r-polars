SEXP savvy_col__ffi(SEXP name);
SEXP savvy_cols__ffi(SEXP names);
SEXP savvy_lit_from_bool__ffi(SEXP value);
SEXP savvy_lit_from_i32__ffi(SEXP value);
SEXP savvy_lit_from_f64__ffi(SEXP value);
SEXP savvy_lit_from_str__ffi(SEXP value);
SEXP savvy_lit_null__ffi(void);
SEXP savvy_lit_from_series__ffi(SEXP value);

// methods and associated functions for PlRDataFrame
SEXP savvy_PlRDataFrame_init__ffi(SEXP columns);
SEXP savvy_PlRDataFrame_print__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_to_struct__ffi(SEXP self__, SEXP name);

// methods and associated functions for PlRDataType
SEXP savvy_PlRDataType_print__ffi(SEXP self__);
SEXP savvy_PlRDataType_new_from_name__ffi(SEXP name);
SEXP savvy_PlRDataType_new_categorical__ffi(SEXP ordering);
SEXP savvy_PlRDataType_new_datetime__ffi(SEXP time_unit, SEXP time_zone);
SEXP savvy_PlRDataType_new_duration__ffi(SEXP time_unit);

// methods and associated functions for PlRExpr
SEXP savvy_PlRExpr_print__ffi(SEXP self__);
SEXP savvy_PlRExpr_add__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_sub__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_mul__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_div__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_rem__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_floor_div__ffi(SEXP self__, SEXP rhs);
SEXP savvy_PlRExpr_neg__ffi(SEXP self__);
SEXP savvy_PlRExpr_cast__ffi(SEXP self__, SEXP data_type, SEXP strict);

// methods and associated functions for PlRSeries
SEXP savvy_PlRSeries_print__ffi(SEXP self__);
SEXP savvy_PlRSeries_struct_unnest__ffi(SEXP self__);
SEXP savvy_PlRSeries_clone__ffi(SEXP self__);
SEXP savvy_PlRSeries_name__ffi(SEXP self__);
SEXP savvy_PlRSeries_rename__ffi(SEXP self__, SEXP name);
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
SEXP savvy_PlRSeries_new_categorical__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_series_list__ffi(SEXP name, SEXP values);