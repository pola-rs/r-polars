items <- c("hamburger", "nuts", "lollypop")
df <- pl$DataFrame(x = items)$cast(pl$Binary)

test_that("bin$contains", {
  test <- df$select(pl$col("x")$bin$contains(charToRaw("nuts")))
  expect_equal(test, pl$DataFrame(x = c(FALSE, TRUE, FALSE)))
})

test_that("bin$starts_with", {
  test <- df$select(pl$col("x")$bin$starts_with(charToRaw("ham")))
  expect_equal(test, pl$DataFrame(x = c(TRUE, FALSE, FALSE)))
})

test_that("bin$ends_with", {
  test <- df$select(pl$col("x")$bin$ends_with(charToRaw("pop")))
  expect_equal(test, pl$DataFrame(x = c(FALSE, FALSE, TRUE)))
})

test_that("bin$encode and bin$decode", {
  test_encode <- df$select(
    hex = pl$col("x")$bin$encode("hex"),
    base64 = pl$col("x")$bin$encode("base64")
  )

  expected_hex_encoded <- c("68616d627572676572", "6e757473", "6c6f6c6c79706f70")
  expected_base64_encoded <- c("aGFtYnVyZ2Vy", "bnV0cw==", "bG9sbHlwb3A=")

  expect_equal(
    test_encode,
    pl$DataFrame(hex = expected_hex_encoded, base64 = expected_base64_encoded)
  )

  expect_snapshot(
    df$select(hex = pl$col("x")$bin$encode("foo")),
    error = TRUE
  )

  encoded_hex <- pl$DataFrame(x = expected_hex_encoded)$cast(pl$Binary)
  encoded_base64 <- pl$DataFrame(x = expected_base64_encoded)$cast(pl$Binary)

  test_hex_decode <- encoded_hex$with_columns(
    pl$col("x")$bin$decode("hex")$cast(pl$String)
  )

  test_base64_decode <- encoded_base64$with_columns(
    pl$col("x")$bin$decode("base64")$cast(pl$String)
  )

  expected_decoded <- pl$DataFrame(x = items)

  expect_equal(test_hex_decode, expected_decoded)
  expect_equal(test_base64_decode, expected_decoded)
  expect_snapshot(
    df$select(hex = pl$col("x")$bin$decode("foo")),
    error = TRUE
  )
})

test_that("bin$size()", {
  dat <- pl$DataFrame(x = "a")$cast(pl$Binary)
  expect_equal(
    dat$select(pl$col("x")$bin$size()),
    pl$DataFrame(x = 1)$cast(pl$UInt32)
  )
  expect_snapshot(
    dat$select(pl$col("x")$bin$size("foo")),
    error = TRUE
  )
})
