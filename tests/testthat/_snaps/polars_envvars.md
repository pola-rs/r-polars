# default envvars

    Code
      default_envvars
    Output
      Environment variables:
      ========                                                                     
      POLARS_ACTIVATE_DECIMAL                                              
      POLARS_AUTO_STRUCTIFY                                                
      POLARS_FMT_MAX_COLS                                                 5
      POLARS_FMT_MAX_ROWS                                                 8
      POLARS_FMT_NUM_DECIMAL                                               
      POLARS_FMT_NUM_GROUP_SEPARATOR                                       
      POLARS_FMT_NUM_LEN                                                   
      POLARS_FMT_STR_LEN                                                 32
      POLARS_FMT_TABLE_CELL_ALIGNMENT                                  LEFT
      POLARS_FMT_TABLE_CELL_LIST_LEN                                      3
      POLARS_FMT_TABLE_CELL_NUMERIC_ALIGNMENT                          LEFT
      POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW                              0
      POLARS_FMT_TABLE_FORMATTING                       UTF8_FULL_CONDENSED
      POLARS_FMT_TABLE_HIDE_COLUMN_DATA_TYPES                             0
      POLARS_FMT_TABLE_HIDE_COLUMN_NAMES                                  0
      POLARS_FMT_TABLE_HIDE_COLUMN_SEPARATOR                              0
      POLARS_FMT_TABLE_HIDE_DATAFRAME_SHAPE_INFORMATION                   0
      POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE                            0
      POLARS_FMT_TABLE_ROUNDED_CORNERS                                    0
      POLARS_STREAMING_CHUNK_SIZE                                  variable
      POLARS_TABLE_WIDTH                                           variable
      POLARS_VERBOSE                                                      0
      POLARS_WARN_UNSTABLE                                                0
      
      See `?polars::polars_envvars` for the definition of all envvars.

# non-default value for each envvar: envvar=POLARS_FMT_MAX_COLS, value=1

    Code
      test_pl
    Output
      shape: (3, 2)
      ┌─────────────────┬───┐
      │ string_var      ┆ … │
      │ ---             ┆   │
      │ str             ┆   │
      ╞═════════════════╪═══╡
      │ some words      ┆ … │
      │ more words      ┆ … │
      │ even more words ┆ … │
      └─────────────────┴───┘

# non-default value for each envvar: envvar=POLARS_FMT_MAX_ROWS, value=1

    Code
      test_pl
    Output
      shape: (3, 2)
      ┌────────────┬─────────────────┐
      │ string_var ┆ list_var        │
      │ ---        ┆ ---             │
      │ str        ┆ list[f64]       │
      ╞════════════╪═════════════════╡
      │ some words ┆ [1.0, 2.0, 3.0] │
      │ …          ┆ …               │
      └────────────┴─────────────────┘

# non-default value for each envvar: envvar=POLARS_FMT_STR_LEN, value=3

    Code
      test_pl
    Output
      shape: (3, 2)
      ┌──────┬──────┐
      │ str… ┆ lis… │
      │ ---  ┆ ---  │
      │ str  ┆ list │
      │      ┆ [f64 │
      │      ┆ ]    │
      ╞══════╪══════╡
      │ som… ┆ [1.… │
      │ mor… ┆ [4.… │
      │ eve… ┆ [6.… │
      └──────┴──────┘

# non-default value for each envvar: envvar=POLARS_FMT_TABLE_CELL_ALIGNMENT, value=CENTER

    Code
      test_pl
    Output
      shape: (3, 2)
      ┌─────────────────┬─────────────────┐
      │    string_var   ┆     list_var    │
      │       ---       ┆       ---       │
      │       str       ┆    list[f64]    │
      ╞═════════════════╪═════════════════╡
      │    some words   ┆ [1.0, 2.0, 3.0] │
      │    more words   ┆ [4.0, 5.0, 6.0] │
      │ even more words ┆ [6.0, 7.0, 8.0] │
      └─────────────────┴─────────────────┘

# non-default value for each envvar: envvar=POLARS_FMT_TABLE_CELL_LIST_LEN, value=1

    Code
      test_pl
    Output
      shape: (3, 2)
      ┌─────────────────┬───────────┐
      │ string_var      ┆ list_var  │
      │ ---             ┆ ---       │
      │ str             ┆ list[f64] │
      ╞═════════════════╪═══════════╡
      │ some words      ┆ [… 3.0]   │
      │ more words      ┆ [… 6.0]   │
      │ even more words ┆ [… 8.0]   │
      └─────────────────┴───────────┘

# non-default value for each envvar: envvar=POLARS_FMT_TABLE_CELL_NUMERIC_ALIGNMENT, value=RIGHT

    Code
      test_pl
    Output
      shape: (3, 2)
      ┌─────────────────┬─────────────────┐
      │ string_var      ┆ list_var        │
      │ ---             ┆ ---             │
      │ str             ┆ list[f64]       │
      ╞═════════════════╪═════════════════╡
      │ some words      ┆ [1.0, 2.0, 3.0] │
      │ more words      ┆ [4.0, 5.0, 6.0] │
      │ even more words ┆ [6.0, 7.0, 8.0] │
      └─────────────────┴─────────────────┘

# non-default value for each envvar: envvar=POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW, value=1

    Code
      test_pl
    Output
      ┌─────────────────┬─────────────────┐
      │ string_var      ┆ list_var        │
      │ ---             ┆ ---             │
      │ str             ┆ list[f64]       │
      ╞═════════════════╪═════════════════╡
      │ some words      ┆ [1.0, 2.0, 3.0] │
      │ more words      ┆ [4.0, 5.0, 6.0] │
      │ even more words ┆ [6.0, 7.0, 8.0] │
      └─────────────────┴─────────────────┘
      shape: (3, 2)

# non-default value for each envvar: envvar=POLARS_FMT_TABLE_FORMATTING, value=ASCII_HORIZONTAL_ONLY

    Code
      test_pl
    Output
      shape: (3, 2)
      -----------------------------------
       string_var        list_var        
       ---               ---             
       str               list[f64]       
      ===================================
       some words        [1.0, 2.0, 3.0] 
      -----------------------------------
       more words        [4.0, 5.0, 6.0] 
      -----------------------------------
       even more words   [6.0, 7.0, 8.0] 
      -----------------------------------

# non-default value for each envvar: envvar=POLARS_FMT_TABLE_HIDE_COLUMN_DATA_TYPES, value=1

    Code
      test_pl
    Output
      shape: (3, 2)
      ┌─────────────────┬─────────────────┐
      │ string_var      ┆ list_var        │
      ╞═════════════════╪═════════════════╡
      │ some words      ┆ [1.0, 2.0, 3.0] │
      │ more words      ┆ [4.0, 5.0, 6.0] │
      │ even more words ┆ [6.0, 7.0, 8.0] │
      └─────────────────┴─────────────────┘

# non-default value for each envvar: envvar=POLARS_FMT_TABLE_HIDE_COLUMN_NAMES, value=1

    Code
      test_pl
    Output
      shape: (3, 2)
      ┌─────────────────┬─────────────────┐
      │ str             ┆ list[f64]       │
      ╞═════════════════╪═════════════════╡
      │ some words      ┆ [1.0, 2.0, 3.0] │
      │ more words      ┆ [4.0, 5.0, 6.0] │
      │ even more words ┆ [6.0, 7.0, 8.0] │
      └─────────────────┴─────────────────┘

# non-default value for each envvar: envvar=POLARS_FMT_TABLE_HIDE_COLUMN_SEPARATOR, value=1

    Code
      test_pl
    Output
      shape: (3, 2)
      ┌─────────────────┬─────────────────┐
      │ string_var      ┆ list_var        │
      │ str             ┆ list[f64]       │
      ╞═════════════════╪═════════════════╡
      │ some words      ┆ [1.0, 2.0, 3.0] │
      │ more words      ┆ [4.0, 5.0, 6.0] │
      │ even more words ┆ [6.0, 7.0, 8.0] │
      └─────────────────┴─────────────────┘

# non-default value for each envvar: envvar=POLARS_FMT_TABLE_HIDE_DATAFRAME_SHAPE_INFORMATION, value=1

    Code
      test_pl
    Output
      ┌─────────────────┬─────────────────┐
      │ string_var      ┆ list_var        │
      │ ---             ┆ ---             │
      │ str             ┆ list[f64]       │
      ╞═════════════════╪═════════════════╡
      │ some words      ┆ [1.0, 2.0, 3.0] │
      │ more words      ┆ [4.0, 5.0, 6.0] │
      │ even more words ┆ [6.0, 7.0, 8.0] │
      └─────────────────┴─────────────────┘

# non-default value for each envvar: envvar=POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE, value=1

    Code
      test_pl
    Output
      shape: (3, 2)
      ┌──────────────────┬──────────────────────┐
      │ string_var (str) ┆ list_var (list[f64]) │
      ╞══════════════════╪══════════════════════╡
      │ some words       ┆ [1.0, 2.0, 3.0]      │
      │ more words       ┆ [4.0, 5.0, 6.0]      │
      │ even more words  ┆ [6.0, 7.0, 8.0]      │
      └──────────────────┴──────────────────────┘

# non-default value for each envvar: envvar=POLARS_FMT_TABLE_ROUNDED_CORNERS, value=1

    Code
      test_pl
    Output
      shape: (3, 2)
      ╭─────────────────┬─────────────────╮
      │ string_var      ┆ list_var        │
      │ ---             ┆ ---             │
      │ str             ┆ list[f64]       │
      ╞═════════════════╪═════════════════╡
      │ some words      ┆ [1.0, 2.0, 3.0] │
      │ more words      ┆ [4.0, 5.0, 6.0] │
      │ even more words ┆ [6.0, 7.0, 8.0] │
      ╰─────────────────┴─────────────────╯

