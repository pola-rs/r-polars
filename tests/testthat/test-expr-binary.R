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

test_that("bin$reinterpret()", {
  skip_if_not_installed("blob")
  df <- pl$DataFrame(x = blob::as_blob(c(5L, 35L)))

  expect_equal(
    df$select(
      pl$col("x")$bin$reinterpret(dtype = pl$UInt8, endianness = "little")
    ),
    pl$DataFrame(x = c(5L, 35L))$cast(pl$UInt8)
  )
  expect_snapshot(
    df$select(
      pl$col("x")$bin$reinterpret(dtype = pl$UInt8, endianness = "foo")
    ),
    error = TRUE
  )
  expect_snapshot(
    df$select(pl$col("x")$bin$reinterpret(dtype = 1)),
    error = TRUE
  )
})

test_that("bin$get()", {
  df <- pl$DataFrame(x = c("\x01\x02\x03", "", "\x04\x05"))$cast(pl$Binary)

  # out of bounds
  expect_snapshot(
    df$select(pl$col("x")$bin$get(0)),
    error = TRUE
  )

  expect_equal(
    df$select(pl$col("x")$bin$get(0, null_on_oob = TRUE)),
    pl$DataFrame(x = c(1, NA, 4))$cast(pl$UInt8)
  )
  # negative index
  expect_equal(
    df$select(pl$col("x")$bin$get(-1, null_on_oob = TRUE)),
    pl$DataFrame(x = c(3, NA, 5))$cast(pl$UInt8)
  )
  # null index
  expect_equal(
    df$select(pl$col("x")$bin$get(NA_integer_, null_on_oob = TRUE)),
    pl$DataFrame(x = c(NA, NA, NA))$cast(pl$UInt8)
  )
  # expr index
  df <- pl$DataFrame(x = c("\x01\x02\x03", "", "\x04\x05"), index = c(2, 0, 0))$cast(x = pl$Binary)
  expect_equal(
    df$select(pl$col("x")$bin$get(pl$col("index"), null_on_oob = TRUE)),
    pl$DataFrame(x = c(3, NA, 4))$cast(pl$UInt8)
  )

  df <- pl$DataFrame(x = c("\x01\x02\x03"))$cast(x = pl$Binary)
  expect_equal(
    df$select(pl$col("x")$bin$get(pl$Series("idx", 1:3), null_on_oob = TRUE)),
    pl$DataFrame(x = c(2, 3, NA))$cast(pl$UInt8)
  )
})
