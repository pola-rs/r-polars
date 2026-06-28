# Override the standalone lifecycle's internal warn function to add polars-specific
# condition classes. `lifecycle_warning_deprecated` is listed first so that lifecycle
# tooling (e.g. `expect_deprecated()`) continues to match on that class, while
# `polars_deprecation_warning` and `polars_warning` allow users to catch R-side
# deprecations with the same handlers used for Rust-side warnings.
# jarl-ignore duplicated_function_definition: Intended to override the standalone lifecycle's internal warn function.
.rlang_lifecycle_deprecate_warn0 <- function(
  msg,
  id = msg,
  trace = NULL,
  always = FALSE,
  call = rlang::caller_env()
) {
  freq <- if (always) "always" else "regularly"
  rlang::warn(
    msg,
    class = c(
      "lifecycle_warning_deprecated",
      "polars_deprecation_warning",
      "polars_warning"
    ),
    .frequency = freq,
    .frequency_id = id
  )
}
