test_that("rust-polars DataFrame import/export via arrow stream", {
  # this round trip conversion is only a unit test, not an integration test.
  # Arrow export/import of DataFrame is mainly useful to interface with other R packages using
  # rust-polars

  # see https://github.com/rpolars/extendrpolarsexamples/blob/main/src/rust/src/lib.rs
  # for simple example of use to import/export polars DataFrames to another rust-polars
  # compilation unit in another R package. Version of rust-polars does not have to match.

  # These function are not a part of the public user API. But package developer can use them to
  # import/export df's.

  # ARROW STREAM HAS AN CONTRACT TO UPHOLD BY PRODUCER AND CONSUMER. WRONG BEHAVOIR CAUSES SEGFAULT.
  # SEE OUTCOMMENTED EXAMPLES OF ILLEGAL BEHAVIOR LEADING TO SEGFAULT BELOW.

  # PRODUCER has some df which could be chunked as here. Categoricals with global string cache
  # are also ok.
  pl$with_string_cache({
    df_export = pl$concat(lapply(1:3, \(i) pl$DataFrame(iris)))
  })

  # CONSUMER creates a new arrow stream and return ptr which is passed to PRODUCER
  str_ptr = new_arrow_stream()

  # PRODUCER exports the df into CONSUMERs stream
  export_df_to_arrow_stream(df_export, str_ptr) |> unwrap()

  # CONSUMER can now import the df from stream
  pl$with_string_cache({
    df_import = arrow_stream_to_df(str_ptr) |> unwrap()
  })

  # check imported/exported df's are identical
  expect_identical(df_import$to_list(), df_export$to_list())

  ## UNSAFE / Undefined behavior / will blow up eventually /  STUFF NOT TO DO
  # examples below of did segfault ~every 5-10th time, during development

  # 1: DO NOT EXPORT TO STREAM MORE THAN ONCE
  # new DataFrame can be exported to stream, but only the latest # BUT THIS SEGFAULTs sometimes
  # export_df_to_arrow_stream(df_export, str_ptr) |> unwrap()
  # export_df_to_arrow_stream(pl$DataFrame(mtcars), str_ptr) |> unwrap()
  # mtcars_import = arrow_stream_to_df(str_ptr) |> unwrap()

  # 2: DO NOT IMPORT FROM STREAM MORE THAN ONCE
  # reading from released(exhuasted) stream results in error most times
  # BUT THIS SEGFAULTs sometimes
  # ctx = arrow_stream_to_df(str_ptr)$err$contexts()
  # expect_equal(
  # ctx$PlainErrorMessage,
  # r"{InvalidArgumentError("The C stream was already released")}"
  # )

  # 3: DO NOT IMPORT/EXPORT ARROW STREAM ACROSS PROCESSES (use IPC for that, see <Expr>$map() docs)
  # background process willSEGFAULT HERE
  # str_ptr = new_arrow_stream()
  # rsess = callr::r_bg(func = \(str_ptr) {
  #   library(polars)
  #   pl$with_string_cache({
  #     df_export = pl$concat(lapply(1:3, \(i) pl$DataFrame(iris)))
  #   })
  #   polars:::export_df_to_arrow_stream(df_export, str_ptr)
  # },args = list(str_ptr=str_ptr))
  #
  # Sys.sleep(3)
  # df_import = arrow_stream_to_df(str_ptr)
  # print(df_import)
  # str_ptr = new_arrow_stream()
  # rsess$get_result()
})
