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

