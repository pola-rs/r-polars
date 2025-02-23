patrick::with_parameters_test_that(
  "infer_polars_dtype() works for various objects",
  x = {
    skip_if_not_installed("hms")
    skip_if_not_installed("blob")
    skip_if_not_installed("bit64")
    skip_if_not_installed("vctrs")
    skip_if_not_installed("clock")

    withr::with_timezone(
      "UTC",
      list2(
        as_polars_series(1),
        pl$DataFrame(a = 1L, b = "foo"),
        pl$LazyFrame(a = 1L, b = "foo"),
        1:10,
        integer(),
        NA,
        NA_character_,
        raw(),
        factor(),
        as.Date(NA),
        as.POSIXct(NA),
        as.POSIXlt(NA, "UTC"),
        as.difftime(integer(), units = "days"),
        numeric_version(character()),
        numeric_version(NA_character_, strict = FALSE),
        NULL,
        list(1, "foo"),
        list(NULL, 1L),
        list(),
        data.frame(a = 1L, b = "foo"),
        data.frame(a = 1L, b = I(list("foo"))),
        vctrs::unspecified(10),
        hms::hms(),
        blob::blob(),
        bit64::integer64(),
        vctrs::list_of(NULL, 1L),
        vctrs::list_of(NULL, raw(0)),
        vctrs::list_of(NULL, list(1L)),
        vctrs::list_of(NULL, list(), list("foo")),
        vctrs::list_of(NULL, data.frame(a = 1L), data.frame(b = "foo")),
        vctrs::list_of(NULL, data.frame(a = 1L), data.frame(b = I(list("foo")))),
        vctrs::new_rcrd(list(a = 1L, b = "foo")),
        vctrs::new_rcrd(list(a = 1L, b = list("foo"), c = list(list("bar")))),
        clock::naive_time_parse(NA_character_),
        clock::duration_years(NA),
      )
    )
  },
  code = {
    withr::with_timezone("UTC", {
      expect_equal(
        infer_polars_dtype(x),
        as_polars_series(x)$dtype
      )
    })
  }
)

patrick::with_parameters_test_that(
  "infer_polars_dtype() works for various objects",
  # fmt: skip
  .cases = tibble::tribble(
    ~.test_name, ~x,
    "complex", 1i,
    "polars_dtype", pl$Null,
  ),
  code = {
    expect_snapshot(infer_polars_dtype(x), error = TRUE)
  }
)
