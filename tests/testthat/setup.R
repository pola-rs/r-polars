# Ensure running snapshot tests on GitHub Actions CI
if (identical(Sys.getenv("GITHUB_ACTIONS"), "true")) {
  withr::local_envvar(
    list(NOT_CRAN = "true"),
    .local_envir = teardown_env()
  )
}

# Set up for mirai tests
if (rlang::is_installed("mirai")) {
  mirai::daemons(0)
  mirai::daemons(1)
  withr::defer(mirai::daemons(0), teardown_env())

  # Ensure load the package even if not installed
  mirai::everywhere({
    if (!rlang::is_installed("neopolars")) pkgload::load_all()
  })
}
