# QueryOptFlags

    Code
      pl$QueryOptFlags
    Output
      <polars::QueryOptFlags> class
      @ parent     : <S7_object>
      @ constructor: function(..., predicate_pushdown, projection_pushdown, simplify_expression, slice_pushdown, comm_subplan_elim, comm_subexpr_elim, cluster_with_columns, check_order_observe, fast_projection) {...}
      @ validator  : function(self) {...}
      @ properties :
       $ type_coercion       : <logical>
       $ type_check          : <logical>
       $ predicate_pushdown  : <logical>
       $ projection_pushdown : <logical>
       $ simplify_expression : <logical>
       $ slice_pushdown      : <logical>
       $ comm_subplan_elim   : <logical>
       $ comm_subexpr_elim   : <logical>
       $ cluster_with_columns: <logical>
       $ check_order_observe : <logical>
       $ fast_projection     : <logical>
       $ eager               : <logical>
       $ streaming           : <logical>

---

    Code
      eager_opt_flags()
    Output
      <polars::QueryOptFlags>
       @ type_coercion       : logi TRUE
       @ type_check          : logi TRUE
       @ predicate_pushdown  : logi FALSE
       @ projection_pushdown : logi FALSE
       @ simplify_expression : logi TRUE
       @ slice_pushdown      : logi FALSE
       @ comm_subplan_elim   : logi FALSE
       @ comm_subexpr_elim   : logi FALSE
       @ cluster_with_columns: logi FALSE
       @ check_order_observe : logi FALSE
       @ fast_projection     : logi FALSE
       @ eager               : logi TRUE
       @ streaming           : logi FALSE

---

    Code
      pl$QueryOptFlags(TRUE)
    Condition <rlib_error_dots_nonempty>
      Error in `pl$QueryOptFlags()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

---

    Code
      opt_flags
    Output
      <polars::QueryOptFlags>
       @ type_coercion       : logi TRUE
       @ type_check          : logi TRUE
       @ predicate_pushdown  : logi TRUE
       @ projection_pushdown : logi TRUE
       @ simplify_expression : logi TRUE
       @ slice_pushdown      : logi TRUE
       @ comm_subplan_elim   : logi TRUE
       @ comm_subexpr_elim   : logi TRUE
       @ cluster_with_columns: logi TRUE
       @ check_order_observe : logi TRUE
       @ fast_projection     : logi TRUE
       @ eager               : logi FALSE
       @ streaming           : logi FALSE

---

    Code
      eager_opt_flags()
    Output
      <polars::QueryOptFlags>
       @ type_coercion       : logi TRUE
       @ type_check          : logi TRUE
       @ predicate_pushdown  : logi FALSE
       @ projection_pushdown : logi FALSE
       @ simplify_expression : logi TRUE
       @ slice_pushdown      : logi FALSE
       @ comm_subplan_elim   : logi FALSE
       @ comm_subexpr_elim   : logi FALSE
       @ cluster_with_columns: logi FALSE
       @ check_order_observe : logi FALSE
       @ fast_projection     : logi FALSE
       @ eager               : logi TRUE
       @ streaming           : logi FALSE

