if (!dir.exists("tools")) {
  dir.create("tools")
}

file.copy(
  "src/rust/rust-toolchain.toml",
  "tools/rust-toolchain.toml",
  overwrite = TRUE
)
