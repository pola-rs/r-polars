test_that("pl$show_versions() show dependent package versions", {
  with_mocked_bindings(
    {
      expect_snapshot(pl$show_versions())
    },
    .get_dependency_version = function(...) "0.0.0",
    .platform = "mocked platform",
    .r_version = "mocked R version",
    .self_version = "0.0.0"
  )
  with_mocked_bindings(
    {
      expect_snapshot(pl$show_versions())
    },
    .dependencies = c("notexistingPackage1", "notexistingPackage2"),
    .platform = "mocked platform",
    .r_version = "mocked R version",
    .self_version = "0.0.0"
  )
})
