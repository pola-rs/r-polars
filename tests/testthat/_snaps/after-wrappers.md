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
      [19] "Series"                    "Struct"                   
      [21] "Time"                      "UInt16"                   
      [23] "UInt32"                    "UInt64"                   
      [25] "UInt8"                     "Unknown"                  
      [27] "Utf8"                      "all"                      
      [29] "all_horizontal"            "any_horizontal"           
      [31] "approx_n_unique"           "coalesce"                 
      [33] "col"                       "concat"                   
      [35] "concat_list"               "concat_str"               
      [37] "corr"                      "count"                    
      [39] "cov"                       "date_range"               
      [41] "disable_string_cache"      "dtypes"                   
      [43] "element"                   "enable_string_cache"      
      [45] "expr_to_r"                 "extra_auto_completion"    
      [47] "first"                     "fold"                     
      [49] "from_arrow"                "get_global_rpool_cap"     
      [51] "head"                      "implode"                  
      [53] "is_schema"                 "last"                     
      [55] "lit"                       "max"                      
      [57] "max_horizontal"            "mean"                     
      [59] "median"                    "mem_address"              
      [61] "min"                       "min_horizontal"           
      [63] "n_unique"                  "numeric_dtypes"           
      [65] "options"                   "polars_info"              
      [67] "raw_list"                  "read_csv"                 
      [69] "read_ndjson"               "read_parquet"             
      [71] "reduce"                    "reset_options"            
      [73] "rolling_corr"              "rolling_cov"              
      [75] "same_outer_dt"             "scan_csv"                 
      [77] "scan_ipc"                  "scan_ndjson"              
      [79] "scan_parquet"              "select"                   
      [81] "set_global_rpool_cap"      "set_options"              
      [83] "show_all_public_functions" "show_all_public_methods"  
      [85] "std"                       "struct"                   
      [87] "sum"                       "sum_horizontal"           
      [89] "tail"                      "using_string_cache"       
      [91] "var"                       "when"                     
      [93] "with_string_cache"        

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
       [1] "clone"          "columns"        "describe"       "drop"          
       [5] "drop_in_place"  "drop_nulls"     "dtype_strings"  "dtypes"        
       [9] "estimated_size" "explode"        "fill_nan"       "fill_null"     
      [13] "filter"         "first"          "frame_equal"    "get_column"    
      [17] "get_columns"    "glimpse"        "group_by"       "head"          
      [21] "height"         "join"           "join_asof"      "last"          
      [25] "lazy"           "limit"          "max"            "mean"          
      [29] "median"         "melt"           "min"            "n_chunks"      
      [33] "null_count"     "pivot"          "print"          "quantile"      
      [37] "rechunk"        "rename"         "reverse"        "sample"        
      [41] "schema"         "select"         "shape"          "shift"         
      [45] "shift_and_fill" "slice"          "sort"           "std"           
      [49] "sum"            "tail"           "to_data_frame"  "to_list"       
      [53] "to_series"      "to_struct"      "transpose"      "unique"        
      [57] "unnest"         "var"            "width"          "with_columns"  
      [61] "with_row_count" "write_csv"      "write_json"     "write_ndjson"  

---

    Code
      ls(.pr[[private_key]])
    Output
       [1] "by_agg"                    "clone_in_rust"            
       [3] "columns"                   "default"                  
       [5] "drop_all_in_place"         "drop_in_place"            
       [7] "dtype_strings"             "dtypes"                   
       [9] "estimated_size"            "export_stream"            
      [11] "frame_equal"               "from_arrow_record_batches"
      [13] "get_column"                "get_columns"              
      [15] "lazy"                      "melt"                     
      [17] "n_chunks"                  "new_with_capacity"        
      [19] "null_count"                "pivot_expr"               
      [21] "print"                     "rechunk"                  
      [23] "sample_frac"               "sample_n"                 
      [25] "schema"                    "select"                   
      [27] "select_at_idx"             "set_column_from_robj"     
      [29] "set_column_from_series"    "set_column_names_mut"     
      [31] "shape"                     "to_list"                  
      [33] "to_list_tag_structs"       "to_list_unwind"           
      [35] "to_struct"                 "transpose"                
      [37] "unnest"                    "with_columns"             
      [39] "with_row_count"            "write_csv"                
      [41] "write_json"                "write_ndjson"             

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
      [17] "group_by"                "head"                   
      [19] "join"                    "join_asof"              
      [21] "last"                    "limit"                  
      [23] "max"                     "mean"                   
      [25] "median"                  "melt"                   
      [27] "min"                     "print"                  
      [29] "profile"                 "quantile"               
      [31] "rename"                  "reverse"                
      [33] "schema"                  "select"                 
      [35] "set_optimization_toggle" "shift"                  
      [37] "shift_and_fill"          "sink_csv"               
      [39] "sink_ipc"                "sink_parquet"           
      [41] "slice"                   "sort"                   
      [43] "std"                     "sum"                    
      [45] "tail"                    "unique"                 
      [47] "unnest"                  "var"                    
      [49] "width"                   "with_columns"           
      [51] "with_context"            "with_row_count"         

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
      [17] "join"                    "join_asof"              
      [19] "last"                    "limit"                  
      [21] "max"                     "mean"                   
      [23] "median"                  "melt"                   
      [25] "min"                     "print"                  
      [27] "profile"                 "quantile"               
      [29] "rename"                  "reverse"                
      [31] "schema"                  "select"                 
      [33] "select_str_as_lit"       "set_optimization_toggle"
      [35] "shift"                   "shift_and_fill"         
      [37] "sink_csv"                "sink_ipc"               
      [39] "sink_parquet"            "slice"                  
      [41] "sort_by_exprs"           "std"                    
      [43] "sum"                     "tail"                   
      [45] "unique"                  "unnest"                 
      [47] "var"                     "with_columns"           
      [49] "with_context"            "with_row_count"         

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
      [130] "reshape"           "reverse"           "rolling"          
      [133] "rolling_max"       "rolling_mean"      "rolling_median"   
      [136] "rolling_min"       "rolling_quantile"  "rolling_skew"     
      [139] "rolling_std"       "rolling_sum"       "rolling_var"      
      [142] "round"             "sample"            "search_sorted"    
      [145] "set_sorted"        "shift"             "shift_and_fill"   
      [148] "shrink_dtype"      "shuffle"           "sign"             
      [151] "sin"               "sinh"              "skew"             
      [154] "slice"             "sort"              "sort_by"          
      [157] "sqrt"              "std"               "str"              
      [160] "struct"            "sub"               "sum"              
      [163] "tail"              "tan"               "tanh"             
      [166] "to_physical"       "to_r"              "to_series"        
      [169] "to_struct"         "top_k"             "unique"           
      [172] "unique_counts"     "upper_bound"       "value_counts"     
      [175] "var"               "where"             "xor"              

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
      [129] "list_arg_max"               "list_arg_min"              
      [131] "list_contains"              "list_diff"                 
      [133] "list_eval"                  "list_gather"               
      [135] "list_get"                   "list_join"                 
      [137] "list_lengths"               "list_max"                  
      [139] "list_mean"                  "list_min"                  
      [141] "list_reverse"               "list_shift"                
      [143] "list_slice"                 "list_sort"                 
      [145] "list_sum"                   "list_to_struct"            
      [147] "list_unique"                "lit"                       
      [149] "log"                        "log10"                     
      [151] "lower_bound"                "lt"                        
      [153] "lt_eq"                      "map_batches"               
      [155] "map_batches_in_background"  "map_elements_in_background"
      [157] "max"                        "mean"                      
      [159] "median"                     "meta_eq"                   
      [161] "meta_has_multiple_outputs"  "meta_is_regex_projection"  
      [163] "meta_output_name"           "meta_pop"                  
      [165] "meta_roots"                 "meta_tree_format"          
      [167] "meta_undo_aliases"          "min"                       
      [169] "mode"                       "mul"                       
      [171] "n_unique"                   "name_keep"                 
      [173] "name_map"                   "name_prefix"               
      [175] "name_suffix"                "name_to_lowercase"         
      [177] "name_to_uppercase"          "nan_max"                   
      [179] "nan_min"                    "neq"                       
      [181] "neq_missing"                "new_count"                 
      [183] "new_first"                  "new_last"                  
      [185] "not"                        "null_count"                
      [187] "or"                         "over"                      
      [189] "pct_change"                 "peak_max"                  
      [191] "peak_min"                   "pow"                       
      [193] "print"                      "product"                   
      [195] "quantile"                   "rank"                      
      [197] "rechunk"                    "reinterpret"               
      [199] "rem"                        "rep"                       
      [201] "repeat_by"                  "reshape"                   
      [203] "reverse"                    "rolling"                   
      [205] "rolling_corr"               "rolling_cov"               
      [207] "rolling_max"                "rolling_mean"              
      [209] "rolling_median"             "rolling_min"               
      [211] "rolling_quantile"           "rolling_skew"              
      [213] "rolling_std"                "rolling_sum"               
      [215] "rolling_var"                "round"                     
      [217] "sample_frac"                "sample_n"                  
      [219] "search_sorted"              "shift"                     
      [221] "shift_and_fill"             "shrink_dtype"              
      [223] "shuffle"                    "sign"                      
      [225] "sin"                        "sinh"                      
      [227] "skew"                       "slice"                     
      [229] "sort"                       "sort_by"                   
      [231] "std"                        "str_base64_decode"         
      [233] "str_base64_encode"          "str_concat"                
      [235] "str_contains"               "str_count_matches"         
      [237] "str_ends_with"              "str_explode"               
      [239] "str_extract"                "str_extract_all"           
      [241] "str_hex_decode"             "str_hex_encode"            
      [243] "str_json_extract"           "str_json_path_match"       
      [245] "str_len_bytes"              "str_len_chars"             
      [247] "str_pad_end"                "str_pad_start"             
      [249] "str_parse_int"              "str_replace"               
      [251] "str_replace_all"            "str_slice"                 
      [253] "str_split"                  "str_split_exact"           
      [255] "str_splitn"                 "str_starts_with"           
      [257] "str_strip_chars"            "str_strip_chars_end"       
      [259] "str_strip_chars_start"      "str_to_date"               
      [261] "str_to_datetime"            "str_to_lowercase"          
      [263] "str_to_time"                "str_to_titlecase"          
      [265] "str_to_uppercase"           "str_zfill"                 
      [267] "struct_field_by_name"       "struct_rename_fields"      
      [269] "sub"                        "sum"                       
      [271] "tail"                       "tan"                       
      [273] "tanh"                       "timestamp"                 
      [275] "to_physical"                "top_k"                     
      [277] "unique"                     "unique_counts"             
      [279] "unique_stable"              "upper_bound"               
      [281] "value_counts"               "var"                       
      [283] "xor"                       

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
      [17] "expr"          "flags"         "floor"         "is_numeric"   
      [21] "is_sorted"     "len"           "list"          "map_elements" 
      [25] "max"           "mean"          "median"        "min"          
      [29] "mul"           "n_unique"      "name"          "print"        
      [33] "rem"           "rename"        "rep"           "series_equal" 
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
      [16] "floor"                  "from_arrow"             "get_fmt"               
      [19] "is_sorted"              "is_sorted_flag"         "is_sorted_reverse_flag"
      [22] "len"                    "map_elements"           "max"                   
      [25] "mean"                   "median"                 "min"                   
      [28] "mul"                    "n_unique"               "name"                  
      [31] "new"                    "panic"                  "print"                 
      [34] "rem"                    "rename_mut"             "rep"                   
      [37] "series_equal"           "set_sorted_mut"         "shape"                 
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

