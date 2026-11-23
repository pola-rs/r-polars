# Normalize cache UUIDs while preserving shared-cache relationships.
normalize_cache_ids <- function(lines) {
  matches <- gregexpr(r"(CACHE\[id: [[:xdigit:]-]{36}\])", lines)
  ids <- unique(unlist(regmatches(lines, matches)))
  for (i in seq_along(ids)) {
    lines <- gsub(
      ids[[i]],
      sprintf("CACHE[id: <cache-%d>]", i),
      lines,
      fixed = TRUE
    )
  }
  lines
}
