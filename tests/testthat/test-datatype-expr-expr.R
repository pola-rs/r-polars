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
    string = c("a", "b"),
    cat = factor("a"),
    enum = factor("a"),
    list = list(1),
    arr = list(1),
    struct = data.frame(x = 1),
    date = as.Date("2020-01-01"),
    datetime = as.POSIXct("2020-01-01 00:00:00"),
    time = 1
  )$cast(arr = pl$Array(pl$Float64, 1), enum = pl$Enum("a"), time = pl$Time)

  expect_snapshot(
    df$select(
      int = pl$dtype_of("int")$display(),
      float = pl$dtype_of("float")$display(),
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
