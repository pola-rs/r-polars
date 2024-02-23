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
      [33] "min"              "n_chunks"         "null_count"       "pivot"           
      [37] "print"            "quantile"         "rechunk"          "rename"          
      [41] "reverse"          "rolling"          "sample"           "schema"          
      [45] "select"           "shape"            "shift"            "shift_and_fill"  
      [49] "slice"            "sort"             "std"              "sum"             
      [53] "tail"             "to_data_frame"    "to_list"          "to_series"       
      [57] "to_struct"        "transpose"        "unique"           "unnest"          
      [61] "var"              "width"            "with_columns"     "with_row_count"  
      [65] "with_row_index"   "write_csv"        "write_json"       "write_ndjson"    
      [69] "write_parquet"   

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
      [19] "pivot_expr"                "print"                    
      [21] "rechunk"                   "sample_frac"              
      [23] "sample_n"                  "schema"                   
      [25] "select"                    "select_at_idx"            
      [27] "set_column_from_robj"      "set_column_from_series"   
      [29] "set_column_names_mut"      "shape"                    
      [31] "to_list"                   "to_list_tag_structs"      
      [33] "to_list_unwind"            "to_struct"                
      [35] "transpose"                 "unnest"                   
      [37] "with_columns"              "with_row_index"           
      [39] "write_csv"                 "write_json"               
      [41] "write_ndjson"              "write_parquet"            

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
      [21] "limit"                   "max"                    
      [23] "mean"                    "median"                 
      [25] "melt"                    "min"                    
      [27] "print"                   "profile"                
      [29] "quantile"                "rename"                 
      [31] "reverse"                 "rolling"                
      [33] "schema"                  "select"                 
      [35] "select_str_as_lit"       "set_optimization_toggle"
      [37] "shift"                   "shift_and_fill"         
      [39] "sink_csv"                "sink_ipc"               
      [41] "sink_json"               "sink_parquet"           
      [43] "slice"                   "sort_by_exprs"          
      [45] "std"                     "sum"                    
      [47] "tail"                    "unique"                 
      [49] "unnest"                  "var"                    
      [51] "with_columns"            "with_context"           
      [53] "with_row_index"         

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
       [88] "limit"             "list"              "lit"              
       [91] "log"               "log10"             "lower_bound"      
       [94] "lt"                "lt_eq"             "map_batches"      
       [97] "map_elements"      "max"               "mean"             
      [100] "median"            "meta"              "min"              
      [103] "mod"               "mode"              "mul"              
      [106] "n_unique"          "name"              "nan_max"          
      [109] "nan_min"           "neq"               "neq_missing"      
      [112] "not"               "null_count"        "or"               
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
      [178] "xor"              

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
       [29] "arr_min"                    "arr_reverse"               
       [31] "arr_sort"                   "arr_sum"                   
       [33] "arr_to_list"                "arr_unique"                
       [35] "backward_fill"              "bin_contains"              
       [37] "bin_decode_base64"          "bin_decode_hex"            
       [39] "bin_encode_base64"          "bin_encode_hex"            
       [41] "bin_ends_with"              "bin_starts_with"           
       [43] "bottom_k"                   "cast"                      
       [45] "cat_get_categories"         "cat_set_ordering"          
       [47] "ceil"                       "clip"                      
       [49] "clip_max"                   "clip_min"                  
       [51] "col"                        "cols"                      
       [53] "corr"                       "cos"                       
       [55] "cosh"                       "count"                     
       [57] "cov"                        "cum_count"                 
       [59] "cum_max"                    "cum_min"                   
       [61] "cum_prod"                   "cum_sum"                   
       [63] "cumulative_eval"            "diff"                      
       [65] "div"                        "dot"                       
       [67] "drop_nans"                  "drop_nulls"                
       [69] "dt_cast_time_unit"          "dt_combine"                
       [71] "dt_convert_time_zone"       "dt_day"                    
       [73] "dt_epoch_seconds"           "dt_hour"                   
       [75] "dt_iso_year"                "dt_microsecond"            
       [77] "dt_millisecond"             "dt_minute"                 
       [79] "dt_month"                   "dt_nanosecond"             
       [81] "dt_offset_by"               "dt_ordinal_day"            
       [83] "dt_quarter"                 "dt_replace_time_zone"      
       [85] "dt_round"                   "dt_second"                 
       [87] "dt_strftime"                "dt_time"                   
       [89] "dt_total_days"              "dt_total_hours"            
       [91] "dt_total_microseconds"      "dt_total_milliseconds"     
       [93] "dt_total_minutes"           "dt_total_nanoseconds"      
       [95] "dt_total_seconds"           "dt_truncate"               
       [97] "dt_week"                    "dt_weekday"                
       [99] "dt_with_time_unit"          "dt_year"                   
      [101] "dtype_cols"                 "entropy"                   
      [103] "eq"                         "eq_missing"                
      [105] "ewm_mean"                   "ewm_std"                   
      [107] "ewm_var"                    "exclude"                   
      [109] "exclude_dtype"              "exp"                       
      [111] "explode"                    "extend_constant"           
      [113] "fill_nan"                   "fill_null"                 
      [115] "fill_null_with_strategy"    "filter"                    
      [117] "first"                      "flatten"                   
      [119] "floor"                      "floor_div"                 
      [121] "forward_fill"               "gather"                    
      [123] "gather_every"               "gt"                        
      [125] "gt_eq"                      "hash"                      
      [127] "head"                       "implode"                   
      [129] "interpolate"                "is_between"                
      [131] "is_duplicated"              "is_finite"                 
      [133] "is_first_distinct"          "is_in"                     
      [135] "is_infinite"                "is_last_distinct"          
      [137] "is_nan"                     "is_not_nan"                
      [139] "is_not_null"                "is_null"                   
      [141] "is_unique"                  "kurtosis"                  
      [143] "last"                       "len"                       
      [145] "list_all"                   "list_any"                  
      [147] "list_arg_max"               "list_arg_min"              
      [149] "list_contains"              "list_diff"                 
      [151] "list_eval"                  "list_gather"               
      [153] "list_get"                   "list_join"                 
      [155] "list_len"                   "list_max"                  
      [157] "list_mean"                  "list_min"                  
      [159] "list_reverse"               "list_set_operation"        
      [161] "list_shift"                 "list_slice"                
      [163] "list_sort"                  "list_sum"                  
      [165] "list_to_struct"             "list_unique"               
      [167] "lit"                        "log"                       
      [169] "log10"                      "lower_bound"               
      [171] "lt"                         "lt_eq"                     
      [173] "map_batches"                "map_batches_in_background" 
      [175] "map_elements_in_background" "max"                       
      [177] "mean"                       "median"                    
      [179] "meta_eq"                    "meta_has_multiple_outputs" 
      [181] "meta_is_regex_projection"   "meta_output_name"          
      [183] "meta_pop"                   "meta_roots"                
      [185] "meta_tree_format"           "meta_undo_aliases"         
      [187] "min"                        "mode"                      
      [189] "mul"                        "n_unique"                  
      [191] "name_keep"                  "name_map"                  
      [193] "name_prefix"                "name_suffix"               
      [195] "name_to_lowercase"          "name_to_uppercase"         
      [197] "nan_max"                    "nan_min"                   
      [199] "neq"                        "neq_missing"               
      [201] "new_first"                  "new_last"                  
      [203] "new_len"                    "not"                       
      [205] "null_count"                 "or"                        
      [207] "over"                       "pct_change"                
      [209] "peak_max"                   "peak_min"                  
      [211] "pow"                        "print"                     
      [213] "product"                    "quantile"                  
      [215] "rank"                       "rechunk"                   
      [217] "reinterpret"                "rem"                       
      [219] "rep"                        "repeat_by"                 
      [221] "replace"                    "reshape"                   
      [223] "reverse"                    "rle"                       
      [225] "rle_id"                     "rolling"                   
      [227] "rolling_corr"               "rolling_cov"               
      [229] "rolling_max"                "rolling_mean"              
      [231] "rolling_median"             "rolling_min"               
      [233] "rolling_quantile"           "rolling_skew"              
      [235] "rolling_std"                "rolling_sum"               
      [237] "rolling_var"                "round"                     
      [239] "sample_frac"                "sample_n"                  
      [241] "search_sorted"              "shift"                     
      [243] "shift_and_fill"             "shrink_dtype"              
      [245] "shuffle"                    "sign"                      
      [247] "sin"                        "sinh"                      
      [249] "skew"                       "slice"                     
      [251] "sort"                       "sort_by"                   
      [253] "std"                        "str_base64_decode"         
      [255] "str_base64_encode"          "str_concat"                
      [257] "str_contains"               "str_contains_any"          
      [259] "str_count_matches"          "str_ends_with"             
      [261] "str_explode"                "str_extract"               
      [263] "str_extract_all"            "str_hex_decode"            
      [265] "str_hex_encode"             "str_json_decode"           
      [267] "str_json_path_match"        "str_len_bytes"             
      [269] "str_len_chars"              "str_pad_end"               
      [271] "str_pad_start"              "str_parse_int"             
      [273] "str_replace"                "str_replace_all"           
      [275] "str_replace_many"           "str_reverse"               
      [277] "str_slice"                  "str_split"                 
      [279] "str_split_exact"            "str_splitn"                
      [281] "str_starts_with"            "str_strip_chars"           
      [283] "str_strip_chars_end"        "str_strip_chars_start"     
      [285] "str_to_date"                "str_to_datetime"           
      [287] "str_to_lowercase"           "str_to_time"               
      [289] "str_to_titlecase"           "str_to_uppercase"          
      [291] "str_zfill"                  "struct_field_by_name"      
      [293] "struct_rename_fields"       "sub"                       
      [295] "sum"                        "tail"                      
      [297] "tan"                        "tanh"                      
      [299] "timestamp"                  "to_physical"               
      [301] "top_k"                      "unique"                    
      [303] "unique_counts"              "unique_stable"             
      [305] "upper_bound"                "value_counts"              
      [307] "var"                        "xor"                       

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
      [1] "otherwise" "when"     

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
      [1] "otherwise" "when"     

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
       [97] "lit"               "log"               "log10"            
      [100] "lower_bound"       "lt"                "lt_eq"            
      [103] "map_batches"       "map_elements"      "max"              
      [106] "mean"              "median"            "min"              
      [109] "mod"               "mode"              "mul"              
      [112] "n_unique"          "name"              "nan_max"          
      [115] "nan_min"           "neq"               "neq_missing"      
      [118] "not"               "null_count"        "or"               
      [121] "over"              "pct_change"        "peak_max"         
      [124] "peak_min"          "pow"               "print"            
      [127] "product"           "quantile"          "rank"             
      [130] "rechunk"           "reinterpret"       "rem"              
      [133] "rename"            "rep"               "rep_extend"       
      [136] "repeat_by"         "replace"           "reshape"          
      [139] "reverse"           "rle"               "rle_id"           
      [142] "rolling"           "rolling_max"       "rolling_mean"     
      [145] "rolling_median"    "rolling_min"       "rolling_quantile" 
      [148] "rolling_skew"      "rolling_std"       "rolling_sum"      
      [151] "rolling_var"       "round"             "sample"           
      [154] "search_sorted"     "set_sorted"        "shape"            
      [157] "shift"             "shift_and_fill"    "shrink_dtype"     
      [160] "shuffle"           "sign"              "sin"              
      [163] "sinh"              "skew"              "slice"            
      [166] "sort"              "sort_by"           "sqrt"             
      [169] "std"               "str"               "struct"           
      [172] "sub"               "sum"               "tail"             
      [175] "tan"               "tanh"              "to_frame"         
      [178] "to_lit"            "to_physical"       "to_r"             
      [181] "to_r_list"         "to_r_vector"       "to_struct"        
      [184] "to_vector"         "top_k"             "unique"           
      [187] "unique_counts"     "upper_bound"       "value_counts"     
      [190] "var"               "xor"              

---

    Code
      ls(.pr[[private_key]])
    Output
       [1] "abs"                         "add"                        
       [3] "alias"                       "all"                        
       [5] "any"                         "append_mut"                 
       [7] "arg_max"                     "arg_min"                    
       [9] "ceil"                        "chunk_lengths"              
      [11] "clone"                       "compare"                    
      [13] "cum_sum"                     "div"                        
      [15] "dtype"                       "equals"                     
      [17] "fast_explode_flag"           "floor"                      
      [19] "from_arrow_array_robj"       "from_arrow_array_stream_str"
      [21] "get_fmt"                     "is_sorted"                  
      [23] "is_sorted_flag"              "is_sorted_reverse_flag"     
      [25] "len"                         "map_elements"               
      [27] "max"                         "mean"                       
      [29] "median"                      "min"                        
      [31] "mul"                         "n_unique"                   
      [33] "name"                        "new"                        
      [35] "panic"                       "print"                      
      [37] "rem"                         "rename_mut"                 
      [39] "rep"                         "set_sorted_mut"             
      [41] "shape"                       "sleep"                      
      [43] "sort_mut"                    "std"                        
      [45] "sub"                         "sum"                        
      [47] "to_fmt_char"                 "to_frame"                   
      [49] "to_r"                        "value_counts"               
      [51] "var"                        

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

