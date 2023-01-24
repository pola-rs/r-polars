# this file sources list-expression functions to be bundled in the 'expr$str' sub namespace
# the sub name space is instanciated from Expr_str- function
# bundling these functions into an environment, depends on a macro call in zzz.R
# expr_str_make_sub_ns = macro_new_subnamespace("^Exprstr_", "ExprStrNameSpace")


ExprStr_strptime = function(
  datatype,#: PolarsTemporalType,
  fmt,#: str | None = None,
  strict,#: bool = True,
  exact,#: bool = True,
  cache,#: bool = True,
  tz_aware#: bool = False,
) { #-> Expr:


 stop("missing implementation")


}
