test_that("$matches() for datatype_expr works", {
  df <- pl$DataFrame(a = 1:3, b = list(1L, 2L, 3L))

  expect_query_equal(
    .input$select(
      a_is_string = pl$dtype_of("a")$matches(cs$string()),
      a_is_integer = pl$dtype_of("a")$matches(cs$integer()),
      b_is_integer = pl$dtype_of("b")$matches(cs$integer()),
      b_is_list_integer = pl$dtype_of("b")$matches(cs$list(cs$integer())),
    ),
    df,
    pl$DataFrame(
      a_is_string = FALSE,
      a_is_integer = TRUE,
      b_is_integer = FALSE,
      b_is_list_integer = TRUE
    )
  )
})

test_that("$display() for datatype_expr works", {
  df <- pl$DataFrame(
    int = 1L,
    float = 1,
    decimal = 1,
    string = c("a", "b"),
    cat = factor("a"),
    enum = factor("a"),
    list = list(1),
    arr = list(1),
    struct = data.frame(x = 1),
    date = as.Date("2020-01-01"),
    datetime = as.POSIXct("2020-01-01 00:00:00"),
    time = 1
  )$cast(arr = pl$Array(pl$Float64, 1), enum = pl$Enum("a"), time = pl$Time, decimal = pl$Decimal())

  withr::with_envvar(
    list(POLARS_FMT_MAX_ROWS = 100),
    {
      expect_snapshot(
        df$select(
          int = pl$dtype_of("int")$display(),
          float = pl$dtype_of("float")$display(),
          decimal = pl$dtype_of("decimal")$display(),
          string = pl$dtype_of("string")$display(),
          cat = pl$dtype_of("cat")$display(),
          enum = pl$dtype_of("enum")$display(),
          list = pl$dtype_of("list")$display(),
          arr = pl$dtype_of("arr")$display(),
          struct = pl$dtype_of("struct")$display(),
          date = pl$dtype_of("date")$display(),
          datetime = pl$dtype_of("datetime")$display(),
          time = pl$dtype_of("time")$display(),
        )$transpose(include_header = TRUE)
      )
    }
  )
})

test_that("$inner_dtype() for datatype_expr works", {
  df <- pl$DataFrame(
    a = list(1L),
    b = list(list("a")),
    c = list(data.frame(x = 1, y = 2))
  )

  expect_snapshot(
    df$select(
      a_inner_dtype = pl$dtype_of("a")$inner_dtype()$display(),
      b_inner_dtype = pl$dtype_of("b")$inner_dtype()$display(),
      c_inner_dtype = pl$dtype_of("c")$inner_dtype()$display()
    )
  )
})

test_that("$default_value(): basic behavior works", {
  df <- pl$select(
    int = pl$Int32$to_dtype_expr()$default_value(),
    float = pl$Float64$to_dtype_expr()$default_value(),
    decimal = pl$Decimal()$to_dtype_expr()$default_value(),
    string = pl$String$to_dtype_expr()$default_value(),
    cat = pl$Categorical()$to_dtype_expr()$default_value(),
    enum = pl$Enum("a")$to_dtype_expr()$default_value(),
    list = pl$List(pl$Float64)$to_dtype_expr()$default_value(),
    arr = pl$Array(pl$Float64, 2)$to_dtype_expr()$default_value(),
    struct = pl$Struct()$to_dtype_expr()$default_value(),
    date = pl$Date$to_dtype_expr()$default_value(),
    datetime = pl$Datetime()$to_dtype_expr()$default_value(),
    time = pl$Time$to_dtype_expr()$default_value(),
    null = pl$Null$to_dtype_expr()$default_value()
  )

  withr::with_envvar(
    list(POLARS_FMT_MAX_COLS = 100, POLARS_TABLE_WIDTH = 100),
    expect_snapshot(df)
  )
})

test_that("$default_value(): arguments work", {
  int <- pl$Int32$to_dtype_expr()

  # arg `n`
  expect_equal(
    pl$select(int = int$default_value(n = 3)),
    pl$DataFrame(int = c(0L, 0L, 0L))
  )
  expect_equal(
    pl$select(int = int$default_value(n = 0)),
    pl$DataFrame(int = integer(0))
  )
  expect_error(
    pl$select(int = int$default_value(n = -1)),
    "out of range that can be safely converted to usize"
  )
  expect_error(
    pl$select(int = int$default_value(n = 0.5)),
    "not integer-ish"
  )

  # arg `numeric_to_one`
  expect_equal(
    pl$select(int = int$default_value(numeric_to_one = TRUE)),
    pl$DataFrame(int = 1L)
  )
  expect_error(
    pl$select(int = int$default_value(numeric_to_one = 1.3)),
    "must be logical, not double"
  )

  # arg `num_list_values`
  l <- pl$List(pl$Float64)$to_dtype_expr()
  expect_equal(
    pl$select(list = l$default_value(num_list_values = 3)),
    pl$DataFrame(list = list(c(0, 0, 0)))
  )
  expect_error(
    pl$select(list = l$default_value(num_list_values = 3.3)),
    "not integer-ish"
  )
  expect_error(
    pl$select(list = l$default_value(num_list_values = -1)),
    "out of range that can be safely converted to usize"
  )
})
