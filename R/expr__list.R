Expr__arr_lengths = "use_extendr_wrapper"

Expr__arr_min = "use_extendr_wrapper"

Expr__arr_max = "use_extendr_wrapper"

Expr__arr_sum = "use_extendr_wrapper"

Expr__arr_mean = "use_extendr_wrapper"

Expr__arr_sort = function(reverse = FALSE) {
  .pr$Expr$lst_sort(self, reverse)
}

Expr__arr_reverse = "use_extendr_wrapper"

Expr__arr_unique = "use_extendr_wrapper"

Expr__arr_get= function(index) {
  .pr$Expr$lst_get(self, wrap_e(index,str_to_lit = FALSE))
}


#missing Expr__arr_concat


