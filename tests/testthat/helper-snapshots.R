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

# S7 1.0.0 changed the format of class printing and of the errors raised by S7.
# Use this as the `variant` of snapshots whose output depends on the S7 version.
# TODO: Remove this once S7 >= 1.0.0 is required.
s7_snapshot_variant <- function() {
  if (utils::packageVersion("S7") > "0.2.2") "S7-1.0" else "S7-0.2"
}
