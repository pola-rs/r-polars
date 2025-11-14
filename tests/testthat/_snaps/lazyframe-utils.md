# forward_old_opt_flags

    Code
      test_fn(type_coercion = FALSE)
    Condition
      Warning:
      ! `type_coercion` is deprecated.
      i Use `optimizations` instead.
    Output
      <polars::QueryOptFlags>
       @ type_coercion       : logi FALSE
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
      test_fn(predicate_pushdown = FALSE)
    Condition
      Warning:
      ! `predicate_pushdown` is deprecated.
      i Use `optimizations` instead.
    Output
      <polars::QueryOptFlags>
       @ type_coercion       : logi TRUE
       @ type_check          : logi TRUE
       @ predicate_pushdown  : logi FALSE
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
      test_fn(projection_pushdown = FALSE)
    Condition
      Warning:
      ! `projection_pushdown` is deprecated.
      i Use `optimizations` instead.
    Output
      <polars::QueryOptFlags>
       @ type_coercion       : logi TRUE
       @ type_check          : logi TRUE
       @ predicate_pushdown  : logi TRUE
       @ projection_pushdown : logi FALSE
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
      test_fn(simplify_expression = FALSE)
    Condition
      Warning:
      ! `simplify_expression` is deprecated.
      i Use `optimizations` instead.
    Output
      <polars::QueryOptFlags>
       @ type_coercion       : logi TRUE
       @ type_check          : logi TRUE
       @ predicate_pushdown  : logi TRUE
       @ projection_pushdown : logi TRUE
       @ simplify_expression : logi FALSE
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
      test_fn(slice_pushdown = FALSE)
    Condition
      Warning:
      ! `slice_pushdown` is deprecated.
      i Use `optimizations` instead.
    Output
      <polars::QueryOptFlags>
       @ type_coercion       : logi TRUE
       @ type_check          : logi TRUE
       @ predicate_pushdown  : logi TRUE
       @ projection_pushdown : logi TRUE
       @ simplify_expression : logi TRUE
       @ slice_pushdown      : logi FALSE
       @ comm_subplan_elim   : logi TRUE
       @ comm_subexpr_elim   : logi TRUE
       @ cluster_with_columns: logi TRUE
       @ check_order_observe : logi TRUE
       @ fast_projection     : logi TRUE
       @ eager               : logi FALSE
       @ streaming           : logi FALSE

---

    Code
      test_fn(comm_subplan_elim = FALSE)
    Condition
      Warning:
      ! `comm_subplan_elim` is deprecated.
      i Use `optimizations` instead.
    Output
      <polars::QueryOptFlags>
       @ type_coercion       : logi TRUE
       @ type_check          : logi TRUE
       @ predicate_pushdown  : logi TRUE
       @ projection_pushdown : logi TRUE
       @ simplify_expression : logi TRUE
       @ slice_pushdown      : logi TRUE
       @ comm_subplan_elim   : logi FALSE
       @ comm_subexpr_elim   : logi TRUE
       @ cluster_with_columns: logi TRUE
       @ check_order_observe : logi TRUE
       @ fast_projection     : logi TRUE
       @ eager               : logi FALSE
       @ streaming           : logi FALSE

---

    Code
      test_fn(comm_subexpr_elim = FALSE)
    Condition
      Warning:
      ! `comm_subexpr_elim` is deprecated.
      i Use `optimizations` instead.
    Output
      <polars::QueryOptFlags>
       @ type_coercion       : logi TRUE
       @ type_check          : logi TRUE
       @ predicate_pushdown  : logi TRUE
       @ projection_pushdown : logi TRUE
       @ simplify_expression : logi TRUE
       @ slice_pushdown      : logi TRUE
       @ comm_subplan_elim   : logi TRUE
       @ comm_subexpr_elim   : logi FALSE
       @ cluster_with_columns: logi TRUE
       @ check_order_observe : logi TRUE
       @ fast_projection     : logi TRUE
       @ eager               : logi FALSE
       @ streaming           : logi FALSE

---

    Code
      test_fn(cluster_with_columns = FALSE)
    Condition
      Warning:
      ! `cluster_with_columns` is deprecated.
      i Use `optimizations` instead.
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
       @ cluster_with_columns: logi FALSE
       @ check_order_observe : logi TRUE
       @ fast_projection     : logi TRUE
       @ eager               : logi FALSE
       @ streaming           : logi FALSE

---

    Code
      test_fn(collapse_joins = FALSE)
    Condition
      Warning:
      ! `collapse_joins` is deprecated.
      i Use `optimizations` instead.
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
      test_fn(no_optimization = TRUE)
    Condition
      Warning:
      ! `no_optimization` is deprecated.
      i Use `optimizations` instead.
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
       @ fast_projection     : logi TRUE
       @ eager               : logi FALSE
       @ streaming           : logi FALSE

