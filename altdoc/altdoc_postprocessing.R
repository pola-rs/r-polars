### To be run after altdoc::render_docs()

list_man_html <- list.files("docs/man", pattern = "\\.html$", full.names = TRUE, recursive = TRUE)

### Make the "Usage" section prettier (if there is one):
### DataFrame_describe(...)   ->   <DataFrame>$describe()

classes <- c(
  "series",
  "dataframe",
  "lazyframe",
  "groupby",
  "lazygroupby",
  "sql_context",
  # "S3",
  "expr",
  "pl",
  "datatype_expr"
)

to_modify <- grep(
  paste0("/", paste(classes, collapse = "|")),
  list_man_html,
  value = TRUE
)

for (i in to_modify) {
  which_class <- if (grepl("man/expr__", i, fixed = TRUE)) {
    "expr"
  } else if (grepl("man/expr_arr_", i, fixed = TRUE)) {
    "expr_arr"
  } else if (grepl("man/expr_bin_", i, fixed = TRUE)) {
    "expr_bin"
  } else if (grepl("man/expr_cat_", i, fixed = TRUE)) {
    "expr_cat"
  } else if (grepl("man/expr_dt_", i, fixed = TRUE)) {
    "expr_dt"
  } else if (grepl("man/expr_list_", i, fixed = TRUE)) {
    "expr_list"
  } else if (grepl("man/expr_meta_", i, fixed = TRUE)) {
    "expr_meta"
  } else if (grepl("man/expr_name_", i, fixed = TRUE)) {
    "expr_name"
  } else if (grepl("man/expr_str_", i, fixed = TRUE)) {
    "expr_str"
  } else if (grepl("man/expr_struct_", i, fixed = TRUE)) {
    "expr_struct"
  } else if (grepl("man/expr__", i, fixed = TRUE)) {
    "expr"
  } else if (grepl("man/dataframe__", i, fixed = TRUE)) {
    "dataframe"
  } else if (grepl("man/lazyframe__", i, fixed = TRUE)) {
    "lazyframe"
  } else if (grepl("man/groupby__", i, fixed = TRUE)) {
    "groupby"
  } else if (grepl("man/lazygroupby__", i, fixed = TRUE)) {
    "lazygroupby"
  } else if (grepl("man/series__", i, fixed = TRUE)) {
    "series"
  } else if (grepl("man/pl__", i, fixed = TRUE)) {
    "pl"
  } else if (grepl("man/sql_context", i, fixed = TRUE)) {
    "sql_context"
  } else if (grepl("man/datatype_expr", i, fixed = TRUE)) {
    "datatype_expr"
  } else {
    "foobar"
  }

  orig <- readLines(i, warn = FALSE)

  if (!any(grepl("<h2 id=\"usage\">Usage</h2>", orig))) {
    next
  }

  # prefix with pl$ for read/scan
  if (which_class == "pl") {
    new <- gsub(
      "<code class='language-R'>pl__",
      "<code class='language-R'>pl$",
      orig,
      fixed = TRUE
    )
  } else if (which_class == "expr") {
    new <- gsub(
      "<code class='language-R'>expr__",
      "<code class='language-R'>&lt;Expr&gt;$",
      orig,
      fixed = TRUE
    )
  } else if (
    which_class %in%
      c(
        "expr_arr",
        "expr_bin",
        "expr_cat",
        "expr_dt",
        "expr_list",
        "expr_meta",
        "expr_name",
        "expr_str",
        "expr_struct"
      )
  ) {
    subns <- gsub("expr_", "", which_class, fixed = TRUE)

    new <- gsub(
      paste0("<code class='language-R'>", which_class, "_"),
      paste0("<code class='language-R'>&lt;Expr&gt;$", subns, "$"),
      orig
    )
  } else if (
    which_class %in%
      c("dataframe", "lazyframe", "groupby", "lazygroupby", "sql_context", "datatype_expr")
  ) {
    replacement <- switch(
      which_class,
      dataframe = "DataFrame",
      lazyframe = "LazyFrame",
      groupby = "GroupBy",
      lazygroupby = "LazyGroupBy",
      sql_context = "SQLContext",
      datatype_expr = "DataTypeExpr",
      "unreachable"
    )
    new <- gsub(
      paste0("<code class='language-R'>", which_class, "__"),
      paste0(
        "<code class='language-R'>&lt;",
        replacement,
        "&gt;$"
      ),
      orig
    )
  } else {
    new <- gsub(
      paste0("<code class='language-R'>", which_class, "_"),
      paste0("<code class='language-R'>&lt;", which_class, "&gt;$"),
      orig
    )
  }

  # fix escaping of left-angle brackets (not needed for right-angle brackets)
  new <- gsub("\\\\&lt;", "&lt;", new)

  writeLines(new, i)
}
