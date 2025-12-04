check_sha256 <- function(file, sum, os = c("linux", "macos", "windows")) {
  message("Checking SHA256 for <", file, ">...")

  # tools::sha256sum should be available in R >= 4.5
  out <- if (exists("sha256sum", where = asNamespace("tools"), mode = "function")) {
    tools::sha256sum(file)
  } else {
    switch(
      match.arg(os),
      linux = system2("sha256sum", args = file, stdout = TRUE) |>
        gsub(r"(\s.*)", "", x = _),
      macos = system2("shasum", args = c("-a", "256", file), stdout = TRUE) |>
        gsub(r"(\s.*)", "", x = _),
      windows = system2("certutil", args = c("-hashfile", file, "SHA256"), stdout = TRUE)[2],
      stop("unreachable")
    )
  }

  if (out != sum) {
    stop(
      "SHA256 mismatch for <",
      file,
      ">.\n",
      "- Expected: ",
      sum,
      "\n",
      "- Got:      ",
      out
    )
  }

  message("SHA256 matches for <", file, ">.")

  invisible()
}

which_os <- function() {
  if (identical(.Platform$OS.type, "windows")) {
    "windows"
  } else if (Sys.info()["sysname"] == "Darwin") {
    "macos"
  } else if (R.version$os %in% c("linux-gnu", "linux-musl")) {
    R.version$os
  } else {
    stop("Pre-built binaries are not available for OS: ", R.version$os)
  }
}

which_arch <- function() {
  switch(
    R.Version()$arch,
    x86_64 = "x86_64",
    aarch64 = "aarch64",
    stop("Pre-built binaries are not available for Arch: ", R.Version()$arch)
  )
}

which_vendor_sys_abi <- function(
  os = c("linux-gnu", "linux-musl", "macos", "windows"),
  arch = c("x86_64", "aarch64")
) {
  switch(
    match.arg(os),
    macos = "apple-darwin",
    # GCC does not support Windows on arm64
    # Ref: https://blog.r-project.org/2024/04/23/r-on-64-bit-arm-windows/
    windows = sprintf(
      "pc-windows-%s",
      switch(
        match.arg(arch),
        x86_64 = "gnu",
        aarch64 = "gnullvm"
      )
    ),
    sprintf("unknown-%s", os)
  )
}

current_os <- which_os()
current_arch <- which_arch()
vendor_sys_abi <- which_vendor_sys_abi(current_os, current_arch)

target_triple <- ifelse(
  Sys.getenv("TARGET") != "",
  Sys.getenv("TARGET"),
  paste0(current_arch, "-", vendor_sys_abi)
)

lib_data <- utils::read.table("tools/lib-sums.tsv", header = TRUE, stringsAsFactors = FALSE)

package_name <- read.dcf("DESCRIPTION", fields = "Package", all = TRUE)
lib_version <- read.dcf(
  "DESCRIPTION",
  fields = sprintf("Config/%s/lib-version", package_name),
  all = TRUE
)
lib_tag_prefix <- "lib-v"

target_url <- sprintf(
  "https://github.com/pola-rs/r-polars/releases/download/%s%s/libr_polars-%s-%s.tar.gz",
  lib_tag_prefix,
  lib_version,
  lib_version,
  target_triple
)

lib_sum <- lib_data |>
  subset(url == target_url) |>
  (\(x) x$sha256sum)()

if (!length(lib_sum)) {
  stop("No pre-built binary found at <", target_url, ">")
}

message("Found pre-built binary at <", target_url, ">.\nDownloading...")

destfile <- tempfile(fileext = ".tar.gz")
on.exit(unlink(destfile))

utils::download.file(target_url, destfile, quiet = TRUE, mode = "wb")
check_sha256(destfile, lib_sum, os = gsub("-.*", "", current_os))

utils::untar(destfile, exdir = "tools")

message("Extracted pre-built binary to <", file.path(getwd(), "tools"), "> directory.")
