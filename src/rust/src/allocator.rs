#[cfg(any(
    not(target_family = "unix"),
    target_os = "emscripten",
    allocator = "mimalloc"
))]
use mimalloc::MiMalloc;
#[cfg(all(
    target_family = "unix",
    not(target_os = "emscripten"),
    not(allocator = "mimalloc"),
))]
use tikv_jemallocator::Jemalloc;

#[global_allocator]
#[cfg(all(
    not(allocator = "mimalloc"),
    target_family = "unix",
    not(target_os = "emscripten"),
))]
static ALLOC: Jemalloc = Jemalloc;

#[global_allocator]
#[cfg(any(
    not(target_family = "unix"),
    target_os = "emscripten",
    allocator = "mimalloc"
))]
static ALLOC: MiMalloc = MiMalloc;
