

// methods and associated functions for PlRDataFrame
SEXP savvy_PlRDataFrame_init__ffi(SEXP columns);
SEXP savvy_PlRDataFrame_print__ffi(SEXP self__);
SEXP savvy_PlRDataFrame_to_struct__ffi(SEXP self__, SEXP name);

// methods and associated functions for PlRSeries
SEXP savvy_PlRSeries_print__ffi(SEXP self__);
SEXP savvy_PlRSeries_struct_unnest__ffi(SEXP self__);
SEXP savvy_PlRSeries_clone__ffi(SEXP self__);
SEXP savvy_PlRSeries_name__ffi(SEXP self__);
SEXP savvy_PlRSeries_rename__ffi(SEXP self__, SEXP name);
SEXP savvy_PlRSeries_add__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRSeries_sub__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRSeries_div__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRSeries_mul__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRSeries_rem__ffi(SEXP self__, SEXP other);
SEXP savvy_PlRSeries_new_empty__ffi(SEXP name);
SEXP savvy_PlRSeries_new_f64__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_i32__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_bool__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_str__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_categorical__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_series_list__ffi(SEXP name, SEXP values);