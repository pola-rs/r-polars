# QueryOptFlags

    Code
      pl$QueryOptFlags
    Output
      <polars::QueryOptFlags> class
      @ parent     : <S7_object>
      @ constructor: function(..., predicate_pushdown, projection_pushdown, simplify_expression, slice_pushdown, comm_subplan_elim, comm_subexpr_elim, cluster_with_columns, check_order_observe, fast_projection, join_order, row_estimate) {...}
      @ validator  : <NULL>
      @ properties :
       $ type_coercion: <logical> = logical(0)
       $ type_check: <logical> = logical(0)
       $ predicate_pushdown: <logical> = logical(0)
       $ projection_pushdown: <logical> = logical(0)
       $ simplify_expression: <logical> = logical(0)
       $ slice_pushdown: <logical> = logical(0)
       $ comm_subplan_elim: <logical> = logical(0)
       $ comm_subexpr_elim: <logical> = logical(0)
       $ cluster_with_columns: <logical> = logical(0)
       $ check_order_observe: <logical> = logical(0)
       $ fast_projection: <logical> = logical(0)
       $ join_order: <logical> = logical(0)
       $ row_estimate: <logical> = logical(0)
       $ eager: <logical> = logical(0)
       $ streaming: <logical> = logical(0)

---

    Code
      opt_flags@type_coercion <- 1L
    Condition <error>
      Error in `<polars::QueryOptFlags>@type_coercion`:
      ! <polars::QueryOptFlags>@type_coercion must be <logical>, not <integer>

---

    Code
      opt_flags@type_coercion <- NA
    Condition <error>
      Error in `<polars::QueryOptFlags>@type_coercion`:
      ! <polars::QueryOptFlags>@type_coercion must be a single `TRUE` or `FALSE`, not `NA`.

---

    Code
      opt_flags@type_coercion <- c(TRUE, TRUE)
    Condition <error>
      Error in `<polars::QueryOptFlags>@type_coercion`:
      ! <polars::QueryOptFlags>@type_coercion must be a single `TRUE`, `FALSE` or `NA`, not a logical vector.

---

    Code
      opt_flags$type
    Condition <rlang_error>
      Error in `opt_flags$type`:
      ! Evaluation failed.
      Caused by error in `<polars::QueryOptFlags>@type`:
      ! Property not found.

# Rust side validation

    Code
      validate(opt_flags)
    Condition <S7_error_validation_failed>
      Error in `validate()`:
      ! <polars::QueryOptFlags> object properties are invalid:
      - @eager must be <logical>, not <integer>

