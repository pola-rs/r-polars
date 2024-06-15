

// methods and associated functions for PlRSeries
SEXP savvy_PlRSeries_print__ffi(SEXP self__);
SEXP savvy_PlRSeries_clone__ffi(SEXP self__);
SEXP savvy_PlRSeries_name__ffi(SEXP self__);
SEXP savvy_PlRSeries_rename__ffi(SEXP self__, SEXP name);
SEXP savvy_PlRSeries_new_empty__ffi(SEXP name);
SEXP savvy_PlRSeries_new_f64__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_i32__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_bool__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_str__ffi(SEXP name, SEXP values);
SEXP savvy_PlRSeries_new_series_list__ffi(SEXP name, SEXP values);