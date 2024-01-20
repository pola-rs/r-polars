# public and private functions in pl and .pr

    Code
      ls(pl)
    Output
       [1] "Binary"                    "Boolean"                  
       [3] "Categorical"               "DataFrame"                
       [5] "Date"                      "Datetime"                 
       [7] "Field"                     "Float32"                  
       [9] "Float64"                   "Int16"                    
      [11] "Int32"                     "Int64"                    
      [13] "Int8"                      "LazyFrame"                
      [15] "List"                      "Null"                     
      [17] "PTime"                     "SQLContext"               
      [19] "Series"                    "String"                   
      [21] "Struct"                    "Time"                     
      [23] "UInt16"                    "UInt32"                   
      [25] "UInt64"                    "UInt8"                    
      [27] "Unknown"                   "Utf8"                     
      [29] "all"                       "all_horizontal"           
      [31] "any_horizontal"            "approx_n_unique"          
      [33] "class_names"               "coalesce"                 
      [35] "col"                       "concat"                   
      [37] "concat_list"               "concat_str"               
      [39] "corr"                      "count"                    
      [41] "cov"                       "date_range"               
      [43] "disable_string_cache"      "dtypes"                   
      [45] "duration"                  "element"                  
      [47] "enable_string_cache"       "expr_to_r"                
      [49] "extra_auto_completion"     "first"                    
      [51] "fold"                      "from_arrow"               
      [53] "from_epoch"                "get_global_rpool_cap"     
      [55] "head"                      "implode"                  
      [57] "is_schema"                 "last"                     
      [59] "lit"                       "max"                      
      [61] "max_horizontal"            "mean"                     
      [63] "median"                    "mem_address"              
      [65] "min"                       "min_horizontal"           
      [67] "n_unique"                  "numeric_dtypes"           
      [69] "options"                   "raw_list"                 
      [71] "read_csv"                  "read_ndjson"              
      [73] "read_parquet"              "reduce"                   
      [75] "reset_options"             "rolling_corr"             
      [77] "rolling_cov"               "same_outer_dt"            
      [79] "scan_csv"                  "scan_ipc"                 
      [81] "scan_ndjson"               "scan_parquet"             
      [83] "select"                    "set_global_rpool_cap"     
      [85] "set_options"               "show_all_public_functions"
      [87] "show_all_public_methods"   "std"                      
      [89] "struct"                    "sum"                      
      [91] "sum_horizontal"            "tail"                     
      [93] "threadpool_size"           "using_string_cache"       
      [95] "var"                       "when"                     
      [97] "with_string_cache"        

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
      [13] "fill_null"        "filter"           "first"            "get_column"      
      [17] "get_columns"      "glimpse"          "group_by"         "group_by_dynamic"
      [21] "head"             "height"           "join"             "join_asof"       
      [25] "last"             "lazy"             "limit"            "max"             
      [29] "mean"             "median"           "melt"             "min"             
      [33] "n_chunks"         "null_count"       "pivot"            "print"           
      [37] "quantile"         "rechunk"          "rename"           "reverse"         
      [41] "rolling"          "sample"           "schema"           "select"          
      [45] "shape"            "shift"            "shift_and_fill"   "slice"           
      [49] "sort"             "std"              "sum"              "tail"            
      [53] "to_data_frame"    "to_list"          "to_series"        "to_struct"       
      [57] "transpose"        "unique"           "unnest"           "var"             
      [61] "width"            "with_columns"     "with_row_count"   "write_csv"       
      [65] "write_json"       "write_ndjson"    

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
      [37] "with_columns"              "with_row_count"           
      [39] "write_csv"                 "write_json"               
      [41] "write_ndjson"             

# public and private methods of each class GroupBy

    Code
      ls(.pr$env[[class_name]])
    Output
       [1] "agg"            "first"          "last"           "max"           
       [5] "mean"           "median"         "min"            "null_count"    
       [9] "quantile"       "shift"          "shift_and_fill" "std"           
      [13] "sum"            "ungroup"        "var"           

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
      [55] "with_row_count"         

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
      [53] "with_row_count"         

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
       [19] "arg_unique"        "argsort"           "backward_fill"    
       [22] "bin"               "bottom_k"          "cast"             
       [25] "cat"               "ceil"              "clip"             
       [28] "clip_max"          "clip_min"          "cos"              
       [31] "cosh"              "count"             "cum_count"        
       [34] "cum_max"           "cum_min"           "cum_prod"         
       [37] "cum_sum"           "cumulative_eval"   "diff"             
       [40] "div"               "dot"               "drop_nans"        
       [43] "drop_nulls"        "dt"                "entropy"          
       [46] "eq"                "eq_missing"        "ewm_mean"         
       [49] "ewm_std"           "ewm_var"           "exclude"          
       [52] "exp"               "explode"           "extend_constant"  
       [55] "fill_nan"          "fill_null"         "filter"           
       [58] "first"             "flatten"           "floor"            
       [61] "floor_div"         "forward_fill"      "gather"           
       [64] "gather_every"      "gt"                "gt_eq"            
       [67] "hash"              "head"              "implode"          
       [70] "inspect"           "interpolate"       "is_between"       
       [73] "is_duplicated"     "is_finite"         "is_first_distinct"
       [76] "is_in"             "is_infinite"       "is_last_distinct" 
       [79] "is_nan"            "is_not_nan"        "is_not_null"      
       [82] "is_null"           "is_unique"         "kurtosis"         
       [85] "last"              "len"               "limit"            
       [88] "list"              "lit"               "log"              
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
       [19] "arg_unique"                 "backward_fill"             
       [21] "bin_contains"               "bin_decode_base64"         
       [23] "bin_decode_hex"             "bin_encode_base64"         
       [25] "bin_encode_hex"             "bin_ends_with"             
       [27] "bin_starts_with"            "bottom_k"                  
       [29] "cast"                       "cat_get_categories"        
       [31] "cat_set_ordering"           "ceil"                      
       [33] "clip"                       "clip_max"                  
       [35] "clip_min"                   "col"                       
       [37] "cols"                       "corr"                      
       [39] "cos"                        "cosh"                      
       [41] "count"                      "cov"                       
       [43] "cum_count"                  "cum_max"                   
       [45] "cum_min"                    "cum_prod"                  
       [47] "cum_sum"                    "cumulative_eval"           
       [49] "diff"                       "div"                       
       [51] "dot"                        "drop_nans"                 
       [53] "drop_nulls"                 "dt_cast_time_unit"         
       [55] "dt_combine"                 "dt_convert_time_zone"      
       [57] "dt_day"                     "dt_epoch_seconds"          
       [59] "dt_hour"                    "dt_iso_year"               
       [61] "dt_microsecond"             "dt_millisecond"            
       [63] "dt_minute"                  "dt_month"                  
       [65] "dt_nanosecond"              "dt_offset_by"              
       [67] "dt_ordinal_day"             "dt_quarter"                
       [69] "dt_replace_time_zone"       "dt_round"                  
       [71] "dt_second"                  "dt_strftime"               
       [73] "dt_time"                    "dt_total_days"             
       [75] "dt_total_hours"             "dt_total_microseconds"     
       [77] "dt_total_milliseconds"      "dt_total_minutes"          
       [79] "dt_total_nanoseconds"       "dt_total_seconds"          
       [81] "dt_truncate"                "dt_week"                   
       [83] "dt_weekday"                 "dt_with_time_unit"         
       [85] "dt_year"                    "dtype_cols"                
       [87] "entropy"                    "eq"                        
       [89] "eq_missing"                 "ewm_mean"                  
       [91] "ewm_std"                    "ewm_var"                   
       [93] "exclude"                    "exclude_dtype"             
       [95] "exp"                        "explode"                   
       [97] "extend_constant"            "fill_nan"                  
       [99] "fill_null"                  "fill_null_with_strategy"   
      [101] "filter"                     "first"                     
      [103] "flatten"                    "floor"                     
      [105] "floor_div"                  "forward_fill"              
      [107] "gather"                     "gather_every"              
      [109] "gt"                         "gt_eq"                     
      [111] "hash"                       "head"                      
      [113] "implode"                    "interpolate"               
      [115] "is_duplicated"              "is_finite"                 
      [117] "is_first_distinct"          "is_in"                     
      [119] "is_infinite"                "is_last_distinct"          
      [121] "is_nan"                     "is_not_nan"                
      [123] "is_not_null"                "is_null"                   
      [125] "is_unique"                  "kurtosis"                  
      [127] "last"                       "len"                       
      [129] "list_all"                   "list_any"                  
      [131] "list_arg_max"               "list_arg_min"              
      [133] "list_contains"              "list_diff"                 
      [135] "list_eval"                  "list_gather"               
      [137] "list_get"                   "list_join"                 
      [139] "list_lengths"               "list_max"                  
      [141] "list_mean"                  "list_min"                  
      [143] "list_reverse"               "list_set_operation"        
      [145] "list_shift"                 "list_slice"                
      [147] "list_sort"                  "list_sum"                  
      [149] "list_to_struct"             "list_unique"               
      [151] "lit"                        "log"                       
      [153] "log10"                      "lower_bound"               
      [155] "lt"                         "lt_eq"                     
      [157] "map_batches"                "map_batches_in_background" 
      [159] "map_elements_in_background" "max"                       
      [161] "mean"                       "median"                    
      [163] "meta_eq"                    "meta_has_multiple_outputs" 
      [165] "meta_is_regex_projection"   "meta_output_name"          
      [167] "meta_pop"                   "meta_roots"                
      [169] "meta_tree_format"           "meta_undo_aliases"         
      [171] "min"                        "mode"                      
      [173] "mul"                        "n_unique"                  
      [175] "name_keep"                  "name_map"                  
      [177] "name_prefix"                "name_suffix"               
      [179] "name_to_lowercase"          "name_to_uppercase"         
      [181] "nan_max"                    "nan_min"                   
      [183] "neq"                        "neq_missing"               
      [185] "new_count"                  "new_first"                 
      [187] "new_last"                   "not"                       
      [189] "null_count"                 "or"                        
      [191] "over"                       "pct_change"                
      [193] "peak_max"                   "peak_min"                  
      [195] "pow"                        "print"                     
      [197] "product"                    "quantile"                  
      [199] "rank"                       "rechunk"                   
      [201] "reinterpret"                "rem"                       
      [203] "rep"                        "repeat_by"                 
      [205] "replace"                    "reshape"                   
      [207] "reverse"                    "rle"                       
      [209] "rle_id"                     "rolling"                   
      [211] "rolling_corr"               "rolling_cov"               
      [213] "rolling_max"                "rolling_mean"              
      [215] "rolling_median"             "rolling_min"               
      [217] "rolling_quantile"           "rolling_skew"              
      [219] "rolling_std"                "rolling_sum"               
      [221] "rolling_var"                "round"                     
      [223] "sample_frac"                "sample_n"                  
      [225] "search_sorted"              "shift"                     
      [227] "shift_and_fill"             "shrink_dtype"              
      [229] "shuffle"                    "sign"                      
      [231] "sin"                        "sinh"                      
      [233] "skew"                       "slice"                     
      [235] "sort"                       "sort_by"                   
      [237] "std"                        "str_base64_decode"         
      [239] "str_base64_encode"          "str_concat"                
      [241] "str_contains"               "str_contains_any"          
      [243] "str_count_matches"          "str_ends_with"             
      [245] "str_explode"                "str_extract"               
      [247] "str_extract_all"            "str_hex_decode"            
      [249] "str_hex_encode"             "str_json_decode"           
      [251] "str_json_path_match"        "str_len_bytes"             
      [253] "str_len_chars"              "str_pad_end"               
      [255] "str_pad_start"              "str_parse_int"             
      [257] "str_replace"                "str_replace_all"           
      [259] "str_replace_many"           "str_reverse"               
      [261] "str_slice"                  "str_split"                 
      [263] "str_split_exact"            "str_splitn"                
      [265] "str_starts_with"            "str_strip_chars"           
      [267] "str_strip_chars_end"        "str_strip_chars_start"     
      [269] "str_to_date"                "str_to_datetime"           
      [271] "str_to_lowercase"           "str_to_time"               
      [273] "str_to_titlecase"           "str_to_uppercase"          
      [275] "str_zfill"                  "struct_field_by_name"      
      [277] "struct_rename_fields"       "sub"                       
      [279] "sum"                        "tail"                      
      [281] "tan"                        "tanh"                      
      [283] "timestamp"                  "to_physical"               
      [285] "top_k"                      "unique"                    
      [287] "unique_counts"              "unique_stable"             
      [289] "upper_bound"                "value_counts"              
      [291] "var"                        "xor"                       

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
       [1] "abs"           "add"           "alias"         "all"          
       [5] "any"           "append"        "arg_max"       "arg_min"      
       [9] "ceil"          "chunk_lengths" "clone"         "compare"      
      [13] "cum_sum"       "div"           "dtype"         "equals"       
      [17] "expr"          "flags"         "floor"         "is_numeric"   
      [21] "is_sorted"     "len"           "list"          "map_elements" 
      [25] "max"           "mean"          "median"        "min"          
      [29] "mul"           "n_unique"      "name"          "print"        
      [33] "rem"           "rename"        "rep"           "set_sorted"   
      [37] "shape"         "sort"          "std"           "sub"          
      [41] "sum"           "to_frame"      "to_lit"        "to_r"         
      [45] "to_r_list"     "to_r_vector"   "to_vector"     "value_counts" 
      [49] "var"          

---

    Code
      ls(.pr[[private_key]])
    Output
       [1] "abs"                    "add"                    "alias"                 
       [4] "all"                    "any"                    "append_mut"            
       [7] "arg_max"                "arg_min"                "ceil"                  
      [10] "chunk_lengths"          "clone"                  "compare"               
      [13] "cum_sum"                "div"                    "dtype"                 
      [16] "equals"                 "floor"                  "from_arrow"            
      [19] "get_fmt"                "is_sorted"              "is_sorted_flag"        
      [22] "is_sorted_reverse_flag" "len"                    "map_elements"          
      [25] "max"                    "mean"                   "median"                
      [28] "min"                    "mul"                    "n_unique"              
      [31] "name"                   "new"                    "panic"                 
      [34] "print"                  "rem"                    "rename_mut"            
      [37] "rep"                    "set_sorted_mut"         "shape"                 
      [40] "sleep"                  "sort_mut"               "std"                   
      [43] "sub"                    "sum"                    "to_fmt_char"           
      [46] "to_frame"               "to_r"                   "value_counts"          
      [49] "var"                   

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

