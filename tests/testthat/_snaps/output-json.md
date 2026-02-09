# lazy_sink_ndjson works

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

# error if wrong compression extension

    Code
      dat$sink_ndjson(tmpf)
    Condition
      Error in `dat$sink_ndjson()`:
      ! Evaluation failed in `$sink_ndjson()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: use the compression parameter to control compression, or set `check_extension` to `False` if you want to suffix an uncompressed filename with an ending intended for compression
      
      Resolved plan until failure:
      
      	---> FAILED HERE RESOLVING THIS_NODE <---
      DF ["mpg", "cyl", "disp"]; PROJECT */3 COLUMNS

