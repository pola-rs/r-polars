# default options

    Code
      polars_options()
    Output
      Options:
      ========                         
      debug_polars        FALSE
      df_knitr_print       auto
      do_not_repeat_call  FALSE
      int64_conversion   double
      maintain_order      FALSE
      no_messages         FALSE
      rpool_active            0
      rpool_cap               4
      strictly_immutable   TRUE
      
      See `?polars_options` for the definition of all options.

# options are validated

    Some polars options have an unexpected value:
    - strictly_immutable: input must be TRUE or FALSE.
    - debug_polars: input must be TRUE or FALSE.
    
    More info at `?polars_options`.

