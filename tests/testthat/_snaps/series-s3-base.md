# .DollarNames(<series>)

    Code
      .DollarNames(as_polars_series(NULL))
    Output
        [1] "arr"                    "bin"                    "cat"                   
        [4] "dt"                     "dtype"                  "flags"                 
        [7] "list"                   "name"                   "shape"                 
       [10] "str"                    "struct"                 "to_frame"              
       [13] "add"                    "alias"                  "cast"                  
       [16] "len"                    "n_chunks"               "rename"                
       [19] "gt"                     "eq"                     "clone"                 
       [22] "sub"                    "chunk_lengths"          "shrink_dtype"          
       [25] "true_div"               "serialize"              "to_r_vector"           
       [28] "reshape"                "gt_eq"                  "lt"                    
       [31] "rechunk"                "eq_missing"             "is_empty"              
       [34] "neq_missing"            "slice"                  "mul"                   
       [37] "mod"                    "equals"                 "lt_eq"                 
       [40] "neq"                    "std"                    "last"                  
       [43] "value_counts"           "bitwise_count_zeros"    "rolling_mean"          
       [46] "unique"                 "forward_fill"           "explode"               
       [49] "replace"                "rolling_std_by"         "floor_div"             
       [52] "cum_count"              "rolling_min"            "round_sig_figs"        
       [55] "upper_bound"            "peak_max"               "rolling_quantile_by"   
       [58] "shift"                  "rank"                   "kurtosis"              
       [61] "truncdiv"               "rolling_max_by"         "mode"                  
       [64] "truediv"                "sum"                    "floordiv"              
       [67] "product"                "cos"                    "rolling_mean_by"       
       [70] "cot"                    "bitwise_leading_zeros"  "count"                 
       [73] "hash"                   "bottom_k"               "ewm_std"               
       [76] "cum_prod"               "rolling_sum"            "exp"                   
       [79] "arg_max"                "cosh"                   "is_null"               
       [82] "sinh"                   "n_unique"               "rolling_std"           
       [85] "bitwise_trailing_ones"  "sort"                   "is_not_nan"            
       [88] "is_finite"              "is_between"             "unique_counts"         
       [91] "shuffle"                "drop_nans"              "log1p"                 
       [94] "index_of"               "bin_quantiles"          "search_sorted"         
       [97] "replace_strict"         "le"                     "ceil"                  
      [100] "rolling_median"         "gather_every"           "max_by"                
      [103] "has_nulls"              "log"                    "cum_min"               
      [106] "approx_n_unique"        "min_by"                 "bin_ranks"             
      [109] "first"                  "min"                    "drop_nulls"            
      [112] "top_k_by"               "sqrt"                   "is_duplicated"         
      [115] "extend_constant"        "is_nan"                 "backward_fill"         
      [118] "item"                   "entropy"                "map_batches"           
      [121] "arg_true"               "ewm_mean_by"            "reinterpret"           
      [124] "tail"                   "clip"                   "median"                
      [127] "set_sorted"             "cbrt"                   "get"                   
      [130] "bitwise_and"            "bin_intervals"          "ewm_mean"              
      [133] "xor"                    "ewm_var"                "ne"                    
      [136] "append"                 "arctan"                 "rolling_rank"          
      [139] "implode"                "floor"                  "rolling_skew"          
      [142] "arctanh"                "nan_max"                "neg"                   
      [145] "rolling_median_by"      "sign"                   "quantile"              
      [148] "qcut"                   "null_count"             "peak_min"              
      [151] "top_k"                  "skew"                   "rle"                   
      [154] "rolling_quantile"       "bitwise_xor"            "arccosh"               
      [157] "all"                    "rolling_kurtosis"       "rolling_var_by"        
      [160] "rolling_rank_by"        "rle_id"                 "bitwise_trailing_zeros"
      [163] "not"                    "bottom_k_by"            "is_close"              
      [166] "abs"                    "truncate"               "max"                   
      [169] "fill_nan"               "to_physical"            "is_infinite"           
      [172] "head"                   "or"                     "interpolate_by"        
      [175] "invert"                 "degrees"                "is_in"                 
      [178] "dot"                    "cut"                    "arg_min"               
      [181] "arcsin"                 "tan"                    "is_first_distinct"     
      [184] "sort_by"                "fill_null"              "and"                   
      [187] "sample"                 "bitwise_or"             "trunc_div"             
      [190] "gather"                 "interpolate"            "limit"                 
      [193] "rolling_min_by"         "diff"                   "radians"               
      [196] "pow"                    "arcsinh"                "cumulative_eval"       
      [199] "cum_max"                "ge"                     "bitwise_count_ones"    
      [202] "is_last_distinct"       "ne_missing"             "lower_bound"           
      [205] "round"                  "is_unique"              "reverse"               
      [208] "arg_unique"             "nan_min"                "filter"                
      [211] "any"                    "cum_sum"                "rolling_max"           
      [214] "log10"                  "is_not_null"            "arccos"                
      [217] "rolling_sum_by"         "tanh"                   "hist"                  
      [220] "var"                    "sin"                    "pct_change"            
      [223] "bitwise_leading_ones"   "rolling_var"            "arg_sort"              
      [226] "repeat_by"              "mean"                  

# as.vector() suggests $to_r_vector() for datatypes that need attributes

    Code
      as.vector(pl$Series("a", as.Date("2020-01-01")))
    Message
      i `as.vector()` on a Polars Series of type date may drop some useful attributes.
      i Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
    Output
      [1] 18262

---

    Code
      as.vector(pl$Series("a", as.POSIXct("2020-01-01", tz = "UTC")))
    Message
      i `as.vector()` on a Polars Series of type datetime[ms, UTC] may drop some useful attributes.
      i Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
    Output
      [1] 1577836800

---

    Code
      as.vector(s_struct)
    Message
      i `as.vector()` on a Polars Series of type struct[1] may drop some useful attributes.
      i Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
    Output
      $x
      [1] "2020-01-01"
      

---

    Code
      as.vector(pl$Series("a", 1:2)$cast(pl$Int64))
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer64"
      i `as.vector()` on a Polars Series of type i64 may drop some useful attributes.
      i Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
    Output
      [1] 4.940656e-324 9.881313e-324

---

    Code
      as.vector(pl$Series("a", hms::hms(1, 2, 3)))
    Message
      i `as.vector()` on a Polars Series of type time may drop some useful attributes.
      i Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
    Output
      [1] 10921

