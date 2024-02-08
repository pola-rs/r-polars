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
  "Expr", "pl"
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
  } else if (which_class == "pl") {
    new = gsub(
      "<code class='language-R'>pl_",
      "<code class='language-R'>pl$",
      orig
    )
  } else if (which_class %in% c(
    "ExprArr", "ExprBin", "ExprCat", "ExprDT", "ExprList",
    "ExprMeta", "ExprName", "ExprStr", "ExprStruct"
  )) {
    subns = tolower(gsub("Expr", "", which_class))

    new = gsub(
      paste0("<code class='language-R'>", which_class, "_"),
      paste0("<code class='language-R'>&lt;Expr&gt;$", subns, "$"),
      orig
    )
  } else {
    new = gsub(
      paste0("<code class='language-R'>", which_class, "_"),
      paste0("<code class='language-R'>&lt;", which_class, "&gt;$"),
      orig
    )
  }

  # fix escaping of left-angle brackets (not needed for right-angle brackets)
  new = gsub("\\\\&lt;", "&lt;", new)

  writeLines(new, i)
}
