## STRING/CHARACTER IPLEMENTS R-POLARS error_trait.R

#' @exportS3Method
when_calling.character = function(err, call) {
  paste(err, "When calling:", call_to_string(call))
}

#' @exportS3Method
where_in.character = function(err, context) {
  paste(context, err)
}

#' @exportS3Method
to_condition.character = function(err) {
  if (!is_string(err)) {
    stop(paste("Internal error: an error msg was not of length 1, but was:", str_string(err)))
  }
  errorCondition(err)
}

#' @exportS3Method
plain.character = function(err, msg) {
  NextMethod("plain", err)
}

#' @exportS3Method
upgrade_err.character = function(err) {
  .pr$Err$new()$plain(err)
}
