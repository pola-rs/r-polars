# Taken from the hellorust package
arch <- if (grepl("aarch", R.version$platform, fixed = TRUE)) {
  "aarch64-pc-windows-gnullvm"
} else if (grepl("clang", Sys.getenv("R_COMPILED_BY"), fixed = TRUE)) {
  "x86_64-pc-windows-gnullvm"
} else if (grepl("i386", R.version$platform, fixed = TRUE)) {
  "i686-pc-windows-gnu"
} else {
  "x86_64-pc-windows-gnu"
}

cat(arch)
