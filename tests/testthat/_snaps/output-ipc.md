# lazy_sink_ipc works

    Code
      cat(lf$explain())
    Output
      SINK (file)
        DF ["mpg", "cyl", "disp", "hp", ...]; PROJECT */11 COLUMNS

---

    Code
      lf$collect()
    Output
      shape: (0, 0)
      ┌┐
      ╞╡
      └┘

# Arrow file compression defaults are deprecated

    Code
      lf$lazy_sink_ipc(withr::local_tempfile())
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The default value of `compression` is deprecated as of polars 1.16.0.
      i The default will change from `"zstd"` to `"uncompressed"` in Polars 2.0. Use `compression = "zstd"` to keep the current behavior or `compression = "uncompressed"` to opt into the new default.
    Output
      <polars_lazy_frame>

---

    Code
      lf$sink_ipc(withr::local_tempfile())
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The default value of `compression` is deprecated as of polars 1.16.0.
      i The default will change from `"zstd"` to `"uncompressed"` in Polars 2.0. Use `compression = "zstd"` to keep the current behavior or `compression = "uncompressed"` to opt into the new default.

---

    Code
      df$write_ipc(withr::local_tempfile())
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The default value of `compression` is deprecated as of polars 1.16.0.
      i The default will change from `"zstd"` to `"uncompressed"` in Polars 2.0. Use `compression = "zstd"` to keep the current behavior or `compression = "uncompressed"` to opt into the new default.

---

    Code
      df$write_ipc_stream(withr::local_tempfile())
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The default value of `compression` is deprecated as of polars 1.16.0.
      i The default will change from `"zstd"` to `"uncompressed"` in Polars 2.0. Use `compression = "zstd"` to keep the current behavior or `compression = "uncompressed"` to opt into the new default.

# Test writing data to Arrow file "uncompressed" - 0

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow file "zstd" - 0

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow file "lz4" - 0

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow file NULL - 0

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow file "uncompressed" - 1

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow file "zstd" - 1

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow file "lz4" - 1

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow file NULL - 1

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow file "uncompressed" - oldest

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow file "zstd" - oldest

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow file "lz4" - oldest

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow file NULL - oldest

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow file "uncompressed" - newest

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow file "zstd" - newest

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow file "lz4" - newest

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow file NULL - newest

    Code
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow stream "uncompressed" - 0

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow stream "zstd" - 0

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow stream "lz4" - 0

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow stream NULL - 0

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow stream "uncompressed" - 1

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow stream "zstd" - 1

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow stream "lz4" - 1

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow stream NULL - 1

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow stream "uncompressed" - oldest

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow stream "zstd" - oldest

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow stream "lz4" - oldest

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow stream NULL - oldest

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: large_string
      cat: dictionary<values=large_string, indices=uint32>

# Test writing data to Arrow stream "uncompressed" - newest

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow stream "zstd" - newest

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow stream "lz4" - newest

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

# Test writing data to Arrow stream NULL - newest

    Code
      arrow::read_ipc_stream(tmpf, as_data_frame = FALSE)$schema
    Output
      Schema
      int: int32
      chr: string_view
      cat: dictionary<values=string_view, indices=uint32>

