# public and private functions in pl and .pr

    Code
      ls(pl)
    Output
        [1] "Array"                     "Binary"                   
        [3] "Boolean"                   "Categorical"              
        [5] "DataFrame"                 "Date"                     
        [7] "Datetime"                  "Duration"                 
        [9] "Enum"                      "Field"                    
       [11] "Float32"                   "Float64"                  
       [13] "Int16"                     "Int32"                    
       [15] "Int64"                     "Int8"                     
       [17] "LazyFrame"                 "List"                     
       [19] "Null"                      "PTime"                    
       [21] "SQLContext"                "Series"                   
       [23] "String"                    "Struct"                   
       [25] "Time"                      "UInt16"                   
       [27] "UInt32"                    "UInt64"                   
       [29] "UInt8"                     "Unknown"                  
       [31] "Utf8"                      "all"                      
       [33] "all_horizontal"            "any_horizontal"           
       [35] "approx_n_unique"           "arg_sort_by"              
       [37] "arg_where"                 "class_names"              
       [39] "coalesce"                  "col"                      
       [41] "concat"                    "concat_list"              
       [43] "concat_str"                "corr"                     
       [45] "count"                     "cov"                      
       [47] "date"                      "date_range"               
       [49] "date_ranges"               "datetime"                 
       [51] "datetime_range"            "datetime_ranges"          
       [53] "deserialize_lf"            "disable_string_cache"     
       [55] "dtypes"                    "duration"                 
       [57] "element"                   "enable_string_cache"      
       [59] "first"                     "fold"                     
       [61] "from_epoch"                "get_global_rpool_cap"     
       [63] "head"                      "implode"                  
       [65] "int_range"                 "int_ranges"               
       [67] "is_schema"                 "last"                     
       [69] "len"                       "lit"                      
       [71] "max"                       "max_horizontal"           
       [73] "mean"                      "mean_horizontal"          
       [75] "median"                    "mem_address"              
       [77] "min"                       "min_horizontal"           
       [79] "n_unique"                  "numeric_dtypes"           
       [81] "raw_list"                  "read_csv"                 
       [83] "read_ipc"                  "read_ndjson"              
       [85] "read_parquet"              "reduce"                   
       [87] "rolling_corr"              "rolling_cov"              
       [89] "same_outer_dt"             "scan_csv"                 
       [91] "scan_ipc"                  "scan_ndjson"              
       [93] "scan_parquet"              "select"                   
       [95] "set_global_rpool_cap"      "show_all_public_functions"
       [97] "show_all_public_methods"   "std"                      
       [99] "struct"                    "sum"                      
      [101] "sum_horizontal"            "tail"                     
      [103] "thread_pool_size"          "time"                     
      [105] "using_string_cache"        "var"                      
      [107] "when"                      "with_string_cache"        

---

    Code
      ls(.pr)
    Output
       [1] "ChainedThen"       "ChainedWhen"       "DataFrame"        
       [4] "DataType"          "DataTypeVector"    "Err"              
       [7] "Expr"              "GroupBy"           "LazyFrame"        
      [10] "LazyGroupBy"       "RField"            "RNullValues"      
      [13] "RThreadHandle"     "SQLContext"        "Series"           
      [16] "StringCacheHolder" "Then"              "VecDataFrame"     
      [19] "When"              "env"               "print_env"        

# public and private methods of each class DataFrame

    Code
      ls(.pr$env[[class_name]])
    Output
       [1] "clear"            "clone"            "columns"          "describe"        
       [5] "drop"             "drop_in_place"    "drop_nulls"       "dtype_strings"   
       [9] "dtypes"           "equals"           "estimated_size"   "explode"         
      [13] "fill_nan"         "fill_null"        "filter"           "first"           
      [17] "flags"            "get_column"       "get_columns"      "glimpse"         
      [21] "group_by"         "group_by_dynamic" "head"             "height"          
      [25] "item"             "join"             "join_asof"        "last"            
      [29] "lazy"             "limit"            "max"              "mean"            
      [33] "median"           "melt"             "min"              "n_chunks"        
      [37] "null_count"       "partition_by"     "pivot"            "print"           
      [41] "quantile"         "rechunk"          "rename"           "reverse"         
      [45] "rolling"          "sample"           "schema"           "select"          
      [49] "select_seq"       "shape"            "shift"            "shift_and_fill"  
      [53] "slice"            "sort"             "sql"              "std"             
      [57] "sum"              "tail"             "to_data_frame"    "to_list"         
      [61] "to_raw_ipc"       "to_series"        "to_struct"        "transpose"       
      [65] "unique"           "unnest"           "var"              "width"           
      [69] "with_columns"     "with_columns_seq" "with_row_index"   "write_csv"       
      [73] "write_ipc"        "write_json"       "write_ndjson"     "write_parquet"   

---

    Code
      ls(.pr[[private_key]])
    Output
       [1] "clear"                  "clone_in_rust"          "columns"               
       [4] "default"                "drop_all_in_place"      "drop_in_place"         
       [7] "dtype_strings"          "dtypes"                 "equals"                
      [10] "estimated_size"         "export_stream"          "from_raw_ipc"          
      [13] "get_column"             "get_columns"            "lazy"                  
      [16] "melt"                   "n_chunks"               "new_with_capacity"     
      [19] "null_count"             "partition_by"           "pivot_expr"            
      [22] "print"                  "rechunk"                "sample_frac"           
      [25] "sample_n"               "schema"                 "select"                
      [28] "select_at_idx"          "select_seq"             "set_column_from_robj"  
      [31] "set_column_from_series" "set_column_names_mut"   "shape"                 
      [34] "to_list"                "to_list_tag_structs"    "to_list_unwind"        
      [37] "to_raw_ipc"             "to_struct"              "transpose"             
      [40] "unnest"                 "with_columns"           "with_columns_seq"      
      [43] "with_row_index"         "write_csv"              "write_ipc"             
      [46] "write_json"             "write_ndjson"           "write_parquet"         

# public and private methods of each class GroupBy

    Code
      ls(.pr$env[[class_name]])
    Output
       [1] "agg"            "columns"        "first"          "last"          
       [5] "max"            "mean"           "median"         "min"           
       [9] "null_count"     "quantile"       "shift"          "shift_and_fill"
      [13] "std"            "sum"            "ungroup"        "var"           

# public and private methods of each class LazyFrame

    Code
      ls(.pr$env[[class_name]])
    Output
       [1] "clear"                   "clone"                  
       [3] "collect"                 "collect_in_background"  
       [5] "columns"                 "describe_optimized_plan"
       [7] "describe_plan"           "drop"                   
       [9] "drop_nulls"              "dtypes"                 
      [11] "explode"                 "fetch"                  
      [13] "fill_nan"                "fill_null"              
      [15] "filter"                  "first"                  
      [17] "get_optimization_toggle" "group_by"               
      [19] "group_by_dynamic"        "head"                   
      [21] "join"                    "join_asof"              
      [23] "last"                    "limit"                  
      [25] "max"                     "mean"                   
      [27] "median"                  "melt"                   
      [29] "min"                     "print"                  
      [31] "profile"                 "quantile"               
      [33] "rename"                  "reverse"                
      [35] "rolling"                 "schema"                 
      [37] "select"                  "select_seq"             
      [39] "serialize"               "set_optimization_toggle"
      [41] "shift"                   "shift_and_fill"         
      [43] "sink_csv"                "sink_ipc"               
      [45] "sink_ndjson"             "sink_parquet"           
      [47] "slice"                   "sort"                   
      [49] "sql"                     "std"                    
      [51] "sum"                     "tail"                   
      [53] "to_dot"                  "unique"                 
      [55] "unnest"                  "var"                    
      [57] "width"                   "with_columns"           
      [59] "with_columns_seq"        "with_context"           
      [61] "with_row_index"         

---

    Code
      ls(.pr[[private_key]])
    Output
       [1] "clone_in_rust"           "collect"                
       [3] "collect_in_background"   "debug_plan"             
       [5] "describe_optimized_plan" "describe_plan"          
       [7] "deserialize"             "drop"                   
       [9] "drop_nulls"              "explode"                
      [11] "fetch"                   "fill_nan"               
      [13] "fill_null"               "filter"                 
      [15] "first"                   "get_optimization_toggle"
      [17] "group_by"                "group_by_dynamic"       
      [19] "join"                    "join_asof"              
      [21] "last"                    "max"                    
      [23] "mean"                    "median"                 
      [25] "melt"                    "min"                    
      [27] "print"                   "profile"                
      [29] "quantile"                "rename"                 
      [31] "reverse"                 "rolling"                
      [33] "schema"                  "select"                 
      [35] "select_seq"              "serialize"              
      [37] "set_optimization_toggle" "shift"                  
      [39] "shift_and_fill"          "sink_csv"               
      [41] "sink_ipc"                "sink_json"              
      [43] "sink_parquet"            "slice"                  
      [45] "sort_by_exprs"           "std"                    
      [47] "sum"                     "tail"                   
      [49] "to_dot"                  "unique"                 
      [51] "unnest"                  "var"                    
      [53] "with_columns"            "with_columns_seq"       
      [55] "with_context"            "with_row_index"         

# public and private methods of each class Expr

    Code
      ls(.pr$env[[class_name]])
    Output
        [1] "abs"               "add"               "agg_groups"       
        [4] "alias"             "all"               "and"              
        [7] "any"               "append"            "approx_n_unique"  
       [10] "arccos"            "arccosh"           "arcsin"           
       [13] "arcsinh"           "arctan"            "arctanh"          
       [16] "arg_max"           "arg_min"           "arg_sort"         
       [19] "arg_unique"        "arr"               "backward_fill"    
       [22] "bin"               "bottom_k"          "cast"             
       [25] "cat"               "ceil"              "clip"             
       [28] "clip_max"          "clip_min"          "cos"              
       [31] "cosh"              "count"             "cum_count"        
       [34] "cum_max"           "cum_min"           "cum_prod"         
       [37] "cum_sum"           "cumulative_eval"   "cut"              
       [40] "diff"              "div"               "dot"              
       [43] "drop_nans"         "drop_nulls"        "dt"               
       [46] "entropy"           "eq"                "eq_missing"       
       [49] "ewm_mean"          "ewm_std"           "ewm_var"          
       [52] "exclude"           "exp"               "explode"          
       [55] "extend_constant"   "fill_nan"          "fill_null"        
       [58] "filter"            "first"             "flatten"          
       [61] "floor"             "floor_div"         "forward_fill"     
       [64] "gather"            "gather_every"      "gt"               
       [67] "gt_eq"             "hash"              "head"             
       [70] "implode"           "inspect"           "interpolate"      
       [73] "is_between"        "is_duplicated"     "is_finite"        
       [76] "is_first_distinct" "is_in"             "is_infinite"      
       [79] "is_last_distinct"  "is_nan"            "is_not_nan"       
       [82] "is_not_null"       "is_null"           "is_unique"        
       [85] "kurtosis"          "last"              "len"              
       [88] "limit"             "list"              "log"              
       [91] "log10"             "lower_bound"       "lt"               
       [94] "lt_eq"             "map_batches"       "map_elements"     
       [97] "max"               "mean"              "median"           
      [100] "meta"              "min"               "mod"              
      [103] "mode"              "mul"               "n_unique"         
      [106] "name"              "nan_max"           "nan_min"          
      [109] "neq"               "neq_missing"       "not"              
      [112] "null_count"        "or"                "over"             
      [115] "pct_change"        "peak_max"          "peak_min"         
      [118] "pow"               "print"             "product"          
      [121] "qcut"              "quantile"          "rank"             
      [124] "rechunk"           "reinterpret"       "rep"              
      [127] "repeat_by"         "replace"           "reshape"          
      [130] "reverse"           "rle"               "rle_id"           
      [133] "rolling"           "rolling_max"       "rolling_mean"     
      [136] "rolling_median"    "rolling_min"       "rolling_quantile" 
      [139] "rolling_skew"      "rolling_std"       "rolling_sum"      
      [142] "rolling_var"       "round"             "sample"           
      [145] "search_sorted"     "set_sorted"        "shift"            
      [148] "shift_and_fill"    "shrink_dtype"      "shuffle"          
      [151] "sign"              "sin"               "sinh"             
      [154] "skew"              "slice"             "sort"             
      [157] "sort_by"           "sqrt"              "std"              
      [160] "str"               "struct"            "sub"              
      [163] "sum"               "tail"              "tan"              
      [166] "tanh"              "to_physical"       "to_r"             
      [169] "to_series"         "to_struct"         "top_k"            
      [172] "unique"            "unique_counts"     "upper_bound"      
      [175] "value_counts"      "var"               "xor"              

---

    Code
      ls(.pr[[private_key]])
    Output
        [1] "abs"                        "add"                       
        [3] "agg_groups"                 "alias"                     
        [5] "all"                        "and"                       
        [7] "any"                        "append"                    
        [9] "approx_n_unique"            "arccos"                    
       [11] "arccosh"                    "arcsin"                    
       [13] "arcsinh"                    "arctan"                    
       [15] "arctanh"                    "arg_max"                   
       [17] "arg_min"                    "arg_sort"                  
       [19] "arg_unique"                 "arr_all"                   
       [21] "arr_any"                    "arr_arg_max"               
       [23] "arr_arg_min"                "arr_contains"              
       [25] "arr_count_matches"          "arr_get"                   
       [27] "arr_join"                   "arr_max"                   
       [29] "arr_median"                 "arr_min"                   
       [31] "arr_reverse"                "arr_shift"                 
       [33] "arr_sort"                   "arr_std"                   
       [35] "arr_sum"                    "arr_to_list"               
       [37] "arr_to_struct"              "arr_unique"                
       [39] "arr_var"                    "backward_fill"             
       [41] "bin_base64_decode"          "bin_base64_encode"         
       [43] "bin_contains"               "bin_ends_with"             
       [45] "bin_hex_decode"             "bin_hex_encode"            
       [47] "bin_starts_with"            "bottom_k"                  
       [49] "cast"                       "cat_get_categories"        
       [51] "cat_set_ordering"           "ceil"                      
       [53] "clip"                       "clip_max"                  
       [55] "clip_min"                   "col"                       
       [57] "cols"                       "corr"                      
       [59] "cos"                        "cosh"                      
       [61] "count"                      "cov"                       
       [63] "cum_count"                  "cum_max"                   
       [65] "cum_min"                    "cum_prod"                  
       [67] "cum_sum"                    "cumulative_eval"           
       [69] "cut"                        "diff"                      
       [71] "div"                        "dot"                       
       [73] "drop_nans"                  "drop_nulls"                
       [75] "dt_cast_time_unit"          "dt_combine"                
       [77] "dt_convert_time_zone"       "dt_day"                    
       [79] "dt_epoch_seconds"           "dt_hour"                   
       [81] "dt_is_leap_year"            "dt_iso_year"               
       [83] "dt_microsecond"             "dt_millisecond"            
       [85] "dt_minute"                  "dt_month"                  
       [87] "dt_nanosecond"              "dt_offset_by"              
       [89] "dt_ordinal_day"             "dt_quarter"                
       [91] "dt_replace_time_zone"       "dt_round"                  
       [93] "dt_second"                  "dt_strftime"               
       [95] "dt_time"                    "dt_total_days"             
       [97] "dt_total_hours"             "dt_total_microseconds"     
       [99] "dt_total_milliseconds"      "dt_total_minutes"          
      [101] "dt_total_nanoseconds"       "dt_total_seconds"          
      [103] "dt_truncate"                "dt_week"                   
      [105] "dt_weekday"                 "dt_with_time_unit"         
      [107] "dt_year"                    "dtype_cols"                
      [109] "entropy"                    "eq"                        
      [111] "eq_missing"                 "ewm_mean"                  
      [113] "ewm_std"                    "ewm_var"                   
      [115] "exclude"                    "exclude_dtype"             
      [117] "exp"                        "explode"                   
      [119] "extend_constant"            "fill_nan"                  
      [121] "fill_null"                  "fill_null_with_strategy"   
      [123] "filter"                     "first"                     
      [125] "flatten"                    "floor"                     
      [127] "floor_div"                  "forward_fill"              
      [129] "gather"                     "gather_every"              
      [131] "gt"                         "gt_eq"                     
      [133] "hash"                       "head"                      
      [135] "implode"                    "interpolate"               
      [137] "is_between"                 "is_duplicated"             
      [139] "is_finite"                  "is_first_distinct"         
      [141] "is_in"                      "is_infinite"               
      [143] "is_last_distinct"           "is_nan"                    
      [145] "is_not_nan"                 "is_not_null"               
      [147] "is_null"                    "is_unique"                 
      [149] "kurtosis"                   "last"                      
      [151] "len"                        "list_all"                  
      [153] "list_any"                   "list_arg_max"              
      [155] "list_arg_min"               "list_contains"             
      [157] "list_diff"                  "list_eval"                 
      [159] "list_gather"                "list_gather_every"         
      [161] "list_get"                   "list_join"                 
      [163] "list_len"                   "list_max"                  
      [165] "list_mean"                  "list_min"                  
      [167] "list_n_unique"              "list_reverse"              
      [169] "list_set_operation"         "list_shift"                
      [171] "list_slice"                 "list_sort"                 
      [173] "list_sum"                   "list_to_struct"            
      [175] "list_unique"                "lit"                       
      [177] "log"                        "log10"                     
      [179] "lower_bound"                "lt"                        
      [181] "lt_eq"                      "map_batches"               
      [183] "map_batches_in_background"  "map_elements_in_background"
      [185] "max"                        "mean"                      
      [187] "median"                     "meta_eq"                   
      [189] "meta_has_multiple_outputs"  "meta_is_regex_projection"  
      [191] "meta_output_name"           "meta_pop"                  
      [193] "meta_roots"                 "meta_tree_format"          
      [195] "meta_undo_aliases"          "min"                       
      [197] "mode"                       "mul"                       
      [199] "n_unique"                   "name_keep"                 
      [201] "name_map"                   "name_prefix"               
      [203] "name_prefix_fields"         "name_suffix"               
      [205] "name_suffix_fields"         "name_to_lowercase"         
      [207] "name_to_uppercase"          "nan_max"                   
      [209] "nan_min"                    "neq"                       
      [211] "neq_missing"                "new_first"                 
      [213] "new_last"                   "new_len"                   
      [215] "not"                        "null_count"                
      [217] "or"                         "over"                      
      [219] "pct_change"                 "peak_max"                  
      [221] "peak_min"                   "pow"                       
      [223] "print"                      "product"                   
      [225] "qcut"                       "qcut_uniform"              
      [227] "quantile"                   "rank"                      
      [229] "rechunk"                    "reinterpret"               
      [231] "rem"                        "rep"                       
      [233] "repeat_by"                  "replace"                   
      [235] "reshape"                    "reverse"                   
      [237] "rle"                        "rle_id"                    
      [239] "rolling"                    "rolling_corr"              
      [241] "rolling_cov"                "rolling_max"               
      [243] "rolling_mean"               "rolling_median"            
      [245] "rolling_min"                "rolling_quantile"          
      [247] "rolling_skew"               "rolling_std"               
      [249] "rolling_sum"                "rolling_var"               
      [251] "round"                      "sample_frac"               
      [253] "sample_n"                   "search_sorted"             
      [255] "shift"                      "shift_and_fill"            
      [257] "shrink_dtype"               "shuffle"                   
      [259] "sign"                       "sin"                       
      [261] "sinh"                       "skew"                      
      [263] "slice"                      "sort_by"                   
      [265] "sort_with"                  "std"                       
      [267] "str_base64_decode"          "str_base64_encode"         
      [269] "str_concat"                 "str_contains"              
      [271] "str_contains_any"           "str_count_matches"         
      [273] "str_ends_with"              "str_explode"               
      [275] "str_extract"                "str_extract_all"           
      [277] "str_extract_groups"         "str_find"                  
      [279] "str_head"                   "str_hex_decode"            
      [281] "str_hex_encode"             "str_json_decode"           
      [283] "str_json_path_match"        "str_len_bytes"             
      [285] "str_len_chars"              "str_pad_end"               
      [287] "str_pad_start"              "str_replace"               
      [289] "str_replace_all"            "str_replace_many"          
      [291] "str_reverse"                "str_slice"                 
      [293] "str_split"                  "str_split_exact"           
      [295] "str_splitn"                 "str_starts_with"           
      [297] "str_strip_chars"            "str_strip_chars_end"       
      [299] "str_strip_chars_start"      "str_tail"                  
      [301] "str_to_date"                "str_to_datetime"           
      [303] "str_to_integer"             "str_to_lowercase"          
      [305] "str_to_time"                "str_to_titlecase"          
      [307] "str_to_uppercase"           "str_zfill"                 
      [309] "struct_field_by_name"       "struct_rename_fields"      
      [311] "sub"                        "sum"                       
      [313] "tail"                       "tan"                       
      [315] "tanh"                       "timestamp"                 
      [317] "to_physical"                "top_k"                     
      [319] "unique"                     "unique_counts"             
      [321] "unique_stable"              "upper_bound"               
      [323] "value_counts"               "var"                       
      [325] "xor"                       

# public and private methods of each class When

    Code
      ls(.pr$env[[class_name]])
    Output
      [1] "then"

---

    Code
      ls(.pr[[private_key]])
    Output
      [1] "new"  "then"

# public and private methods of each class Then

    Code
      ls(.pr$env[[class_name]])
    Output
        [1] "abs"               "add"               "agg_groups"       
        [4] "alias"             "all"               "and"              
        [7] "any"               "append"            "approx_n_unique"  
       [10] "arccos"            "arccosh"           "arcsin"           
       [13] "arcsinh"           "arctan"            "arctanh"          
       [16] "arg_max"           "arg_min"           "arg_sort"         
       [19] "arg_unique"        "arr"               "backward_fill"    
       [22] "bin"               "bottom_k"          "cast"             
       [25] "cat"               "ceil"              "clip"             
       [28] "clip_max"          "clip_min"          "cos"              
       [31] "cosh"              "count"             "cum_count"        
       [34] "cum_max"           "cum_min"           "cum_prod"         
       [37] "cum_sum"           "cumulative_eval"   "cut"              
       [40] "diff"              "div"               "dot"              
       [43] "drop_nans"         "drop_nulls"        "dt"               
       [46] "entropy"           "eq"                "eq_missing"       
       [49] "ewm_mean"          "ewm_std"           "ewm_var"          
       [52] "exclude"           "exp"               "explode"          
       [55] "extend_constant"   "fill_nan"          "fill_null"        
       [58] "filter"            "first"             "flatten"          
       [61] "floor"             "floor_div"         "forward_fill"     
       [64] "gather"            "gather_every"      "gt"               
       [67] "gt_eq"             "hash"              "head"             
       [70] "implode"           "inspect"           "interpolate"      
       [73] "is_between"        "is_duplicated"     "is_finite"        
       [76] "is_first_distinct" "is_in"             "is_infinite"      
       [79] "is_last_distinct"  "is_nan"            "is_not_nan"       
       [82] "is_not_null"       "is_null"           "is_unique"        
       [85] "kurtosis"          "last"              "len"              
       [88] "limit"             "list"              "log"              
       [91] "log10"             "lower_bound"       "lt"               
       [94] "lt_eq"             "map_batches"       "map_elements"     
       [97] "max"               "mean"              "median"           
      [100] "meta"              "min"               "mod"              
      [103] "mode"              "mul"               "n_unique"         
      [106] "name"              "nan_max"           "nan_min"          
      [109] "neq"               "neq_missing"       "not"              
      [112] "null_count"        "or"                "otherwise"        
      [115] "over"              "pct_change"        "peak_max"         
      [118] "peak_min"          "pow"               "print"            
      [121] "product"           "qcut"              "quantile"         
      [124] "rank"              "rechunk"           "reinterpret"      
      [127] "rep"               "repeat_by"         "replace"          
      [130] "reshape"           "reverse"           "rle"              
      [133] "rle_id"            "rolling"           "rolling_max"      
      [136] "rolling_mean"      "rolling_median"    "rolling_min"      
      [139] "rolling_quantile"  "rolling_skew"      "rolling_std"      
      [142] "rolling_sum"       "rolling_var"       "round"            
      [145] "sample"            "search_sorted"     "set_sorted"       
      [148] "shift"             "shift_and_fill"    "shrink_dtype"     
      [151] "shuffle"           "sign"              "sin"              
      [154] "sinh"              "skew"              "slice"            
      [157] "sort"              "sort_by"           "sqrt"             
      [160] "std"               "str"               "struct"           
      [163] "sub"               "sum"               "tail"             
      [166] "tan"               "tanh"              "to_physical"      
      [169] "to_r"              "to_series"         "to_struct"        
      [172] "top_k"             "unique"            "unique_counts"    
      [175] "upper_bound"       "value_counts"      "var"              
      [178] "when"              "xor"              

---

    Code
      ls(.pr[[private_key]])
    Output
      [1] "otherwise" "when"     

# public and private methods of each class ChainedWhen

    Code
      ls(.pr$env[[class_name]])
    Output
      [1] "then"

---

    Code
      ls(.pr[[private_key]])
    Output
      [1] "then"

# public and private methods of each class ChainedThen

    Code
      ls(.pr$env[[class_name]])
    Output
        [1] "abs"               "add"               "agg_groups"       
        [4] "alias"             "all"               "and"              
        [7] "any"               "append"            "approx_n_unique"  
       [10] "arccos"            "arccosh"           "arcsin"           
       [13] "arcsinh"           "arctan"            "arctanh"          
       [16] "arg_max"           "arg_min"           "arg_sort"         
       [19] "arg_unique"        "arr"               "backward_fill"    
       [22] "bin"               "bottom_k"          "cast"             
       [25] "cat"               "ceil"              "clip"             
       [28] "clip_max"          "clip_min"          "cos"              
       [31] "cosh"              "count"             "cum_count"        
       [34] "cum_max"           "cum_min"           "cum_prod"         
       [37] "cum_sum"           "cumulative_eval"   "cut"              
       [40] "diff"              "div"               "dot"              
       [43] "drop_nans"         "drop_nulls"        "dt"               
       [46] "entropy"           "eq"                "eq_missing"       
       [49] "ewm_mean"          "ewm_std"           "ewm_var"          
       [52] "exclude"           "exp"               "explode"          
       [55] "extend_constant"   "fill_nan"          "fill_null"        
       [58] "filter"            "first"             "flatten"          
       [61] "floor"             "floor_div"         "forward_fill"     
       [64] "gather"            "gather_every"      "gt"               
       [67] "gt_eq"             "hash"              "head"             
       [70] "implode"           "inspect"           "interpolate"      
       [73] "is_between"        "is_duplicated"     "is_finite"        
       [76] "is_first_distinct" "is_in"             "is_infinite"      
       [79] "is_last_distinct"  "is_nan"            "is_not_nan"       
       [82] "is_not_null"       "is_null"           "is_unique"        
       [85] "kurtosis"          "last"              "len"              
       [88] "limit"             "list"              "log"              
       [91] "log10"             "lower_bound"       "lt"               
       [94] "lt_eq"             "map_batches"       "map_elements"     
       [97] "max"               "mean"              "median"           
      [100] "meta"              "min"               "mod"              
      [103] "mode"              "mul"               "n_unique"         
      [106] "name"              "nan_max"           "nan_min"          
      [109] "neq"               "neq_missing"       "not"              
      [112] "null_count"        "or"                "otherwise"        
      [115] "over"              "pct_change"        "peak_max"         
      [118] "peak_min"          "pow"               "print"            
      [121] "product"           "qcut"              "quantile"         
      [124] "rank"              "rechunk"           "reinterpret"      
      [127] "rep"               "repeat_by"         "replace"          
      [130] "reshape"           "reverse"           "rle"              
      [133] "rle_id"            "rolling"           "rolling_max"      
      [136] "rolling_mean"      "rolling_median"    "rolling_min"      
      [139] "rolling_quantile"  "rolling_skew"      "rolling_std"      
      [142] "rolling_sum"       "rolling_var"       "round"            
      [145] "sample"            "search_sorted"     "set_sorted"       
      [148] "shift"             "shift_and_fill"    "shrink_dtype"     
      [151] "shuffle"           "sign"              "sin"              
      [154] "sinh"              "skew"              "slice"            
      [157] "sort"              "sort_by"           "sqrt"             
      [160] "std"               "str"               "struct"           
      [163] "sub"               "sum"               "tail"             
      [166] "tan"               "tanh"              "to_physical"      
      [169] "to_r"              "to_series"         "to_struct"        
      [172] "top_k"             "unique"            "unique_counts"    
      [175] "upper_bound"       "value_counts"      "var"              
      [178] "when"              "xor"              

---

    Code
      ls(.pr[[private_key]])
    Output
      [1] "otherwise" "when"     

# public and private methods of each class RField

    Code
      ls(.pr$env[[class_name]])
    Output
      [1] "datatype" "name"     "print"   

---

    Code
      ls(.pr[[private_key]])
    Output
      [1] "clone"            "get_datatype"     "get_name"         "new"             
      [5] "print"            "set_datatype_mut" "set_name_mut"    

# public and private methods of each class RPolarsSeries

    Code
      ls(.pr$env[[class_name]])
    Output
        [1] "abs"               "add"               "alias"            
        [4] "all"               "and"               "any"              
        [7] "append"            "approx_n_unique"   "arccos"           
       [10] "arccosh"           "arcsin"            "arcsinh"          
       [13] "arctan"            "arctanh"           "arg_max"          
       [16] "arg_min"           "arg_sort"          "arg_unique"       
       [19] "arr"               "backward_fill"     "bin"              
       [22] "bottom_k"          "cast"              "cat"              
       [25] "ceil"              "chunk_lengths"     "clear"            
       [28] "clip"              "clip_max"          "clip_min"         
       [31] "clone"             "compare"           "cos"              
       [34] "cosh"              "count"             "cum_count"        
       [37] "cum_max"           "cum_min"           "cum_prod"         
       [40] "cum_sum"           "cumulative_eval"   "cut"              
       [43] "diff"              "div"               "dot"              
       [46] "drop_nans"         "drop_nulls"        "dt"               
       [49] "dtype"             "entropy"           "eq"               
       [52] "eq_missing"        "equals"            "ewm_mean"         
       [55] "ewm_std"           "ewm_var"           "exp"              
       [58] "explode"           "extend_constant"   "fill_nan"         
       [61] "fill_null"         "filter"            "first"            
       [64] "flags"             "flatten"           "floor"            
       [67] "floor_div"         "forward_fill"      "gather"           
       [70] "gather_every"      "gt"                "gt_eq"            
       [73] "hash"              "head"              "implode"          
       [76] "interpolate"       "is_between"        "is_duplicated"    
       [79] "is_finite"         "is_first_distinct" "is_in"            
       [82] "is_infinite"       "is_last_distinct"  "is_nan"           
       [85] "is_not_nan"        "is_not_null"       "is_null"          
       [88] "is_numeric"        "is_sorted"         "is_unique"        
       [91] "item"              "kurtosis"          "last"             
       [94] "len"               "limit"             "list"             
       [97] "log"               "log10"             "lower_bound"      
      [100] "lt"                "lt_eq"             "map_batches"      
      [103] "map_elements"      "max"               "mean"             
      [106] "median"            "min"               "mod"              
      [109] "mode"              "mul"               "n_chunks"         
      [112] "n_unique"          "name"              "nan_max"          
      [115] "nan_min"           "neq"               "neq_missing"      
      [118] "not"               "null_count"        "or"               
      [121] "pct_change"        "peak_max"          "peak_min"         
      [124] "pow"               "print"             "product"          
      [127] "qcut"              "quantile"          "rank"             
      [130] "rechunk"           "reinterpret"       "rename"           
      [133] "rep"               "repeat_by"         "replace"          
      [136] "reshape"           "reverse"           "rle"              
      [139] "rle_id"            "rolling_max"       "rolling_mean"     
      [142] "rolling_median"    "rolling_min"       "rolling_quantile" 
      [145] "rolling_skew"      "rolling_std"       "rolling_sum"      
      [148] "rolling_var"       "round"             "sample"           
      [151] "search_sorted"     "set_sorted"        "shape"            
      [154] "shift"             "shift_and_fill"    "shrink_dtype"     
      [157] "shuffle"           "sign"              "sin"              
      [160] "sinh"              "skew"              "slice"            
      [163] "sort"              "sort_by"           "sqrt"             
      [166] "std"               "str"               "struct"           
      [169] "sub"               "sum"               "tail"             
      [172] "tan"               "tanh"              "to_frame"         
      [175] "to_list"           "to_lit"            "to_physical"      
      [178] "to_r"              "to_struct"         "to_vector"        
      [181] "top_k"             "unique"            "unique_counts"    
      [184] "upper_bound"       "value_counts"      "var"              
      [187] "xor"              

---

    Code
      ls(.pr[[private_key]])
    Output
       [1] "add"                    "alias"                  "all"                   
       [4] "any"                    "append_mut"             "arg_max"               
       [7] "arg_min"                "chunk_lengths"          "clear"                 
      [10] "clone"                  "compare"                "div"                   
      [13] "dtype"                  "equals"                 "export_stream"         
      [16] "fast_explode_flag"      "from_arrow_array_robj"  "get_fmt"               
      [19] "import_stream"          "is_sorted"              "is_sorted_flag"        
      [22] "is_sorted_reverse_flag" "len"                    "map_elements"          
      [25] "max"                    "mean"                   "median"                
      [28] "min"                    "mul"                    "n_chunks"              
      [31] "n_unique"               "name"                   "new"                   
      [34] "panic"                  "print"                  "rem"                   
      [37] "rename_mut"             "rep"                    "set_sorted_mut"        
      [40] "shape"                  "sleep"                  "sort"                  
      [43] "std"                    "struct_fields"          "sub"                   
      [46] "sum"                    "to_fmt_char"            "to_frame"              
      [49] "to_r"                   "value_counts"           "var"                   

# public and private methods of each class RThreadHandle

    Code
      ls(.pr$env[[class_name]])
    Output
      [1] "is_finished" "join"       

---

    Code
      ls(.pr[[private_key]])
    Output
      [1] "is_finished"        "join"               "thread_description"

# public and private methods of each class RPolarsSQLContext

    Code
      ls(.pr$env[[class_name]])
    Output
      [1] "execute"          "register"         "register_globals" "register_many"   
      [5] "tables"           "unregister"      

---

    Code
      ls(.pr[[private_key]])
    Output
      [1] "execute"    "get_tables" "new"        "register"   "unregister"

