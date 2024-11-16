# alpha

    Code
      df$select(cs$alpha(TRUE, TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$alpha()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# alphanumeric

    Code
      df$select(cs$alphanumeric(TRUE, TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$alphanumeric()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# by_dtype

    Code
      df$select(cs$by_dtype(a = pl$String))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$by_dtype()`:
      ! Arguments in `...` must be passed by position, not name.
      x Problematic argument:
      * a = pl$String

# by_name

    Code
      df$select(cs$by_name(a = "foo"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$by_name()`:
      ! Arguments in `...` must be passed by position, not name.
      x Problematic argument:
      * a = "foo"

# contains

    Code
      df$select(cs$contains("ba", 1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$contains()`:
      ! `...` must be a list of single strings, not a list.

---

    Code
      df$select(cs$contains("ba", NA_character_))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$contains()`:
      ! `...` must be a list of single strings, not a list.

# ends_with

    Code
      df$select(cs$ends_with("z", 1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$ends_with()`:
      ! `...` must be a list of single strings, not a list.

# exclude

    Code
      df$select(cs$exclude("^b.*$", pl$Int32, 1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$exclude()`:
      ! `...` can only contain column names, regexes, polars data types or polars selectors.

# starts_with

    Code
      df$select(cs$starts_with("b", 1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$starts_with()`:
      ! `...` must be a list of single strings, not a list.

