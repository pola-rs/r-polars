test_that("pl$Series_apply", {
  # non strict casting just yields null for wrong type
  expect_identical(
    as_polars_series(1:3, "integers")$
      map_elements(function(x) "wrong type", NULL, strict = FALSE)$
      to_r(),
    rep(NA_integer_, 3)
  )

  # strict type casting, throws an error
  expect_grepl_error(
    as_polars_series(1:3, "integers")$map_elements(function(x) "wrong type", NULL, strict = TRUE)
  )

  # handle na int
  expect_identical(
    as_polars_series(c(1:3, NA_integer_), "integers")
    $map_elements(function(x) x, NULL, TRUE)
    $to_vector(),
    c(1:3, NA)
  )

  # handle na nan double
  expect_identical(
    as_polars_series(c(1, 2, NA_real_, NaN), "doubles")$
      map_elements(function(x) x, NULL, TRUE)$
      to_vector(),
    c(1, 2, NA, NaN) * 1.0
  )

  # handle na logical
  expect_identical(
    as_polars_series(c(TRUE, FALSE, NA), "boolean")$
      map_elements(function(x) x, NULL, FALSE)$
      to_vector(),
    c(TRUE, FALSE, NA)
  )

  # handle na character
  expect_identical(
    as_polars_series(c("A", "B", NA_character_), "strings")$
      map_elements(function(x) {
      if (isTRUE(x == "B")) 2 else x
    }, NULL, FALSE)$
      to_vector(),
    c("A", NA_character_, NA_character_)
  )


  # Int32 -> Float64
  expect_identical(
    as_polars_series(c(1:3, NA_integer_), "integers")$
      map_elements(
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
    as_polars_series(c(1, 2, 3, NA_real_), "integers")$
      map_elements(function(x) {
      if (is.na(x)) 42L else as.integer(x)
    }, datatype = pl$dtypes$Int32)$
      to_vector(),
    c(1:3, 42L)
  )


  # global statefull variables can be used in R user function (so can browser() debugging, nice!)
  global_var = 0L
  expect_identical(
    as_polars_series(c(1:3, NA), "name")$
      map_elements(\(x) {
      global_var <<- global_var + 1L
      x + global_var
    }, NULL, TRUE)$
      to_vector(),
    c(2L, 4L, 6L, NA_integer_)
  )
  expect_equal(global_var, 4)
})

test_that("pl$Series_abs", {
  s = as_polars_series(c(-42, 42, NA_real_))
  expect_identical(
    s$abs()$to_vector(),
    c(42, 42, NA_real_)
  )

  expect_s3_class(s$abs(), "RPolarsSeries")

  s_int = as_polars_series(c(-42L, 42L, NA_integer_))
  expect_identical(
    s_int$abs()$to_vector(),
    c(42L, 42L, NA_integer_)
  )
})


test_that("pl$Series_alias", {
  s = as_polars_series(letters, "foo")
  s2 = s$alias("bar")
  expect_identical(s$name, "foo")
  expect_identical(s2$name, "bar")
})


test_that("Series_append", {
  skip_if_not_installed("withr")
  withr::with_options(
    list(polars.strictly_immutable = FALSE),
    {
      s = as_polars_series(letters, "foo")
      s2 = s
      S = as_polars_series(LETTERS, "bar")
      unwrap(.pr$Series$append_mut(s, S))

      expect_identical(
        s$to_vector(),
        as_polars_series(c(letters, LETTERS))$to_vector()
      )

      # default immutable behavior, s_imut and s_imut_copy stay the same
      s_imut = as_polars_series(1:3)
      s_imut_copy = s_imut
      s_new = s_imut$append(as_polars_series(1:3))
      expect_identical(s_imut$to_vector(), s_imut_copy$to_vector())

      # pypolars-like mutable behavior,s_mut_copy become the same as s_new
      s_mut = as_polars_series(1:3)
      s_mut_copy = s_mut
      s_new = s_mut$append(as_polars_series(1:3), immutable = FALSE)
      expect_identical(s_new$to_vector(), s_mut_copy$to_vector())
    }
  )

  expect_grepl_error(
    s_mut$append(as_polars_series(1:3), immutable = FALSE),
    regexp = "breaks immutability"
  )
})


test_that("pl$Series_combine_c", {
  s = as_polars_series(1:3, "foo")
  s2 = c(s, s, 1:3)
  s3 = as_polars_series(c(1:3, 1:3, 1:3), "bar")

  expect_identical(
    s2$to_vector(),
    s3$to_vector()
  )
  expect_s3_class(s2, "RPolarsSeries")
})


test_that("all any", {
  expect_false(as_polars_series(c(TRUE, TRUE, NA))$all())
  expect_false(as_polars_series(c(TRUE, TRUE, FALSE))$all())
  expect_false(as_polars_series(c(NA, NA, NA))$all())
  expect_true(as_polars_series(c(TRUE, TRUE, TRUE))$all())
  expect_grepl_error(as_polars_series(1:3)$all())

  expect_true(as_polars_series(c(TRUE, TRUE, NA))$any())
  expect_true(as_polars_series(c(TRUE, NA, FALSE))$any())
  expect_true(as_polars_series(c(TRUE, FALSE, FALSE))$any())
  expect_false(as_polars_series(c(FALSE, FALSE, NA))$any())
  expect_false(as_polars_series(c(NA, NA, NA))$any())
  expect_grepl_error(as_polars_series(1:3)$any())
})


# deprecated will come back when all expr functions are accisble via series
# test_that("is_unique", {
#   expect_true(as_polars_series(1:5)$is_unique()$all())
#   expect_false(as_polars_series(c(1:5,1))$is_unique()$all())
#   expect_false(as_polars_series(c(1:3,NA,NA))$is_unique()$all())
#   expect_true(as_polars_series(c(1:3,NA,NA))$is_unique()$any())
#   expect_true(as_polars_series(c(1:3,NA))$is_unique()$all())
# })


test_that("clone", {
  s = as_polars_series(1:3)
  s2 = s$clone()
  s3 = s2
  expect_different(s, s2)
  expect_different(pl$mem_address(s), pl$mem_address(s2))

  expect_identical(s2, s3)
  expect_identical(pl$mem_address(s2), pl$mem_address(s3))
})

test_that("cloning to avoid giving attributes to original data", {
  df1 = as_polars_series(1:10)

  give_attr = function(data) {
    attr(data, "created_on") = "2024-01-29"
    data
  }
  df2 = give_attr(df1)
  expect_identical(attributes(df1)$created_on, "2024-01-29")

  give_attr2 = function(data) {
    data = data$clone()
    attr(data, "created_on") = "2024-01-29"
    data
  }
  df1 = as_polars_series(1:10)
  df2 = give_attr2(df1)
  expect_null(attributes(df1)$created_on)
})

test_that("dtype and equality", {
  expect_true(as_polars_series(1:3)$dtype == pl$dtypes$Int32)
  expect_false(as_polars_series(1:3)$dtype == pl$dtypes$Float64)

  expect_true(as_polars_series(1.0)$dtype == pl$dtypes$Float64)
  expect_false(as_polars_series(1.0)$dtype == pl$dtypes$Int32)
})


test_that("shape and len", {
  expect_identical(
    as_polars_series(1:3)$shape,
    c(3, 1)
  )
  expect_identical(
    as_polars_series(integer())$shape,
    c(0, 1)
  )
  expect_identical(as_polars_series(integer())$len(), 0)
  expect_identical(as_polars_series(1:3)$len(), 3)
})

test_that("n_chunks", {
  s = as_polars_series(1:3)
  s2 = as_polars_series(4:6)
  expect_identical(s$n_chunks(), 1)
  expect_identical(pl$concat(s, s2, rechunk = TRUE)$n_chunks(), 1)
  expect_identical(pl$concat(s, s2, rechunk = FALSE)$n_chunks(), 2)
})

test_that("floor & ceil", {
  expect_identical(
    as_polars_series(c(1.5, .5, -.5, NA_real_, NaN))$
      floor()$
      to_r(),
    c(1, 0, -1, NA_real_, NaN)
  )
  expect_identical(
    as_polars_series(c(1.5, .5, -.5, NA_real_, NaN))$
      ceil()$
      to_r(),
    c(2, 1, 0, NA_real_, NaN)
  )
})

test_that("to_frame", {
  # high level
  expect_identical(
    as_polars_series(1:3, "foo")$
      to_frame()$
      to_data_frame(),
    data.frame(foo = 1:3)
  )
})

test_that("flags work", {
  s = as_polars_series(c(2, 1, 3))
  expect_identical(
    s$sort()$flags,
    list(SORTED_ASC = TRUE, SORTED_DESC = FALSE)
  )
  expect_identical(
    s$sort(descending = TRUE)$flags,
    list(SORTED_ASC = FALSE, SORTED_DESC = TRUE)
  )

  s = as_polars_series(list(1, 2, 3))
  expect_identical(
    s$flags,
    list(SORTED_ASC = FALSE, SORTED_DESC = FALSE, FAST_EXPLODE = TRUE)
  )
})

test_that("sort on Series and Expr gives same results", {
  s = as_polars_series(c(2, 1, 3))

  l = list(a = c(6, 1, 0, NA, Inf, -Inf, NaN))
  s = as_polars_series(l$a, "a")
  l_actual_expr_sort = pl$DataFrame(l)$select(
    pl$col("a")$sort()$alias("sort"),
    pl$col("a")$sort(descending = TRUE)$alias("sort_reverse")
  )$to_list()

  expect_identical(
    l_actual_expr_sort,
    list(
      sort = s$sort()$to_r(),
      sort_reverse = s$sort(descending = TRUE)$to_r()
    )
  )
})

test_that("$is_sorted() works", {
  s = as_polars_series(c(NA, 2, 1, 3, NA))
  expect_false(s$is_sorted())

  s_sorted = s$sort(descending = FALSE)
  expect_true(s_sorted$is_sorted())

  s_sorted = s$sort(descending = FALSE, nulls_last = TRUE)
  expect_true(s_sorted$is_sorted())

  s_sorted_rev = s$sort(descending = TRUE)
  expect_false(s_sorted_rev$is_sorted(descending = FALSE))
  expect_true(s_sorted_rev$is_sorted(descending = TRUE))
})

test_that("set_sorted", {
  expect_grepl_error(
    as_polars_series(c(1, 3, 2, 4))$set_sorted(in_place = TRUE),
    regexp = "breaks immutability"
  )

  skip_if_not_installed("withr")
  withr::with_options(
    list(polars.strictly_immutable = FALSE),
    {
      # test in_place, test set_sorted
      s = as_polars_series(c(1, 3, 2, 4))
      s$set_sorted(descending = FALSE, in_place = TRUE)
      expect_identical(
        s$sort(descending = FALSE)$to_r(),
        c(1, 3, 2, 4)
      )

      # test NOT in_place no effect
      s = as_polars_series(c(1, 3, 2, 4))
      s$set_sorted(descending = FALSE, in_place = FALSE)
      expect_identical(
        s$sort(descending = FALSE)$to_r(),
        c(1, 2, 3, 4)
      )

      # test NOT in_place with effect
      s = as_polars_series(c(1, 3, 2, 4))$
        set_sorted(descending = FALSE, in_place = FALSE)$
        sort()$
        to_r()
      expect_identical(s, c(1, 3, 2, 4))

      # test NOT in_place. reverse-reverse
      s = as_polars_series(c(1, 3, 2, 4))$
        set_sorted(descending = TRUE, in_place = FALSE)$
        sort(descending = TRUE)$
        to_r()
      expect_identical(s, c(1, 3, 2, 4))
    }
  )
})

test_that("value counts", {
  s = as_polars_series(c(1, 4, 4, 4, 4, 3, 3, 3, 2, 2, NA))
  s_st = s$value_counts(sort = TRUE, parallel = FALSE)
  s_mt = s$value_counts(sort = TRUE, parallel = FALSE)
  df_st = s_st$to_data_frame()
  df_mt = s_st$to_data_frame()

  expect_identical(df_st[[1L]], c(4, 3, 2, 1, NA))
  expect_identical(df_mt[[1L]], c(4, 3, 2, 1, NA))

  # notice counts are mapped to numeric
  expect_identical(df_st[[2]], c(4, 3, 2, 1, 1))
  expect_identical(df_mt[[2]], c(4, 3, 2, 1, 1))
})

test_that("arg minmax", {
  s1 = as_polars_series(c(NA, 3, 1, 2))
  s2 = as_polars_series(c(NA_real_, NA_real_))
  expect_equal(s1$arg_max(), 1)
  expect_equal(s1$arg_min(), 2)
  expect_equal(s2$arg_max(), NA_real_)
  expect_equal(s2$arg_min(), NA_real_)
})

test_that("series comparison", {
  expect_true((as_polars_series(1:4) == as_polars_series(1:4))$all())
  expect_true((as_polars_series(1:4) == 1:4)$all())
  expect_true((as_polars_series(letters) == as_polars_series(letters))$all())
  expect_true((as_polars_series(letters) == letters)$all())
  expect_false((as_polars_series(letters) == LETTERS)$any())
  expect_true((as_polars_series(1:4, "foo") == as_polars_series(1:4, "foo"))$all())

  expect_true((as_polars_series(1:4) == as_polars_series(1:4))$any())
  expect_true((as_polars_series(letters) == as_polars_series(letters))$any())
  expect_true((as_polars_series(1:4, "foo") == as_polars_series(1:4, "bar"))$all())

  expect_false((as_polars_series(1) == as_polars_series(NA_integer_))$all())
  expect_false((as_polars_series(1) == as_polars_series(NA_integer_))$all())
  expect_true((as_polars_series(5L) == as_polars_series(5.0))$all())

  expect_true((as_polars_series(5) < 6)$all())
  expect_true((as_polars_series(5) <= 6)$all())
  expect_false((as_polars_series(6) < 5)$all())
  expect_false((as_polars_series(6) <= 5)$all())

  expect_true((as_polars_series("a") > 5)$all())
  expect_true((as_polars_series("a") < "ab")$all())
  expect_true((as_polars_series("ab") == "ab")$all())
  expect_true((as_polars_series("true") == TRUE)$all())

  expect_true((as_polars_series(1:5) <= 5)$all())
  expect_false((as_polars_series(1:5) <= 3)$all())
  expect_true((as_polars_series(1:5) < 11:15)$all())
  expect_grepl_error(
    (as_polars_series(1:5) <= c(1:2))$all(),
    regexp = "not same length or either of length 1."
  )
})



test_that("rep", {
  # rechunk FALSE gives same result
  expect_identical(
    as_polars_series(1:2, "alice")$rep(2, rechunk = FALSE)$to_r(),
    as_polars_series(rep(1:2, 2), "alice")$to_r()
  )

  expect_identical(
    as_polars_series(1:2, "alice")$rep(2, rechunk = TRUE)$to_r(),
    as_polars_series(rep(1:2, 2), "alice")$to_r()
  )
  # ^^^^^^^^^^^^^^^^ why is the expectation the same in both cases?

  expect_identical(
    as_polars_series(1:2, "alice")$rep(1)$to_r(),
    as_polars_series(rep(1:2, 1), "alice")$to_r()
  )

  expect_identical(
    as_polars_series(1:2, "alice")$rep(0)$to_r(),
    as_polars_series(rep(1:2, 0), "alice")$to_r()
  )

  expect_identical(
    as_polars_series(1:2, "alice")$rep(0)$to_r(),
    integer(0)
  )

  expect_grepl_error(
    as_polars_series(1:2, "alice")$rep(-1)$to_r(),
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
  expect_identical(series_list$to_list(), expected_list)
  expect_identical(series_list$to_vector(), unlist(expected_list))

  series_vec = as_polars_series(1:5)
  expect_identical(series_vec$to_r(), 1:5)
  expect_identical(series_vec$to_vector(), 1:5)
  expect_identical(series_vec$to_list(), as.list(1:5))


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
  s = as_polars_series(l)

  # check data_type
  expect_true(s$dtype == with(pl, List(List(List(String)))))

  # Note: flattening an empty list returns null in polars
  # https://github.com/pola-rs/polars/issues/6723
  # https://github.com/pola-rs/polars/issues/14381
  ul = pl$DataFrame(s)$select(pl$col("")$flatten()$flatten()$flatten())$to_list() |>
    unlist()

  expect_identical(
    lapply(ul, \(x) if (length(x) == 0) NA_character_ else x) |>
      unlist(),
    ul
  )
})


test_that("Series numeric", {
  expect_true(as_polars_series(1:4)$is_numeric())
  expect_true(as_polars_series(c(1, 2, 3))$is_numeric())
  expect_false(as_polars_series(c("a", "b", "c"))$is_numeric())
  expect_false(as_polars_series(c(TRUE, FALSE))$is_numeric())
  expect_false(as_polars_series(c(NA, NA))$is_numeric())
})

test_that("to_series", {
  l = list(a = 1:3, b = c("a", "b", "c"))
  expect_identical(pl$DataFrame(l)$to_series(0)$to_r(), l$a)
  expect_identical(pl$DataFrame(l)$to_series(1)$to_r(), l$b)
  expect_identical(pl$DataFrame(l)$to_series(2), NULL)
})

test_that("internal method get_fmt and to_fmt_char", {
  s_1 = as_polars_series(c("foo", "bar"))
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
    s = as_polars_series(rnorm(100))
    a = s[[.test_name]]()
    # upstream .std_as_series() does not appear to return Series
    if (inherits(a, "RPolarsSeries")) a = a$to_vector()
    b = base(s$to_vector())
    expect_equal(a, b)
  },
  .cases = make_cases()
)


test_that("n_unique", {
  x = c(1:4, NA, NaN, 1) # 6 unique one repeated
  expect_identical(as_polars_series(x)$n_unique(), 6)
  expect_identical(as_polars_series(c())$n_unique(), 0)
})


test_that("method from Expr", {
  expect_equal(as_polars_series(1:3)$cos()$to_r(), cos(1:3))
})

test_that("cum_sum", {
  expect_equal(as_polars_series(c(1, 2, NA, 3))$cum_sum()$to_r(), c(1, 3, NA, 6))
})

test_that("the dtype argument of pl$Series", {
  expect_identical(pl$Series(values = 1, dtype = pl$String)$to_r(), "1.0")
  expect_grepl_error(pl$Series(values = "foo", dtype = pl$Int32), "conversion from `str` to `i32`")
})

test_that("the nan_to_null argument of pl$Series", {
  expect_identical(pl$Series(values = c(1, 2, NA, NaN), nan_to_null = TRUE)$to_r(), c(1, 2, NA, NA))
})

# TODO: remove this
test_that("Positional arguments deprecation", {
  expect_warning(
    pl$Series("foo"),
    "the first argument"
  )
  expect_true(
    suppressWarnings(pl$Series("foo"))$equals(
      pl$Series(values = "foo")
    )
  )
  expect_true(
    suppressWarnings(pl$Series("foo", "bar"))$equals(
      pl$Series(values = "foo", name = "bar")
    )
  )
  expect_true(
    suppressWarnings(pl$Series(1, "bar", pl$UInt8))$equals(
      pl$Series(values = 1, name = "bar", dtype = pl$UInt8)
    )
  )
  expect_true(
    suppressWarnings(pl$Series(1, name = "bar", dtype = pl$UInt8))$equals(
      pl$Series(values = 1, name = "bar", dtype = pl$UInt8)
    )
  )
  expect_true(
    suppressWarnings(pl$Series(values = "foo", "bar"))$equals(
      pl$Series(values = "foo")
    )
  )
})

test_that("$item() works", {
  expect_equal(pl$Series(values = 1)$item(), 1)
  expect_equal(pl$Series(values = 3:1)$cum_sum()$item(-1), 6)

  # errors
  expect_grepl_error(
    pl$Series(values = 1)$item(c(0, 0)),
    "`index` must be an integer of length 1"
  )
  expect_grepl_error(
    pl$Series(values = 1)$item("a"),
    "`index` must be an integer of length 1"
  )
  expect_grepl_error(
    pl$Series(values = 1:2)$item(),
    "if the Series is of length 1"
  )
})

test_that("$clear() works", {
  s = pl$Series(name = "a", values = 1:3)

  expect_identical(
    s$clear() |> as.vector(),
    integer(0)
  )

  expect_identical(s$clear()$name, "a")

  expect_identical(
    s$clear(5) |> as.vector(),
    rep(NA_integer_, 5)
  )

  # error
  expect_grepl_error(
    s$clear(-1),
    "greater or equal to 0"
  )
  expect_grepl_error(
    s$clear("a"),
    "greater or equal to 0"
  )
  expect_grepl_error(
    s$clear(0:1),
    "greater or equal to 0"
  )
})
