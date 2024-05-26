fn main() {
    println!("cargo::rustc-check-cfg=cfg(allocator, values(\"mimalloc\"))");
}
