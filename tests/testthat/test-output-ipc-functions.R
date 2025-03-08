# TODO-REWRITE: needs $write_ipc()
# patrick::with_parameters_test_that("write and read Apache Arrow file",
#   {
#     tmpf <- tempfile(fileext = ".arrow")
#     on.exit(unlink(tmpf))

#     df <- pl$DataFrame(
#       int = 1:4,
#       chr = letters[1:4],
#       fct = factor(letters[1:4])
#     )
#     df$write_ipc(tmpf, compression = compression)

#     expect_identical(
#       as.data.frame(df),
#       as.data.frame(pl$read_ipc(tmpf, memory_map = FALSE))
#     )

#     expect_true(
#       df$equals(pl$read_ipc(tmpf, memory_map = FALSE))
#     )
#   },
#   compression = list(NULL, "uncompressed", "lz4", "zstd"),
#   .test_name = compression
# )

# TODO-REWRITE: needs $write_ipc()
# test_that("write_ipc returns the input data", {
#   dat <- as_polars_df(mtcars)
#   tmpf <- tempfile(fileext = ".arrow")
#   x <- dat$write_ipc(tmpf)
#   expect_identical(x$to_list(), dat$to_list())
# })
