###### Custom script:
######
###### - get the Rd files, convert them to markdown in "docs/docs/reference" and
######   put them in "mkdocs.yaml"
###### - run the examples in the "Reference" files
library(yaml)
library(here)
library(pkgload)

# use latest version of polars
pkgload::load_all(quiet = TRUE)


# delete old .md files
if (dir.exists(here("docs/docs/reference"))) {
  unlink(here::here("docs/docs/reference"), recursive = TRUE, force = TRUE)
}
dir.create(here("docs/docs/reference"))


rd2md = function(src) {
  # Rd -> html
  rd = tools::parse_Rd(here(src))
  tmp_md = paste0(tempfile(), ".md")
  tmp_html = paste0(tempfile(), ".html")
  tools::Rd2HTML(rd, out = tmp_html)

  # superfluous header and footer
  tmp = readLines(tmp_html)
  tmp = tmp[(grep("</table>$", tmp)[1] + 1):length(tmp)]
  tmp = tmp[seq_len(which("</div>" == tmp) - 3)]
  
  # first column of Arguments should not be wrapped
  tmp = sub('vertical-align: top;', 'white-space: nowrap;>', tmp, fixed = TRUE)
  idx = grep("<td>", tmp)
  
  # examples: evaluate code blocks (assume examples are always last)
  idx = which(tmp == "<h3>Examples</h3>")
  if (length(idx) == 1) {
    ex = tmp[(idx + 1):length(tmp)]
    ex = gsub("<.*>", "", ex)
    ex = downlit::evaluate_and_highlight(ex)
    tmp = c(tmp[seq_len(idx)], "\n<pre class='r-example'><code>", ex, "</code></pre>")
  }
  
  # Usage cleanup
  tmp = paste(tmp, collapse = "\n")
  for (cl in c("DataFrame", "Series", "Expr", "GroupBy", "LazyFrame", "LazyGroupBy")) {
    x = sprintf("<h3>Usage</h3>\n\n<pre><code class='r-example'>%s_", cl)
    y = sprintf("<h3>Usage</h3>\n\n<pre><code class='r-example'>&lt%s&gt$", cl)
    tmp = sub(x, y, tmp)
    tmp = sub("language-R", "r-example", tmp)
  }
  tmp = strsplit(tmp, split = "\n")[[1]]

  # write to file
  fn = file.path(here("docs/docs/reference"), sub("Rd$", "md", basename(src)))
  writeLines(tmp, con = fn)
}


is_internal <- function(file) {
  y <- capture.output(tools::Rd2latex(file))
  z <- grepl("\\\\keyword\\{", y)
  if (!any(z)) return(FALSE)
  reg <- regmatches(y, gregexpr("\\{\\K[^{}]+(?=\\})", y, perl = TRUE))
  test <- vapply(seq_along(y), function(foo) {
    z[foo] && ("internal" %in% reg[[foo]] || "docs" %in% reg[[foo]])
  }, FUN.VALUE = logical(1L))
  any(test)
}


make_doc_hierarchy = function() {
  other = list.files("man", pattern = "\\.Rd")
  other = Filter(\(x) !is_internal(paste0("man/", x)), other)
  other = sub("Rd$", "md", other)
  out = list()
  # order determines order in navbar
  classes = c("pl", "Series", "DataFrame", "LazyFrame", "GroupBy",
              "LazyGroupBy", "arr", "ExprBin", "ExprDT", "ExprMeta", "ExprStr", "ExprStruct", "Expr")
  for (cl in classes) {
    files = grep(paste0("^", cl, "_"), other, value = TRUE)
    tmp = sprintf("%s: reference/%s", sub("\\.md", "", sub("[^_]*_", "", files)), files)
    cl_label = ifelse(cl == "pl", "Polars", cl)
    out = append(out, setNames(list(tmp), cl_label))
    other = setdiff(other, files)
  }
  # expr: nested
  nam = c(
    "arr" = "Array",
    "ExprBin" = "Binary",
    "ExprDT" = "DateTime",
    "ExprMeta" = "Meta",
    "ExprStr" = "String",
    "ExprStruct" = "Struct",
    "Expr" = "Other")
  tmp = lapply(names(nam), \(n) setNames(list(out[[n]]), nam[n]))
  out = out[!names(out) %in% names(nam)]
  out[["Expr"]] = tmp
  # other
  tmp = sprintf("%s: reference/%s", sub("\\.md$", "", other), other)
  out = append(out, setNames(list(tmp), "Other"))
  out
}


# Insert the "Reference" structure in the yaml (requires to overwrite the full mkdocs.yml)
convert_hierarchy_to_yml <- function() {
  hierarchy <- make_doc_hierarchy()

  new_yaml <- orig_yaml <- yaml.load_file(
    "docs/mkdocs.yml"
  )

  for (i in c("extra_css", "plugins")) {
    if (!is.null(orig_yaml[[i]]) && !is.list(length(orig_yaml[[i]]))) {
      new_yaml[[i]] <- as.list(new_yaml[[i]])
    }
  }

  reference_idx <- which(
    unlist(lapply(orig_yaml$nav, \(x) names(x) == "Reference"))
  )

  new_yaml$nav[[reference_idx]]$Reference <- hierarchy

  out = as.yaml(new_yaml, indent.mapping.sequence = TRUE)
  out = gsub("- '", "- ", out)
  out = gsub("\\.md'", "\\.md", out)

  cat(out, file = "docs/mkdocs.yml")
}


# Run all
message("Converting Rd files to markdown...\n")
rd_files <- list.files(here("man"), pattern = "\\.Rd")
for (i in rd_files) {
  if (is_internal(paste0("man/", i))) next
  rd2md(here(paste0("man/", i)))
}

message("Updating {.file docs/mkdocs.yaml}...\n")
convert_hierarchy_to_yml()