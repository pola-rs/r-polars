### To be run after altdoc::render_docs()

list_man_md = list.files("docs/man", pattern = "\\.md$", full.names = TRUE)

### Make the "Usage" section prettier (if there is one):
### DataFrame_describe(...)   ->   <DataFrame>$describe()

classes = c(
  "Series", "DataFrame", "LazyFrame", "GroupBy",
  "LazyGroupBy", "IO", "RField", "RThreadHandle", "SQLContext", "S3"
)

to_modify = grep(
  paste0("/", paste(classes, collapse = "|")),
  list_man_md,
  value = TRUE
)

for (i in to_modify) {
  which_class = gsub("_.*$", "", basename(i))
  orig = readLines(i, warn = FALSE)

  if (!any(grepl("## Usage", orig))) {
    next
  }
  new = gsub(
    paste0("<code class='language-R'>", which_class, "_"),
    paste0("<code class='language-R'><", which_class, ">$"),
    orig
  )
  writeLines(new, i)
}


### Add a "Usage" section if there is none (which is the case for all Expr)

Expr_classes = c("pl", "ExprList", "ExprBin", "ExprCat", "ExprDT", "ExprMeta",
                 "ExprName", "ExprStr", "ExprStruct", "Expr")

to_modify2 = grep(
  paste0("/", paste(Expr_classes, collapse = "|")),
  list_man_md,
  value = TRUE
)

for (i in to_modify2) {
  which_class = gsub("_.*$", "", basename(i))
  orig = readLines(i, warn = FALSE)

  if (!any(grepl("## Usage", orig))) {
    next
  }
  new = gsub(
    paste0("<code class='language-R'>", which_class, "_"),
    paste0("<code class='language-R'><", which_class, ">$"),
    orig
  )
  writeLines(new, i)
}
