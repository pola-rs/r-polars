# QueryOptFlags

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
       @ join_order          : logi FALSE
       @ row_estimate        : logi FALSE
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
       @ join_order          : logi TRUE
       @ row_estimate        : logi TRUE
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
       @ join_order          : logi FALSE
       @ row_estimate        : logi FALSE
       @ eager               : logi TRUE
       @ streaming           : logi FALSE

---

    Code
      opt_flags$type_coercion
    Output
      [1] TRUE

---

    Code
      opt_flags$no_optimizations()
    Output
      <polars::QueryOptFlags>
       @ type_coercion       : logi TRUE
       @ type_check          : logi TRUE
       @ predicate_pushdown  : logi FALSE
       @ projection_pushdown : logi FALSE
       @ simplify_expression : logi FALSE
       @ slice_pushdown      : logi FALSE
       @ comm_subplan_elim   : logi FALSE
       @ comm_subexpr_elim   : logi FALSE
       @ cluster_with_columns: logi FALSE
       @ check_order_observe : logi FALSE
       @ fast_projection     : logi FALSE
       @ join_order          : logi FALSE
       @ row_estimate        : logi FALSE
       @ eager               : logi FALSE
       @ streaming           : logi FALSE

---

    Code
      DEFAULT_EAGER_OPT_FLAGS
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
       @ join_order          : logi FALSE
       @ row_estimate        : logi FALSE
       @ eager               : logi TRUE
       @ streaming           : logi FALSE

# Rust side validation

    Code
      pl$collect_all(list(), optimizations = opt_flags)
    Condition <rlang_error>
      Error in `pl$collect_all()`:
      ! Evaluation failed in `$collect_all()`.
      Caused by error:
      ! Must be logical, not integer

