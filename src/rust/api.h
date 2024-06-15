SEXP savvy_to_upper__ffi(SEXP x);
SEXP savvy_int_times_int__ffi(SEXP x, SEXP y);

// methods and associated functions for Person
SEXP savvy_Person_new__ffi(void);
SEXP savvy_Person_set_name__ffi(SEXP self__, SEXP name);
SEXP savvy_Person_name__ffi(SEXP self__);
SEXP savvy_Person_associated_function__ffi(void);