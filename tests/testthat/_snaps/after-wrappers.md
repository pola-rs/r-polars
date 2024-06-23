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
      [33] "median"           "min"              "n_chunks"         "null_count"      
      [37] "partition_by"     "pivot"            "print"            "quantile"        
      [41] "rechunk"          "rename"           "reverse"          "rolling"         
      [45] "sample"           "schema"           "select"           "select_seq"      
      [49] "shape"            "shift"            "shift_and_fill"   "slice"           
      [53] "sort"             "sql"              "std"              "sum"             
      [57] "tail"             "to_data_frame"    "to_list"          "to_raw_ipc"      
      [61] "to_series"        "to_struct"        "transpose"        "unique"          
      [65] "unnest"           "unpivot"          "var"              "width"           
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
      [17] "n_chunks"                  "new_with_capacity"        
      [19] "null_count"                "partition_by"             
      [21] "pivot_expr"                "print"                    
      [23] "rechunk"                   "sample_frac"              
      [25] "sample_n"                  "schema"                   
      [27] "select"                    "select_at_idx"            
      [29] "select_seq"                "set_column_from_robj"     
      [31] "set_column_from_series"    "set_column_names_mut"     
      [33] "shape"                     "to_list"                  
      [35] "to_list_tag_structs"       "to_list_unwind"           
      [37] "to_raw_ipc"                "to_struct"                
      [39] "transpose"                 "unnest"                   
      [41] "unpivot"                   "with_columns"             
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
      [27] "median"                  "min"                    
      [29] "print"                   "profile"                
      [31] "quantile"                "rename"                 
      [33] "reverse"                 "rolling"                
      [35] "schema"                  "select"                 
      [37] "select_seq"              "serialize"              
      [39] "set_optimization_toggle" "shift"                  
      [41] "shift_and_fill"          "sink_csv"               
      [43] "sink_ipc"                "sink_ndjson"            
      [45] "sink_parquet"            "slice"                  
      [47] "sort"                    "sql"                    
      [49] "std"                     "sum"                    
      [51] "tail"                    "to_dot"                 
      [53] "unique"                  "unnest"                 
      [55] "unpivot"                 "var"                    
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
      [25] "min"                     "print"                  
      [27] "profile"                 "quantile"               
      [29] "rename"                  "reverse"                
      [31] "rolling"                 "schema"                 
      [33] "select"                  "select_seq"             
      [35] "serialize"               "set_optimization_toggle"
      [37] "shift"                   "shift_and_fill"         
      [39] "sink_csv"                "sink_ipc"               
      [41] "sink_json"               "sink_parquet"           
      [43] "slice"                   "sort_by_exprs"          
      [45] "std"                     "sum"                    
      [47] "tail"                    "to_dot"                 
      [49] "unique"                  "unnest"                 
      [51] "unpivot"                 "var"                    
      [53] "with_columns"            "with_columns_seq"       
      [55] "with_context"            "with_row_index"         

# public and private methods of each class Expr

    Code
      ls(.pr$env[[class_name]])
    Output
        [1] "abs"                 "add"                 "agg_groups"         
        [4] "alias"               "all"                 "and"                
        [7] "any"                 "append"              "approx_n_unique"    
       [10] "arccos"              "arccosh"             "arcsin"             
       [13] "arcsinh"             "arctan"              "arctanh"            
       [16] "arg_max"             "arg_min"             "arg_sort"           
       [19] "arg_unique"          "arr"                 "backward_fill"      
       [22] "bin"                 "bottom_k"            "cast"               
       [25] "cat"                 "ceil"                "clip"               
       [28] "clip_max"            "clip_min"            "cos"                
       [31] "cosh"                "count"               "cum_count"          
       [34] "cum_max"             "cum_min"             "cum_prod"           
       [37] "cum_sum"             "cumulative_eval"     "cut"                
       [40] "diff"                "div"                 "dot"                
       [43] "drop_nans"           "drop_nulls"          "dt"                 
       [46] "entropy"             "eq"                  "eq_missing"         
       [49] "ewm_mean"            "ewm_std"             "ewm_var"            
       [52] "exclude"             "exp"                 "explode"            
       [55] "extend_constant"     "fill_nan"            "fill_null"          
       [58] "filter"              "first"               "flatten"            
       [61] "floor"               "floor_div"           "forward_fill"       
       [64] "gather"              "gather_every"        "gt"                 
       [67] "gt_eq"               "has_nulls"           "hash"               
       [70] "head"                "implode"             "inspect"            
       [73] "interpolate"         "is_between"          "is_duplicated"      
       [76] "is_finite"           "is_first_distinct"   "is_in"              
       [79] "is_infinite"         "is_last_distinct"    "is_nan"             
       [82] "is_not_nan"          "is_not_null"         "is_null"            
       [85] "is_unique"           "kurtosis"            "last"               
       [88] "len"                 "limit"               "list"               
       [91] "log"                 "log10"               "lower_bound"        
       [94] "lt"                  "lt_eq"               "map_batches"        
       [97] "map_elements"        "max"                 "mean"               
      [100] "median"              "meta"                "min"                
      [103] "mod"                 "mode"                "mul"                
      [106] "n_unique"            "name"                "nan_max"            
      [109] "nan_min"             "neq"                 "neq_missing"        
      [112] "not"                 "null_count"          "or"                 
      [115] "over"                "pct_change"          "peak_max"           
      [118] "peak_min"            "pow"                 "print"              
      [121] "product"             "qcut"                "quantile"           
      [124] "rank"                "rechunk"             "reinterpret"        
      [127] "rep"                 "repeat_by"           "replace"            
      [130] "replace_strict"      "reshape"             "reverse"            
      [133] "rle"                 "rle_id"              "rolling"            
      [136] "rolling_max"         "rolling_max_by"      "rolling_mean"       
      [139] "rolling_mean_by"     "rolling_median"      "rolling_median_by"  
      [142] "rolling_min"         "rolling_min_by"      "rolling_quantile"   
      [145] "rolling_quantile_by" "rolling_skew"        "rolling_std"        
      [148] "rolling_std_by"      "rolling_sum"         "rolling_sum_by"     
      [151] "rolling_var"         "rolling_var_by"      "round"              
      [154] "sample"              "search_sorted"       "set_sorted"         
      [157] "shift"               "shift_and_fill"      "shrink_dtype"       
      [160] "shuffle"             "sign"                "sin"                
      [163] "sinh"                "skew"                "slice"              
      [166] "sort"                "sort_by"             "sqrt"               
      [169] "std"                 "str"                 "struct"             
      [172] "sub"                 "sum"                 "tail"               
      [175] "tan"                 "tanh"                "to_physical"        
      [178] "to_r"                "to_series"           "top_k"              
      [181] "unique"              "unique_counts"       "upper_bound"        
      [184] "value_counts"        "var"                 "xor"                

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
        [1] "abs"                 "add"                 "agg_groups"         
        [4] "alias"               "all"                 "and"                
        [7] "any"                 "append"              "approx_n_unique"    
       [10] "arccos"              "arccosh"             "arcsin"             
       [13] "arcsinh"             "arctan"              "arctanh"            
       [16] "arg_max"             "arg_min"             "arg_sort"           
       [19] "arg_unique"          "arr"                 "backward_fill"      
       [22] "bin"                 "bottom_k"            "cast"               
       [25] "cat"                 "ceil"                "clip"               
       [28] "clip_max"            "clip_min"            "cos"                
       [31] "cosh"                "count"               "cum_count"          
       [34] "cum_max"             "cum_min"             "cum_prod"           
       [37] "cum_sum"             "cumulative_eval"     "cut"                
       [40] "diff"                "div"                 "dot"                
       [43] "drop_nans"           "drop_nulls"          "dt"                 
       [46] "entropy"             "eq"                  "eq_missing"         
       [49] "ewm_mean"            "ewm_std"             "ewm_var"            
       [52] "exclude"             "exp"                 "explode"            
       [55] "extend_constant"     "fill_nan"            "fill_null"          
       [58] "filter"              "first"               "flatten"            
       [61] "floor"               "floor_div"           "forward_fill"       
       [64] "gather"              "gather_every"        "gt"                 
       [67] "gt_eq"               "has_nulls"           "hash"               
       [70] "head"                "implode"             "inspect"            
       [73] "interpolate"         "is_between"          "is_duplicated"      
       [76] "is_finite"           "is_first_distinct"   "is_in"              
       [79] "is_infinite"         "is_last_distinct"    "is_nan"             
       [82] "is_not_nan"          "is_not_null"         "is_null"            
       [85] "is_unique"           "kurtosis"            "last"               
       [88] "len"                 "limit"               "list"               
       [91] "log"                 "log10"               "lower_bound"        
       [94] "lt"                  "lt_eq"               "map_batches"        
       [97] "map_elements"        "max"                 "mean"               
      [100] "median"              "meta"                "min"                
      [103] "mod"                 "mode"                "mul"                
      [106] "n_unique"            "name"                "nan_max"            
      [109] "nan_min"             "neq"                 "neq_missing"        
      [112] "not"                 "null_count"          "or"                 
      [115] "otherwise"           "over"                "pct_change"         
      [118] "peak_max"            "peak_min"            "pow"                
      [121] "print"               "product"             "qcut"               
      [124] "quantile"            "rank"                "rechunk"            
      [127] "reinterpret"         "rep"                 "repeat_by"          
      [130] "replace"             "replace_strict"      "reshape"            
      [133] "reverse"             "rle"                 "rle_id"             
      [136] "rolling"             "rolling_max"         "rolling_max_by"     
      [139] "rolling_mean"        "rolling_mean_by"     "rolling_median"     
      [142] "rolling_median_by"   "rolling_min"         "rolling_min_by"     
      [145] "rolling_quantile"    "rolling_quantile_by" "rolling_skew"       
      [148] "rolling_std"         "rolling_std_by"      "rolling_sum"        
      [151] "rolling_sum_by"      "rolling_var"         "rolling_var_by"     
      [154] "round"               "sample"              "search_sorted"      
      [157] "set_sorted"          "shift"               "shift_and_fill"     
      [160] "shrink_dtype"        "shuffle"             "sign"               
      [163] "sin"                 "sinh"                "skew"               
      [166] "slice"               "sort"                "sort_by"            
      [169] "sqrt"                "std"                 "str"                
      [172] "struct"              "sub"                 "sum"                
      [175] "tail"                "tan"                 "tanh"               
      [178] "to_physical"         "to_r"                "to_series"          
      [181] "top_k"               "unique"              "unique_counts"      
      [184] "upper_bound"         "value_counts"        "var"                
      [187] "when"                "xor"                

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
        [1] "abs"                 "add"                 "agg_groups"         
        [4] "alias"               "all"                 "and"                
        [7] "any"                 "append"              "approx_n_unique"    
       [10] "arccos"              "arccosh"             "arcsin"             
       [13] "arcsinh"             "arctan"              "arctanh"            
       [16] "arg_max"             "arg_min"             "arg_sort"           
       [19] "arg_unique"          "arr"                 "backward_fill"      
       [22] "bin"                 "bottom_k"            "cast"               
       [25] "cat"                 "ceil"                "clip"               
       [28] "clip_max"            "clip_min"            "cos"                
       [31] "cosh"                "count"               "cum_count"          
       [34] "cum_max"             "cum_min"             "cum_prod"           
       [37] "cum_sum"             "cumulative_eval"     "cut"                
       [40] "diff"                "div"                 "dot"                
       [43] "drop_nans"           "drop_nulls"          "dt"                 
       [46] "entropy"             "eq"                  "eq_missing"         
       [49] "ewm_mean"            "ewm_std"             "ewm_var"            
       [52] "exclude"             "exp"                 "explode"            
       [55] "extend_constant"     "fill_nan"            "fill_null"          
       [58] "filter"              "first"               "flatten"            
       [61] "floor"               "floor_div"           "forward_fill"       
       [64] "gather"              "gather_every"        "gt"                 
       [67] "gt_eq"               "has_nulls"           "hash"               
       [70] "head"                "implode"             "inspect"            
       [73] "interpolate"         "is_between"          "is_duplicated"      
       [76] "is_finite"           "is_first_distinct"   "is_in"              
       [79] "is_infinite"         "is_last_distinct"    "is_nan"             
       [82] "is_not_nan"          "is_not_null"         "is_null"            
       [85] "is_unique"           "kurtosis"            "last"               
       [88] "len"                 "limit"               "list"               
       [91] "log"                 "log10"               "lower_bound"        
       [94] "lt"                  "lt_eq"               "map_batches"        
       [97] "map_elements"        "max"                 "mean"               
      [100] "median"              "meta"                "min"                
      [103] "mod"                 "mode"                "mul"                
      [106] "n_unique"            "name"                "nan_max"            
      [109] "nan_min"             "neq"                 "neq_missing"        
      [112] "not"                 "null_count"          "or"                 
      [115] "otherwise"           "over"                "pct_change"         
      [118] "peak_max"            "peak_min"            "pow"                
      [121] "print"               "product"             "qcut"               
      [124] "quantile"            "rank"                "rechunk"            
      [127] "reinterpret"         "rep"                 "repeat_by"          
      [130] "replace"             "replace_strict"      "reshape"            
      [133] "reverse"             "rle"                 "rle_id"             
      [136] "rolling"             "rolling_max"         "rolling_max_by"     
      [139] "rolling_mean"        "rolling_mean_by"     "rolling_median"     
      [142] "rolling_median_by"   "rolling_min"         "rolling_min_by"     
      [145] "rolling_quantile"    "rolling_quantile_by" "rolling_skew"       
      [148] "rolling_std"         "rolling_std_by"      "rolling_sum"        
      [151] "rolling_sum_by"      "rolling_var"         "rolling_var_by"     
      [154] "round"               "sample"              "search_sorted"      
      [157] "set_sorted"          "shift"               "shift_and_fill"     
      [160] "shrink_dtype"        "shuffle"             "sign"               
      [163] "sin"                 "sinh"                "skew"               
      [166] "slice"               "sort"                "sort_by"            
      [169] "sqrt"                "std"                 "str"                
      [172] "struct"              "sub"                 "sum"                
      [175] "tail"                "tan"                 "tanh"               
      [178] "to_physical"         "to_r"                "to_series"          
      [181] "top_k"               "unique"              "unique_counts"      
      [184] "upper_bound"         "value_counts"        "var"                
      [187] "when"                "xor"                

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
        [1] "abs"                 "add"                 "alias"              
        [4] "all"                 "and"                 "any"                
        [7] "append"              "approx_n_unique"     "arccos"             
       [10] "arccosh"             "arcsin"              "arcsinh"            
       [13] "arctan"              "arctanh"             "arg_max"            
       [16] "arg_min"             "arg_sort"            "arg_unique"         
       [19] "arr"                 "backward_fill"       "bin"                
       [22] "bottom_k"            "cast"                "cat"                
       [25] "ceil"                "chunk_lengths"       "clear"              
       [28] "clip"                "clip_max"            "clip_min"           
       [31] "clone"               "compare"             "cos"                
       [34] "cosh"                "count"               "cum_count"          
       [37] "cum_max"             "cum_min"             "cum_prod"           
       [40] "cum_sum"             "cumulative_eval"     "cut"                
       [43] "diff"                "div"                 "dot"                
       [46] "drop_nans"           "drop_nulls"          "dt"                 
       [49] "dtype"               "entropy"             "eq"                 
       [52] "eq_missing"          "equals"              "ewm_mean"           
       [55] "ewm_std"             "ewm_var"             "exp"                
       [58] "explode"             "extend_constant"     "fill_nan"           
       [61] "fill_null"           "filter"              "first"              
       [64] "flags"               "flatten"             "floor"              
       [67] "floor_div"           "forward_fill"        "gather"             
       [70] "gather_every"        "gt"                  "gt_eq"              
       [73] "has_nulls"           "hash"                "head"               
       [76] "implode"             "interpolate"         "is_between"         
       [79] "is_duplicated"       "is_finite"           "is_first_distinct"  
       [82] "is_in"               "is_infinite"         "is_last_distinct"   
       [85] "is_nan"              "is_not_nan"          "is_not_null"        
       [88] "is_null"             "is_numeric"          "is_sorted"          
       [91] "is_unique"           "item"                "kurtosis"           
       [94] "last"                "len"                 "limit"              
       [97] "list"                "log"                 "log10"              
      [100] "lower_bound"         "lt"                  "lt_eq"              
      [103] "map_batches"         "map_elements"        "max"                
      [106] "mean"                "median"              "min"                
      [109] "mod"                 "mode"                "mul"                
      [112] "n_chunks"            "n_unique"            "name"               
      [115] "nan_max"             "nan_min"             "neq"                
      [118] "neq_missing"         "not"                 "null_count"         
      [121] "or"                  "pct_change"          "peak_max"           
      [124] "peak_min"            "pow"                 "print"              
      [127] "product"             "qcut"                "quantile"           
      [130] "rank"                "rechunk"             "reinterpret"        
      [133] "rename"              "rep"                 "repeat_by"          
      [136] "replace"             "replace_strict"      "reshape"            
      [139] "reverse"             "rle"                 "rle_id"             
      [142] "rolling_max"         "rolling_max_by"      "rolling_mean"       
      [145] "rolling_mean_by"     "rolling_median"      "rolling_median_by"  
      [148] "rolling_min"         "rolling_min_by"      "rolling_quantile"   
      [151] "rolling_quantile_by" "rolling_skew"        "rolling_std"        
      [154] "rolling_std_by"      "rolling_sum"         "rolling_sum_by"     
      [157] "rolling_var"         "rolling_var_by"      "round"              
      [160] "sample"              "search_sorted"       "set_sorted"         
      [163] "shape"               "shift"               "shift_and_fill"     
      [166] "shrink_dtype"        "shuffle"             "sign"               
      [169] "sin"                 "sinh"                "skew"               
      [172] "slice"               "sort"                "sort_by"            
      [175] "sqrt"                "std"                 "str"                
      [178] "struct"              "sub"                 "sum"                
      [181] "tail"                "tan"                 "tanh"               
      [184] "to_frame"            "to_list"             "to_lit"             
      [187] "to_physical"         "to_r"                "to_vector"          
      [190] "top_k"               "unique"              "unique_counts"      
      [193] "upper_bound"         "value_counts"        "var"                
      [196] "xor"                

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

