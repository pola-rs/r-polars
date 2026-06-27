wrap <- function(x, ...) {
  call <- caller_env()
  try_fetch(
    x,
    error = function(cnd) {
      # Drain pending warnings so they don't leak to the next successful operation.
      polars_drain_warnings()
      err_call <- error_call(call)[[1]]
      msg_body <- if (is.call(err_call)) {
        paste0("Evaluation failed in `$", err_call[[length(err_call)]], "()`.")
      } else {
        "Evaluation failed."
      }
      abort(
        msg_body,
        call = call,
        parent = cnd
      )
    }
  )

  warns <- polars_drain_warnings()
  if (!is.null(warns)) {
    mapply(
      function(msg, cat) {
        warn(msg, class = c(cat, "polars_warning"))
      },
      warns$message,
      warns$category,
      SIMPLIFY = FALSE
    )
  }

  UseMethod("wrap")
}

#' @export
wrap.default <- function(x, ...) {
  x
}
