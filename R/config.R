parse_env_auto_structify <- function() {
  value <- Sys.getenv("POLARS_AUTO_STRUCTIFY", "0")
  switch(
    value,
    "0" = FALSE,
    "1" = TRUE,
    abort(sprintf(
      "Environment variable `POLARS_AUTO_STRUCTIFY` must be one of ('0', '1'), got '%s'",
      value
    ))
  )
}
