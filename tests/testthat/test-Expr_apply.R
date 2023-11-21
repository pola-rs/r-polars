test_that("Expr_map_elements works", {
  df = pl$DataFrame(list(
    a = c(1:3, 5L, NA_integer_, 50, 100),
    b = c("a", "b", "c", "c", "d", NA_character_, NA_character_)
  ))

  df$group_by("b")$agg(pl$col("a")$sum())
  # df$group_by("b")$agg(pl$col("a")$map_elements(function(s) {print("hej");(s*2)}))
  rdf = df$group_by("b", maintain_order = TRUE)$agg(
    pl$col("a")$map_elements(function(s) {
      v = (s * 2)$to_r()
      which.max(v)
    })$alias("a_which_max"),
    pl$col("a")$map_elements(function(s) s$len())$alias("a_count")
  )

  expect_equal(
    rdf$to_data_frame(),
    data.frame(
      b = c("a", "b", "c", "d", NA_character_),
      a_which_max = c(1L, 1L, 2L, NA_integer_, 2L),
      a_count = c(1, 1, 2, 1, 2)
    )
  )


  df = pl$DataFrame(list(
    a = c("a", "a", "a", "b", "b", "b", "c", "c", "c", NA_character_, NA_character_),
    b = c("a", "b", NA_character_, "b", "c", NA_character_, "c", "a", NA_character_, NA_character_, NA_character_),
    val1 = 1:11,
    val2 = (1:11) * 2.0
  ))

  # in groupby context
  edf = df$to_data_frame()[1:10, c("a", "b")]
  edf$count = c(rep(1, 9), 2)
  expect_identical(
    df$group_by("a", "b", maintain_order = TRUE)$agg(
      pl$col("val1")$map_elements(function(s) {
        s$len()
      })$alias("count")
    )$to_data_frame(),
    edf
  )


  # in select context
  expect_identical(
    df$select(
      pl$col("val1")$map_elements(function(x) {
        x + 5L
      })$alias("val1_add5"),
      pl$col("b")$map_elements(function(x) {
        toupper(x)
      })$alias("b_toupper")
    )$to_data_frame(),
    data.frame(
      val1_add5 = df$get_column("val1")$to_r() + 5L,
      b_toupper = toupper(df$get_column("b")$to_r())
    )
  )


  # iwith columns context
  expect_identical(
    df$with_columns(
      pl$col("val1")$map_elements(function(x) {
        x + 5L
      })$alias("val1_add5"),
      pl$col("b")$map_elements(function(x) {
        toupper(x)
      })$alias("b_toupper")
    )$to_data_frame(),
    cbind(
      df,
      data.frame(
        val1_add5 = df$get_column("val1")$to_r() + 5L,
        b_toupper = toupper(df$get_column("b")$to_r())
      )
    )
  )
})
