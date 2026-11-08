# QueryOptFlags

    Code
      pl$QueryOptFlags
    Output
      <polars::QueryOptFlags> class
      @ parent     : <S7_object>
      @ constructor: function(..., predicate_pushdown, projection_pushdown, simplify_expression, slice_pushdown, comm_subplan_elim, comm_subexpr_elim, cluster_with_columns, check_order_observe, fast_projection, join_order, row_estimate) {...}
      @ validator  : <NULL>
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
       $ join_order          : <logical>
       $ row_estimate        : <logical>
       $ eager               : <logical>
       $ streaming           : <logical>

---

    Code
      opt_flags@type_coercion <- 1L
    Condition <simpleError>
      Error:
      ! <polars::QueryOptFlags>@type_coercion must be <logical>, not <integer>

---

    Code
      opt_flags@type_coercion <- NA
    Condition <simpleError>
      Error:
      ! <polars::QueryOptFlags>@type_coercion must be a single `TRUE` or `FALSE`, not `NA`.

---

    Code
      opt_flags@type_coercion <- c(TRUE, TRUE)
    Condition <simpleError>
      Error:
      ! <polars::QueryOptFlags>@type_coercion must be a single `TRUE`, `FALSE` or `NA`, not a logical vector.

---

    Code
      opt_flags$type
    Condition <rlang_error>
      Error in `opt_flags$type`:
      ! Evaluation failed.
      Caused by error:
      ! Can't find property <polars::QueryOptFlags>@type

# Rust side validation

    Code
      validate(opt_flags)
    Condition <simpleError>
      Error:
      ! <polars::QueryOptFlags> object properties are invalid:
      - @eager must be <logical>, not <integer>

