### To be run after altdoc::render_docs()

list_man_html = list.files("docs/man",
  pattern = "\\.html$", full.names = TRUE,
  recursive = TRUE
)

### Make the "Usage" section prettier (if there is one):
### DataFrame_describe(...)   ->   <DataFrame>$describe()

classes = c(
  "Series", "DataFrame", "LazyFrame", "GroupBy",
  "LazyGroupBy", "IO", "RField", "RThreadHandle", "SQLContext", "S3",
  "Expr"
)

to_modify = grep(
  paste0("/", paste(classes, collapse = "|")),
  list_man_html,
  value = TRUE
)

for (i in to_modify) {
  which_class = gsub("docs/man/([^_]+).*$", "\\1", i, perl = TRUE)
  orig = readLines(i, warn = FALSE)

  if (!any(grepl("<h2 id=\"usage\">Usage</h2>", orig))) {
    next
  }

  # IO functions are DataFrame or LazyFrame methods
  if (which_class == "IO") {
    if (any(grepl("<code class='language-R'>LazyFrame_sink", orig))) {
      which_class <<- "LazyFrame"
    } else if (any(grepl("<code class='language-R'>DataFrame_write", orig))) {
      which_class <<- "DataFrame"
    }
  }

  # prefix with pl$ for read/scan
  if (which_class == "IO") {
    which_input = if (any(grepl("<code class='language-R'>read_", orig))) {
      "read"
    } else if (any(grepl("<code class='language-R'>scan_", orig))) {
      "scan"
    } else {
      ""
    }
    new = gsub(
      paste0("<code class='language-R'>", which_input, "_"),
      paste0("<code class='language-R'>pl$", which_input, "_"),
      orig
    )
  } else {
    new = gsub(
      paste0("<code class='language-R'>", which_class, "_"),
      paste0("<code class='language-R'>&lt;", which_class, "&gt;$"),
      orig
    )
  }

  writeLines(new, i)
}


### Add a "Usage" section if there is none (which is the case for all Expr)

# Expr_classes = c("pl", "ExprList", "ExprBin", "ExprCat", "ExprDT", "ExprMeta",
#                  "ExprName", "ExprStr", "ExprStruct")
#
# to_modify2 = grep(
#   paste0("/", paste(Expr_classes, collapse = "|")),
#   list_man_html,
#   value = TRUE
# )
#
# for (i in to_modify2) {
#   which_class = gsub("docs/man/(.*)_.*$", "\\1", i)
#   orig = readLines(i, warn = FALSE)
#
#   if (any(grepl("<h2 id=\"usage\">Usage</h2>", orig))) {
#     next
#   }
#
#   before_usage = grep("id=\"description\">", orig) + 1
#   after_usage = grep("id=\"description\">", orig) + 2
#   if (length(before_usage) == 0) {
#     next
#   }
#
#   usage = if (grep("^Expr", which_class)) {
#     paste0("&lt;Expr&gt;$", tolower(gsub("^Expr", "", which_class)))
#   } else if (which_class == "pl") {
#     "pl"
#   }
#
#   usage = paste0(usage, "$")
#   new = c(
#     orig[1:before_usage],
#     "<h2 id=\"usage\">Usage</h2>",
#     paste0("<pre><code class='language-R'>", usage),
#     "</code></pre>",
#     orig[after_usage:length(orig)]
#   )
#   writeLines(new, i)
# }
