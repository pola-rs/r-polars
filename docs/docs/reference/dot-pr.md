data

*Source: [R/after-wrappers.R](https://github.com/pola-rs/r-polars/tree/main/R/after-wrappers.R)*

# polars-API: private calls to rust-polars

## Format

An object of class `environment` of length 16.

```r
.pr
```

`.pr`

Original extendr bindings converted into pure functions

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#.pr$DataFrame$print() is an external function where self is passed as arg</span></span></span>
<span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/dot-pr.html'>.pr</a></span><span class='op'>$</span><span class='va'>DataFrame</span><span class='op'>$</span><span class='fu'>print</span><span class='op'>(</span>self <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (150, 5)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬──────────────┬─────────────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width ┆ Species   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---          ┆ ---         ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64          ┆ f64         ┆ f64          ┆ f64         ┆ cat       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪══════════════╪═════════════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 3.5         ┆ 1.4          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.9          ┆ 3.0         ┆ 1.4          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.7          ┆ 3.2         ┆ 1.3          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.6          ┆ 3.1         ┆ 1.5          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          ┆ ...         ┆ ...          ┆ ...         ┆ ...       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.3          ┆ 2.5         ┆ 5.0          ┆ 1.9         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.5          ┆ 3.0         ┆ 5.2          ┆ 2.0         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.2          ┆ 3.4         ┆ 5.4          ┆ 2.3         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.9          ┆ 3.0         ┆ 5.1          ┆ 1.8         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴──────────────┴─────────────┴───────────┘</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (150, 5)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬──────────────┬─────────────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width ┆ Species   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---          ┆ ---         ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64          ┆ f64         ┆ f64          ┆ f64         ┆ cat       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪══════════════╪═════════════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 3.5         ┆ 1.4          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.9          ┆ 3.0         ┆ 1.4          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.7          ┆ 3.2         ┆ 1.3          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.6          ┆ 3.1         ┆ 1.5          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          ┆ ...         ┆ ...          ┆ ...         ┆ ...       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.3          ┆ 2.5         ┆ 5.0          ┆ 1.9         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.5          ┆ 3.0         ┆ 5.2          ┆ 2.0         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.2          ┆ 3.4         ┆ 5.4          ┆ 2.3         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.9          ┆ 3.0         ┆ 5.1          ┆ 1.8         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴──────────────┴─────────────┴───────────┘</span>
<span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/print_env.html'>print_env</a></span><span class='op'>(</span><span class='va'>.pr</span>,<span class='st'>".pr the collection of private method calls to rust-polars"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     .pr the collection of private method calls to rust-polars ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        DataFrame ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ by_agg ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ clone_see_me_macro ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ columns ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop_in_place ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dtype_strings ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dtypes ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ estimated_size ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ export_stream ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ frame_equal ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ from_arrow_record_batches ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ get_column ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ get_columns ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lazy ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_par_from_list ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_with_capacity ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ null_count ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ schema ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ select ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ select_at_idx ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ set_column_from_robj ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ set_column_from_series ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ set_column_names_mut ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shape ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_list ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_list_tag_structs ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_list_unwind ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_struct ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ unnest ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        DataType ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ eq ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ get_all_simple_type_names ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ get_insides ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_temporal ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ne ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_datetime ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_duration ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_list ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_object ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_struct ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ same_outer_datatype ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        DataTypeVector ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ from_rlist ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ push ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        Expr ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ abs ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ add ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ agg_groups ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ alias ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ all ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ and ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ any ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ append ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arccos ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arccosh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arcsin ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arcsinh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arctan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arctanh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_sort ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arr_contains ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arr_lengths ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ backward_fill ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ bin_contains ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ bin_decode_base64 ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ bin_decode_hex ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ bin_encode_base64 ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ bin_encode_hex ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ bin_ends_with ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ bin_starts_with ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cast ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cat_set_ordering ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ceil ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ clip ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ clip_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ clip_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ col ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cols ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cos ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cosh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ count ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cumcount ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cummax ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cummin ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cumprod ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cumsum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cumulative_eval ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ diff ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ div ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dot ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop_nans ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop_nulls ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_cast_time_unit ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_combine ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_convert_time_zone ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_day ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_epoch_seconds ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_hour ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_iso_year ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_microsecond ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_millisecond ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_minute ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_month ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_nanosecond ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_offset_by ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_ordinal_day ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_quarter ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_replace_time_zone ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_round ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_second ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_strftime ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_truncate ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_tz_localize ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_week ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_weekday ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_with_time_unit ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt_year ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dtype_cols ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ duration_days ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ duration_hours ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ duration_microseconds ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ duration_milliseconds ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ duration_minutes ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ duration_nanoseconds ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ duration_seconds ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ entropy ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ eq ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ewm_mean ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ewm_std ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ewm_var ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ exclude ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ exclude_dtype ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ exp ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ explode ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ extend_constant ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ extend_expr ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ fill_nan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ fill_null ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ fill_null_with_strategy ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ filter ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ first ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ flatten ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ floor ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ forward_fill ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ gt ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ gt_eq ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ hash ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ head ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ interpolate ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_duplicated ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_finite ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_first ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_in ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_infinite ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_nan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_not ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_not_nan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_not_null ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_null ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ keep_name ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ kurtosis ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ last ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ len ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ list ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lit ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ log ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ log10 ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lower_bound ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_arg_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_arg_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_diff ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_eval ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_get ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_join ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_mean ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_reverse ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_shift ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_slice ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_sort ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_sum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_take ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_to_struct ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lst_unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lt ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lt_eq ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ map ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ map_alias ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ mean ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ median ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ meta_eq ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ meta_has_multiple_outputs ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ meta_is_regex_projection ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ meta_output_name ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ meta_pop ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ meta_roots ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ meta_undo_aliases ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ mode ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ mul ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ n_unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ nan_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ nan_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ neq ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_count ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_first ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_last ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ null_count ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ or ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ over ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ pct_change ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ pow ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ prefix ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ product ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ quantile ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rank ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rechunk ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ reinterpret ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rep ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ repeat_by ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ reshape ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ reverse ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_mean ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_median ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_quantile ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_skew ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_std ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_sum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_var ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ round ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sample_frac ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sample_n ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ search_sorted ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shift ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shift_and_fill ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shrink_dtype ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shuffle ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sign ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sin ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sinh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ skew ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ slice ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sort ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sort_by ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ std ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_base64_decode ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_base64_encode ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_concat ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_contains ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_count_match ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_ends_with ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_extract ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_extract_all ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_hex_decode ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_hex_encode ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_json_extract ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_json_path_match ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_lengths ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_ljust ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_lstrip ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_n_chars ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_parse_date ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_parse_datetime ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_parse_int ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_parse_time ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_replace ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_replace_all ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_rjust ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_rstrip ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_slice ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_split ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_split_exact ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_splitn ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_starts_with ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_strip ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_to_lowercase ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_to_uppercase ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str_zfill ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ struct_field_by_name ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ struct_rename_fields ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sub ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ suffix ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ tail ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ take ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ take_every ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ tan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ tanh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ timestamp ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_physical ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ top_k ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ unique_counts ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ unique_stable ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ upper_bound ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ value_counts ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ var ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ xor ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ GroupBy ; NULL ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        LazyFrame ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ collect ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ collect_background ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ describe_optimized_plan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ describe_plan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop_nulls ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ fill_nan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ fill_null ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ filter ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ first ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ groupby ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ join ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ last ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ limit ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ mean ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ median ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ quantile ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ reverse ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ select ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shift ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shift_and_fill ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ slice ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sort_by_exprs ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ std ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ tail ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ var ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ with_column ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ with_columns ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        LazyGroupBy ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ agg ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ head ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ tail ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        PolarsBackgroundHandle ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_exhausted ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ join ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        ProtoExprArray ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ push_back_rexpr ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ push_back_str ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        RField ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ clone ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ get_datatype ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ get_name ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ set_datatype_mut ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ set_name_mut ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        RNullValues ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_all_columns ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_columns ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_named ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        Series ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ abs ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ add ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ alias ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ all ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ any ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ append_mut ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ apply ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ceil ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ chunk_lengths ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ clone ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ compare ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cumsum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ div ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dtype ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ floor ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ from_arrow ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ get_fmt ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_sorted ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_sorted_flag ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_sorted_reverse_flag ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ len ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ mul ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ name ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ panic ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rem ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rename_mut ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rep ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ series_equal ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ set_sorted_mut ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shape ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sleep ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sort_mut ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sub ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_fmt_char ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_frame ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_r ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ value_counts ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        VecDataFrame ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ push ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ with_capacity ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        When ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ then ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ when ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        WhenThen ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ otherwise ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ when ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        WhenThenThen ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ otherwise ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ then ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ when ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>