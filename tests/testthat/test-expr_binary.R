items = c("hamburger", "nuts", "lollypop")
df = pl$select(pl$lit(items)
$cast(pl$Binary)
$alias("a"))

test_that("bin$contains", {
  test = df$select(
    pl$col("a")$bin$contains(charToRaw("nuts"))$alias("lit")
  )

  expected = list(lit = c(FALSE, TRUE, FALSE))

  expect_identical(test$to_list(), expected)
})

test_that("bin$starts_with", {
  test = df$select(
    pl$col("a")$bin$starts_with(charToRaw("ham"))$alias("ham")
  )

  expected = list(ham = c(TRUE, FALSE, FALSE))

  expect_identical(test$to_list(), expected)
})

test_that("bin$ends_with", {
  test = df$select(
    pl$col("a")$bin$ends_with(charToRaw("pop"))$alias("pop")
  )

  expected = list(pop = c(FALSE, FALSE, TRUE))

  expect_identical(test$to_list(), expected)
})

test_that("bin$encode and bin$decode", {
  test_encode = df$with_columns(
    pl$col("a")$bin$encode("hex")$alias("hex"),
    pl$col("a")$bin$encode("base64")$alias("base64")
  )$select(
    c("hex", "base64")
  )$to_list()

  expected_hex_encoded = c("68616d627572676572", "6e757473", "6c6f6c6c79706f70")
  expected_base64_encoded = c("aGFtYnVyZ2Vy", "bnV0cw==", "bG9sbHlwb3A=")

  expect_identical(test_encode$hex, expected_hex_encoded)
  expect_identical(test_encode$base64, expected_base64_encoded)

  encoded_hex = pl$select(pl$lit(expected_hex_encoded)
  $cast(pl$Binary)
  $alias("hex"))

  encoded_base64 = pl$select(pl$lit(expected_base64_encoded)
  $cast(pl$Binary)
  $alias("base64"))

  test_hex_decode = encoded_hex$with_columns(
    pl$col("hex")$bin$decode("hex")$alias("hex_decoded")
  )$select(
    c("hex_decoded")
  )$select(
    pl$lit(
      pl$col("hex_decoded")$cast(pl$Utf8)
    )
  )$to_list()

  test_base64_decode = encoded_base64$with_columns(
    pl$col("base64")$bin$decode("base64")$alias("base64_decoded")
  )$select(
    c("base64_decoded")
  )$select(
    pl$lit(
      pl$col("base64_decoded")$cast(pl$Utf8)
    )
  )$to_list()

  expected_decoded = items

  expect_identical(test_hex_decode$hex_decoded, expected_decoded)
  expect_identical(test_base64_decode$base64_decoded, expected_decoded)
})


test_that("Raw to lit and series", {
  # craete a rpolars_raw_list
  raw_list = pl$raw_list(raw(1), raw(3), charToRaw("alice"), NULL)
  bin_series = pl$Series(raw_list)

  # round trip conversion
  expect_identical(bin_series$to_r(), raw_list)

  # non isomorphic conversions of plain Raw, via Series and lit
  expect_identical(pl$Series(raw())$to_r(), pl$raw_list(raw())) # plain raw becomes, rpolars_raw_list
  expect_identical(pl$lit(raw())$to_r(), pl$raw_list(raw())) # plain lit becomes, rpolars_raw_list

  # raw -> lit -> s -> R == raw -> s -> R
  expect_identical(pl$lit(raw())$to_series()$to_r(), pl$Series(raw())$to_r())

  # raw -> s -> lit -> R  == raw -> lit -> R
  expect_identical(pl$lit(pl$Series(raw()))$to_r(), pl$lit(raw())$to_r())

  # empty raw_list
  expect_identical(pl$Series(pl$raw_list())$to_r(), raw_list[c()])

  # subset
  expect_identical(pl$raw_list(raw(1), raw(2), raw(3))[2:4], pl$raw_list(raw(2), raw(3), NULL))

  # convert
  expect_identical(as.list(raw_list), unclass(raw_list))

  # test non-raw invalid input
  expect_identical(
    pl$raw_list(42) |> get_err_ctx("Plain"),
    "some elements where not raw or NULL"
  )
})
