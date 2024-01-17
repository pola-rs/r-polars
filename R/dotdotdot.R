#' list2 - one day like rlang
#' list2 placeholder for future rust-impl
#' @noRd
#' @return An R list
#' @details rlang has this wonderful list2 implemented in c/c++, that is agnostic about trailing
#' commas in ... params. One day r-polars will have a list2-impl written in rust, which also allows
#' trailing commas.
#' https://github.com/extendr/extendr/pull/578 see progress here.
list2 = function(..., .context = NULL, .call = sys.call(1L)) {
  list(...) |>
    result() |>
    map_err(\(err) {
      if (identical(err$contexts()$PlainErrorMessage, "argument is missing, with no default")) {
        err$plain("trailing argument commas are not (yet) supported with polars")
      } else {
        err
      }
    }) |>
    unwrap(context = .context, call = .call)
}




#' Internal unpack list
#' @noRd
#'
#' @param ... args to unwrap
#' @param .context a context passed to unwrap
#' @param .call  a call passed to unwrap
#' @param skip_classes char vec, do not unpack list inherits skip_classes.
#'
#' @details py-polars syntax only allows e.g. `df.select([expr1, expr2,])` and not
#' `df.select(expr1, expr2,)`. r-polars also allows user to directly write
#' `df$select(expr1, expr2)` or `df$select(list(expr1,expr2))`. Unpack list
#' checks whether first and only arg is a list and unpacks it, to bridge the
#' allowed patterns of passing expr to methods with ... param input.
#' Will throw an error if trailing comma.
#' @return a list
#' @examples
#' f = \(...) unpack_list(list(...))
#' identical(f(list(1L, 2L, 3L)), f(1L, 2L, 3L)) # is TRUE
#' identical(f(list(1L, 2L), 3L), f(1L, 2L, 3L)) # is FALSE
unpack_list = function(..., .context = NULL, .call = sys.call(1L), skip_classes = NULL) {
  l = list2(..., .context = .context, .call = .call)
  if (
    length(l) == 1L &&
      is.list(l[[1L]]) &&
      !(!is.null(skip_classes) && inherits(l[[1L]], skip_classes))
  ) {
    l[[1L]]
  } else {
    l
  }
}


#' Convert dot-dot-dot to bool expression
#' @noRd
#' @return Result, a list has `ok` (RPolarsExpr class) and `err` (RPolarsErr class)
#' @examples
#' unpack_bool_expr_result(pl$lit(TRUE), pl$lit(FALSE))
unpack_bool_expr_result = function(...) {
  unpack_list(...) |>
    result() |>
    and_then(\(l) {
      if (!is.null(names(l))) {
        Err_plain(
          "Detected a named input.",
          "This usually means that you've used `=` instead of `==`.",
          "Some names seen:", head(names(l))
        )
      } else {
        l |>
          Reduce(`&`, x = _) |>
          result() |>
          suppressWarnings()
      }
    })
}
