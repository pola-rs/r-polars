# public and private functions in pl and .pr

    Code
      ls(pl)
    Output
       [1] "Array"                     "Binary"                   
       [3] "Boolean"                   "Categorical"              
       [5] "DataFrame"                 "Date"                     
       [7] "Datetime"                  "Field"                    
       [9] "Float32"                   "Float64"                  
      [11] "Int16"                     "Int32"                    
      [13] "Int64"                     "Int8"                     
      [15] "LazyFrame"                 "List"                     
      [17] "Null"                      "PTime"                    
      [19] "SQLContext"                "Series"                   
      [21] "String"                    "Struct"                   
      [23] "Time"                      "UInt16"                   
      [25] "UInt32"                    "UInt64"                   
      [27] "UInt8"                     "Unknown"                  
      [29] "Utf8"                      "all"                      
      [31] "all_horizontal"            "any_horizontal"           
      [33] "approx_n_unique"           "class_names"              
      [35] "coalesce"                  "col"                      
      [37] "concat"                    "concat_list"              
      [39] "concat_str"                "corr"                     
      [41] "count"                     "cov"                      
      [43] "date_range"                "disable_string_cache"     
      [45] "dtypes"                    "duration"                 
      [47] "element"                   "enable_string_cache"      
      [49] "expr_to_r"                 "first"                    
      [51] "fold"                      "from_epoch"               
      [53] "get_global_rpool_cap"      "head"                     
      [55] "implode"                   "is_schema"                
      [57] "last"                      "len"                      
      [59] "lit"                       "max"                      
      [61] "max_horizontal"            "mean"                     
      [63] "median"                    "mem_address"              
      [65] "min"                       "min_horizontal"           
      [67] "n_unique"                  "numeric_dtypes"           
      [69] "raw_list"                  "read_csv"                 
      [71] "read_ndjson"               "read_parquet"             
      [73] "reduce"                    "rolling_corr"             
      [75] "rolling_cov"               "same_outer_dt"            
      [77] "scan_csv"                  "scan_ipc"                 
      [79] "scan_ndjson"               "scan_parquet"             
      [81] "select"                    "set_global_rpool_cap"     
      [83] "show_all_public_functions" "show_all_public_methods"  
      [85] "std"                       "struct"                   
      [87] "sum"                       "sum_horizontal"           
      [89] "tail"                      "thread_pool_size"         
      [91] "threadpool_size"           "using_string_cache"       
      [93] "var"                       "when"                     
      [95] "with_string_cache"        

---

    Code
      ls(.pr)
    Output
       [1] "ChainedThen"       "ChainedWhen"       "DataFrame"        
       [4] "DataType"          "DataTypeVector"    "Err"              
       [7] "Expr"              "GroupBy"           "LazyFrame"        
      [10] "LazyGroupBy"       "ProtoExprArray"    "RField"           
      [13] "RNullValues"       "RThreadHandle"     "SQLContext"       
      [16] "Series"            "StringCacheHolder" "Then"             
      [19] "VecDataFrame"      "When"              "env"              
      [22] "print_env"        

# public and private methods of each class DataFrame

    Code
      ls(.pr$env[[class_name]])
    Output
       [1] "clone"            "columns"          "describe"         "drop"            
       [5] "drop_in_place"    "drop_nulls"       "dtype_strings"    "dtypes"          
       [9] "equals"           "estimated_size"   "explode"          "fill_nan"        
      [13] "fill_null"        "filter"           "first"            "flags"           
      [17] "get_column"       "get_columns"      "glimpse"          "group_by"        
      [21] "group_by_dynamic" "head"             "height"           "join"            
      [25] "join_asof"        "last"             "lazy"             "limit"           
      [29] "max"              "mean"             "median"           "melt"            
      [33] "min"              "n_chunks"         "null_count"       "partition_by"    
      [37] "pivot"            "print"            "quantile"         "rechunk"         
      [41] "rename"           "reverse"          "rolling"          "sample"          
      [45] "schema"           "select"           "shape"            "shift"           
      [49] "shift_and_fill"   "slice"            "sort"             "std"             
      [53] "sum"              "tail"             "to_data_frame"    "to_list"         
      [57] "to_series"        "to_struct"        "transpose"        "unique"          
      [61] "unnest"           "var"              "width"            "with_columns"    
      [65] "with_row_count"   "with_row_index"   "write_csv"        "write_json"      
      [69] "write_ndjson"     "write_parquet"   

---

    Code
      ls(.pr[[private_key]])
    Output
       [1] "clone_in_rust"             "columns"                  
       [3] "default"                   "drop_all_in_place"        
       [5] "drop_in_place"             "dtype_strings"            
       [7] "dtypes"                    "equals"                   
       [9] "estimated_size"            "export_stream"            
      [11] "from_arrow_record_batches" "get_column"               
      [13] "get_columns"               "lazy"                     
      [15] "melt"                      "n_chunks"                 
      [17] "new_with_capacity"         "null_count"               
      [19] "partition_by"              "pivot_expr"               
      [21] "print"                     "rechunk"                  
      [23] "sample_frac"               "sample_n"                 
      [25] "schema"                    "select"                   
      [27] "select_at_idx"             "set_column_from_robj"     
      [29] "set_column_from_series"    "set_column_names_mut"     
      [31] "shape"                     "to_list"                  
      [33] "to_list_tag_structs"       "to_list_unwind"           
      [35] "to_struct"                 "transpose"                
      [37] "unnest"                    "with_columns"             
      [39] "with_row_index"            "write_csv"                
      [41] "write_json"                "write_ndjson"             
      [43] "write_parquet"            

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
       [1] "clone"                   "collect"                
       [3] "collect_in_background"   "columns"                
       [5] "describe_optimized_plan" "describe_plan"          
       [7] "drop"                    "drop_nulls"             
       [9] "dtypes"                  "explode"                
      [11] "fetch"                   "fill_nan"               
      [13] "fill_null"               "filter"                 
      [15] "first"                   "get_optimization_toggle"
      [17] "group_by"                "group_by_dynamic"       
      [19] "head"                    "join"                   
      [21] "join_asof"               "last"                   
      [23] "limit"                   "max"                    
      [25] "mean"                    "median"                 
      [27] "melt"                    "min"                    
      [29] "print"                   "profile"                
      [31] "quantile"                "rename"                 
      [33] "reverse"                 "rolling"                
      [35] "schema"                  "select"                 
      [37] "set_optimization_toggle" "shift"                  
      [39] "shift_and_fill"          "sink_csv"               
      [41] "sink_ipc"                "sink_ndjson"            
      [43] "sink_parquet"            "slice"                  
      [45] "sort"                    "std"                    
      [47] "sum"                     "tail"                   
      [49] "unique"                  "unnest"                 
      [51] "var"                     "width"                  
      [53] "with_columns"            "with_context"           
      [55] "with_row_count"          "with_row_index"         

---

    Code
      ls(.pr[[private_key]])
    Output
       [1] "clone_in_rust"           "collect"                
       [3] "collect_in_background"   "debug_plan"             
       [5] "describe_optimized_plan" "describe_plan"          
       [7] "drop"                    "drop_nulls"             
       [9] "explode"                 "fetch"                  
      [11] "fill_nan"                "fill_null"              
      [13] "filter"                  "first"                  
      [15] "get_optimization_toggle" "group_by"               
      [17] "group_by_dynamic"        "join"                   
      [19] "join_asof"               "last"                   
      [21] "max"                     "mean"                   
      [23] "median"                  "melt"                   
      [25] "min"                     "print"                  
      [27] "profile"                 "quantile"               
      [29] "rename"                  "reverse"                
      [31] "rolling"                 "schema"                 
      [33] "select"                  "select_str_as_lit"      
      [35] "set_optimization_toggle" "shift"                  
      [37] "shift_and_fill"          "sink_csv"               
      [39] "sink_ipc"                "sink_json"              
      [41] "sink_parquet"            "slice"                  
      [43] "sort_by_exprs"           "std"                    
      [45] "sum"                     "tail"                   
      [47] "unique"                  "unnest"                 
      [49] "var"                     "with_columns"           
      [51] "with_context"            "with_row_index"         

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
       [19] "arg_unique"        "argsort"           "arr"              
       [22] "backward_fill"     "bin"               "bottom_k"         
       [25] "cast"              "cat"               "ceil"             
       [28] "clip"              "clip_max"          "clip_min"         
       [31] "cos"               "cosh"              "count"            
       [34] "cum_count"         "cum_max"           "cum_min"          
       [37] "cum_prod"          "cum_sum"           "cumulative_eval"  
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
      [121] "quantile"          "rank"              "rechunk"          
      [124] "reinterpret"       "rep"               "rep_extend"       
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
       [41] "bin_contains"               "bin_decode_base64"         
       [43] "bin_decode_hex"             "bin_encode_base64"         
       [45] "bin_encode_hex"             "bin_ends_with"             
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
       [69] "diff"                       "div"                       
       [71] "dot"                        "drop_nans"                 
       [73] "drop_nulls"                 "dt_cast_time_unit"         
       [75] "dt_combine"                 "dt_convert_time_zone"      
       [77] "dt_day"                     "dt_epoch_seconds"          
       [79] "dt_hour"                    "dt_iso_year"               
       [81] "dt_microsecond"             "dt_millisecond"            
       [83] "dt_minute"                  "dt_month"                  
       [85] "dt_nanosecond"              "dt_offset_by"              
       [87] "dt_ordinal_day"             "dt_quarter"                
       [89] "dt_replace_time_zone"       "dt_round"                  
       [91] "dt_second"                  "dt_strftime"               
       [93] "dt_time"                    "dt_total_days"             
       [95] "dt_total_hours"             "dt_total_microseconds"     
       [97] "dt_total_milliseconds"      "dt_total_minutes"          
       [99] "dt_total_nanoseconds"       "dt_total_seconds"          
      [101] "dt_truncate"                "dt_week"                   
      [103] "dt_weekday"                 "dt_with_time_unit"         
      [105] "dt_year"                    "dtype_cols"                
      [107] "entropy"                    "eq"                        
      [109] "eq_missing"                 "ewm_mean"                  
      [111] "ewm_std"                    "ewm_var"                   
      [113] "exclude"                    "exclude_dtype"             
      [115] "exp"                        "explode"                   
      [117] "extend_constant"            "fill_nan"                  
      [119] "fill_null"                  "fill_null_with_strategy"   
      [121] "filter"                     "first"                     
      [123] "flatten"                    "floor"                     
      [125] "floor_div"                  "forward_fill"              
      [127] "gather"                     "gather_every"              
      [129] "gt"                         "gt_eq"                     
      [131] "hash"                       "head"                      
      [133] "implode"                    "interpolate"               
      [135] "is_between"                 "is_duplicated"             
      [137] "is_finite"                  "is_first_distinct"         
      [139] "is_in"                      "is_infinite"               
      [141] "is_last_distinct"           "is_nan"                    
      [143] "is_not_nan"                 "is_not_null"               
      [145] "is_null"                    "is_unique"                 
      [147] "kurtosis"                   "last"                      
      [149] "len"                        "list_all"                  
      [151] "list_any"                   "list_arg_max"              
      [153] "list_arg_min"               "list_contains"             
      [155] "list_diff"                  "list_eval"                 
      [157] "list_gather"                "list_gather_every"         
      [159] "list_get"                   "list_join"                 
      [161] "list_len"                   "list_max"                  
      [163] "list_mean"                  "list_min"                  
      [165] "list_n_unique"              "list_reverse"              
      [167] "list_set_operation"         "list_shift"                
      [169] "list_slice"                 "list_sort"                 
      [171] "list_sum"                   "list_to_struct"            
      [173] "list_unique"                "lit"                       
      [175] "log"                        "log10"                     
      [177] "lower_bound"                "lt"                        
      [179] "lt_eq"                      "map_batches"               
      [181] "map_batches_in_background"  "map_elements_in_background"
      [183] "max"                        "mean"                      
      [185] "median"                     "meta_eq"                   
      [187] "meta_has_multiple_outputs"  "meta_is_regex_projection"  
      [189] "meta_output_name"           "meta_pop"                  
      [191] "meta_roots"                 "meta_tree_format"          
      [193] "meta_undo_aliases"          "min"                       
      [195] "mode"                       "mul"                       
      [197] "n_unique"                   "name_keep"                 
      [199] "name_map"                   "name_prefix"               
      [201] "name_prefix_fields"         "name_suffix"               
      [203] "name_suffix_fields"         "name_to_lowercase"         
      [205] "name_to_uppercase"          "nan_max"                   
      [207] "nan_min"                    "neq"                       
      [209] "neq_missing"                "new_first"                 
      [211] "new_last"                   "new_len"                   
      [213] "not"                        "null_count"                
      [215] "or"                         "over"                      
      [217] "pct_change"                 "peak_max"                  
      [219] "peak_min"                   "pow"                       
      [221] "print"                      "product"                   
      [223] "quantile"                   "rank"                      
      [225] "rechunk"                    "reinterpret"               
      [227] "rem"                        "rep"                       
      [229] "repeat_by"                  "replace"                   
      [231] "reshape"                    "reverse"                   
      [233] "rle"                        "rle_id"                    
      [235] "rolling"                    "rolling_corr"              
      [237] "rolling_cov"                "rolling_max"               
      [239] "rolling_mean"               "rolling_median"            
      [241] "rolling_min"                "rolling_quantile"          
      [243] "rolling_skew"               "rolling_std"               
      [245] "rolling_sum"                "rolling_var"               
      [247] "round"                      "sample_frac"               
      [249] "sample_n"                   "search_sorted"             
      [251] "shift"                      "shift_and_fill"            
      [253] "shrink_dtype"               "shuffle"                   
      [255] "sign"                       "sin"                       
      [257] "sinh"                       "skew"                      
      [259] "slice"                      "sort"                      
      [261] "sort_by"                    "std"                       
      [263] "str_base64_decode"          "str_base64_encode"         
      [265] "str_concat"                 "str_contains"              
      [267] "str_contains_any"           "str_count_matches"         
      [269] "str_ends_with"              "str_explode"               
      [271] "str_extract"                "str_extract_all"           
      [273] "str_hex_decode"             "str_hex_encode"            
      [275] "str_json_decode"            "str_json_path_match"       
      [277] "str_len_bytes"              "str_len_chars"             
      [279] "str_pad_end"                "str_pad_start"             
      [281] "str_parse_int"              "str_replace"               
      [283] "str_replace_all"            "str_replace_many"          
      [285] "str_reverse"                "str_slice"                 
      [287] "str_split"                  "str_split_exact"           
      [289] "str_splitn"                 "str_starts_with"           
      [291] "str_strip_chars"            "str_strip_chars_end"       
      [293] "str_strip_chars_start"      "str_to_date"               
      [295] "str_to_datetime"            "str_to_lowercase"          
      [297] "str_to_time"                "str_to_titlecase"          
      [299] "str_to_uppercase"           "str_zfill"                 
      [301] "struct_field_by_name"       "struct_rename_fields"      
      [303] "sub"                        "sum"                       
      [305] "tail"                       "tan"                       
      [307] "tanh"                       "timestamp"                 
      [309] "to_physical"                "top_k"                     
      [311] "unique"                     "unique_counts"             
      [313] "unique_stable"              "upper_bound"               
      [315] "value_counts"               "var"                       
      [317] "xor"                       

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
       [19] "arg_unique"        "argsort"           "arr"              
       [22] "backward_fill"     "bin"               "bottom_k"         
       [25] "cast"              "cat"               "ceil"             
       [28] "clip"              "clip_max"          "clip_min"         
       [31] "cos"               "cosh"              "count"            
       [34] "cum_count"         "cum_max"           "cum_min"          
       [37] "cum_prod"          "cum_sum"           "cumulative_eval"  
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
      [121] "product"           "quantile"          "rank"             
      [124] "rechunk"           "reinterpret"       "rep"              
      [127] "rep_extend"        "repeat_by"         "replace"          
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
       [19] "arg_unique"        "argsort"           "arr"              
       [22] "backward_fill"     "bin"               "bottom_k"         
       [25] "cast"              "cat"               "ceil"             
       [28] "clip"              "clip_max"          "clip_min"         
       [31] "cos"               "cosh"              "count"            
       [34] "cum_count"         "cum_max"           "cum_min"          
       [37] "cum_prod"          "cum_sum"           "cumulative_eval"  
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
      [121] "product"           "quantile"          "rank"             
      [124] "rechunk"           "reinterpret"       "rep"              
      [127] "rep_extend"        "repeat_by"         "replace"          
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
       [19] "argsort"           "arr"               "backward_fill"    
       [22] "bin"               "bottom_k"          "cast"             
       [25] "cat"               "ceil"              "chunk_lengths"    
       [28] "clip"              "clip_max"          "clip_min"         
       [31] "clone"             "compare"           "cos"              
       [34] "cosh"              "count"             "cum_count"        
       [37] "cum_max"           "cum_min"           "cum_prod"         
       [40] "cum_sum"           "cumulative_eval"   "diff"             
       [43] "div"               "dot"               "drop_nans"        
       [46] "drop_nulls"        "dt"                "dtype"            
       [49] "entropy"           "eq"                "eq_missing"       
       [52] "equals"            "ewm_mean"          "ewm_std"          
       [55] "ewm_var"           "exclude"           "exp"              
       [58] "explode"           "extend_constant"   "fill_nan"         
       [61] "fill_null"         "filter"            "first"            
       [64] "flags"             "flatten"           "floor"            
       [67] "floor_div"         "forward_fill"      "gather"           
       [70] "gather_every"      "gt"                "gt_eq"            
       [73] "hash"              "head"              "implode"          
       [76] "inspect"           "interpolate"       "is_between"       
       [79] "is_duplicated"     "is_finite"         "is_first_distinct"
       [82] "is_in"             "is_infinite"       "is_last_distinct" 
       [85] "is_nan"            "is_not_nan"        "is_not_null"      
       [88] "is_null"           "is_numeric"        "is_sorted"        
       [91] "is_unique"         "kurtosis"          "last"             
       [94] "len"               "limit"             "list"             
       [97] "log"               "log10"             "lower_bound"      
      [100] "lt"                "lt_eq"             "map_batches"      
      [103] "map_elements"      "max"               "mean"             
      [106] "median"            "min"               "mod"              
      [109] "mode"              "mul"               "n_unique"         
      [112] "name"              "nan_max"           "nan_min"          
      [115] "neq"               "neq_missing"       "not"              
      [118] "null_count"        "or"                "over"             
      [121] "pct_change"        "peak_max"          "peak_min"         
      [124] "pow"               "print"             "product"          
      [127] "quantile"          "rank"              "rechunk"          
      [130] "reinterpret"       "rename"            "rep"              
      [133] "rep_extend"        "repeat_by"         "replace"          
      [136] "reshape"           "reverse"           "rle"              
      [139] "rle_id"            "rolling"           "rolling_max"      
      [142] "rolling_mean"      "rolling_median"    "rolling_min"      
      [145] "rolling_quantile"  "rolling_skew"      "rolling_std"      
      [148] "rolling_sum"       "rolling_var"       "round"            
      [151] "sample"            "search_sorted"     "set_sorted"       
      [154] "shape"             "shift"             "shift_and_fill"   
      [157] "shrink_dtype"      "shuffle"           "sign"             
      [160] "sin"               "sinh"              "skew"             
      [163] "slice"             "sort"              "sort_by"          
      [166] "sqrt"              "std"               "str"              
      [169] "struct"            "sub"               "sum"              
      [172] "tail"              "tan"               "tanh"             
      [175] "to_frame"          "to_lit"            "to_physical"      
      [178] "to_r"              "to_r_list"         "to_r_vector"      
      [181] "to_struct"         "to_vector"         "top_k"            
      [184] "unique"            "unique_counts"     "upper_bound"      
      [187] "value_counts"      "var"               "xor"              

---

    Code
      ls(.pr[[private_key]])
    Output
       [1] "add"                         "alias"                      
       [3] "all"                         "any"                        
       [5] "append_mut"                  "arg_max"                    
       [7] "arg_min"                     "chunk_lengths"              
       [9] "clone"                       "compare"                    
      [11] "div"                         "dtype"                      
      [13] "equals"                      "fast_explode_flag"          
      [15] "from_arrow_array_robj"       "from_arrow_array_stream_str"
      [17] "get_fmt"                     "is_sorted"                  
      [19] "is_sorted_flag"              "is_sorted_reverse_flag"     
      [21] "len"                         "map_elements"               
      [23] "max"                         "mean"                       
      [25] "median"                      "min"                        
      [27] "mul"                         "n_unique"                   
      [29] "name"                        "new"                        
      [31] "panic"                       "print"                      
      [33] "rem"                         "rename_mut"                 
      [35] "rep"                         "set_sorted_mut"             
      [37] "shape"                       "sleep"                      
      [39] "sort_mut"                    "std"                        
      [41] "sub"                         "sum"                        
      [43] "to_fmt_char"                 "to_frame"                   
      [45] "to_r"                        "value_counts"               
      [47] "var"                        

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
      [1] "execute"       "register"      "register_many" "tables"       
      [5] "unregister"   

---

    Code
      ls(.pr[[private_key]])
    Output
      [1] "execute"    "get_tables" "new"        "register"   "unregister"

