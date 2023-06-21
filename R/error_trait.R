# ANY NEW ERROR MUST IMPLEMENT THESE S3 METHODS, these are the "trait" of a polars error
# ALSO MUST IMPLEMENT BASE THESE METHODS: print

#' Internal generic method to add call to error
#' @param err any type which impl as.character
#' @param call calling context
#' @details
#' Additional details...
#'
#' @keywords internal
#' @return err as string
#' @examples
#' #
when_calling = function(err, call) {
  if (polars_optenv$do_not_repeat_call || is.null(call)) {
    err
  } else {
    UseMethod("when_calling", err)
  }
}
when_calling.default = function(err, call) {
  stop("internal error: an error-type was not fully implemented")
}
# support function to convert a call to a string
call_to_string = function(call) {
  paste(
    "\n",
    paste(capture.output(print(call)), collapse = "\n")
  )
}


#' Internal generic method to point to which public method the user got wrong
#' @param err any type which impl as.character
#' @param call calling context
#' @keywords internal
#' @return err as string
#' @examples
#' #
where_in = function(err, context) {
  if (is.null(context)) {
    return(err)
  }
  if (!is_string(context)) {
    stop(
      paste(
        "internal error: where_in context must be a string or NULL it was: ",
        str_string(context)
      )
    )
  }
  UseMethod("where_in", err)
}
where_in.default = function(err, context) {
  stop("internal error: an error-type was not fully implemented")
}

#' Internal generic method to convert an error_type to condition.
#' @param err any type which impl as.character
#' @param call calling context
#' @keywords internal
#' @details
#' this method is needed to preserve state of err without upcasting to a string message
#' an implementation will describe how to store the error in the condition
#' @return condition
to_condition = function(err) {
  UseMethod("to_condition", err)
}
to_condition.default = function(err) {
  errorCondition(
    paste(capture.output(print(err)), collapse = "\n"),
    class = c("default_error"),
    value = err,
    call = NULL
  )
}



#' Internal generic method to add plain text to error message
#' @param err some error type object
#' @param msg string to add
#' @keywords internal
#' @return condition
plain = function(err, msg) {
  if (is.null(msg)) {
    return(err)
  }
  UseMethod("plain", err)
}
plain.default = function(err, msg) {
  paste0(msg, ": ", err)
}
