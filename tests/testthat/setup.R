# Ensure running snapshot tests on GitHub Actions CI
if (identical(Sys.getenv("GITHUB_ACTIONS"), "true")) {
  withr::local_envvar(
    list(NOT_CRAN = "true"),
    .local_envir = teardown_env()
  )
}
