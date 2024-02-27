test_that("list$len", {
  df = pl$DataFrame(list_of_strs = pl$Series(list(c("a", "b"), "c", character(), list(), NULL)))
  l = df$with_columns(pl$col("list_of_strs")$list$len()$alias("list_of_strs_lengths"))$to_list()

  expect_identical(
    l |> lapply(\(x) if (inherits(x, "integer64")) as.numeric(x) else x),
    list(
      list_of_strs = list(c("a", "b"), "c", character(), character(), character()),
      list_of_strs_lengths = c(2, 1, 0, 0, 0)
    )
  )
})


test_that("list$sum max min mean", {
  # outcommented ones have different behavior in R and polars

  ints = list(
    1:5,
    # c(1:5, NA_integer_),
    # NA_integer_,
    -.Machine$integer.max
  )


  floats = list(
    (1:5) * 1,
    c((1:5) * 1, NA),
    # c((1:5) * 1,NaN),
    c((1:5) * 1, Inf),
    c((1:5) * 1, -Inf),
    # c((1:5) * 1,NA,NaN),
    c((1:5) * 1, NA, Inf),
    c((1:5) * 1, NA, -Inf),
    # c((1:5) * 1,NaN,Inf),
    # c((1:5) * 1,NaN,-Inf),
    c((1:5) * 1, Inf, -Inf),
    # c((1:5) * 1,Inf,-Inf,NA),
    # c((1:5) * 1,Inf,-Inf,NaN),

    # c(NA_real_),
    # c(NaN),
    c(Inf),
    c(-Inf)
  )

  df = pl$DataFrame(x = ints)
  p_res = df$select(
    pl$col("x")$list$sum()$alias("sum"),
    pl$col("x")$list$max()$alias("max"),
    pl$col("x")$list$min()$alias("min"),
    pl$col("x")$list$mean()$alias("mean")
  )$to_list()

  r_res = list(
    sum  = sapply(ints, sum, na.rm = TRUE),
    max  = sapply(ints, max, na.rm = TRUE),
    min  = sapply(ints, min, na.rm = TRUE),
    mean = sapply(ints, mean, na.rm = TRUE)
  )
  expect_identical(
    p_res,
    r_res
  )

  df = pl$DataFrame(x = floats)
  p_res = df$select(
    pl$col("x")$list$sum()$alias("sum"),
    pl$col("x")$list$max()$alias("max"),
    pl$col("x")$list$min()$alias("min"),
    pl$col("x")$list$mean()$alias("mean")
  )$to_list()

  r_res = list(
    sum  = sapply(floats, sum, na.rm = TRUE),
    max  = sapply(floats, max, na.rm = TRUE),
    min  = sapply(floats, min, na.rm = TRUE),
    mean = sapply(floats, mean, na.rm = TRUE)
  )

  expect_identical(
    p_res,
    r_res
  )
})

test_that("list$reverse", {
  l = list(
    l_i32 = list(1:5, c(NA_integer_, 3:1)),
    l_f64 = list(c(1, 3, 2, 4, NA, Inf), (3:1) * 1),
    l_char = list(letters, LETTERS)
  )
  df = pl$DataFrame(l)
  p_res = df$select(pl$all()$list$reverse())$to_list()
  r_res = lapply(l, lapply, rev)
  expect_identical(p_res, r_res)
})




test_that("list$unique arr$sort", {
  l = list(
    l_i32 = list(c(1:2, 1:2), c(NA_integer_, NA_integer_, 3L, 1:2)),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1)),
    l_char = list(c(letters, letters), c("a", "a", "b"))
  )
  df = pl$DataFrame(l)
  p_res = df$select(pl$all()$list$unique()$list$sort())$to_list()
  r_res = lapply(l, lapply, \(x)  sort(unique(x), na.last = FALSE))
  expect_equal(p_res, r_res)


  df = pl$DataFrame(l)
  p_res = df$select(pl$all()$list$unique()$list$sort(descending = TRUE))$to_list()
  r_res = lapply(l, lapply, \(x)  sort(unique(x), na.last = FALSE, decr = TRUE))
  expect_equal(p_res, r_res)
})


test_that("list$get", {
  l = list(
    l_i32 = list(c(1:2, 1:2), c(NA_integer_, NA_integer_, 3L, 1:2), integer()),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric()),
    l_char = list(c(letters, letters), c("a", "a", "b"), character())
  )

  for (i in -5:5) {
    df = pl$DataFrame(l)
    p_res = df$select(pl$all()$list$get(i))$to_list()
    r_res = lapply(l, sapply, \(x) pcase(
      i >= 0, x[i + 1],
      i < 0, rev(x)[-i],
      or_else = stop("internal error in test")
    ))
    expect_equal(p_res, r_res)
  }
})

test_that("gather", {
  l = list(1:3, 1:2, 1:1)
  l_roundtrip = pl$lit(l)$list$gather(lapply(l, "-", 1L))$to_r()
  expect_identical(l_roundtrip, l)


  l = list(1:3, 4:5, 6L)
  expect_identical(
    pl$lit(l)$list$gather(list(c(0:3), 0L, 0L), null_on_oob = TRUE)$to_r(),
    list(c(1:3, NA), 4L, 6L)
  )

  expect_error(
    pl$lit(l)$list$gather(list(c(0:3), 0L, 0L))$to_r(),
    "gather indices are out of bounds"
  )
})

test_that("first last head tail", {
  l = list(
    l_i32 = list(1:5, 1:3, 1:10),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric()),
    l_char = list(letters, c("a", "a", "b"), character())
  )
  df = pl$DataFrame(l)

  # first

  p_res = df$select(pl$all()$list$first())$to_list()
  r_res = lapply(l, sapply, function(x) x[1])
  expect_equal(p_res, r_res)

  # last
  p_res = df$select(pl$all()$list$last())$to_list()
  r_res = lapply(l, sapply, function(x) rev(x)[1])
  expect_equal(p_res, r_res)

  for (i in 0:5) {
    p_res = df$select(pl$all()$list$head(i))$to_list()
    r_res = lapply(l, lapply, \(x) pcase(
      i >= 0, head(x, i),
      i < 0, head(x, i),
      or_else = stop("internal error in test")
    ))
    expect_equal(p_res, r_res)
  }

  for (i in 0:5) {
    p_res = df$select(pl$all()$list$tail(i))$to_list()
    r_res = lapply(l, lapply, \(x) pcase(
      i >= 0, tail(x, i),
      i < 0, tail(x, i),
      or_else = stop("internal error in test")
    ))
    expect_equal(p_res, r_res)
  }
})


test_that("join", {
  l = list(letters, as.character(1:5))
  s = pl$Series(l)
  l_act = pl$select(s$to_lit()$list$join("-"))$to_list()
  l_exp = list(sapply(l, paste, collapse = "-"))
  names(l_exp) = ""
  expect_identical(l_act, l_exp)

  df = pl$DataFrame(
    s = list(c("a", "b", "c"), c("x", "y"), c("foo", NA, "bar")),
    separator = c("*", "_", "*")
  )
  expect_identical(
    df$select(pl$col("s")$list$join(pl$col("separator")))$to_list(),
    list(s = c("a*b*c", "x_y", NA))
  )
  # ignore_nulls
  expect_identical(
    df$select(pl$col("s")$list$join(pl$col("separator"), ignore_nulls = TRUE))$to_list(),
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

  l_act_arg_min = df$select(pl$all()$list$arg_min())$to_list()
  l_act_arg_max = df$select(pl$all()$list$arg_max())$to_list()

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



test_that("diff", {
  l = list(
    l_i32 = list(1:5, 1:3, c(4L, 2L, 1L, 7L, 42L)),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric())
  )
  df = pl$DataFrame(l)

  l_act_diff_1 = df$select(pl$all()$list$diff())$to_list()
  l_exp_diff_1 = list(
    l_i32 = list(c(NA, rep(1L, 4)), c(NA, 1L, 1L), c(NA, -2L, -1L, 6L, 35L)),
    l_f64 = list(c(NA, 0, 1, 1, NA, NA, NA, NA), NA_real_, numeric())
  )
  expect_identical(l_act_diff_1, l_exp_diff_1)

  l_act_diff_2 = df$select(pl$all()$list$diff(n = 2))$to_list()
  l_exp_diff_2 = list(
    l_i32 = list(c(NA, NA, rep(2L, 3)), c(NA, NA, 2L), c(NA, NA, -3L, 5L, 41L)),
    l_f64 = list(c(NA, NA, 1, 2, NA, Inf, NA, NaN), NA_real_, numeric())
  )
  expect_identical(l_act_diff_2, l_exp_diff_2)

  l_act_diff_0 = df$select(pl$all()$list$diff(n = 0))$to_list()
  l_exp_diff_0 = list(
    l_i32 = list(rep(0L, 5), rep(0L, 3), rep(0L, 5)),
    l_f64 = list(c(rep(0, 4), NA, NaN, NA, NaN), 0, numeric())
  )
  expect_identical(l_act_diff_0, l_exp_diff_0)
})



test_that("shift", {
  l = list(
    l_i32 = list(1:5, 1:3, c(4L, 2L, 1L, 7L, 42L)),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric())
  )
  df = pl$DataFrame(l)

  l_act_diff_1 = df$select(pl$all()$list$shift())$to_list()
  l_exp_diff_1 = list(
    l_i32 = list(c(NA, 1L:4L), c(NA, 1L, 2L), c(NA, 4L, 2L, 1L, 7L)),
    l_f64 = list(c(NA, 1, 1, 2, 3, NA, Inf, NA), NA_real_, numeric())
  )
  expect_identical(l_act_diff_1, l_exp_diff_1)

  l_act_diff_2 = df$select(pl$all()$list$shift(2))$to_list()
  l_exp_diff_2 = list(
    l_i32 = list(c(NA, NA, 1L:3L), c(NA, NA, 1L), c(NA, NA, 4L, 2L, 1L)),
    l_f64 = list(c(NA, NA, 1, 1, 2, 3, NA, Inf), NA_real_, numeric())
  )
  expect_identical(l_act_diff_2, l_exp_diff_2)

  l_act_diff_0 = df$select(pl$all()$list$shift(0))$to_list()
  l_exp_diff_0 = list(
    l_i32 = list(1L:5L, 1L:3L, c(4L, 2L, 1L, 7L, 42L)),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), 1, numeric())
  )
  expect_identical(l_act_diff_0, l_exp_diff_0)

  l_act_diff_m1 = df$select(pl$all()$list$shift(-1))$to_list()
  l_exp_diff_m1 = list(
    l_i32 = list(c(2L:5L, NA), c(2L, 3L, NA), c(2L, 1L, 7L, 42L, NA)),
    l_f64 = list(c(1, 2, 3, NA, Inf, NA, Inf, NA), NA_real_, numeric())
  )
  expect_identical(l_act_diff_m1, l_exp_diff_m1)
})



test_that("slice", {
  l = list(
    l_i32 = list(1:5, 1:3, c(4L, 2L, 1L, 7L, 42L)),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric())
  )
  df = pl$DataFrame(l)

  r_slice = function(x, o, n = NULL) {
    if (is.null(n)) n = max(length(x) - o, 1L)
    if (o >= 0) {
      o = o + 1
    } else {
      o = length(x) + o + 1
    }
    s = seq(o, o + n - 1)
    s = s[s %in% seq_along(x)]
    x[s]
  }

  l_act_slice = df$select(pl$all()$list$slice(0, 3))$to_list()
  l_exp_slice = lapply(l, lapply, r_slice, 0, 3)
  expect_identical(l_act_slice, l_exp_slice)


  l_act_slice = df$select(pl$all()$list$slice(1, 3))$to_list()
  l_exp_slice = lapply(l, lapply, r_slice, 1, 3)
  expect_identical(l_act_slice, l_exp_slice)


  l_act_slice = df$select(pl$all()$list$slice(1, 5))$to_list()
  l_exp_slice = lapply(l, lapply, r_slice, 1, 5)
  expect_identical(l_act_slice, l_exp_slice)

  l_act_slice = df$select(pl$all()$list$slice(-1, 1))$to_list()
  l_exp_slice = lapply(l, lapply, r_slice, -1, 1)
  expect_identical(l_act_slice, l_exp_slice)

  l2 = list(a = list(1:3, 1:2, 1:1, integer()))
  df2 = pl$DataFrame(l2)
  l_act_slice = df2$select(pl$all()$list$slice(-2, 2))$to_list()
  l_exp_slice = lapply(l2, lapply, r_slice, -2, 2)
  expect_identical(l_act_slice, l_exp_slice)

  l_act_slice = df2$select(pl$all()$list$slice(1, ))$to_list()
  l_exp_slice = lapply(l2, lapply, r_slice, 1)
  expect_identical(l_act_slice, l_exp_slice)
})

test_that("contains", {
  l = list(
    i32 = list(1:4, 1:3, 1:1),
    f64 = list(c(1, 2, 3, NaN), c(NaN, 1, NA), c(Inf)),
    utf = list(letters, LETTERS, c(NA_character_, "a"))
  )
  df = pl$DataFrame(l)

  l_act = df$select(
    pl$col("i32")$list$contains(2L),
    pl$col("f64")$list$contains(Inf),
    pl$col("utf")$list$contains("a")
  )$to_list()

  l_exp = list(
    i32 = sapply(l$i32, \(x) 2L %in% x),
    f64 = sapply(l$f64, \(x) Inf %in% x),
    utf = sapply(l$utf, \(x) "a" %in% x)
  )

  expect_identical(l_act, l_exp)
})


test_that("concat", {
  df = pl$DataFrame(
    a = list("a", "x"),
    b = list(c("b", "c"), c("y", "z"))
  )

  expect_identical(
    df$select(pl$col("a")$list$concat(pl$col("b")))$to_list(),
    list(a = list(c("a", "b", "c"), c("x", "y", "z")))
  )

  expect_identical(
    df$select(pl$col("a")$list$concat(pl$lit("hello from R")))$to_list(),
    list(a = list(c("a", "hello from R"), c("x", "hello from R")))
  )

  expect_identical(
    df$select(pl$col("a")$list$concat(pl$lit(c("hello", "world"))))$to_list(),
    list(a = list(c("a", "hello"), c("x", "world")))
  )
})



test_that("to_struct", {
  l = list(integer(), 1:2, 1:3, 1:2)
  df = pl$DataFrame(a = l)
  act_1 = df$select(pl$col("a")$list$to_struct(
    n_field_strategy = "first_non_null",
    fields = \(idx) paste0("hello_you_", idx)
  ))$to_list()

  act_2 = df$select(pl$col("a")$list$to_struct(
    n_field_strategy = "max_width",
    fields = \(idx) paste0("hello_you_", idx)
  ))$to_list()


  exp_1 = list(
    a = list(
      hello_you_0 = c(NA, 1L, 1L, 1L),
      hello_you_1 = c(NA, 2L, 2L, 2L)
    )
  )

  exp_2 = list(
    a = list(
      hello_you_0 = c(NA, 1L, 1L, 1L),
      hello_you_1 = c(NA, 2L, 2L, 2L),
      hello_you_2 = c(NA, NA, 3L, NA)
    )
  )

  expect_identical(act_1, exp_1)
  expect_identical(act_2, exp_2)
})



test_that("eval", {
  df = pl$DataFrame(a = c(1, 8, 3), b = c(4, 5, 2))
  l_act = df$with_columns(
    pl$concat_list(list("a", "b"))$list$eval(pl$element()$rank())$alias("rank")
  )$to_list()
  expect_identical(
    l_act,
    list(
      a = c(1, 8, 3),
      b = c(4, 5, 2),
      rank = list(c(1, 2), c(2, 1), c(2, 1))
    )
  )
})

test_that("$list$all() works", {
  df = pl$DataFrame(
    a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c())
  )
  expect_identical(
    df$select(all = pl$col("a")$list$all())$to_list(),
    list(all = c(TRUE, FALSE, FALSE, TRUE, TRUE))
  )
})

test_that("$list$any() works", {
  df = pl$DataFrame(
    a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c())
  )
  expect_identical(
    df$select(any = pl$col("a")$list$any())$to_list(),
    list(any = c(TRUE, TRUE, FALSE, FALSE, FALSE))
  )
})

test_that("$list$set_*() work with integers", {
  df = pl$DataFrame(
    a = list(1:3, NA_integer_, c(NA_integer_, 3L), 5:7),
    b = list(2:4, 3L, c(3L, 4L, NA_integer_), c(6L, 8L)),
    schema = list(a = pl$List(pl$Int16), b = pl$List(pl$Int32))
  )

  expect_identical(
    df$select(pl$col("a")$list$set_union("b"))$to_list(),
    list(a = list(1:4, c(NA, 3L), c(NA, 3L, 4L), 5:8))
  )
  expect_identical(
    df$select(pl$col("a")$list$set_intersection("b"))$to_list(),
    list(a = list(2:3, integer(0), c(NA, 3L), 6L))
  )
  expect_identical(
    df$select(pl$col("a")$list$set_difference("b"))$to_list(),
    list(a = list(1L, NA_integer_, integer(0), c(5L, 7L)))
  )
  expect_identical(
    df$select(pl$col("a")$list$set_symmetric_difference("b"))$to_list(),
    list(a = list(c(1L, 4L), c(NA, 3L), 4L, c(5L, 7L, 8L)))
  )
})

test_that("$list$set_*() work with strings", {
  df = pl$DataFrame(
    a = list(letters[1:3], NA_character_, c(NA_character_, letters[3]), letters[5:7]),
    b = list(letters[2:4], letters[3], c(letters[3:4], NA_character_), letters[c(6, 8)])
  )

  expect_identical(
    df$select(pl$col("a")$list$set_union("b"))$to_list(),
    list(a = list(letters[1:4], c(NA, "c"), c(NA, "c", "d"), letters[5:8]))
  )
  expect_identical(
    df$select(pl$col("a")$list$set_intersection("b"))$to_list(),
    list(a = list(c("b", "c"), character(0), c(NA, "c"), "f"))
  )
  expect_identical(
    df$select(pl$col("a")$list$set_difference("b"))$to_list(),
    list(a = list("a", NA_character_, character(0), c("e", "g")))
  )
  expect_identical(
    df$select(pl$col("a")$list$set_symmetric_difference("b"))$to_list(),
    list(a = list(c("a", "d"), c(NA, "c"), "d", c("e", "g", "h")))
  )
})

# TODO: currently (rs-0.36.2), this panicks, which leads to other tests failing
# due to panicks
# Uncomment when resolved upstream: https://github.com/pola-rs/polars/issues/13840
# test_that("$list$set_*() errors if no common supertype", {
#   df = pl$DataFrame(
#     a = list(c(1, 2, 3), NA_real_, c(NA_real_, 3), c(5, 6, 7)),
#     b = list(2:4, 3L, c(3L, 4L, NA_integer_), c(6L, 8L))
#   )
#   expect_error(
#     df$select(pl$col("a")$list$set_union("b"))
#   )
#   expect_error(
#     df$select(pl$col("a")$list$set_intersection("b"))
#   )
#   expect_error(
#     df$select(pl$col("a")$list$set_difference("b"))
#   )
#   expect_error(
#     df$select(pl$col("a")$list$set_symmetric_difference("b"))
#   )
# })
