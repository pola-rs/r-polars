test_that("pl$Series_apply", {
  # non strict casting just yields null for wrong type
  expect_identical(
    pl$Series(1:3, "integers")$
      apply(function(x) "wrong type", NULL, strict = FALSE)$
      to_r(),
    rep(NA_integer_, 3)
  )

  # strict type casting, throws an error
  expect_error(
    pl$Series(1:3, "integers")$apply(function(x) "wrong type", NULL, strict = TRUE)
  )

  # handle na int
  expect_identical(
    pl$Series(c(1:3, NA_integer_), "integers")
    $apply(function(x) x, NULL, TRUE)
    $to_vector(),
    c(1:3, NA)
  )

  # handle na nan double
  expect_identical(
    pl$Series(c(1, 2, NA_real_, NaN), "doubles")$
      apply(function(x) x, NULL, TRUE)$
      to_vector(),
    c(1, 2, NA, NaN) * 1.0
  )

  # handle na logical
  expect_identical(
    pl$Series(c(TRUE, FALSE, NA), "boolean")$
      apply(function(x) x, NULL, FALSE)$
      to_vector(),
    c(TRUE, FALSE, NA)
  )

  # handle na character
  expect_identical(
    pl$Series(c("A", "B", NA_character_), "strings")$
      apply(function(x) {
      if (isTRUE(x == "B")) 2 else x
    }, NULL, FALSE)$
      to_vector(),
    c("A", NA_character_, NA_character_)
  )


  # Int32 -> Float64
  expect_identical(
    pl$Series(c(1:3, NA_integer_), "integers")$
      apply(
      function(x) {
        if (is.na(x)) NA_real_ else as.double(x)
      },
      pl$dtypes$Float64,
      TRUE
    )$
      to_vector(),
    c(1, 2, 3, NA)
  )


  # Float64 -> Int32
  expect_identical(
    pl$Series(c(1, 2, 3, NA_real_), "integers")$
      apply(function(x) {
      if (is.na(x)) 42L else as.integer(x)
    }, datatype = pl$dtypes$Int32)$
      to_vector(),
    c(1:3, 42L)
  )


  # global statefull variables can be used in R user function (so can browser() debugging, nice!)
  global_var = 0L
  expect_identical(
    pl$Series(c(1:3, NA), "name")$
      apply(\(x) {
      global_var <<- global_var + 1L
      x + global_var
    }, NULL, TRUE)$
      to_vector(),
    c(2L, 4L, 6L, NA_integer_)
  )
  expect_equal(global_var, 4)
})

test_that("pl$Series_abs", {
  s = pl$Series(c(-42, 42, NA_real_))
  expect_identical(
    s$abs()$to_vector(),
    c(42, 42, NA_real_)
  )

  expect_s3_class(s$abs(), "Series")

  s_int = pl$Series(c(-42L, 42L, NA_integer_))
  expect_identical(
    s_int$abs()$to_vector(),
    c(42L, 42L, NA_integer_)
  )
})


test_that("pl$Series_alias", {
  s = pl$Series(letters, "foo")
  s2 = s$alias("bar")
  expect_identical(s$name, "foo")
  expect_identical(s2$name, "bar")
})


test_that("Series_append", {
  pl$set_polars_options(strictly_immutable = FALSE)

  s = pl$Series(letters, "foo")
  s2 = s
  S = pl$Series(LETTERS, "bar")
  unwrap(.pr$Series$append_mut(s, S))

  expect_identical(
    s$to_vector(),
    pl$Series(c(letters, LETTERS))$to_vector()
  )

  # default immutable behaviour, s_imut and s_imut_copy stay the same
  s_imut = pl$Series(1:3)
  s_imut_copy = s_imut
  s_new = s_imut$append(pl$Series(1:3))
  expect_identical(s_imut$to_vector(), s_imut_copy$to_vector())

  # pypolars-like mutable behaviour,s_mut_copy become the same as s_new
  s_mut = pl$Series(1:3)
  s_mut_copy = s_mut
  s_new = s_mut$append(pl$Series(1:3), immutable = FALSE)
  expect_identical(s_new$to_vector(), s_mut_copy$to_vector())

  pl$reset_polars_options()

  expect_error(
    s_new <- s_mut$append(pl$Series(1:3), immutable = FALSE),
    regexp = "breaks immutability"
  )
})


test_that("pl$Series_combine_c", {
  s = pl$Series(1:3, "foo")
  s2 = c(s, s, 1:3)
  s3 = pl$Series(c(1:3, 1:3, 1:3), "bar")

  expect_identical(
    s2$to_vector(),
    s3$to_vector()
  )
  expect_s3_class(s2, "Series")
})


test_that("all any", {
  expect_false(pl$Series(c(TRUE, TRUE, NA))$all())
  expect_false(pl$Series(c(TRUE, TRUE, FALSE))$all())
  expect_false(pl$Series(c(NA, NA, NA))$all())
  expect_true(pl$Series(c(TRUE, TRUE, TRUE))$all())
  expect_error(pl$Series(1:3)$all())

  expect_true(pl$Series(c(TRUE, TRUE, NA))$any())
  expect_true(pl$Series(c(TRUE, NA, FALSE))$any())
  expect_true(pl$Series(c(TRUE, FALSE, FALSE))$any())
  expect_false(pl$Series(c(FALSE, FALSE, NA))$any())
  expect_false(pl$Series(c(NA, NA, NA))$any())
  expect_error(pl$Series(1:3)$any())
})


# deprecated will come back when all expr functions are accisble via series
# test_that("is_unique", {
#   expect_true(pl$Series(1:5)$is_unique()$all())
#   expect_false(pl$Series(c(1:5,1))$is_unique()$all())
#   expect_false(pl$Series(c(1:3,NA,NA))$is_unique()$all())
#   expect_true(pl$Series(c(1:3,NA,NA))$is_unique()$any())
#   expect_true(pl$Series(c(1:3,NA))$is_unique()$all())
# })


test_that("clone", {
  s = pl$Series(1:3)
  s2 = s$clone()
  s3 = s2
  expect_different(s, s2)
  expect_different(pl$mem_address(s), pl$mem_address(s2))

  expect_identical(s2, s3)
  expect_identical(pl$mem_address(s2), pl$mem_address(s3))
})

test_that("dtype and equality", {
  expect_true(pl$Series(1:3)$dtype == pl$dtypes$Int32)
  expect_false(pl$Series(1:3)$dtype == pl$dtypes$Float64)

  expect_true(pl$Series(1.0)$dtype == pl$dtypes$Float64)
  expect_false(pl$Series(1.0)$dtype == pl$dtypes$Int32)
})


test_that("shape and len", {
  expect_identical(
    pl$Series(1:3)$shape,
    c(3, 1)
  )
  expect_identical(
    pl$Series(integer())$shape,
    c(0, 1)
  )
  expect_identical(pl$Series(integer())$len(), 0)
  expect_identical(pl$Series(1:3)$len(), 3)
})

test_that("floor & ceil", {
  expect_identical(
    pl$Series(c(1.5, .5, -.5, NA_real_, NaN))$
      floor()$
      to_r(),
    c(1, 0, -1, NA_real_, NaN)
  )
  expect_identical(
    pl$Series(c(1.5, .5, -.5, NA_real_, NaN))$
      ceil()$
      to_r(),
    c(2, 1, 0, NA_real_, NaN)
  )
})

test_that("to_frame", {
  # high level
  expect_identical(
    pl$Series(1:3, "foo")$
      to_frame()$
      to_data_frame(),
    data.frame(foo = 1:3)
  )
})


test_that("sorted flags, sort", {
  s = pl$Series(c(2, 1, 3))
  expect_true(s$sort(reverse = FALSE)$flags$SORTED_ASC)
  expect_true(s$sort(reverse = TRUE)$flags$SORTED_DESC)
  expect_false(any(unlist(pl$Series(1:4)$flags)))


  # Compare performance with Expr
  l = list(a = c(6, 1, 0, NA, Inf, -Inf, NaN))
  s = pl$Series(l$a, "a")
  l_actual_expr_sort = pl$DataFrame(l)$select(
    pl$col("a")$sort()$alias("sort"),
    pl$col("a")$sort(reverse = TRUE)$alias("sort_reverse")
  )$to_list()

  expect_identical(
    l_actual_expr_sort,
    list(
      sort = s$sort()$to_r(),
      sort_reverse = s$sort(reverse = TRUE)$to_r()
    )
  )
})

# test_that("is_sorted  sort", {
#   s = pl$Series(c(NA,2,1,3,NA))
#   s_sorted = s$sort(reverse = FALSE)
#   expect_true(s_sorted$is_sorted())
#   expect_false(s$is_sorted())
#
#   s_sorted_rev = s$sort(reverse = TRUE)
#   expect_false(s_sorted_rev$is_sorted(reverse = FALSE))
#   expect_true(s_sorted_rev$is_sorted(reverse = TRUE, nulls_last = FALSE))
#   expect_false(s_sorted_rev$is_sorted(reverse = TRUE, nulls_last = TRUE))
#
# })

test_that("set_sorted", {
  pl$reset_polars_options()

  expect_error(
    pl$Series(c(1, 3, 2, 4))$set_sorted(in_place = TRUE),
    regexp = "breaks immutability"
  )

  pl$set_polars_options(strictly_immutable = FALSE)

  # test in_place, test set_sorted
  s = pl$Series(c(1, 3, 2, 4))
  s$set_sorted(reverse = FALSE, in_place = TRUE)
  expect_identical(
    s$sort(reverse = FALSE)$to_r(),
    c(1, 3, 2, 4)
  )

  # test NOT in_place no effect
  s = pl$Series(c(1, 3, 2, 4))
  s$set_sorted(reverse = FALSE, in_place = FALSE)
  expect_identical(
    s$sort(reverse = FALSE)$to_r(),
    c(1, 2, 3, 4)
  )

  # test NOT in_place with effect
  s = pl$Series(c(1, 3, 2, 4))$
    set_sorted(reverse = FALSE, in_place = FALSE)$
    sort()$
    to_r()
  expect_identical(s, c(1, 3, 2, 4))

  # test NOT in_place. reverse-reverse
  s = pl$Series(c(1, 3, 2, 4))$
    set_sorted(reverse = TRUE, in_place = FALSE)$
    sort(reverse = TRUE)$
    to_r()
  expect_identical(s, c(1, 3, 2, 4))

  pl$reset_polars_options()
})

test_that("value counts", {
  s = pl$Series(c(1, 4, 4, 4, 4, 3, 3, 3, 2, 2, NA))
  s_st = s$value_counts(sorted = TRUE, multithreaded = FALSE)
  s_mt = s$value_counts(sorted = TRUE, multithreaded = FALSE)
  df_st = s_st$to_data_frame()
  df_mt = s_st$to_data_frame()

  expect_identical(df_st[[1L]], c(4, 3, 2, 1, NA))
  expect_identical(df_mt[[1L]], c(4, 3, 2, 1, NA))

  # notice counts are mapped to numeric
  expect_identical(df_st[[2]], c(4, 3, 2, 1, 1))
  expect_identical(df_mt[[2]], c(4, 3, 2, 1, 1))
})

test_that("arg minmax", {
  s1 = pl$Series(c(NA, 3, 1, 2))
  s2 = pl$Series(c(NA_real_, NA_real_))
  expect_equal(s1$arg_max(), 1)
  expect_equal(s1$arg_min(), 0) # polars define NULL as smallest value
  expect_equal(s2$arg_max(), 0)
  expect_equal(s2$arg_min(), 0)
})

test_that("series comparison", {
  expect_true((pl$Series(1:4) == pl$Series(1:4))$all())
  expect_true((pl$Series(1:4) == 1:4)$all())
  expect_true((pl$Series(letters) == pl$Series(letters))$all())
  expect_true((pl$Series(letters) == letters)$all())
  expect_false((pl$Series(letters) == LETTERS)$any())
  expect_true((pl$Series(1:4, "foo") == pl$Series(1:4, "foo"))$all())

  expect_true((pl$Series(1:4) == pl$Series(1:4))$any())
  expect_true((pl$Series(letters) == pl$Series(letters))$any())
  expect_true((pl$Series(1:4, "foo") == pl$Series(1:4, "bar"))$all())

  expect_false((pl$Series(1) == pl$Series(NA_integer_))$all())
  expect_false((pl$Series(1) == pl$Series(NA_integer_))$all())
  expect_true((pl$Series(5L) == pl$Series(5.0))$all())

  expect_true((pl$Series(5) < 6)$all())
  expect_true((pl$Series(5) <= 6)$all())
  expect_false((pl$Series(6) < 5)$all())
  expect_false((pl$Series(6) <= 5)$all())

  expect_true((pl$Series("a") > 5)$all())
  expect_true((pl$Series("a") < "ab")$all())
  expect_true((pl$Series("ab") == "ab")$all())
  expect_true((pl$Series("true") == TRUE)$all())

  expect_true((pl$Series(1:5) <= 5)$all())
  expect_false((pl$Series(1:5) <= 3)$all())
  expect_true((pl$Series(1:5) < 11:15)$all())
  expect_error(
    (pl$Series(1:5) <= c(1:2))$all(),
    regexp = "not same length or either of length 1."
  )
})



test_that("rep", {
  # rechunk FALSE gives same result
  expect_identical(
    pl$Series(1:2, "alice")$rep(2, rechunk = FALSE)$to_r(),
    pl$Series(rep(1:2, 2), "alice")$to_r()
  )

  expect_identical(
    pl$Series(1:2, "alice")$rep(2, rechunk = TRUE)$to_r(),
    pl$Series(rep(1:2, 2), "alice")$to_r()
  )
  # ^^^^^^^^^^^^^^^^ why is the expectation the same in both cases?

  expect_identical(
    pl$Series(1:2, "alice")$rep(1)$to_r(),
    pl$Series(rep(1:2, 1), "alice")$to_r()
  )

  expect_identical(
    pl$Series(1:2, "alice")$rep(0)$to_r(),
    pl$Series(rep(1:2, 0), "alice")$to_r()
  )

  expect_identical(
    pl$Series(1:2, "alice")$rep(0)$to_r(),
    integer(0)
  )

  expect_error(
    pl$Series(1:2, "alice")$rep(-1)$to_r(),
    regexp = "cannot be less than zero"
  )
})


test_that("Series list", {
  series_list = pl$DataFrame(list(a = c(1:5, NA_integer_)))$select(
    pl$col("a")$implode()$implode()$append(
      (
        pl$col("a")$head(2)$implode()$append(
          pl$col("a")$tail(1)$implode()
        )
      )$implode()
    )
  )$get_column("a") # get series from DataFrame

  expected_list = list(list(c(1L, 2L, 3L, 4L, 5L, NA)), list(1:2, NA_integer_))
  expect_identical(series_list$to_r(), expected_list)
  expect_identical(series_list$to_r_list(), expected_list)
  expect_identical(series_list$to_vector(), unlist(expected_list))

  series_vec = pl$Series(1:5)
  expect_identical(series_vec$to_r(), 1:5)
  expect_identical(series_vec$to_vector(), 1:5)
  expect_identical(series_vec$to_r_list(), as.list(1:5))


  # build heterogenous sized 3-level nested list of chars
  set.seed(1)
  l = lapply(sample(1:10, size = 10, replace = TRUE), function(x) {
    lapply(sample(1:10, size = x, replace = TRUE), function(x) {
      lapply(sample(0:4, size = x, replace = TRUE), function(x) {
        sample(letters, size = x, replace = TRUE)
      })
    })
  })

  # parse and assemble nested Series
  s = pl$Series(l)

  # check data_type
  expect_true(s$dtype == with(pl, List(List(List(Utf8)))))

  # flatten 3-levels and return to R
  # TODO CONTRIBUTE POLARS this is a bug, when flattening an empty list, it should not give a null
  # ul = unlist(pl$DataFrame(s)$select(pl$col("")$flatten()$flatten()$flatten())$to_list())
  # expect_true(all(unlist(l) == ul))
})


test_that("Series numeric", {
  expect_true(pl$Series(1:4)$is_numeric())
  expect_true(pl$Series(c(1, 2, 3))$is_numeric())
  expect_false(pl$Series(c("a", "b", "c"))$is_numeric())
  expect_false(pl$Series(c(TRUE, FALSE))$is_numeric())
  expect_false(pl$Series(c(NA, NA))$is_numeric())
})

test_that("to_series", {
  l = list(a = 1:3, b = c("a", "b", "c"))
  expect_identical(pl$DataFrame(l)$to_series(0)$to_r(), l$a)
  expect_identical(pl$DataFrame(l)$to_series(1)$to_r(), l$b)
  expect_identical(pl$DataFrame(l)$to_series(2), NULL)
})


test_that("Backward compatibility: to_r_vector", {
  expect_identical(pl$Series(1:3)$to_r_vector(), 1:3)
})

test_that("internal method get_fmt and to_fmt_char", {
  s_1 = pl$Series(c("foo", "bar"))
  expect_equal(
    .pr$Series$get_fmt(s_1, index = 1, str_length = 3),
    '"ba…'
  )
  expect_equal(
    .pr$Series$get_fmt(s_1, index = 0, str_length = 100),
    '"foo"'
  )
  expect_equal(
    .pr$Series$to_fmt_char(s_1, 3),
    c('"fo…', '"ba…')
  )
  expect_equal(
    .pr$Series$to_fmt_char(s_1, 100),
    c('"foo"', '"bar"')
  )
})


make_cases = function() {
  tibble::tribble(
    ~.test_name, ~base,
    "mean", mean,
    "median", median,
    "std", sd,
    "var", var,
  )
}
patrick::with_parameters_test_that("mean, median, std, var",
  {
    s = pl$Series(rnorm(100))
    a = s[[.test_name]]()
    # upstream .std_as_series() does not appear to return Series
    if (inherits(a, "Series")) a <- a$to_vector()
    b = base(s$to_vector())
    expect_equal(a, b)
  },
  .cases = make_cases()
)


test_that("n_unique", {
  x = c(1:4, NA, NaN, 1) # 6 unique one repeated
  expect_identical(pl$Series(x)$n_unique(), 6)
  expect_grepl_error(pl$Series(c())$n_unique(), "operation not supported for dtype")
})
