library(altdoc)
library(yaml)
library(tinkr)
library(magrittr)

if (fs::dir_exists(here::here("docs/docs/reference"))) {
  fs::dir_delete(here::here("docs/docs/reference"))
}
fs::dir_create(here::here("docs/docs/reference"))

get_general_classes <- function() {
  rd_files <- list.files("man", pattern = "_class\\.Rd")
  gsub("_class\\.Rd$", "", rd_files)
}

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
  foo <- list(remaining)
  names(foo) <- "Other"
  hierarchy[[length(hierarchy) + 1]] <- foo

  hierarchy
}

convert_to_md <- function() {
  rd_files <- list.files("man", pattern = "\\.Rd")
  for (i in rd_files) {
    Rd2md::Rd2markdown(
      paste0("man/", i),
      paste0("docs/docs/reference/", gsub("\\.Rd", "\\.md", i))
    )
  }
}


clean_md <- function() {
  general_classes <- get_general_classes()
  for (i in general_classes) {
    files <- list.files(paste0("docs/docs/reference/"),
                        pattern = paste0("^", i, "_"),
                        full.names = TRUE)
    for (j in files) {
      tmp <- tinkr::yarn$new(j)
      # transform level 3 headers into level 1 headers
      replacement <- tmp$body %>%
        xml2::xml_find_all(xpath = ".//md:heading[@level='1']", tmp$ns) %>%
        xml2::xml_text() %>%
        gsub(paste0("^", i, "_"), "", .)

      tmp$body %>%
        xml2::xml_find_all(xpath = ".//md:heading[@level='1']", tmp$ns) |>
        xml2::xml_set_text(replacement) |>
        invisible()

      tmp$write(j)
    }
  }
}

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
  write_yaml(new_yaml, "docs/mkdocs.yml", indent.mapping.sequence = TRUE)
}

convert_to_md()
clean_md()
convert_hierarchy_to_yml()


