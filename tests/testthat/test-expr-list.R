test_that("list$len", {
  df <- pl$DataFrame(x = list(c("a", "b"), "c", character(), NULL, NULL))
  expect_equal(
    df$with_columns(pl$col("x")$list$len()),
    pl$DataFrame(
      x = c(2, 1, 0, NA, NA)
    )$cast(x = pl$UInt32)
  )
})


test_that("list$sum max min mean", {
  # outcommented ones have different behavior in R and polars

  ints <- list(
    1:5,
    # c(1:5, NA),
    # NA,
    -.Machine$integer.max
  )

  floats <- list(
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

    # c(NA),
    # c(NaN),
    c(Inf),
    c(-Inf)
  )

  df <- pl$DataFrame(x = ints)
  p_res <- df$select(
    pl$col("x")$list$sum()$alias("sum"),
    pl$col("x")$list$max()$alias("max"),
    pl$col("x")$list$min()$alias("min"),
    pl$col("x")$list$mean()$alias("mean")
  )

  r_res <- pl$DataFrame(
    sum  = sapply(ints, sum, na.rm = TRUE),
    max  = sapply(ints, max, na.rm = TRUE),
    min  = sapply(ints, min, na.rm = TRUE),
    mean = sapply(ints, mean, na.rm = TRUE)
  )
  expect_equal(p_res, r_res)

  df <- pl$DataFrame(x = floats)
  p_res <- df$select(
    pl$col("x")$list$sum()$alias("sum"),
    pl$col("x")$list$max()$alias("max"),
    pl$col("x")$list$min()$alias("min"),
    pl$col("x")$list$mean()$alias("mean")
  )

  r_res <- pl$DataFrame(
    sum  = sapply(floats, sum, na.rm = TRUE),
    max  = sapply(floats, max, na.rm = TRUE),
    min  = sapply(floats, min, na.rm = TRUE),
    mean = sapply(floats, mean, na.rm = TRUE)
  )

  expect_equal(p_res, r_res)
})

test_that("list$reverse", {
  l <- list(
    l_i32 = list(1:5, c(NA, 3:1)),
    l_f64 = list(c(1, 3, 2, 4, NA, Inf), (3:1) * 1),
    l_char = list(letters, LETTERS)
  )
  df <- pl$DataFrame(!!!l)
  p_res <- df$select(pl$all()$list$reverse())
  r_res <- pl$DataFrame(!!!lapply(l, lapply, rev))
  expect_equal(p_res, r_res)
})

test_that("list$unique list$sort", {
  l <- list(
    l_i32 = list(c(1:2, 1:2), c(NA, NA, 3L, 1:2)),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1)),
    l_char = list(c(letters, letters), c("a", "a", "b"))
  )
  df <- pl$DataFrame(!!!l)
  p_res <- df$select(pl$all()$list$unique()$list$sort())
  r_res <- pl$DataFrame(!!!lapply(l, lapply, \(x)  sort(unique(x), na.last = FALSE)))
  expect_equal(p_res, r_res)

  df <- pl$DataFrame(!!!l)
  p_res <- df$select(pl$all()$list$unique()$list$sort(descending = TRUE))
  r_res <- pl$DataFrame(!!!lapply(l, lapply, \(x)  sort(unique(x), na.last = FALSE, decr = TRUE)))
  expect_equal(p_res, r_res)

  expect_snapshot(
    df$select(pl$all()$list$unique(TRUE)),
    error = TRUE
  )
  expect_snapshot(
    df$select(pl$all()$list$sort(TRUE)),
    error = TRUE
  )
})

test_that("list$n_unique", {
  df <- pl$DataFrame(
    l_i32 = list(c(1:2, 1:2), c(NA, NA, 3L, 1:2)),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1)),
    l_char = list(c(letters, letters), c("a", "a", "b"))
  )
  expect_equal(
    df$select(pl$all()$list$n_unique()),
    pl$DataFrame(l_i32 = c(2, 4), l_f64 = c(5, 1), l_char = c(26, 2))$cast(pl$UInt32)
  )
})

test_that("list$get", {
  l <- list(
    l_i32 = list(c(1:2, 1:2), c(NA, NA, 3L, 1:2), integer()),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric()),
    l_char = list(c(letters, letters), c("a", "a", "b"), character())
  )
  df <- pl$DataFrame(!!!l)

  for (i in -5:5) {
    p_res <- df$select(pl$all()$list$get(i))
    r_res <- pl$DataFrame(!!!lapply(l, sapply, \(x) {
      if (i >= 0) {
        x[i + 1]
      } else if (i < 0) {
        rev(x)[-i]
      } else {
        stop("internal error in test")
      }
    }))
    expect_equal(p_res, r_res)
  }
})

test_that("gather", {
  l <- list(1:3, 1:2, 1:1)
  l_roundtrip <- pl$DataFrame(x = l)$with_columns(pl$col("x")$list$gather(lapply(l, "-", 1L)))
  expect_equal(l_roundtrip, pl$DataFrame(x = l))


  l <- list(1:3, 4:5, 6L)
  expect_equal(
    pl$DataFrame(x = l)$with_columns(pl$col("x")$list$gather(list(c(0:3), 0L, 0L), null_on_oob = TRUE)),
    pl$DataFrame(x = list(c(1:3, NA), 4L, 6L))
  )

  expect_snapshot(
    pl$DataFrame(x = l)$with_columns(pl$col("x")$list$gather(list(c(0:3), 0L, 0L))),
    error = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = l)$with_columns(pl$col("x")$list$gather(1, TRUE)),
    error = TRUE
  )
})

test_that("gather_every", {
  df <- pl$DataFrame(
    a = list(1:5, 6:8, 9:12),
    n = c(2, 1, 3),
    offset = c(0, 1, 0)
  )

  expect_equal(
    df$select(
      out = pl$col("a")$list$gather_every("n", offset = pl$col("offset"))
    ),
    pl$DataFrame(out = list(c(1L, 3L, 5L), c(7L, 8L), c(9L, 12L)))
  )

  # wrong n
  expect_snapshot(df$select(
    out = pl$col("a")$list$gather_every(-1)
  ), error = TRUE)

  # missing n
  expect_snapshot(df$select(
    out = pl$col("a")$list$gather_every()
  ), error = TRUE)

  # wrong offset
  expect_snapshot(df$select(
    out = pl$col("a")$list$gather_every(n = 2, offset = -1)
  ), error = TRUE)
})

test_that("first last head tail", {
  l <- list(
    l_i32 = list(1:5, 1:3, 1:10),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric()),
    l_char = list(letters, c("a", "a", "b"), character())
  )
  df <- pl$DataFrame(!!!l)

  # first

  p_res <- df$select(pl$all()$list$first())
  r_res <- pl$DataFrame(!!!lapply(l, sapply, function(x) x[1]))
  expect_equal(p_res, r_res)

  # last
  p_res <- df$select(pl$all()$list$last())
  r_res <- pl$DataFrame(!!!lapply(l, sapply, function(x) rev(x)[1]))
  expect_equal(p_res, r_res)

  for (i in 0:5) {
    p_res <- df$select(pl$all()$list$head(i))
    r_res <- pl$DataFrame(!!!lapply(l, lapply, \(x) {
      head(x, i)
    }))
    expect_equal(p_res, r_res)
  }

  for (i in 0:5) {
    p_res <- df$select(pl$all()$list$tail(i))
    r_res <- pl$DataFrame(!!!lapply(l, lapply, \(x) tail(x, i)))
    expect_equal(p_res, r_res)
  }
})


test_that("join", {
  l <- list(letters, as.character(1:5))
  l_act <- pl$DataFrame(x = l)$with_columns(pl$col("x")$list$join("-"))
  l_exp <- pl$DataFrame(x = sapply(l, paste, collapse = "-"))
  expect_equal(l_act, l_exp)

  df <- pl$DataFrame(
    s = list(c("a", "b", "c"), c("x", "y"), c("foo", NA, "bar")),
    separator = c("*", "_", "*")
  )
  expect_equal(
    df$select(pl$col("s")$list$join(pl$col("separator"))),
    pl$DataFrame(s = c("a*b*c", "x_y", NA))
  )
  # ignore_nulls
  expect_equal(
    df$select(pl$col("s")$list$join(pl$col("separator"), ignore_nulls = TRUE)),
    pl$DataFrame(s = c("a*b*c", "x_y", "foo*bar"))
  )

  expect_snapshot(
    df$select(pl$col("s")$list$join(pl$col("separator"), TRUE)),
    error = TRUE
  )
})

test_that("arg_min arg_max", {
  l <- list(
    l_i32 = list(1:5, 1:3, 1:10),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric()),
    l_char = list(letters, c("a", "a", "b"), character())
  )
  df <- pl$DataFrame(!!!l)

  l_act_arg_min <- df$select(pl$all()$list$arg_min())
  l_act_arg_max <- df$select(pl$all()$list$arg_max())

  # not the same as R NA is min
  l_exp_arg_min <- pl$DataFrame(
    l_i32 = c(0, 0, 0),
    l_f64 = c(0, 0, NA),
    l_char = c(0, 0, NA)
  )$cast(pl$UInt32)
  l_exp_arg_max <- pl$DataFrame(
    l_i32 = c(4, 2, 9),
    l_f64 = c(5, 0, NA),
    l_char = c(25, 2, NA)
  )$cast(pl$UInt32)

  expect_equal(l_act_arg_min, l_exp_arg_min)
  expect_equal(l_act_arg_max, l_exp_arg_max)
})

test_that("diff", {
  l <- list(
    l_i32 = list(1:5, 1:3, c(4L, 2L, 1L, 7L, 42L)),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric())
  )
  df <- pl$DataFrame(!!!l)

  l_act_diff_1 <- df$select(pl$all()$list$diff())
  l_exp_diff_1 <- pl$DataFrame(
    l_i32 = list(c(NA, rep(1L, 4)), c(NA, 1L, 1L), c(NA, -2L, -1L, 6L, 35L)),
    l_f64 = list(c(NA, 0, 1, 1, NA, NA, NA, NA), NA, numeric())
  )
  expect_equal(l_act_diff_1, l_exp_diff_1)

  l_act_diff_2 <- df$select(pl$all()$list$diff(n = 2))
  l_exp_diff_2 <- pl$DataFrame(
    l_i32 = list(c(NA, NA, rep(2L, 3)), c(NA, NA, 2L), c(NA, NA, -3L, 5L, 41L)),
    l_f64 = list(c(NA, NA, 1, 2, NA, Inf, NA, NaN), NA, numeric())
  )
  expect_equal(l_act_diff_2, l_exp_diff_2)

  l_act_diff_0 <- df$select(pl$all()$list$diff(n = 0))
  l_exp_diff_0 <- pl$DataFrame(
    l_i32 = list(rep(0L, 5), rep(0L, 3), rep(0L, 5)),
    l_f64 = list(c(rep(0, 4), NA, NaN, NA, NaN), 0, numeric())
  )
  expect_equal(l_act_diff_0, l_exp_diff_0)
})

test_that("shift", {
  l <- list(
    l_i32 = list(1:5, 1:3, c(4L, 2L, 1L, 7L, 42L)),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric())
  )
  df <- pl$DataFrame(!!!l)

  l_act_diff_1 <- df$select(pl$all()$list$shift())
  l_exp_diff_1 <- pl$DataFrame(
    l_i32 = list(c(NA, 1L:4L), c(NA, 1L, 2L), c(NA, 4L, 2L, 1L, 7L)),
    l_f64 = list(c(NA, 1, 1, 2, 3, NA, Inf, NA), NA, numeric())
  )
  expect_equal(l_act_diff_1, l_exp_diff_1)

  l_act_diff_2 <- df$select(pl$all()$list$shift(2))
  l_exp_diff_2 <- pl$DataFrame(
    l_i32 = list(c(NA, NA, 1L:3L), c(NA, NA, 1L), c(NA, NA, 4L, 2L, 1L)),
    l_f64 = list(c(NA, NA, 1, 1, 2, 3, NA, Inf), NA, numeric())
  )
  expect_equal(l_act_diff_2, l_exp_diff_2)

  l_act_diff_0 <- df$select(pl$all()$list$shift(0))
  l_exp_diff_0 <- pl$DataFrame(
    l_i32 = list(1L:5L, 1L:3L, c(4L, 2L, 1L, 7L, 42L)),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), 1, numeric())
  )
  expect_equal(l_act_diff_0, l_exp_diff_0)

  l_act_diff_m1 <- df$select(pl$all()$list$shift(-1))
  l_exp_diff_m1 <- pl$DataFrame(
    l_i32 = list(c(2L:5L, NA), c(2L, 3L, NA), c(2L, 1L, 7L, 42L, NA)),
    l_f64 = list(c(1, 2, 3, NA, Inf, NA, Inf, NA), NA, numeric())
  )
  expect_equal(l_act_diff_m1, l_exp_diff_m1)
})

test_that("slice", {
  l <- list(
    l_i32 = list(1:5, 1:3, c(4L, 2L, 1L, 7L, 42L)),
    l_f64 = list(c(1, 1, 2, 3, NA, Inf, NA, Inf), c(1), numeric())
  )
  df <- pl$DataFrame(!!!l)

  r_slice <- function(x, o, n = NULL) {
    if (is.null(n)) n <- max(length(x) - o, 1L)
    if (o >= 0) {
      o <- o + 1
    } else {
      o <- length(x) + o + 1
    }
    s <- seq(o, o + n - 1)
    s <- s[s %in% seq_along(x)]
    x[s]
  }

  l_act_slice <- df$select(pl$all()$list$slice(0, 3))
  l_exp_slice <- pl$DataFrame(!!!lapply(l, lapply, r_slice, 0, 3))
  expect_equal(l_act_slice, l_exp_slice)


  l_act_slice <- df$select(pl$all()$list$slice(1, 3))
  l_exp_slice <- pl$DataFrame(!!!lapply(l, lapply, r_slice, 1, 3))
  expect_equal(l_act_slice, l_exp_slice)


  l_act_slice <- df$select(pl$all()$list$slice(1, 5))
  l_exp_slice <- pl$DataFrame(!!!lapply(l, lapply, r_slice, 1, 5))
  expect_equal(l_act_slice, l_exp_slice)

  l_act_slice <- df$select(pl$all()$list$slice(-1, 1))
  l_exp_slice <- pl$DataFrame(!!!lapply(l, lapply, r_slice, -1, 1))
  expect_equal(l_act_slice, l_exp_slice)

  l2 <- list(a = list(1:3, 1:2, 1:1, integer()))
  df2 <- pl$DataFrame(!!!l2)
  l_act_slice <- df2$select(pl$all()$list$slice(-2, 2))
  l_exp_slice <- pl$DataFrame(!!!lapply(l2, lapply, r_slice, -2, 2))
  expect_equal(l_act_slice, l_exp_slice)

  l_act_slice <- df2$select(pl$all()$list$slice(1, ))
  l_exp_slice <- pl$DataFrame(!!!lapply(l2, lapply, r_slice, 1))
  expect_equal(l_act_slice, l_exp_slice)
})

test_that("contains", {
  l <- list(
    i32 = list(1:4, 1:3, 1:1),
    f64 = list(c(1, 2, 3, NaN), c(NaN, 1, NA), c(Inf)),
    utf = list(letters, LETTERS, c(NA, "a"))
  )
  df <- pl$DataFrame(!!!l)

  l_act <- df$select(
    pl$col("i32")$list$contains(2L),
    pl$col("f64")$list$contains(Inf),
    pl$col("utf")$list$contains("a")
  )

  l_exp <- pl$DataFrame(
    i32 = sapply(l$i32, \(x) 2L %in% x),
    f64 = sapply(l$f64, \(x) Inf %in% x),
    utf = sapply(l$utf, \(x) "a" %in% x)
  )

  expect_equal(l_act, l_exp)
})

test_that("contains with categorical", {
  df <- pl$DataFrame(
    a = list(factor(c("a", "b")), factor(c("c", "d"))),
    item = c("a", "a")
  )
  expect_equal(
    df$select(
      with_expr = pl$col("a")$list$contains(pl$col("item")),
      with_lit = pl$col("a")$list$contains("e")
    ),
    pl$DataFrame(with_expr = c(TRUE, FALSE), with_lit = c(FALSE, FALSE))
  )
})


test_that("concat", {
  df <- pl$DataFrame(
    a = list("a", "x"),
    b = list(c("b", "c"), c("y", "z"))
  )

  expect_equal(
    df$select(pl$col("a")$list$concat(pl$col("b"))),
    pl$DataFrame(a = list(c("a", "b", "c"), c("x", "y", "z")))
  )

  expect_equal(
    df$select(pl$col("a")$list$concat(pl$lit("hello from R"))),
    pl$DataFrame(a = list(c("a", "hello from R"), c("x", "hello from R")))
  )

  expect_equal(
    df$select(pl$col("a")$list$concat(pl$lit(c("hello", "world")))),
    pl$DataFrame(a = list(c("a", "hello"), c("x", "world")))
  )
})


# TODO-REWRITE: don't know how to adapt Rust code
# test_that("to_struct", {
#   l <- list(integer(), 1:2, 1:3, 1:2)
#   df <- pl$DataFrame(a = l)
#   act_1 <- df$select(pl$col("a")$list$to_struct(
#     n_field_strategy = "first_non_null",
#     fields = \(idx) paste0("hello_you_", idx)
#   ))

#   act_2 <- df$select(pl$col("a")$list$to_struct(
#     n_field_strategy = "max_width",
#     fields = \(idx) paste0("hello_you_", idx)
#   ))


#   exp_1 <- list(
#     a = list(
#       hello_you_0 = c(NA, 1L, 1L, 1L),
#       hello_you_1 = c(NA, 2L, 2L, 2L)
#     )
#   )

#   exp_2 <- list(
#     a = list(
#       hello_you_0 = c(NA, 1L, 1L, 1L),
#       hello_you_1 = c(NA, 2L, 2L, 2L),
#       hello_you_2 = c(NA, NA, 3L, NA)
#     )
#   )

#   expect_equal(act_1, exp_1)
#   expect_equal(act_2, exp_2)
# })


# TODO-REWRITE: uncomment after pl$element() is implemented
# test_that("eval", {
#   df <- pl$DataFrame(a = c(1, 8, 3), b = c(4, 5, 2))
#   l_act <- df$with_columns(
#     pl$concat_list(list("a", "b"))$list$eval(pl$element()$rank())$alias("rank")
#   )
#   expect_equal(
#     l_act,
#     pl$DataFrame(
#       a = c(1, 8, 3),
#       b = c(4, 5, 2),
#       rank = list(c(1, 2), c(2, 1), c(2, 1))
#     )
#   )
#   expect_snapshot(
#     df$with_columns(
#       pl$concat_list(list("a", "b"))$list$eval(pl$element(), TRUE)
#     ),
#     error = TRUE
#   )
# })

test_that("$list$all() works", {
  df <- pl$DataFrame(
    a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c(), logical())
  )
  expect_equal(
    df$select(all = pl$col("a")$list$all()),
    pl$DataFrame(all = c(TRUE, FALSE, FALSE, TRUE, NA, TRUE))
  )
})

test_that("$list$any() works", {
  df <- pl$DataFrame(
    a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c(), logical())
  )
  expect_equal(
    df$select(any = pl$col("a")$list$any()),
    pl$DataFrame(any = c(TRUE, TRUE, FALSE, FALSE, NA, FALSE))
  )
})

# TODO-REWRITE: uncomment after pl$DataFrame() accepts schema, #13
# test_that("$list$set_*() work with integers", {
#   df <- pl$DataFrame(
#     a = list(1:3, NA, c(NA, 3L), 5:7),
#     b = list(2:4, 3L, c(3L, 4L, NA), c(6L, 8L)),
#     schema = list(a = pl$List(pl$Int16), b = pl$List(pl$Int32))
#   )

#   expect_equal(
#     df$select(pl$col("a")$list$set_union("b")),
#     pl$DataFrame(a = list(1:4, c(NA, 3L), c(NA, 3L, 4L), 5:8))
#   )
#   expect_equal(
#     df$select(pl$col("a")$list$set_intersection("b")),
#     pl$DataFrame(a = list(2:3, integer(0), c(NA, 3L), 6L))
#   )
#   expect_equal(
#     df$select(pl$col("a")$list$set_difference("b")),
#     pl$DataFrame(a = list(1L, NA, integer(0), c(5L, 7L)))
#   )
#   expect_equal(
#     df$select(pl$col("a")$list$set_symmetric_difference("b")),
#     pl$DataFrame(a = list(c(1L, 4L), c(NA, 3L), 4L, c(5L, 7L, 8L)))
#   )
# })

test_that("$list$set_*() work with strings", {
  df <- pl$DataFrame(
    a = list(letters[1:3], NA, c(NA, letters[3]), letters[5:7]),
    b = list(letters[2:4], letters[3], c(letters[3:4], NA), letters[c(6, 8)])
  )

  expect_equal(
    df$select(pl$col("a")$list$set_union("b")),
    pl$DataFrame(a = list(letters[1:4], c(NA, "c"), c(NA, "c", "d"), letters[5:8]))
  )
  expect_equal(
    df$select(pl$col("a")$list$set_intersection("b")),
    pl$DataFrame(a = list(c("b", "c"), character(0), c(NA, "c"), "f"))
  )
  expect_equal(
    df$select(pl$col("a")$list$set_difference("b")),
    pl$DataFrame(a = list("a", NA, character(0), c("e", "g")))
  )
  expect_equal(
    df$select(pl$col("a")$list$set_symmetric_difference("b")),
    pl$DataFrame(a = list(c("a", "d"), c(NA, "c"), "d", c("e", "g", "h")))
  )
})

test_that("$list$set_*() casts to common supertype", {
  df <- pl$DataFrame(
    a = list(c(1, 2), NA),
    b = list(c("a", "b"), NA)
  )
  expect_equal(
    df$select(pl$col("a")$list$set_union("b")),
    pl$DataFrame(a = list(c("1.0", "2.0", "a", "b"), NA))
  )
  expect_equal(
    df$select(pl$col("a")$list$set_intersection("b")),
    pl$DataFrame(a = list(character(0), NA))
  )
  expect_equal(
    df$select(pl$col("a")$list$set_difference("b")),
    pl$DataFrame(a = list(c("1.0", "2.0"), character(0)))
  )
  expect_equal(
    df$select(pl$col("a")$list$set_symmetric_difference("b")),
    pl$DataFrame(a = list(c("1.0", "2.0", "a", "b"), character(0)))
  )
})

test_that("$list$explode() works", {
  df <- pl$DataFrame(a = list(c(1, 2, 3), c(4, 5, 6)))
  expect_equal(
    df$select(pl$col("a")$list$explode()),
    pl$DataFrame(a = c(1, 2, 3, 4, 5, 6))
  )
  expect_snapshot(
    df$with_columns(pl$col("a")$list$explode()),
    error = TRUE
  )
})

test_that("$list$sample() works", {
  df <- pl$DataFrame(
    values = list(1:3, NA, c(NA, 3L), 5:7),
    n = c(1, 1, 1, 2)
  )

  expect_equal(
    df$select(
      sample = pl$col("values")$list$sample(n = pl$col("n"), seed = 1)
    ),
    pl$DataFrame(sample = list(3L, NA, 3L, 6:5))
  )

  expect_snapshot(df$select(pl$col("values")$list$sample(fraction = 2)), error = TRUE)

  expect_equal(
    df$select(
      sample = pl$col("values")$list$sample(fraction = 2, with_replacement = TRUE, seed = 1)
    ),
    pl$DataFrame(
      sample = list(
        c(3L, 1L, 1L, 2L, 2L, 3L),
        c(NA, NA),
        c(3L, NA, NA, NA),
        c(7L, 5L, 5L, 6L, 6L, 7L)
      )
    )
  )
})

test_that("list$std", {
  df <- pl$DataFrame(x = list(c(-1, 0, 1), c(1, 10)))

  expect_equal(
    df$with_columns(pl$col("x")$list$std()),
    pl$DataFrame(x = c(1, 6.369)),
    tolerance = 0.001
  )
})

test_that("list$var", {
  df <- pl$DataFrame(x = list(c(-1, 0, 1), c(1, 10)))

  expect_equal(
    df$with_columns(x = pl$col("x")$list$var()),
    pl$DataFrame(x = c(1, 40.5)),
    tolerance = 0.001
  )
})

test_that("list$median", {
  df <- pl$DataFrame(x = list(c(-1, 0, 1), c(1, 10)))
  expect_equal(
    df$with_columns(x = pl$col("x")$list$median()),
    pl$DataFrame(x = c(0, 5.5))
  )
})

test_that("list$to_array", {
  df <- pl$DataFrame(x = list(c(-1, 0), c(1, 10)))

  expect_equal(
    df$with_columns(pl$col("x")$list$to_array(2)),
    pl$DataFrame(x = list(c(-1, 0), c(1, 10)))$cast(pl$Array(pl$Float64, 2))
  )
})

test_that("list$drop_nulls", {
  df <- pl$DataFrame(x = list(c(NA, 0, NA), c(1, NaN), NA))

  expect_equal(
    df$with_columns(pl$col("x")$list$drop_nulls()),
    pl$DataFrame(x = list(0, c(1, NaN), numeric(0)))
  )
})

test_that("list$count_matches", {
  df <- pl$DataFrame(x = list(0, 1, c(1, 2, 3, 2), c(1, 2, 1), c(4, 4)))

  expect_equal(
    df$with_columns(pl$col("x")$list$count_matches(2)),
    pl$DataFrame(x = c(0, 0, 2, 1, 0))$cast(pl$UInt32)
  )
})
