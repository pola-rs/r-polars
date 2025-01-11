#[cfg(all(
    target_family = "unix",
    not(target_os = "emscripten"),
    not(allocator = "mimalloc"),
))]
use jemallocator::Jemalloc;
#[cfg(all(any(
    not(target_family = "unix"),
    target_os = "emscripten",
    allocator = "mimalloc"
),))]
use mimalloc::MiMalloc;

#[global_allocator]
#[cfg(all(
    not(allocator = "mimalloc"),
    target_family = "unix",
    not(target_os = "emscripten"),
))]
static ALLOC: Jemalloc = Jemalloc;

#[global_allocator]
#[cfg(all(any(
    not(target_family = "unix"),
    target_os = "emscripten",
    allocator = "mimalloc"
),))]
static ALLOC: MiMalloc = MiMalloc;
