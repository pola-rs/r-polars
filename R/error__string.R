## STRING/CHARACTER IPLEMENTS R-POLARS error_trait.R
when_calling.character = function(err, call) {
  paste(err, "When calling:", call_to_string(call))
}
where_in.character = function(err, context) {
  paste(context, err)
}
to_condition.character = function(err) {
  if (!is_string(err)) {
    stop(paste("Internal error: an error msg was not of length 1, but was:", str_string(err)))
  }
  errorCondition(err)
}
plain.character = function(err, msg) {
  NextMethod("plain", err)
}
upgrade_err.character = function(err) {
  .pr$Err$new()$plain(err)
}
