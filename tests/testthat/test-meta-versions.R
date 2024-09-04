test_that("pl$show_versions() show dependent package versions", {
  with_mocked_bindings(
    {
      expect_snapshot(pl$show_versions())
    },
    .get_dependency_version = function(...) "0.0.0",
    .platform = "mocked platform",
    .r_version = "mocked R version"
  )
})
