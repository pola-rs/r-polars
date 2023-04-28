###### Custom script:
######
###### - get the Rd files, convert them to markdown in "docs/docs/reference" and
######   put them in "mkdocs.yaml"
###### - run the examples in the "Reference" files
library(yaml)

pkgload::load_all(quiet = TRUE)

if (fs::dir_exists(here::here("docs/docs/reference"))) {
  fs::dir_delete(here::here("docs/docs/reference"))
}
fs::dir_create(here::here("docs/docs/reference"))


rd2md = function(src) {
  # file names
  fn = src
  tar = file.path("docs/docs/reference", sub("Rd$", "md", basename(fn)))

  # read
  rd = capture.output(tools::Rd2txt(fn, options = list(
    useFancyQuotes = FALSE,
    showURLS = TRUE,
    underline_titles = FALSE,
    code_quote = TRUE)))

  # headers
  rd[1] = paste("#", rd[1])
  for (v in c("Description", "Arguments", "Value", "Details", "References", "Usage", "Format", "Examples")) {
    rd = sub(paste0("^", v), paste0("## ", v), rd)
  }
  
  # arguments as code (ugly hack, but seems to work OK)
  rd = gsub("(^\\s*)(\\w+):", "\\1`\\2`:", rd)

  # examples
  idx = grep("^## Examples:", rd)
  ex = NULL
  if (isTRUE(length(idx) == 1)) {
    rd = rd[1:(idx - 1)]
    ex = capture.output(tools::Rd2ex(fn, options = list(
      useFancyQuotes = FALSE,
      showURLS = TRUE,
      underline_titles = FALSE)))
    idx = grep("^### \\*\\* Examples", ex)
    ex = ex[(idx + 1):length(ex)]
    ex <- paste(
      "## Examples:\n\n<pre class='r-example'><code>",
      downlit::evaluate_and_highlight(ex),
      "</code></pre>")
  }
  rd = c(rd, ex)

  # finish
  rd = trimws(rd)
  rd = gsub("’|‘", "`", rd)
  rd = paste(rd, collapse = "\n")
  
  # Usage: as code
  rd = gsub("## Usage:\n\n(.*)\n", "## Usage:\n\n`\\1`\n", rd, perl = TRUE)
  
  # write
  cat(rd, file = tar)
}

# Is the Rd file for internal documentation only (if so, it won't be included
# in the website)

is_internal <- function(file) {
  y <- capture.output(tools::Rd2latex(file))
  z <- grepl("\\\\keyword\\{", y)

  if (!any(z)) return(FALSE)

  reg <- regmatches(y, gregexpr("\\{\\K[^{}]+(?=\\})", y, perl=TRUE))

  test <- vapply(seq_along(y), function(foo) {
    z[foo] && ("internal" %in% reg[[foo]] || "docs" %in% reg[[foo]])
  }, FUN.VALUE = logical(1L))

  any(test)
}


make_doc_hierarchy = function() {
  # # example structure:
  # list(
  #   list("DataFrame" = c("class: reference/DataFrame_class.md")),
  #   list("Expr" = c("abs: reference/Expr_abs.md", "add: reference/Expr_add.md"))
  # )
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

convert_to_md <- function() {
  rd_files <- list.files("man", pattern = "\\.Rd")
  for (i in rd_files) {
    if (is_internal(paste0("man/", i))) next
    rd2md(paste0("man/", i))
  }
}


# Insert the "Reference" structure in the yaml (requires to overwrite the full
# mkdocs.yml)
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
convert_to_md()
message("Updating {.file docs/mkdocs.yaml}...\n")
convert_hierarchy_to_yml()




#library(cli)
#library(tinkr)
#library(magrittr)
#library(stringr)
#library(rd2markdown) # Genentech/rd2markdown (github only)
# cli_alert_info("Converting Rd files to markdown...")
# convert_to_md()
# cli_alert_info("Updating {.file docs/mkdocs.yaml}...")
# convert_hierarchy_to_yml()
# cli_alert_info("Running examples...")
# eval_reference_examples()

## Copy Rd files to "docs" folder and convert them to markdown
#
#convert_to_md <- function() {
#  rd_files <- list.files("man", pattern = "\\.Rd")
#
#  r_source <- get_r_source()
#
#  for (i in rd_files) {
#    if (is_internal(paste0("man/", i))) next
#    out <- rd2markdown::rd2markdown(file = paste0("man/", i))
#    corr_source <- unlist(r_source[r_source$rd == i, "r_source"])
#    out <- sub("\\\n\\\n",
#               paste0("\\\n\\\n*Source: [", corr_source,
#                      "](https://github.com/pola-rs/r-polars/tree/main/",
#                      corr_source, ")*\\\n\\\n"),
#               out)
#    cat(out, file = paste0("docs/docs/reference/", gsub("\\.Rd", "\\.md", i)))
#  }
#}
#
#
## Evaluate examples in "Reference" files and plug them back
#
#eval_reference_examples <- function() {
#
#  rd_files <- list.files("man", pattern = "\\.Rd", full.names = TRUE)
#  rd_files <- Filter(Negate(is_internal), rd_files)
#  md_files <- gsub("^man/", "docs/docs/reference/", rd_files)
#  md_files <- gsub("\\.Rd$", "\\.md", md_files)
#
#  subset_even <- function(x) x[!seq_along(x) %% 2]
#
#  cli_progress_bar(
#    format = paste0(
#      "{pb_spin} Evaluating examples for file {.path {md_files[i]}} ",
#      "[{pb_current}/{pb_total}]   ETA:{pb_eta}"
#    ),
#    format_done = "{col_green(symbol$tick)} Done",
#    total = length(rd_files)
#  )
#
#  for (i in seq_along(rd_files)) {
#
#    cli_progress_update()
#
#    orig_ex <- rd2markdown::rd2markdown(
#      file = rd_files[i],
#      fragments = "examples"
#    )
#
#    if (orig_ex == "") next
#
#    lines <- orig_ex %>%
#      stringr::str_split("```.*", simplify = TRUE) %>%
#      subset_even() %>%
#      stringr::str_flatten("\n## new chunk \n") %>%
#      stringr::str_remove("^\\\n")
#
#    evaluated_ex <- paste(
#      "## Examples\n\n<pre class='r-example'><code>",
#      downlit::evaluate_and_highlight(lines),
#      "</code></pre>"
#    )
#
#    evaluated_ex <- gsub("class='r-example'><code> <span ",
#                         "class='r-example'><code><span ",
#                         evaluated_ex)
#
#    orig_md <- readLines(md_files[i], warn = FALSE) %>%
#      paste(., collapse = "\n")
#
#    new_md <- gsub("## Examples.*", "", orig_md)
#    new_md <- paste0(new_md, evaluated_ex)
#
#    cat(new_md, file = md_files[i])
#
#  }
#
#}
#
## Find general classes: DataFrame, GroupBy, etc.
#
#get_general_classes <- function() {
#  rd_files <- list.files("man", pattern = "_class\\.Rd")
#  gsub("_class\\.Rd$", "", rd_files)
#}
#
#
## Find the R file in which the function was documented
#
#get_r_source <- function() {
#  rd_files <- list.files("man", pattern = "\\.Rd", full.names = TRUE)
#  out <- list()
#
#  for (i in seq_along(rd_files)) {
#    parsed <- as.character(tools::parse_Rd(rd_files[i], encoding = "UTF-8"))
#    contains_source <- grep("% Please edit documentation in", parsed)
#
#    r_source <- gsub("% Please edit documentation in ", "",
#                     parsed[contains_source])
#    rd <- gsub("^man/", "", rd_files[i])
#    out[[i]] <- list(rd, r_source)
#  }
#
#  out <- as.data.frame(do.call(rbind, out))
#  colnames(out) <- c("rd", "r_source")
#  out
#}
#
## Find the R file in which the function was documented
#
#det_r_source <- function() {
#  rd_files <- list.files("man", pattern = "\\.Rd", full.names = TRUE)
#  out <- list()
#
#  for (i in seq_along(rd_files)) {
#    parsed <- as.character(tools::parse_Rd(rd_files[i], encoding = "UTF-8"))
#    contains_source <- grep("% Please edit documentation in", parsed)
#
#    r_source <- gsub("% Please edit documentation in ", "",
#                     parsed[contains_source])
#    rd <- gsub("^man/", "", rd_files[i])
#    out[[i]] <- list(rd, r_source)
#  }
#
#  out <- as.data.frame(do.call(rbind, out))
#  colnames(out) <- c("rd", "r_source")
#  out
#}