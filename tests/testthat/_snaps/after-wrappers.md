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
       [59] "field"                     "first"                    
       [61] "fold"                      "from_epoch"               
       [63] "get_global_rpool_cap"      "head"                     
       [65] "implode"                   "int_range"                
       [67] "int_ranges"                "is_schema"                
       [69] "last"                      "len"                      
       [71] "lit"                       "max"                      
       [73] "max_horizontal"            "mean"                     
       [75] "mean_horizontal"           "median"                   
       [77] "mem_address"               "min"                      
       [79] "min_horizontal"            "n_unique"                 
       [81] "numeric_dtypes"            "raw_list"                 
       [83] "read_csv"                  "read_ipc"                 
       [85] "read_ndjson"               "read_parquet"             
       [87] "reduce"                    "rolling_corr"             
       [89] "rolling_cov"               "same_outer_dt"            
       [91] "scan_csv"                  "scan_ipc"                 
       [93] "scan_ndjson"               "scan_parquet"             
       [95] "select"                    "set_global_rpool_cap"     
       [97] "show_all_public_functions" "show_all_public_methods"  
       [99] "std"                       "struct"                   
      [101] "sum"                       "sum_horizontal"           
      [103] "tail"                      "thread_pool_size"         
      [105] "time"                      "using_string_cache"       
      [107] "var"                       "when"                     
      [109] "with_string_cache"        

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
       [1] "clear"                     "clone_in_rust"            
       [3] "columns"                   "default"                  
       [5] "drop_all_in_place"         "drop_in_place"            
       [7] "dtype_strings"             "dtypes"                   
       [9] "equals"                    "estimated_size"           
      [11] "export_stream"             "from_arrow_record_batches"
      [13] "from_raw_ipc"              "get_column"               
      [15] "get_columns"               "lazy"                     
      [17] "melt"                      "n_chunks"                 
      [19] "new_with_capacity"         "null_count"               
      [21] "partition_by"              "pivot_expr"               
      [23] "print"                     "rechunk"                  
      [25] "sample_frac"               "sample_n"                 
      [27] "schema"                    "select"                   
      [29] "select_at_idx"             "select_seq"               
      [31] "set_column_from_robj"      "set_column_from_series"   
      [33] "set_column_names_mut"      "shape"                    
      [35] "to_list"                   "to_list_tag_structs"      
      [37] "to_list_unwind"            "to_raw_ipc"               
      [39] "to_struct"                 "transpose"                
      [41] "unnest"                    "with_columns"             
      [43] "with_columns_seq"          "with_row_index"           
      [45] "write_csv"                 "write_ipc"                
      [47] "write_json"                "write_ndjson"             
      [49] "write_parquet"            

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
      [133] "rolling"           "rolling_max"       "rolling_max_by"   
      [136] "rolling_mean"      "rolling_mean_by"   "rolling_median"   
      [139] "rolling_median_by" "rolling_min"       "rolling_min_by"   
      [142] "rolling_quantile"  "rolling_skew"      "rolling_std"      
      [145] "rolling_sum"       "rolling_sum_by"    "rolling_var"      
      [148] "round"             "sample"            "search_sorted"    
      [151] "set_sorted"        "shift"             "shift_and_fill"   
      [154] "shrink_dtype"      "shuffle"           "sign"             
      [157] "sin"               "sinh"              "skew"             
      [160] "slice"             "sort"              "sort_by"          
      [163] "sqrt"              "std"               "str"              
      [166] "struct"            "sub"               "sum"              
      [169] "tail"              "tan"               "tanh"             
      [172] "to_physical"       "to_r"              "to_series"        
      [175] "top_k"             "unique"            "unique_counts"    
      [178] "upper_bound"       "value_counts"      "var"              
      [181] "xor"              

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
      [136] "rolling_max_by"    "rolling_mean"      "rolling_mean_by"  
      [139] "rolling_median"    "rolling_median_by" "rolling_min"      
      [142] "rolling_min_by"    "rolling_quantile"  "rolling_skew"     
      [145] "rolling_std"       "rolling_sum"       "rolling_sum_by"   
      [148] "rolling_var"       "round"             "sample"           
      [151] "search_sorted"     "set_sorted"        "shift"            
      [154] "shift_and_fill"    "shrink_dtype"      "shuffle"          
      [157] "sign"              "sin"               "sinh"             
      [160] "skew"              "slice"             "sort"             
      [163] "sort_by"           "sqrt"              "std"              
      [166] "str"               "struct"            "sub"              
      [169] "sum"               "tail"              "tan"              
      [172] "tanh"              "to_physical"       "to_r"             
      [175] "to_series"         "top_k"             "unique"           
      [178] "unique_counts"     "upper_bound"       "value_counts"     
      [181] "var"               "when"              "xor"              

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
      [136] "rolling_max_by"    "rolling_mean"      "rolling_mean_by"  
      [139] "rolling_median"    "rolling_median_by" "rolling_min"      
      [142] "rolling_min_by"    "rolling_quantile"  "rolling_skew"     
      [145] "rolling_std"       "rolling_sum"       "rolling_sum_by"   
      [148] "rolling_var"       "round"             "sample"           
      [151] "search_sorted"     "set_sorted"        "shift"            
      [154] "shift_and_fill"    "shrink_dtype"      "shuffle"          
      [157] "sign"              "sin"               "sinh"             
      [160] "skew"              "slice"             "sort"             
      [163] "sort_by"           "sqrt"              "std"              
      [166] "str"               "struct"            "sub"              
      [169] "sum"               "tail"              "tan"              
      [172] "tanh"              "to_physical"       "to_r"             
      [175] "to_series"         "top_k"             "unique"           
      [178] "unique_counts"     "upper_bound"       "value_counts"     
      [181] "var"               "when"              "xor"              

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
      [139] "rle_id"            "rolling_max"       "rolling_max_by"   
      [142] "rolling_mean"      "rolling_mean_by"   "rolling_median"   
      [145] "rolling_median_by" "rolling_min"       "rolling_min_by"   
      [148] "rolling_quantile"  "rolling_skew"      "rolling_std"      
      [151] "rolling_sum"       "rolling_sum_by"    "rolling_var"      
      [154] "round"             "sample"            "search_sorted"    
      [157] "set_sorted"        "shape"             "shift"            
      [160] "shift_and_fill"    "shrink_dtype"      "shuffle"          
      [163] "sign"              "sin"               "sinh"             
      [166] "skew"              "slice"             "sort"             
      [169] "sort_by"           "sqrt"              "std"              
      [172] "str"               "struct"            "sub"              
      [175] "sum"               "tail"              "tan"              
      [178] "tanh"              "to_frame"          "to_list"          
      [181] "to_lit"            "to_physical"       "to_r"             
      [184] "to_vector"         "top_k"             "unique"           
      [187] "unique_counts"     "upper_bound"       "value_counts"     
      [190] "var"               "xor"              

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

