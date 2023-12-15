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
       [91] "lit_to_df"         "log"               "log10"            
       [94] "lower_bound"       "lt"                "lt_eq"            
       [97] "map"               "map_batches"       "map_elements"     
      [100] "max"               "mean"              "median"           
      [103] "meta"              "min"               "mod"              
      [106] "mode"              "mul"               "n_unique"         
      [109] "name"              "nan_max"           "nan_min"          
      [112] "neq"               "neq_missing"       "not"              
      [115] "null_count"        "or"                "over"             
      [118] "pct_change"        "peak_max"          "peak_min"         
      [121] "pow"               "print"             "product"          
      [124] "quantile"          "rank"              "rechunk"          
      [127] "reinterpret"       "rep"               "rep_extend"       
      [130] "repeat_by"         "reshape"           "reverse"          
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
      [175] "value_counts"      "var"               "where"            
      [178] "xor"              

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

