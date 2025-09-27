test_that("$matches() for datatype_expr works", {
  df <- pl$DataFrame(a = 1:3, b = list(1L, 2L, 3L))
  expect_equal(
    df$select(
      a_is_string = pl$dtype_of("a")$matches(cs$string()),
      a_is_integer = pl$dtype_of("a")$matches(cs$integer()),
      b_is_integer = pl$dtype_of("b")$matches(cs$integer()),
      b_is_list_integer = pl$dtype_of("b")$matches(cs$list(cs$integer())),
    ),
    pl$DataFrame(
      a_is_string = FALSE,
      a_is_integer = TRUE,
      b_is_integer = FALSE,
      b_is_list_integer = TRUE
    )
  )
})
