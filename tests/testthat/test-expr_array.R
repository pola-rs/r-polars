test_that("arr$sum", {
  df = pl$DataFrame(
    ints = list(1:2, c(1L, NA_integer_), c(NA_integer_, NA_integer_)),
    floats = list(c(1, 2), c(1, NA_real_), c(NA_real_, NA_real_)),
    schema = list(
      ints = pl$Array(pl$Int32, 2),
      floats = pl$Array(pl$Float32, 2)
    )
  )
  expect_identical(
    df$select(pl$col("ints")$arr$sum())$to_list(),
    list(ints = c(3L, 1L, 0L))
  )
  expect_identical(
    df$select(pl$col("floats")$arr$sum())$to_list(),
    list(floats = c(3, 1, 0))
  )
})

test_that("arr$max and arr$min", {
  df = pl$DataFrame(
    ints = list(1:2, c(1L, NA_integer_), c(NA_integer_, NA_integer_)),
    floats = list(c(1, 2), c(1, NA_real_), c(NA_real_, NA_real_)),
    schema = list(
      ints = pl$Array(pl$Int32, 2),
      floats = pl$Array(pl$Float32, 2)
    )
  )
  # max ---
  expect_identical(
    df$select(pl$col("ints")$arr$max())$to_list(),
    list(ints = c(2L, 1L, NA_integer_))
  )
  expect_identical(
    df$select(pl$col("floats")$arr$max())$to_list(),
    list(floats = c(2, 1, NA_real_))
  )

  # min ---
  expect_identical(
    df$select(pl$col("ints")$arr$min())$to_list(),
    list(ints = c(1L, 1L, NA_integer_))
  )
  expect_identical(
    df$select(pl$col("floats")$arr$min())$to_list(),
    list(floats = c(1, 1, NA_real_))
  )
})

test_that("arr$reverse", {
  df = pl$DataFrame(
    list(a = list(c(Inf, 2, 2), c(4, NaN, 2))),
    schema = list(a = pl$Array(pl$Float32, 3))
  )
  expect_identical(
    df$select(pl$col("a")$arr$reverse())$to_list(),
    list(a = list(c(2, 2, Inf), c(2, NaN, 4)))
  )
})

test_that("arr$unique", {
  df = pl$DataFrame(
    list(a = list(c(Inf, 2, 2), c(4, NaN, 2))),
    schema = list(a = pl$Array(pl$Float32, 3))
  )
  expect_identical(
    df$select(pl$col("a")$arr$unique())$to_list(),
    list(a = list(c(2, Inf), c(2, 4, NaN)))
  )
})

test_that("arr$sort", {
  df = pl$DataFrame(
    list(a = list(c(Inf, 2, 2), c(4, NaN, 2))),
    schema = list(a = pl$Array(pl$Float32, 3))
  )
  expect_identical(
    df$select(pl$col("a")$arr$sort())$to_list(),
    list(a = list(c(2, 2, Inf), c(2, 4, NaN)))
  )
})

test_that("arr$get", {
  df = pl$DataFrame(
    a = list(c(Inf, 2, 2), c(4, NaN, 2)),
    b = c(1, 2),
    schema = list(a = pl$Array(pl$Float32, 3))
  )
  # with literal
  expect_identical(
    df$select(pl$col("a")$arr$get(1))$to_list(),
    list(a = c(2, NaN))
  )
  # with expr
  expect_identical(
    df$select(pl$col("a")$arr$get("b"))$to_list(),
    list(a = c(2, 2))
  )
})

test_that("join", {
  l = list(letters, as.character(1:5))
  s = pl$Series(l)
  l_act = pl$select(s$to_lit()$arr$join("-"))$to_list()
  l_exp = list(sapply(l, paste, collapse = "-"))
  names(l_exp) = ""
  expect_identical(l_act, l_exp)

  df = pl$DataFrame(
    s = list(c("a", "b", "c"), c("x", "y"), c("foo", NA, "bar")),
    separator = c("*", "_", "*")
  )
  expect_identical(
    df$select(pl$col("s")$arr$join(pl$col("separator")))$to_list(),
    list(s = c("a*b*c", "x_y", NA))
  )
  # ignore_nulls
  expect_identical(
    df$select(pl$col("s")$arr$join(pl$col("separator"), ignore_nulls = TRUE))$to_list(),
    list(s = c("a*b*c", "x_y", "foo*bar"))
  )
})

test_that("arg_min arg_max", {
  l = list(
    l_i32 = list(1:5, 1:3, 1:10),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric()),
    l_char = list(letters, c("a", "a", "b"), character())
  )
  df = pl$DataFrame(l)

  l_act_arg_min = df$select(pl$all()$arr$arg_min())$to_list()
  l_act_arg_max = df$select(pl$all()$arr$arg_max())$to_list()

  # not the same as R NA is min
  l_exp_arg_min = list(
    l_i32 = c(0, 0, 0),
    l_f64 = c(0, 0, NA),
    l_char = c(0, 0, NA)
  )
  l_exp_arg_max = list(
    l_i32 = c(4, 2, 9),
    l_f64 = c(5, 0, NA),
    l_char = c(25, 2, NA)
  )

  expect_identical(l_act_arg_min |> lapply(as.numeric), l_exp_arg_min)
  expect_identical(l_act_arg_max |> lapply(as.numeric), l_exp_arg_max)
})


test_that("contains", {
  l = list(
    i32 = list(1:4, 1:3, 1:1),
    f64 = list(c(1, 2, 3, NaN), c(NaN, 1, NA), c(Inf)),
    utf = list(letters, LETTERS, c(NA_character_, "a"))
  )
  df = pl$DataFrame(l)

  l_act = df$select(
    pl$col("i32")$arr$contains(2L),
    pl$col("f64")$arr$contains(Inf),
    pl$col("utf")$arr$contains("a")
  )$to_list()

  l_exp = list(
    i32 = sapply(l$i32, \(x) 2L %in% x),
    f64 = sapply(l$f64, \(x) Inf %in% x),
    utf = sapply(l$utf, \(x) "a" %in% x)
  )

  expect_identical(l_act, l_exp)
})


# test_that("to_struct", {
#   l = list(integer(), 1:2, 1:3, 1:2)
#   df = pl$DataFrame(list(a = l))
#   act_1 = df$select(pl$col("a")$arr$to_struct(
#     n_field_strategy = "first_non_null",
#     fields = \(idx) paste0("hello_you_", idx)
#   ))$to_list()
#
#   act_2 = df$select(pl$col("a")$arr$to_struct(
#     n_field_strategy = "max_width",
#     fields = \(idx) paste0("hello_you_", idx)
#   ))$to_list()
#
#
#   exp_1 = list(
#     a = list(
#       hello_you_0 = c(NA, 1L, 1L, 1L),
#       hello_you_1 = c(NA, 2L, 2L, 2L)
#     )
#   )
#
#   exp_2 = list(
#     a = list(
#       hello_you_0 = c(NA, 1L, 1L, 1L),
#       hello_you_1 = c(NA, 2L, 2L, 2L),
#       hello_you_2 = c(NA, NA, 3L, NA)
#     )
#   )
#
#   expect_identical(act_1, exp_1)
#   expect_identical(act_2, exp_2)
# })


test_that("$arr$all() works", {
  df = pl$DataFrame(
    list(a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c()))
  )
  expect_identical(
    df$select(all = pl$col("a")$arr$all())$to_list(),
    list(all = c(TRUE, FALSE, FALSE, TRUE, TRUE))
  )
})

test_that("$arr$any() works", {
  df = pl$DataFrame(
    list(a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c()))
  )
  expect_identical(
    df$select(any = pl$col("a")$arr$any())$to_list(),
    list(any = c(TRUE, TRUE, FALSE, FALSE, FALSE))
  )
})
