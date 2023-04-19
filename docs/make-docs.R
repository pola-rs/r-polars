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


# find general classes: DataFrame, GroupBy, etc.

get_general_classes <- function() {
  rd_files <- list.files("man", pattern = "_class\\.Rd")
  gsub("_class\\.Rd$", "", rd_files)
}


# nested list with general classes as titles and methods for these classes
# as children

make_doc_hierarchy <- function() {
  general_classes <- get_general_classes()

  all_rd <- list.files("man", pattern = "\\.Rd")

  hierarchy <- list()
  for (i in seq_along(general_classes)) {
    components <- list.files("man", pattern = paste0("^", general_classes[i]))
    all_rd <<- all_rd[-which(components %in% all_rd)]
    components <- components[-which(grepl("_class\\.Rd$", components))]
    components <- gsub("\\.Rd", "\\.md", components)
    components <- paste0("reference/", components)
    components <- sort(components)
    components <- paste0(
      gsub(paste0("^reference/", general_classes[i], "\\_"), "", components),
      ": ", components
    )
    components <- gsub("\\.md:", ":", components)
    components <- gsub("^reference/", "", components)
    foo <- list(components)
    names(foo) <- general_classes[i]
    hierarchy[[i]] <- foo
  }

  remaining <- grep(paste0("^(", paste(general_classes, collapse = "|"), ")"),
                    all_rd, invert = TRUE)
  remaining <- all_rd[remaining]
  remaining <- gsub("\\.Rd", "\\.md", remaining)
  remaining <- paste0("reference/", remaining)
  remaining <- sort(remaining)
  remaining <- paste0(
    gsub(paste0("^Other\\_"), "", remaining),
    ": ", remaining
  )
  remaining <- gsub("^reference/", "", remaining)
  remaining <- gsub("\\.md:", ":", remaining)
  foo <- list(remaining)
  names(foo) <- "Other"
  hierarchy[[length(hierarchy) + 1]] <- foo

  hierarchy
}


# copy Rd files to "docs" folder and convert them to markdown

convert_to_md <- function() {
  rd_files <- list.files("man", pattern = "\\.Rd")
  for (i in rd_files) {
    out <- rd2markdown::rd2markdown(file = paste0("man/", i))
    cat(out, file = paste0("docs/docs/reference/", gsub("\\.Rd", "\\.md", i)))
  }
}


# insert the "Reference" structure in the yaml (requires to overwrite the full
# mkdocs.yml)

convert_hierarchy_to_yml <- function() {
  hierarchy <- make_doc_hierarchy()

  new_yaml <- orig_yaml <- yaml.load_file(
    "docs/mkdocs.yml"
  )

  if (!is.null(orig_yaml$plugins) && !is.list(length(orig_yaml$plugins))) {
    new_yaml$plugins <- as.list(new_yaml$plugins)
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


# TODO: evaluate examples in reference pages
eval_reference_examples <- function() {

  pkgload::load_all()

  orig_ex <- rd2markdown::rd2markdown(file = "man/DataFrame_as_data_frame.Rd", fragments = "examples")

  # subset_even <- function(x) x[!seq_along(x) %% 2]
  #
  # lines <- orig_ex %>%
  #   stringr::str_split("```.*", simplify = TRUE) %>%
  #   subset_even() %>%
  #   stringr::str_flatten("\n## new chunk \n")
  #
  # file_output <- tempfile(fileext = ".R")
  # writeLines(lines, file_output)
  #
  # knitr::knit(file_output)
  #
  # eval(parse(text = lines))




  # gsub("```r", "```{r}", orig_ex) |>
  #   cat(_, file = )

}




convert_to_md()
convert_hierarchy_to_yml()


