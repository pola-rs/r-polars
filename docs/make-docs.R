###### Custom script:
######
###### - get the Rd files, convert them to markdown in "docs/docs/reference" and
######   put them in "mkdocs.yaml"
###### - run the examples in the "Reference" files


library(altdoc)
library(yaml)
library(tinkr)
library(magrittr)
library(stringr)
library(rd2markdown) # Genentech/rd2markdown (github only)


if (fs::dir_exists(here::here("docs/docs/reference"))) {
  fs::dir_delete(here::here("docs/docs/reference"))
}
fs::dir_create(here::here("docs/docs/reference"))



# Is the Rd file for internal documentation only (if so, it won't be included
# in the website)

is_internal <- function(file) {
  y <- capture.output(tools::Rd2latex(file))
  z <- grepl("\\\\keyword\\{", y)

  if (!any(z)) return(FALSE)

  reg <- regmatches(y, gregexpr("\\{\\K[^{}]+(?=\\})", y, perl=TRUE))

  test <- vapply(seq_along(y), function(foo) {
    z[foo] && "internal" %in% reg[[foo]]
  }, FUN.VALUE = logical(1L))

  any(test)
}


# Find the R file in which the function was documented

get_r_source <- function() {
  rd_files <- list.files("man", pattern = "\\.Rd", full.names = TRUE)
  out <- list()

  for (i in seq_along(rd_files)) {
    parsed <- as.character(tools::parse_Rd(rd_files[i], encoding = "UTF-8"))
    contains_source <- grep("% Please edit documentation in", parsed)

    r_source <- gsub("% Please edit documentation in ", "",
                     parsed[contains_source])
    rd <- gsub("^man/", "", rd_files[i])
    out[[i]] <- list(rd, r_source)
  }

  out <- as.data.frame(do.call(rbind, out))
  colnames(out) <- c("rd", "r_source")
  out
}


# Find general classes: DataFrame, GroupBy, etc.

get_general_classes <- function() {
  rd_files <- list.files("man", pattern = "_class\\.Rd")
  gsub("_class\\.Rd$", "", rd_files)
}


# Nested list with general classes as titles and methods for these classes
# as children

make_doc_hierarchy <- function() {
  general_classes <- get_general_classes()

  all_rd <- list.files("man", pattern = "\\.Rd")

  hierarchy <- list()
  for (i in seq_along(general_classes)) {
    components <- list.files("man", pattern = paste0("^", general_classes[i]))
    components <- Filter(Negate(is_internal), paste0("man/", components))
    components <- gsub("^man/", "", components)

    if (length(components) <= 1) next

    all_rd <<- all_rd[-which(all_rd %in% components)]
    components <- components[-which(grepl("_class\\.Rd$", components))] %>%
      gsub("\\.Rd", "\\.md", x = .) %>%
      paste0("reference/", .) %>%
      sort(x = .) %>%
      paste0(
        gsub(
          paste0("^reference/", general_classes[i], "\\_"),
          "", x = .
        ),
        ": ", .
      ) %>%
      gsub("\\.md:", ":", x = .) %>%
      gsub("^reference/", "", x = .)

    foo <- list(components)
    names(foo) <- general_classes[i]
    hierarchy[[i]] <- foo
  }

  remaining <- grep(paste0("^(", paste(general_classes, collapse = "|"), ")"),
                    all_rd, invert = TRUE)
  remaining <- Filter(Negate(is_internal), paste0("man/", all_rd[remaining]))
  remaining <- gsub("^man/", "", remaining)
  remaining <- remaining %>%
    gsub("\\.Rd", "\\.md", x = .) %>%
    paste0("reference/", .) %>%
    sort(x = .) %>%
    paste0(
      gsub(
        paste0("^reference/", general_classes[i], "\\_"),
        "", x = .
      ),
      ": ", .
    ) %>%
    gsub("\\.md:", ":", x = .) %>%
    gsub("^reference/", "", x = .)

  foo <- list(remaining)
  names(foo) <- "Other"
  hierarchy[[length(hierarchy) + 1]] <- foo

  hierarchy <- Filter(Negate(is.null), hierarchy)

  hierarchy
}


# Copy Rd files to "docs" folder and convert them to markdown

convert_to_md <- function() {
  rd_files <- list.files("man", pattern = "\\.Rd")

  r_source <- get_r_source()

  for (i in rd_files) {
    if (is_internal(paste0("man/", i))) next
    out <- rd2markdown::rd2markdown(file = paste0("man/", i))
    corr_source <- unlist(r_source[r_source$rd == i, "r_source"])
    out <- sub("\\\n\\\n",
               paste0("\\\n\\\n*Source: [", corr_source,
                      "](https://github.com/pola-rs/r-polars/tree/main/",
                      corr_source, ")*\\\n\\\n"),
               out)
    cat(out, file = paste0("docs/docs/reference/", gsub("\\.Rd", "\\.md", i)))
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


# Evaluate examples in "Reference" files and plug them back

eval_reference_examples <- function() {

  pkgload::load_all()

  rd_files <- list.files("man", pattern = "\\.Rd", full.names = TRUE)
  md_files <- gsub("^man/", "docs/docs/reference/", rd_files)
  md_files <- gsub("\\.Rd$", "\\.md", md_files)

  subset_even <- function(x) x[!seq_along(x) %% 2]

  for (i in seq_along(rd_files)) {

    if (is_internal(rd_files[i])) next

    cat(paste0("Evaluating examples for file ", md_files[i], "\n"))

    orig_ex <- rd2markdown::rd2markdown(
      file = rd_files[i],
      fragments = "examples"
    )

    if (orig_ex == "") next

    lines <- orig_ex %>%
      stringr::str_split("```.*", simplify = TRUE) %>%
      subset_even() %>%
      stringr::str_flatten("\n## new chunk \n") %>%
      stringr::str_remove("^\\\n")

    evaluated_ex <- paste(
      "## Examples\n\n<pre class='r-example'><code>",
      downlit::evaluate_and_highlight(lines),
      "</code></pre>"
    )

    evaluated_ex <- gsub("class='r-example'><code> <span ",
                         "class='r-example'><code><span ",
                         evaluated_ex)

    orig_md <- readLines(md_files[i], warn = FALSE) %>%
      paste(., collapse = "\n")

    new_md <- gsub("## Examples.*", "", orig_md)
    new_md <- paste0(new_md, evaluated_ex)

    cat(new_md, file = md_files[i])

  }

}


# Run all

convert_to_md()
convert_hierarchy_to_yml()
eval_reference_examples()

