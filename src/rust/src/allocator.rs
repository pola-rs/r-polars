#[cfg(all(target_family = "unix", not(allocator = "mimalloc"),))]
use jemallocator::Jemalloc;
#[cfg(all(any(not(target_family = "unix"), allocator = "mimalloc"),))]
use mimalloc::MiMalloc;

#[global_allocator]
#[cfg(all(not(allocator = "mimalloc"), target_family = "unix",))]
static ALLOC: Jemalloc = Jemalloc;

#[global_allocator]
#[cfg(all(any(not(target_family = "unix"), allocator = "mimalloc"),))]
static ALLOC: MiMalloc = MiMalloc;
