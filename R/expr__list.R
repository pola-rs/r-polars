
# create new environment with methods pointing to a given self
make_expr_arr_opts = function(self) {

  env = new.env()
  env$lengths = function() .pr$Expr$arr_lengths(self)

  env$min = function() .pr$Expr$lst_min(self)

  env$max = function() .pr$Expr$lst_max(self)

  env$sum = function() .pr$Expr$lst_sum(self)

  env$mean = function() .pr$Expr$lst_mean(self)

  env$sort = function(reverse = FALSE) {
    .pr$Expr$lst_sort(self, reverse)
  }

  env$reverse = function() .pr$Expr$lst_reverse(self)

  env$unique = function() .pr$Expr$lst_unique(self)

  env$get= function(index) {
    .pr$Expr$lst_get(self, wrap_e(index,str_to_lit = FALSE))
  }

  env
}
