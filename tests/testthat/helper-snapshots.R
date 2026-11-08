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

# Since R 4.7 (r90805), `str()` no longer prepends a space to its output,
# and S7 <= 0.2.2 relied on it when printing properties
# (`@ prop: logi TRUE` became `@ prop:logi TRUE`).
# Restore the space so that snapshots match on both old and new R versions.
# TODO: Remove this once a fixed S7 version is released and required.
normalize_s7_str_spacing <- function(lines) {
  gsub(":logi ", ": logi ", lines, fixed = TRUE)
}
