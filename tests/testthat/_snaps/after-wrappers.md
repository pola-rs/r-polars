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
      [53] "get_global_rpool_cap"      "head"                     
      [55] "implode"                   "is_schema"                
      [57] "last"                      "lit"                      
      [59] "max"                       "max_horizontal"           
      [61] "mean"                      "median"                   
      [63] "mem_address"               "min"                      
      [65] "min_horizontal"            "n_unique"                 
      [67] "numeric_dtypes"            "options"                  
      [69] "polars_info"               "raw_list"                 
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
        [7] "any"               "append"            "apply"            
       [10] "approx_n_unique"   "arccos"            "arccosh"          
       [13] "arcsin"            "arcsinh"           "arctan"           
       [16] "arctanh"           "arg_max"           "arg_min"          
       [19] "arg_sort"          "arg_unique"        "argsort"          
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
       [94] "lt"                "lt_eq"             "map"              
       [97] "map_batches"       "map_elements"      "max"              
      [100] "mean"              "median"            "meta"             
      [103] "min"               "mod"               "mode"             
      [106] "mul"               "n_unique"          "name"             
      [109] "nan_max"           "nan_min"           "neq"              
      [112] "neq_missing"       "not"               "null_count"       
      [115] "or"                "over"              "pct_change"       
      [118] "peak_max"          "peak_min"          "pow"              
      [121] "print"             "product"           "quantile"         
      [124] "rank"              "rechunk"           "reinterpret"      
      [127] "rep"               "rep_extend"        "repeat_by"        
      [130] "replace"           "reshape"           "reverse"          
      [133] "rle"               "rle_id"            "rolling"          
      [136] "rolling_max"       "rolling_mean"      "rolling_median"   
      [139] "rolling_min"       "rolling_quantile"  "rolling_skew"     
      [142] "rolling_std"       "rolling_sum"       "rolling_var"      
      [145] "round"             "sample"            "search_sorted"    
      [148] "set_sorted"        "shift"             "shift_and_fill"   
      [151] "shrink_dtype"      "shuffle"           "sign"             
      [154] "sin"               "sinh"              "skew"             
      [157] "slice"             "sort"              "sort_by"          
      [160] "sqrt"              "std"               "str"              
      [163] "struct"            "sub"               "sum"              
      [166] "tail"              "tan"               "tanh"             
      [169] "to_physical"       "to_r"              "to_series"        
      [172] "to_struct"         "top_k"             "unique"           
      [175] "unique_counts"     "upper_bound"       "value_counts"     
      [178] "var"               "where"             "xor"              

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
      [143] "list_reverse"               "list_shift"                
      [145] "list_slice"                 "list_sort"                 
      [147] "list_sum"                   "list_to_struct"            
      [149] "list_unique"                "lit"                       
      [151] "log"                        "log10"                     
      [153] "lower_bound"                "lt"                        
      [155] "lt_eq"                      "map_batches"               
      [157] "map_batches_in_background"  "map_elements_in_background"
      [159] "max"                        "mean"                      
      [161] "median"                     "meta_eq"                   
      [163] "meta_has_multiple_outputs"  "meta_is_regex_projection"  
      [165] "meta_output_name"           "meta_pop"                  
      [167] "meta_roots"                 "meta_tree_format"          
      [169] "meta_undo_aliases"          "min"                       
      [171] "mode"                       "mul"                       
      [173] "n_unique"                   "name_keep"                 
      [175] "name_map"                   "name_prefix"               
      [177] "name_suffix"                "name_to_lowercase"         
      [179] "name_to_uppercase"          "nan_max"                   
      [181] "nan_min"                    "neq"                       
      [183] "neq_missing"                "new_count"                 
      [185] "new_first"                  "new_last"                  
      [187] "not"                        "null_count"                
      [189] "or"                         "over"                      
      [191] "pct_change"                 "peak_max"                  
      [193] "peak_min"                   "pow"                       
      [195] "print"                      "product"                   
      [197] "quantile"                   "rank"                      
      [199] "rechunk"                    "reinterpret"               
      [201] "rem"                        "rep"                       
      [203] "repeat_by"                  "replace"                   
      [205] "reshape"                    "reverse"                   
      [207] "rle"                        "rle_id"                    
      [209] "rolling"                    "rolling_corr"              
      [211] "rolling_cov"                "rolling_max"               
      [213] "rolling_mean"               "rolling_median"            
      [215] "rolling_min"                "rolling_quantile"          
      [217] "rolling_skew"               "rolling_std"               
      [219] "rolling_sum"                "rolling_var"               
      [221] "round"                      "sample_frac"               
      [223] "sample_n"                   "search_sorted"             
      [225] "shift"                      "shift_and_fill"            
      [227] "shrink_dtype"               "shuffle"                   
      [229] "sign"                       "sin"                       
      [231] "sinh"                       "skew"                      
      [233] "slice"                      "sort"                      
      [235] "sort_by"                    "std"                       
      [237] "str_base64_decode"          "str_base64_encode"         
      [239] "str_concat"                 "str_contains"              
      [241] "str_contains_any"           "str_count_matches"         
      [243] "str_ends_with"              "str_explode"               
      [245] "str_extract"                "str_extract_all"           
      [247] "str_hex_decode"             "str_hex_encode"            
      [249] "str_json_decode"            "str_json_path_match"       
      [251] "str_len_bytes"              "str_len_chars"             
      [253] "str_pad_end"                "str_pad_start"             
      [255] "str_parse_int"              "str_replace"               
      [257] "str_replace_all"            "str_replace_many"          
      [259] "str_reverse"                "str_slice"                 
      [261] "str_split"                  "str_split_exact"           
      [263] "str_splitn"                 "str_starts_with"           
      [265] "str_strip_chars"            "str_strip_chars_end"       
      [267] "str_strip_chars_start"      "str_to_date"               
      [269] "str_to_datetime"            "str_to_lowercase"          
      [271] "str_to_time"                "str_to_titlecase"          
      [273] "str_to_uppercase"           "str_zfill"                 
      [275] "struct_field_by_name"       "struct_rename_fields"      
      [277] "sub"                        "sum"                       
      [279] "tail"                       "tan"                       
      [281] "tanh"                       "timestamp"                 
      [283] "to_physical"                "top_k"                     
      [285] "unique"                     "unique_counts"             
      [287] "unique_stable"              "upper_bound"               
      [289] "value_counts"               "var"                       
      [291] "xor"                       

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
       [5] "any"           "append"        "apply"         "arg_max"      
       [9] "arg_min"       "ceil"          "chunk_lengths" "clone"        
      [13] "compare"       "cum_sum"       "div"           "dtype"        
      [17] "equals"        "expr"          "flags"         "floor"        
      [21] "is_numeric"    "is_sorted"     "len"           "list"         
      [25] "map_elements"  "max"           "mean"          "median"       
      [29] "min"           "mul"           "n_unique"      "name"         
      [33] "print"         "rem"           "rename"        "rep"          
      [37] "set_sorted"    "shape"         "sort"          "std"          
      [41] "sub"           "sum"           "to_frame"      "to_lit"       
      [45] "to_r"          "to_r_list"     "to_r_vector"   "to_vector"    
      [49] "value_counts"  "var"          

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

