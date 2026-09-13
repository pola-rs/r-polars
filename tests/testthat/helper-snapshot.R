normalize_expression_error_snapshot <- function(lines) {
  lines <- sub("\\r$", "", lines)
  lines <- gsub("\t", "  ", lines, fixed = TRUE)
  lines[!grepl("^[[:blank:]]*$", lines)]
}
