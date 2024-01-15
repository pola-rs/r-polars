### To be run after altdoc::render_docs()
###
### Make the "Usage" section prettier (if there is one):
### DataFrame_describe(...)   ->   <DataFrame>$describe()

list_man_html = list.files("docs/man",
  pattern = "\\.html$", full.names = TRUE,
  recursive = TRUE
)

patterns_replacements = rbind(
  c("DataFrame_", "<DataFrame>$"),
  c("DynamicGroupBy_", "<DynamicGroupBy>$"),
  c("Expr_", "<Expr>$"),
  c("ExprBin_", "<Expr>$bin$"),
  c("ExprCat_", "<Expr>$cat$"),
  c("ExprDT_", "<Expr>$dt$"),
  c("ExprList_", "<Expr>$list$"),
  c("ExprMeta_", "<Expr>$meta$"),
  c("ExprName_", "<Expr>$name$"),
  c("ExprStr_", "<Expr>$str$"),
  c("ExprStruct_", "<Expr>$struct$"),
  c("GroupBy_", "<GroupBy>$"),
  # file names are "IO_read_", function names are "pl_read_"
  c("(IO|pl)_read_", "pl$read_"),
  # file names are "IO_scan_", function names are "pl_scan_"
  c("(IO|pl)_scan_", "pl$scan_"),
  # file names are "IO_sink_", function names are "LazyFrame_sink_"
  c("(IO|LazyFrame)_sink_", "<LazyFrame>$sink_"),
  # file names are "IO_write_", function names are "DataFrame_write_"
  c("(IO|DataFrame)_write_", "<DataFrame>$write_"),
  c("LazyFrame_", "<LazyFrame>$"),
  c("LazyGroupBy_", "<LazyGroupBy>$"),
  c("pl_", "pl$"),
  # Category "DataType" in the sidebar, but called with "pl$"
  c("DataType_", "pl$"),
  c("RField_", "<RField>$"),
  c("RThreadHandle_", "<RThreadHandle>$"),
  c("Series_", "<Series>$"),
  c("SQLContext_", "<SQLContext>$")
) |> as.data.frame()

colnames(patterns_replacements) = c("pattern", "replacement")



replace_in_usage = function(txt, which_class, replacement) {
  usage_section = grep("<h2 id=\"usage\">Usage</h2>", txt)
  if (length(usage_section) == 1) {
      before_usage_idx = 1:usage_section
      usage = txt[-before_usage_idx]
      after_usage_idx = grep("</h2>", usage)[1]
      usage = usage[1:(after_usage_idx - 1)]
      new_usage = gsub(which_class, replacement, usage)
      c(
        txt[before_usage_idx],
        new_usage,
        txt[(length(before_usage_idx) + length(usage) + after_usage_idx):length(txt)]
      )
  } else {
    txt
  }
}



for (i in list_man_html) {
  which_class = paste0(gsub("docs/man/([^_]+).*$", "\\1", i, perl = TRUE), "_")
  orig = readLines(i, warn = FALSE)

  if (!any(grepl("<h2 id=\"usage\">Usage</h2>", orig))) {
    next
  }

  replacement = patterns_replacements[
    patterns_replacements$pattern == which_class,
    "replacement"
  ] |>
    gsub("<", "&lt;", x = _) |>
    gsub(">", "&gt;", x = _)

  if (length(replacement) == 1) {
    new = replace_in_usage(orig, which_class, replacement)
  }

  # fix escaping of angle brackets
  new = gsub("\\\\&lt;", "&lt;", new)
  new = gsub("\\\\&gt;", "&gt;", new)

  writeLines(new, i)
}
