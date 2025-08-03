# clear error message when passing lists with some Polars expr to dynamic dots

    Code
      dat$select(exprs)
    Condition
      Error in `dat$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! `...` doesn't accept inputs of type list with Polars expressions.
      i Element(s) 1 are of type list.
      i Perhaps you forgot to use `!!!` on the input(s), e.g. `!!!my_list`?

---

    Code
      dat$select(exprs, exprs, exprs, exprs)
    Condition
      Error in `dat$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! `...` doesn't accept inputs of type list with Polars expressions.
      i Element(s) 1, 2, 3 and more are of type list.
      i Perhaps you forgot to use `!!!` on the input(s), e.g. `!!!my_list`?

# parse_into_selector works

    Code
      parse_into_selector(NULL)
    Condition
      Error:
      ! `...` can only contain single strings or polars selectors.

---

    Code
      parse_into_selector(integer())
    Condition
      Error:
      ! `...` can only contain single strings or polars selectors.

---

    Code
      parse_into_selector(pl$lit(NULL))
    Condition
      Error:
      ! `...` can only contain single strings or polars selectors.

