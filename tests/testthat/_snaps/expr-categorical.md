# cat$physical() works

    Code
      pl$DataFrame(x = 1)$select(pl$col("x")$cat$physical())
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! invalid dtype: expected an Enum or Categorical type, received 'Float64'

# cat$to() works

    Code
      invalid$select(pl$col("x")$cat$to(dtype))
    Condition
      Error in `invalid$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! found invalid category value when converting from physical to enum
      
      This error occurred in the following expression:
      	col("x").cat.to()

---

    Code
      pl$DataFrame(x = c(1, 0))$cast(pl$UInt16)$select(pl$col("x")$cat$to(dtype))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! cannot convert column of type u16 to enum with physical type u8; column dtype must match the enum/categorical's physical type
      
      This error occurred in the following expression:
      	col("x").cat.to()

---

    Code
      df$select(pl$col("x")$cat$to(pl$String))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! invalid dtype: expected an Enum or Categorical type, received 'String'
      
      This error occurred in the following expression:
      	col("x").cat.to()

---

    Code
      df$select(pl$col("x")$cat$to(dtype, FALSE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$cat$to()`:
      ! Evaluation failed in `$to()`.
      Caused by error in `pl$col("x")$cat$to()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = FALSE
      i Did you forget to name an argument?

