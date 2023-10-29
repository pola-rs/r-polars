base_url <- "https://github.com/pola-rs/r-polars/releases/download/"

tag_prefix <- "lib-v"

lib_data_file_path <- file.path("tools", "lib-sums.tsv")

package_name <- desc::desc_get("Package")
current_lib_version <- RcppTOML::parseTOML("src/rust/Cargo.toml")$package$version

latest_released_lib_version <- gert::git_remote_ls(remote = "https://github.com/pola-rs/r-polars/") |>
  dplyr::pull(ref) |>
  stringr::str_subset(stringr::str_c(r"(^refs/tags/)", tag_prefix)) |>
  stringr::str_remove(stringr::str_c(".*", tag_prefix)) |>
  numeric_version() |>
  sort() |>
  tail(1) |>
  as.character()

write_bin_lib_data <- function(path, sums_url, libs_base_url) {
  df <- readr::read_table(sums_url, col_names = FALSE, show_col_types = FALSE) |>
    dplyr::mutate(
      url = glue::glue("{libs_base_url}{X2}"),
      sha256sum = X1,
      .keep = "none"
    )

  readr::write_tsv(df, path)
}

desc::desc_set(paste0("Config/", package_name, "/LibVersion"), current_lib_version)

if (identical(current_lib_version, latest_released_lib_version)) {
  message("Current lib version is available via the binary release.")
  write_bin_lib_data(
    lib_data_file_path,
    glue::glue("{base_url}{tag_prefix }{latest_released_lib_version}/sha256sums.txt"),
    glue::glue("{base_url}{tag_prefix }{latest_released_lib_version}/")
  )
} else {
  message("Current lib version is not available via binary releases.")
  if (fs::file_exists(lib_data_file_path)) fs::file_delete(lib_data_file_path)
}
