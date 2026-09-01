#!/bin/sh
# zig-cc wrapper that bridges the cc crate's Rust-style target triple to Zig.
#
# The cc crate (used by ring, jemalloc-sys, etc.) passes the target triple as
# `--target=aarch64-unknown-linux-musl`. Zig rejects the `-unknown-` vendor
# component and requires its own format `aarch64-linux-musl`. This wrapper
# rewrites the triple before exec'ing `zig cc`.
set -eu

newargs=""
for arg in "$@"; do
	# Skip a stray leading `cc` subcommand; cc-rs invokes the wrapper with the
	# flags only, but some callers pass `cc` explicitly.
	case "$arg" in
	cc)
		continue
		;;
	esac
	case "$arg" in
	--target=aarch64-unknown-linux-musl)
		arg="--target=aarch64-linux-musl"
		;;
	esac
	# Quote each arg so paths with spaces survive the final eval.
	newargs="$newargs '$(printf '%s' "$arg" | sed "s/'/'\\\\''/g")'"
done

eval "exec zig cc $newargs"
