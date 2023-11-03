check_sha256 = function(file, sum, os = c("linux", "macos", "windows")) {
  message("Checking SHA256 for <", file, ">...")

  if (match.arg(os) == "linux") {
    out = system2("sha256sum", args = file, stdout = TRUE) |>
      gsub(r"(\s.*)", "", x = _)
  } else if (match.arg(os) == "macos") {
    out = system2("shasum", args = c("-a", "256", file), stdout = TRUE) |>
      gsub(r"(\s.*)", "", x = _)
  } else if (match.arg(os) == "windows") {
    out = system2("certutil", args = c("-hashfile", file, "SHA256"), stdout = TRUE)[2]
  } else {
    stop("Unsupported OS: ", os)
  }

  if (out != sum) {
    stop(
      "SHA256 mismatch for <", file, ">.\n",
      "- Expected: ", sum, "\n",
      "- Got:      ", out
    )
  }

  message("SHA256 matches for <", file, ">.")

  invisible()
}

which_os = function() {
  if (identical(.Platform$OS.type, "windows")) {
    "windows"
  } else if (Sys.info()["sysname"] == "Darwin") {
    "macos"
  } else if (R.version$os == "linux-gnu") {
    "linux"
  } else {
    stop("Pre-built binaries are not available for OS: ", R.version$os)
  }
}

which_arch = function() {
  if ((Sys.info()[["machine"]] %in% c("amd64", "x86_64", "x86-64"))) {
    "x86_64"
  } else if (Sys.info()[["machine"]] %in% c("arm64", "aarch64")) {
    "aarch64"
  } else {
    stop("Pre-built binaries are not available for Arch: ", Sys.info()[["machine"]])
  }
}

which_vendor_sys_abi = function(os = c("linux", "macos", "windows")) {
  if (match.arg(os) == "linux") {
    "unknown-linux-gnu"
  } else if (match.arg(os) == "macos") {
    "apple-darwin"
  } else if (match.arg(os) == "windows") {
    "pc-windows-gnu"
  } else {
    stop("Unsupported OS: ", os)
  }
}

current_os = which_os()
vendor_sys_abi = which_vendor_sys_abi(current_os)
current_arch = which_arch()

target_triple = paste0(current_arch, "-", vendor_sys_abi)

lib_data = utils::read.table("tools/lib-sums.tsv", header = TRUE, stringsAsFactors = FALSE)

package_name = read.dcf("DESCRIPTION", fields = "Package", all = TRUE)
lib_version = read.dcf("DESCRIPTION", fields = sprintf("Config/%s/LibVersion", package_name), all = TRUE)
lib_tag_prefix = "lib-v"

target_url = sprintf(
  "https://github.com/pola-rs/r-polars/releases/download/%s%s/libr_polars-%s-%s.tar.gz",
  lib_tag_prefix,
  lib_version,
  lib_version,
  target_triple
)

lib_sum = lib_data |>
  subset(url == target_url) |>
  (\(x) x$sha256sum)()

if (!length(lib_sum)) stop("No pre-built binary found at <", target_url, ">")

message("Found pre-built binary at <", target_url, ">.\nDownloading...")

destfile = tempfile(fileext = ".tar.gz")
on.exit(unlink(destfile))

utils::download.file(target_url, destfile, quiet = TRUE, mode = "wb")
check_sha256(destfile, lib_sum, os = current_os)

utils::untar(destfile, exdir = "tools")

message("Extracted pre-built binary to <", file.path(getwd(), "tools"), "> directory.")
