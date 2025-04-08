dir.create("tools", showWarnings = FALSE)

# The rust-toolchain.toml file is needed at src/ directory
# only when compiling the rust lib with the nightly toolchain.
# So the configure script will copy it from the tools/ directory
# only if it is needed.
if (file.exists("src/rust/rust-toolchain.toml")) {
  file.copy(
    "src/rust/rust-toolchain.toml",
    "tools/rust-toolchain.toml",
    overwrite = TRUE
  ) |>
    invisible()
}
