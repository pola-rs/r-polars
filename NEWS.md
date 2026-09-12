# NEWS

## polars 1.16.0

This is the last release before R Polars 2.0. It doesn't remove any existing API
and keeps the behaviour of Polars 1.x, except where noted below. However, it comes
with a number of deprecation warnings and suggestions that can be applied before
moving to R Polars 2.0, which will break code or silently produce wrong results
otherwise.

Note that **some changes described below cannot warn**, meaning that you should
manually check your code when upgrading.

### Polars 2.0 changes that cannot warn

#### The streaming engine becomes the default

`engine = "auto"` used to select the `in-memory` engine for most queries in
Polars 1.x, but it will select the `streaming` engine in Polars 2.0.

The streaming engine may change the row order of the output, so if you rely on
it you should make this row order explicit with `$sort()` or an operation-specific
ordering option (e.g. with the argument `.maintain_order` in some functions).

Pass `engine = "in-memory"` to keep the behavior from Polars 1.x.

#### CSV reading

- Automatically generated column names for headerless files start at zero. For
  example, the first generated name changes from `column_1` to `column_0`.
- When `schema` is supplied, fields are matched to file columns by name rather
  than position, while the file's column order is preserved.
- Without reading a file, it is not possible to detect that a fully named
  `schema` changes the order of fields while preserving the file's column
  order. Review code that relies on the positional interpretation of `schema`.
- `schema_overrides` must be fully named when it is partial. A fully unnamed
  list remains positional, but must include one override for every CSV column;
  a mixture of named and unnamed elements is not supported.

#### Type coercion and casting become stricter

- The supertype of a signed integer type and `UInt64` changes from `Float64` to
  `Int128`.
- Lossy numeric coercion in `is_in()`, `<expr>$list$contains()`, and
  `<expr>$arr$contains()` becomes an error. Cast the operands explicitly to
  compatible numeric dtypes.
- Strict casts to a `Struct` dtype reject mismatched fields.
- `$std()` and `$ewm_std()` on `Duration` columns become errors.

#### Other behavior changes

- The output column names of `pl$datetime()` and `pl$repeat_()` change. Use
  `$alias()` if your code depends on a particular output name.
- Sampling list values with `with_replacement = TRUE` and `shuffle = FALSE`
  may return values in a different order, even with a fixed `seed`.
- Transposing an empty DataFrame succeeds instead of raising an error.
- Null `List` and `Array` values remain outer nulls when converted with `$to_struct()`.
- Dropping every column of a three-row DataFrame or LazyFrame retains its height
  instead of collapsing to zero, returning a frame of shape `(3, 0)`. Selecting
  no columns remains a `(0, 0)` result. In Polars 2.0, an empty `pl$DataFrame()`
  has a fixed height of `0`, so adding a longer column with `$with_columns()`
  raises instead of adopting the new column's length.

### Deprecations

Unless noted otherwise, the deprecated forms below retain their Polars 1.x
behavior in R Polars 1.16 but no longer retain that behavior in R Polars 2.0.

#### Column selection and selectors

- The `...` interfaces of `pl$col()`, `cs$by_name()`, and `cs$by_dtype()` are
  deprecated. Pass column names or data types as one vector or list instead, for
  example `pl$col(c("a", "b"))`, `cs$by_name(c("a", "b"))`, or
  `cs$by_dtype(c(pl$Int32, pl$Float64))` (#1857).
- Using a bare `pl$col()` as the right-hand operand of selector `&`, `|`, or
  `$xor()` is deprecated. Use `cs$by_name()` for set operations on columns, or
  `<selector>$as_expr()` for element-wise operations (#1861).

#### Aggregation helpers

- The dynamic-dots interfaces of `pl$all()`, `pl$any()`, `pl$max()`, `pl$min()`,
  `pl$sum()`, and `pl$cum_sum()` are deprecated. Pass column names or data types
  in a single `names` argument instead.

#### String patterns and struct fields

- Bare character vectors passed to `<expr>$str$contains_any()` and
  `<expr>$str$replace_many()` will be interpreted as column names in Polars 2.0.
  Use `pl$lit(...)$implode()` for literal patterns or `pl$col()` for column patterns.
  A shared literal vector can also be passed as `list(c(...))` (#1855).
- Passing a flat character vector as `replace_with` to
  `<expr>$str$replace_many()` is deprecated. Use `list(c(...))` for a literal
  scalar or vector replacement; Polars 2.0 requires the list form.
- For `<expr>$list$to_struct()` and `<series>$list$to_struct()`, omitting `fields`
  or passing a function as `fields` is deprecated. The `n_field_strategy` argument
  is also deprecated in all forms. Pass an explicit character vector of field
  names instead (#1863).
- `upper_bound` is deprecated for `<expr>$list$to_struct()`. Passing a function to
  `fields` are deprecated for `<expr>$arr$to_struct()` and `<series>$arr$to_struct()`
  (#1863).

#### Readers and writers

- A complete CSV `schema` with any unnamed elements is deprecated. In Polars
  2.0, schema fields are matched to CSV columns by name; name every element
  with its corresponding CSV column name.
- Omitting `infer_schema_files` in CSV readers now warns because its default
  changes from `NULL` to `10` in Polars 2.0. Pass `infer_schema_files = 10` to
  opt into the new default, or `infer_schema_files = NULL` to continue using all
  files (#1870).
- Omitting `raise_if_empty` when reading a CSV with `has_header = FALSE` and a
  non-`NULL` `schema` now warns because its default becomes `FALSE` in Polars
  2.0. In other cases, the effective default remains `TRUE` without a warning.
  Pass an explicit value to select the desired behavior.
- Omitting `compression` in `$write_ipc()` and `$sink_ipc()` now warns because
  the default changes from `"zstd"` to `"uncompressed"` in Polars 2.0. Pass
  `compression = "zstd"` to preserve the current behavior, or `compression = "uncompressed"`
  to opt into the new default (#1856).
- The `cache` argument of CSV and Arrow IPC File Format readers is deprecated.
  Polars 2.0 streaming readers do not use the file cache, and there is no direct
  replacement. Remove the argument (#1865).
- The already-deprecated `file_cache_ttl` argument of CSV, Arrow IPC File Format,
  and NDJSON readers is no longer translated into `storage_options` and can be
  removed (#1854, #1865).

#### Other methods and arguments

- Casting a non-list expression, including a column expression, to a `List`
  dtype is deprecated. Use `pl$list(expr)` to construct a list expression
  instead.
- The `seed_1`, `seed_2`, and `seed_3` arguments of `<expr>$hash()` and
  `<dataframe>$hash_rows()` are deprecated. Polars 2.0 removes them and retains
  only `seed`. Hash values are not guaranteed to remain the same across Polars
  versions (#1860).
- `<expr>$agg_groups()` is deprecated. Use the row-index aggregation pattern
  documented in its help page instead (#1859).
- `<series>$cat$is_local()` and `<series>$cat$uses_lexical_ordering()` are
  deprecated. Categoricals no longer have a local scope and are always ordered
  lexically (#1859).
- `<Enum>$union()` is deprecated. Construct an Enum explicitly from the combined
  categories instead (#1859).

#### Migration notes for deprecations from earlier releases

The following APIs were already deprecated before R Polars 1.16. They are
repeated here because their Polars 2.0 migration path was previously incomplete,
incorrect, or easy to miss.

- `<expr>$flatten()` (deprecated in 1.9.0): use `$list$explode(empty_as_null = FALSE, keep_nulls = FALSE)`
  for Polars 2.0-compatible behavior. To preserve the legacy behavior instead,
  set both arguments to `TRUE` (#1866).
- `<expr>$str$concat()` (deprecated before 1.0.0): use `$str$join("-")` when
  `delimiter` is omitted, or pass the same delimiter explicitly to `$str$join()`
  (#1866).
- `allow_missing_columns` in Parquet readers (deprecated in 1.7.0): use
  `missing_columns = "insert"` for `TRUE` or `missing_columns = "raise"`
  for `FALSE` (#1866).
- `<lazyframe>$profile()` (deprecated in 1.14.0): this will be entirely removed
  because Polars will use the streaming engine by default, which makes the
  profiling information reported by this method misleading (#1866).
- `<expr>$dt$with_time_unit()` (deprecated before 1.0.0): cast to `Int64`, then
  cast to the desired `Datetime` or `Duration` dtype and time unit (#1866).
- `<expr>$cat$get_categories()` (deprecated in 1.14.0): this will be entirely
  removed. Use `$unique()` for the distinct values present in a Categorical
  column, or `dtype$categories` for the fixed category list of an Enum.
- The `strict` argument of `pl$concat()` (deprecated in 1.13.0): in Polars 2.0,
  `how = "horizontal"` requires all frames to have the same height instead of
  padding shorter frames with `null`. Use `how = "horizontal_extend"` to preserve
  padding, or pass `strict = TRUE` in R Polars 1.16 to opt into the Polars 2.0
  behavior early.

### Bug fixes

- Deprecated query-optimization arguments on LazyFrame methods are forwarded
  correctly again. `collapse_joins = FALSE` was previously ignored, while
  `no_optimization = TRUE` left `simplify_expression` and `fast_projection`
  enabled (#1864).

## polars 1.15.0

This is an update that corresponds to Python Polars 1.44.1.

### Deprecations

- The `rechunk` argument of `pl$read_csv()`, `pl$scan_csv()`,
  `pl$read_parquet()`, `pl$scan_parquet()`, `pl$read_ndjson()`,
  `pl$scan_ndjson()`, `pl$read_ipc()`, `pl$scan_ipc()` and
  `pl$read_ipc_stream()` is deprecated. Call `$rechunk()` on the output
  instead
  (#1842, [pola-rs/polars#28063](https://github.com/pola-rs/polars/pull/28063)).
- `<expr>$rechunk()` is deprecated. Rechunking within a query is not
  well-defined; call `$rechunk()` on the DataFrame after collecting the
  results instead
  (#1842, [pola-rs/polars#28692](https://github.com/pola-rs/polars/pull/28692)).
- `<expr>$struct$rename_fields()` now warns when the number of names passed
  doesn't match the number of fields of the struct. This will become an error
  in Polars 2.0. Use the new `<expr>$struct$drop()` to drop the trailing
  fields first
  (#1842, [pola-rs/polars#28672](https://github.com/pola-rs/polars/pull/28672)).

### New features

- `<expr>$struct$drop()` to drop one or more fields from a struct
  (#1842, [pola-rs/polars#28666](https://github.com/pola-rs/polars/pull/28666)).
- `<expr>$arr$dot()` to compute the row-wise dot product of two `Array`
  columns of numeric type
  (#1842, [pola-rs/polars#28504](https://github.com/pola-rs/polars/pull/28504),
  [pola-rs/polars#28829](https://github.com/pola-rs/polars/pull/28829)).
- `<lazyframe>$join_where()` and `<dataframe>$join_where()` gain a `how`
  argument, which accepts `"inner"` (default), `"left"` and `"right"`
  (#1842, [pola-rs/polars#28880](https://github.com/pola-rs/polars/pull/28880)).
- `pl$read_csv()` and `pl$scan_csv()` gain the experimental
  `infer_schema_files` argument to control how many files are used to infer
  the schema when reading several files at once
  (#1842, [pola-rs/polars#28809](https://github.com/pola-rs/polars/pull/28809)).

### Bug fixes

- `pl$when()$then()$otherwise()` could return incorrect results in some cases
  involving broadcasting or a non-scalar null mask
  (#1842, [pola-rs/polars#28970](https://github.com/pola-rs/polars/pull/28970),
  [pola-rs/polars#28946](https://github.com/pola-rs/polars/pull/28946)).
- `pl$min_horizontal()` and `pl$max_horizontal()` now ignore `NaN` values, as
  `pl$min()` and `pl$max()` already do
  (#1842, [pola-rs/polars#28710](https://github.com/pola-rs/polars/pull/28710)).
- `<expr>$rolling_*_by()` now returns `null` for rows where the `by` column is
  `null` instead of producing incorrect results
  (#1842, [pola-rs/polars#27367](https://github.com/pola-rs/polars/pull/27367)).
- `<expr>$dt$add_business_days()` now propagates `null` values in its input
  correctly
  (#1842, [pola-rs/polars#28703](https://github.com/pola-rs/polars/pull/28703)).
- `<expr>$sum()` on a `Decimal` column now raises on overflow instead of
  silently wrapping around
  (#1842, [pola-rs/polars#28688](https://github.com/pola-rs/polars/pull/28688)).
- `<expr>$is_nan()`, `<expr>$is_not_nan()`, `<expr>$is_finite()`, and
  `<expr>$is_infinite()` now return `null` for `null` entries
  (#1842, [pola-rs/polars#28883](https://github.com/pola-rs/polars/pull/28883)).
- `pl$lit(x, dtype = pl$Unknown)` now behaves identically to `pl$lit(x)`
  (#1842, [pola-rs/polars#28830](https://github.com/pola-rs/polars/pull/28830)).
- Fixed several data-correctness issues when importing Arrow data: `null`
  values in `Map` arrays, buffer offsets for `String` and `Binary`, and
  nested `LargeList` values
  (#1842, [pola-rs/polars#28680](https://github.com/pola-rs/polars/pull/28680),
  [pola-rs/polars#28662](https://github.com/pola-rs/polars/pull/28662),
  [pola-rs/polars#28632](https://github.com/pola-rs/polars/pull/28632)).
- Fixed reading Parquet files whose data pages contain concatenated gzip
  members
  (#1842, [pola-rs/polars#28808](https://github.com/pola-rs/polars/pull/28808)).
- The `mirai` integration no longer hangs indefinitely when a worker fails to
  deserialize a Polars object (for example because the worker loaded a
  different Polars build); the error is now reported immediately (#1842).

## polars 1.14.0

This is an update that corresponds to Python Polars 1.43.2.

### Deprecations

- The `missing_utf8_is_empty_string` argument of `pl$read_csv()` and
  `pl$scan_csv()` is deprecated in favor of `empty_string_is_null`, whose
  meaning is inverted
  ([pola-rs/polars#28173](https://github.com/pola-rs/polars/pull/28173)).
- `<expr>$cat$get_categories()` is deprecated. To get the distinct values
  present in a Categorical column, use `$unique()`. For the fixed category
  list of an Enum, use its `dtype$categories`
  ([pola-rs/polars#28299](https://github.com/pola-rs/polars/pull/28299)).
- `<series>$cat$to_local()` is deprecated; Categoricals no longer have a local
  scope
  ([pola-rs/polars#28299](https://github.com/pola-rs/polars/pull/28299)).
- `<lazyframe>$profile()` is deprecated. Starting with Polars 2.0,
  `engine = "auto"` will use the streaming engine by default, and the
  profiling information from this method would be misleading
  ([pola-rs/polars#28275](https://github.com/pola-rs/polars/pull/28275)).

### New features

- `pl$list()` to gather several elements into a list column. Contrary to
  `pl$concat_list()`, `pl$list()` doesn't merge elements into a single list,
  i.e. merging a `List(Float64)` and a `String` will give
  `List(List(Float64), String)`. (#1825)
- `<expr>$cat$to()` and `<expr>$cat$physical()` to convert between a Categorical
  or Enum column and its physical representation (#1826).

## polars 1.13.0

This is an update that corresponds to Python Polars 1.42.1.

### Deprecations

- The default value of the `empty_as_null` argument in `$explode()` will
  change from `TRUE` to `FALSE` in Polars 2.0. Affected functions:
  `<expr>$explode()`, `<expr>$list$explode()`, `<expr>$arr$explode()`,
  `<lazyframe>$explode()`, `<dataframe>$explode()`. A deprecation warning is
  now emitted when `empty_as_null` is not explicitly set
  ([pola-rs/polars#28040](https://github.com/pola-rs/polars/pull/28040), #1804).
- The `strict` argument of `pl$concat()` is deprecated. Use `how =
"horizontal_extend"` (pad with null) to keep the current behavior.
  `how = "horizontal"` will require equal heights by default in the next
  breaking release
  ([pola-rs/polars#27965](https://github.com/pola-rs/polars/pull/27965), #1812).

### New features

- Warnings from the Rust side, which were previously output to stderr, are now treated as R warnings (#1805).
- Deprecation warnings from the R side gain the `polars_warning` class and `polars_deprecation_warning` class (#1812).
- `pl$concat()` gains `how = "horizontal_extend"`, which stacks DataFrames
  horizontally and pads shorter frames with `null`
  ([pola-rs/polars#27965](https://github.com/pola-rs/polars/pull/27965), #1812).

## polars 1.12.0

This is an update that corresponds to Python Polars 1.41.2.

### New features

- `<expr>$gather()` gains an argument `null_on_oob` (#1789).

## polars 1.11.0

This is an update that corresponds to Python Polars 1.40.1.

### New features

- `pl$row_index()`, a shortcut for `pl$int_range(pl$len())` (#1770).
- `polars_code_completion_activate()` and `polars_code_completion_deactivate()` to
  enable Polars-specific code completion. This only works in RStudio for now (#1768).
- `<expr>$arr$any()`, `<expr>$arr$all()`, `<expr>$list$any()`, and `<expr>$list$all()`
  gain an argument `ignore_nulls` (#1778).
- `<dataframe>$merge_sorted()` and `<lazyframe>$merge_sorted()` gain an argument
  `maintain_order` (#1778).

### Other changes

- Bumped `rlang` dependency to be >= 1.2.0.

## polars 1.10.0

This is an update that corresponds to Python Polars 1.39.3.

### New features

- `<expr>$implode()` gains the `maintain_order` argument to control whether
  the order of elements within each group is preserved (#1751).
- `<expr>$set_sorted()` gains the `nulls_last` argument to specify the
  position of null values in the sorted order (#1751).
- `<expr>$dt$add_business_days()` now accepts a Polars expression for
  the `holidays` argument, in addition to R Date vectors (#1751).
- `$pivot()` gains the `column_naming` argument to control how pivoted
  column names are constructed (#1751).
- New `<expr>$truncate()` (#1755).
- `<expr>$round()` can now take `mode = "to_zero"` (#1755).
- `pl$scan_csv()` and `pl$read_csv()` gain the `missing_columns` argument to
  control behavior when some CSV files have missing columns compared to the
  expected schema (#1754).

### Bug fixes

- `$unpivot()` now properly checks for duplicate column names when using
  custom `value_name` or `variable_name`
  ([pola-rs/polars#26606](https://github.com/pola-rs/polars/pull/26606), #1751).

## polars 1.9.0

This is an update that corresponds to Python Polars 1.38.1.

### Deprecations

- The `retries` argument in scan/read and sink/write functions is deprecated (#1726).
  Use `max_retries` in `storage_options` instead.
- The `file_cache_ttl` argument in `pl$scan_csv()`, `pl$scan_ipc()`, `pl$scan_ndjson()`,
  and their `read_*` counterparts is deprecated (#1726). The previous
  recommendation to use `file_cache_ttl` in `storage_options` has since been
  superseded: the file cache is no longer supported and has no direct
  replacement in Polars 2.0.
- `<expr>$flatten()` is deprecated. Use
  `<expr>$list$explode(empty_as_null = FALSE, keep_nulls = FALSE)` for
  Polars 2.0-compatible behavior, or set both arguments to `TRUE` to preserve
  the legacy behavior (#1726).

### New features

- `cs$by_name()` gains the `expand_patterns` argument. When set to `TRUE`, regex patterns
  (`^...$`) and wildcards (`*`) in column names are expanded
  ([pola-rs/polars#26437](https://github.com/pola-rs/polars/pull/26437), #1726).
- New `<expr>$bin$get()` to extract a specific byte from a binary value (#1731).
- `<expr>$str$split()` has two new arguments `literal` and `strict` (#1730).
- New `pl$scan_lines()` and `pl$read_lines()` to read one or several files into
  a single column (#1732).
- `$sink_ndjson()`, `$write_ndjson()`, `$sink_csv()`, and `$write_csv()` can now export compressed files (#1733, #1735).

### Bug fixes

- `<expr>$rolling_rank_by()` now requires the `closed` argument to be `"right"` or `"both"`.
  Previously, `"left"` and `"none"` were silently accepted but could produce incorrect results
  ([pola-rs/polars#26287](https://github.com/pola-rs/polars/pull/26287), #1726).

### Other changes

- The `per_partition_sort_by` argument of the deprecated partition classes
  (`pl$PartitionByKey()`, `pl$PartitionMaxSize()`, `pl$PartitionParted()`) has been removed.
  This feature was removed from upstream Polars
  ([pola-rs/polars#26130](https://github.com/pola-rs/polars/pull/26130), #1726).

## polars 1.8.0

This is an update that corresponds to Python Polars 1.37.1.

### Deprecations

- The experimental partitioning scheme classes
  (constructed with `pl$PartitionByKey()`, `pl$PartitionMaxSize()`, or `pl$PartitionParted()`)
  are deprecated in favor of the new experimental partition by class, constructed with
  `pl$PartitionBy()` (#1716).

### New features

- New S3 method `nanoarrow::as_nanoarrow_array_stream(<lazyframe>)` to export a LazyFrame via the Arrow C stream interface
  ([pola-rs/polars#25918](https://github.com/pola-rs/polars/pull/25918), #1709).
- `<expr>$min_by()` and `<expr>$max_by()` to get the value of a column ordered by another column (#1715).

## polars 1.7.0

This is an update that corresponds to Python Polars 1.36.1, which includes significant internal changes.

### Deprecations

- The `allow_missing_columns` argument of `pl$scan_parquet()` and `pl$read_parquet()` is deprecated (#1662).
  Use the new `missing_columns` argument instead.
- `<expr>$index_of()` now strictly checks types. Therefore, operations like `$index_of(NA)`
  that worked previously will error if `NA` is converted to Bool type and the target column cannot be converted from Bool type.
  Use `NULL` or `vctrs::unspecified(1)` instead of `NA` for such operations (#1662).

### New features

- New data type `Float16` (#1673, [pola-rs/polars#25185](https://github.com/pola-rs/polars/pull/25185)).
- New method `<lazyframe>$pivot()` and `<dataframe>$pivot()`'s new argument `on_columns`
  (#1662, [pola-rs/polars#25016](https://github.com/pola-rs/polars/pull/25016)).
- `<lazyframe>$unique()` and `<dataframe>$unique()`' now allow polars expressions in `...`
  (#1662, [pola-rs/polars#25099](https://github.com/pola-rs/polars/pull/25099)).
- `<expr>$item()` to strictly extract a single value from an expression (#1652).
- `<expr>$arr$eval()` to run any Polars expression on all subarrays of an Array column (#1653).
- `<expr>$name$replace()` to replace expression names using regular expressions (#1654).
- `<expr>$dt$days_in_month()` (#1659).
- `<expr>$rolling_rank()` and `<expr>$rolling_rank_by()` (#1656).
- `<expr>$arr$agg()` and `<expr>$list$agg()`, similar to their `$eval()` counterparts
  but automatically explode the column if all elements return a scalar (#1655).
- `<expr>$rolling_kurtosis()` (#1665).
- `pl$explain_all()` to show a single optimized query plan from several input LazyFrames (#1666).
- `<expr>$bin$reinterpret()` (#1664).
- `<expr>$mode()` gains the `maintain_order` argument (#1662).
- The following methods gain two arguments, `empty_as_null` and `keep_nulls` (#1662).
  - `<expr>$explode()`
  - `<expr>$arr$explode()`
  - `<expr>$list$explode()`
  - `<lazyframe>$explode()`
- `is_list_of_polars_expr()` (#1662).
- `<groupby>$having()`, `<rolling_groupby>$having()`, `<dynamic_groupby>$having()`
  (and their lazy implementations) to filter groups before applying aggregations (#1671).
- `<expr>$str$extract_many()`, `<expr>$str$find_many()`, and `<expr>$str$replace_many()`
  gain the `leftmost` argument (#1673, [pola-rs/polars#25398](https://github.com/pola-rs/polars/pull/25398)).
- `pl$concat()` gains the `strict` argument (#1673, [pola-rs/polars#25452](https://github.com/pola-rs/polars/pull/25452)).

### Bug fixes

- `<expr>$list$eval()` now properly errors (as documented) if the input is not a Polars expression (#1655).
- `<lazyframe>$sink_parquet()` and `<dataframe>$write_parquet()`'s `compression` argument
  should not be `"lzo"`, which does not work correctly
  (#1673, [pola-rs/polars#25522](https://github.com/pola-rs/polars/pull/25522)).
- Installing on arm64 Windows (aarch64-pc-windows-gnullvm) now works (#1681, #1684).

### Other changes

- The experimental partitioning scheme class
  (constructed with `pl$PartitionByKey()`, `pl$PartitionMaxSize()`, or `pl$PartitionParted()`)
  is rewritten as S7 class (#1662).
- `pl$element()` is rewritten in Rust (#1662, [pola-rs/polars#24885](https://github.com/pola-rs/polars/pull/24885)).

## polars 1.6.0

This is an update that corresponds to Python Polars 1.35.2.

As of this version, this package depends on `{S7}`.
The newly added `QueryOptFlags` object is an S7 object.

### Deprecations

- The following arguments of certain LazyFrame methods, which were previously used for query optimization,
  are deprecated in favor of the new `optimizations` argument (#1635).
  Some arguments that were intended for internal use have been removed without deprecation.
  - `type_coercion`
  - `predicate_pushdown`
  - `projection_pushdown`
  - `simplify_expression`
  - `slice_pushdown`
  - `comm_subplan_elim`
  - `comm_subexpr_elim`
  - `cluster_with_columns`
  - `no_optimization`
  - `_type_check` (removed)
  - `_check_order` (removed)
  - `_eager` (removed)

  Functions affected are those that gained the `optimizations` argument.
  See the next new features section for details.

  For the experimental `<lazyframe>$lazy_sink_*` methods,
  the above arguments and the `collapse_joins` argument (deprecated as of polars 1.4.0) are removed.

- `<lazyframe>$to_dot()`s ignored `...` (dots) argument is deprecated (#1635).
  In future versions, an error will be raised if dots are not empty.

### New features

- The following functions gain the experimental `optimizations` argument
  taking a `QueryOptFlags` object (#1633, #1634, #1635).
  - `<lazyframe>$collect()`
  - `<lazyframe>$explain()`
  - `<lazyframe>$profile()`
  - `<lazyframe>$to_dot()`
  - `<lazyframe>$sink_batches()`
  - `<lazyframe>$sink_csv()`
  - `<lazyframe>$sink_ipc()`
  - `<lazyframe>$sink_parquet()`
  - `<lazyframe>$sink_ndjson()`
  - `as_polars_df(<lazyframe>)`
- The following functions gain the `engine` argument (#1635).
  - `<lazyframe>$explain()`
  - `<lazyframe>$profile()`
- `pl$collect_all()` to efficiently collect a list of LazyFrames (#1598, #1635).
- `<lazyframe>$remove()` and `<dataframe>$remove()` as a complement to
  `$filter()` (#1632).
- New method `<expr>$is_close()` (#1637).
- New methods `<group_by>$len()` and `<lazy_group_by>$len()` (#1638).

### Bug fixes

- Bump Rust Polars to py-1.35.2 (#1636).

## polars 1.5.0

This is an update that corresponds to Python Polars 1.35.1.

### New features

- `<lazyframe>$unnest()` and `<dataframe>$unnest()` gain the `separator` argument.
- Arithmetic operations between list columns are supported (#1589).
- `polars_info()` shows the corresponding Python Polars version and the supported
  Polars CompatLevel (#1591).
- Experimental `{reticulate}` integration.
  Series, DataFrame, and LazyFrame can be exchanged between R Polars and Python Polars
  using `reticulate::r_to_py()` and `as_polars_*` functions (#1607).
  Conversion of Series and DataFrame relies on `{nanoarrow}`
  ([apache/arrow-nanoarrow#817](https://github.com/apache/arrow-nanoarrow/pull/817)).

### Bug fixes

- `<expr>$pct_change()` preserves null values
  (#1603, [pola-rs/polars#24952](https://github.com/pola-rs/polars/pull/24952/files)).

## polars 1.4.0

This is an update that corresponds to Python Polars 1.34.0.

### Deprecations

- `pl$Decimal()`'s arguments should not be `NULL` (#1553).
  Since the automatic inference feature has been removed, `precision` and `scale` must always be specified.
- The `collapse_joins` argument of some LazyFrame methods is deprecated (#1553).
  Use `predicate_pushdown` instead.

### New features

- `<lazyframe>$sink_batches()` to apply a function to each reading batch (#1557).
- `<lazyframe>$lazy_sink_*` methods, variants of `<lazyframe>$sink_*` methods, that return a LazyFrame
  instead of executing immediately (#1562).
- `<lazyframe>$sink_*` methods gain the `engine` argument (#1562).
- `compat_level` or `polars_compat_level` arguments, which specifies the compatibility level with Apache Arrow format,
  can be overridden by the `polars.compat_level` option if not specified (#1565).
  This can be useful especially when overriding the behavior of `nanoarrow::as_nanoarrow_array_stream()` used in external packages' functions.
- `<dataframe>$write_ipc_stream()` to write Arrow IPC stream format (`.arrows` file) (#1570).
- `<expr>$dt$total_*` methods gain the new `fractional` argument
  ([pola-rs/polars#24598](https://github.com/pola-rs/polars/pull/24598), #1573).
- New function `polars_envvars()` to show all environment variables available
  in polars, for instance to customize the number of rows displayed when printing
  a DataFrame. This was available in `polars < 1.0.0` but not in the rewritten
  version until now (#1580).

### Bug fixes

- `<expr>$reshape()` does not allow `-1` in dimensions other than the first dimension
  ([pola-rs/polars#24591](https://github.com/pola-rs/polars/pull/24591), #1564).

## polars 1.3.1

This is an update that corresponds to Python Polars 1.33.1.

Only updates Rust dependencies (#1540, #1542).

## polars 1.3.0

This is an update that corresponds to Python Polars 1.33.0, which includes significant internal changes.

### Deprecations

Some entire expr methods or arguments of expr methods have been deprecated.
They still work the same way on series
([pola-rs/polars#24027](https://github.com/pola-rs/polars/pull/24027), #1507, #1531, #1534).

As a workaround of these deprecations, the new `<dataframe>$map_columns()` function can be used
to apply functions for Series to each column (#1533).

```r
df <- pl$DataFrame(n = list(c(0, 1), c(0, 1, 2)))

# `df$with_columns(pl$col("n")$list$to_struct(n_field_strategy = "max_width"))` no longer works identically.
df$map_columns("n", \(s) s$list$to_struct(n_field_strategy = "max_width"))
#> shape: (2, 1)
#> ┌────────────────┐
#> │ n              │
#> │ ---            │
#> │ struct[3]      │
#> ╞════════════════╡
#> │ {0.0,1.0,null} │
#> │ {0.0,1.0,2.0}  │
#> └────────────────┘
```

#### Entire expr method deprecations

- `<expr>$shrink_dtype()` (#1507).

#### Arguments of expr method deprecations

- `<expr>$list$to_struct()`'s first argument `n_field_strategy` (#1507).
- `<expr>$list$to_struct()`'s `upper_bound` argument must be specified when used with
  non-vector `fields` specification (#1534).
- `<expr>$str$json_decode()`'s first argument `dtype` must be specified (#1507).
- `<expr>$str$json_decode()`'s `infer_schema_length` (#1507).
- `<expr>$str$to_datetime()`'s first argument `format` or `time_zone` must be specified
  for time zone aware datetime (#1507).
  - Related to this, in `<expr>$str$strptime()`, if the string to be parsed contains a time zone,
    the time zone must be specified.
- `<expr>$str$to_decimal()`'s `inference_length` (#1507).
- `<expr>$str$to_decimal()`'s new `scale` argument must be specified (#1507).

### New features

- In `<expr>$log()`, argument `base` can now take an expression (#1523).
- New method `<dataframe>$map_columns()` (#1533).
- New method `<expr>$index_of()` (#1519).
- New argument `mkdir` in `<DataFrame>$write_parquet()` (#1525).

## polars 1.2.1

This is an update that corresponds to Python Polars 1.32.3.

Only updates Rust dependencies (#1502).

## polars 1.2.0

This is an update that corresponds to Python Polars 1.32.2.

### New features

#### New top-level functions

- `pl$concat_arr()` (#1490).
- `pl$linear_space()` (#1487).
- `pl$linear_spaces()` (#1487).

#### New methods of expr

- `<expr>$arr$len()` (#1478).
- `<expr>$dt$millennium()` (#1485).
- `<expr>$dt$replace()` (#1491).
- `<expr>$meta$is_literal()` (#1483).
- `<expr>$str$escape_regex()` (#1486).
- `<expr>$str$find_many()` (#1484).
- `<expr>$str$normalize()` (#1479).

### Performance

- The performance of converting character vectors to selectors has been improved,
  resolving performance issues when specifying column names with a large number of strings (#1481, #1493).

## polars 1.1.0

This is an update that corresponds to Python Polars 1.32.0, which includes significant internal changes.

### Deprecations

- `pl$Categorical()`'s first argument `ordering` is deprecated
  ([pola-rs/polars#23016](https://github.com/pola-rs/polars/pull/23016), #1452, #1468).
  In this version, global categories are always used, and the behavior matches the previous `ordering = "lexical"`.
- The experimental feature "auto structify" is deprecated
  ([pola-rs/polars#23351](https://github.com/pola-rs/polars/pull/23351), #1452, #1468).
  Since this feature could previously be used in two ways, both are now deprecated:
  - `as_polars_expr()`'s argument `structify`.
  - Setting the `POLARS_AUTO_STRUCTIFY` environment variable to `1`.
- `<lazyframe>$unique()` and `<dataframe>$unique()`'s first argument is replaced from `subset` to `...`
  (dynamic dots) (#1463).
  Because of this change, it is also deprecated to pass the following objects as the first argument of these functions:
  - `NULL`: Use `cs$all()` or pass nothing to select all columns.
    If you want to pass column selections as a variable, you can use the `%||%` (base R >= 4.4.0, or `{rlang}`'s op-null-default)
    operator to replace `NULL` with `cs$all()`:

    ```r
    subset <- nullable_selection %||% cs$all()
    lf$unique(!!!c(subset))
    ```

  - A list of column names or selectors: Use `!!!` to expand the list to the dynamic-dots.

    ```r
    subset <- list("col1", "col2")
    lf$unique(!!!c(subset))
    ```

### New features

- New experimental polars selectors have been added
  ([pola-rs/polars#23351](https://github.com/pola-rs/polars/pull/23351), #1452).
  - `cs$empty()` to avoid matching any column.
  - `cs$enum()` for Enum data types.
  - `cs$list()` for List data types.
  - `cs$array()` for Array data types.
  - `cs$struct()` for Struct data types.
  - `cs$nested()` for List, Array, or Struct data types.
- polars selectors can now be used in place of column names in more locations (#1452).
  - `...` (dynamic dots) of these functions.
    - `<dataframe>$to_dummies()`
    - `<dataframe>$partition_by()`
    - `<lazyframe>$drop_nulls()` and `<dataframe>$drop_nulls()`
    - `<lazyframe>$drop_nans()` and `<dataframe>$drop_nans()`
    - `<lazyframe>$unique()` and `<dataframe>$unique()`
    - `<lazyframe>$drop()` and `<dataframe>$drop()`
    - `<lazyframe>$explode()` and `<dataframe>$explode()`
    - `<lazyframe>$unnest()` and `<dataframe>$unnest()`
  - `<dataframe>$pivot()`'s `on`, `index`, and `values`.
  - `<lazyframe>$join()` and `<dataframe>$join()`'s `on` and `index`.

  This change also fixes the odd behavior of some functions that had the semantics
  of selecting all columns by default
  (`$drop_nulls()`, `$drop_nans()`, and `$unique()` of lazyframe or dataframe).

  In the previous version, passing `c()` (`NULL`) would result in strange behavior
  doesn't match either of "select nothing" or "select all columns".
  And, expanding an empty vector with `!!!` would select all columns.

  ```r
  ### OLD
  df <- pl$DataFrame(a = c(NA, TRUE), b = 1:2)
  df$drop_nulls(c())
  #> shape: (0, 2)
  #> ┌──────┬─────┐
  #> │ a    ┆ b   │
  #> │ ---  ┆ --- │
  #> │ bool ┆ i32 │
  #> ╞══════╪═════╡
  #> └──────┴─────┘

  df$drop_nulls(!!!c())
  #> shape: (1, 2)
  #> ┌──────┬─────┐
  #> │ a    ┆ b   │
  #> │ ---  ┆ --- │
  #> │ bool ┆ i32 │
  #> ╞══════╪═════╡
  #> │ true ┆ 2   │
  #> └──────┴─────┘
  ```

  In the new version, passing `c()` (`NULL`) will cause an error,
  and expanding an empty vector with `!!!` will select no columns.

  ```r
  ### NEW
  df <- pl$DataFrame(a = c(NA, TRUE), b = 1:2)
  df$drop_nulls(c())
  #> Error:
  #> ! Evaluation failed in `$drop_nulls()`.
  #> Caused by error:
  #> ! Evaluation failed in `$drop_nulls()`.
  #> Caused by error:
  #> ! `...` can only contain single strings or polars selectors.

  df$drop_nulls(!!!c())
  #> shape: (2, 2)
  #> ┌──────┬─────┐
  #> │ a    ┆ b   │
  #> │ ---  ┆ --- │
  #> │ bool ┆ i32 │
  #> ╞══════╪═════╡
  #> │ null ┆ 1   │
  #> │ true ┆ 2   │
  #> └──────┴─────┘
  ```

- `pl$nth()` gains the `strict` argument (#1452).
- `<expr>$str$pad_end()` and `<expr>$str$pad_start()`'s `length` argument accepts a polars expression (#1452).
- `<expr>$str$to_integer()` gains the `dtype` argument to specify the output data type (#1452).
- `<lazyframe>$sink_csv()` and `<dataframe>$write_csv()` gains the `decimal_commna` argument (#1452).

## polars 1.0.1

This is a small patch release that includes minor improvements discovered right after the 1.0.0 release.

### Performance

- The performance of creating polars expressions has been significantly improved (#1444).

### Other improvements

- To improve interoperability with other `data.frame`-like objects,
  the `[[` operator can now be used to extract a column from a polars DataFrame as a Series (#1442).

## polars 1.0.0

This is a completely rewritten new version of the polars R package. It improves
the internal structure of the package and catches up with Python Polars' API.
This version of R Polars matches Python Polars 1.31.0.

Therefore it contains many breaking changes compared to the previous R Polars
implementation. Some of those breaking changes are explained below, but many
others are due to modifications of function names, argument names, or argument
positions. There are too many to list here, so you should refer to the [Python
Polars API docs](https://docs.pola.rs/api/python/dev/reference/index.html).

For compatibility, the old version (polars 0.22.4) is now available as a separate package named "polars0".
We can install both polars and polars0 at the same time.
See the [polars0 documentation](https://rpolars.github.io/r-polars0/) for details.

### Breaking changes

- The class names of polars objects have changed:
  - `RPolarsLazyFrame` -> `polars_lazy_frame`
  - `RPolarsDataFrame` -> `polars_data_frame`
  - `RPolarsSeries` -> `polars_series`
  - `RPolarsExpr` -> `polars_expr`

- Conversion from unknown classes to Polars objects now fails. Developers can
  specify how those objects should be handled by polars by creating a method
  for `as_polars_series.my_class`.

  ```r
  ### OLD
  a <- 1
  class(a) <- "foo"
  as_polars_series(a)
  #> polars Series: shape: (1,)
  #> Series: '' [f64]
  #> [
  #>         1.0
  #> ]
  ```

  ```r
  ### NEW
  a <- 1
  class(a) <- "foo"
  as_polars_series(a)
  #> Error:
  #> a <foo> object can't be converted to a polars Series.
  #> Run `rlang::last_trace()` to see where the error occurred.
  ```

- Conversion from polars objects to R vectors has been revamped: `<series>$to_r()`,
  `<series>$to_list()` and `<dataframe>$to_data_frame()` no longer exist. Instead, you must use
  `as.data.frame(<dataframe>)`, `as.list(<dataframe>)`, `as.vector(<series>)`, or `<series>$to_r_vector()`.

  `as.vector(<series>)` will remove attributes that might be useful, for instance to
  convert Int64 values using the bit64 package or to convert Time values using
  the hms package. It is therefore recommended to use `<series>$to_r_vector()` instead for usual conversions.

  ```r
  s_time <- as_polars_series(c("00:00", "12:00"))$str$to_time()

  as.vector(s_time)
  #> ℹ `as.vector()` on a Polars Series of type time may drop some useful attributes.
  #> ℹ Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
  #> [1]     0 43200

  s_time$to_r_vector()
  #> 00:00:00
  #> 12:00:00
  ```

- In general, polars now uses dots (`...`) in two scenarios:
  1. to pass an unlimited number of inputs (for instance in `<lazyframe>$select()`, `<lazyframe>$cast()`,
     or `<lazyframe>$group_by()`), using [dynamic-dots](https://rlang.r-lib.org/reference/dyn-dots.html).

     For example, if you used to pass a vector of column names or a list of
     expressions, you now need to expand it with `!!!`:

     ```r
     ### OLD
     dat <- as_polars_df(head(mtcars, 3))
     my_exprs <- list(pl$col("drat") + 1, "mpg", "cyl")
     dat$select(my_exprs)
     #> shape: (6, 3)
     #> ┌──────┬──────┬─────┐
     #> │ drat ┆ mpg  ┆ cyl │
     #> │ ---  ┆ ---  ┆ --- │
     #> │ f64  ┆ f64  ┆ f64 │
     #> ╞══════╪══════╪═════╡
     #> │ 4.9  ┆ 21.0 ┆ 6.0 │
     #> │ 4.9  ┆ 21.0 ┆ 6.0 │
     #> │ 4.85 ┆ 22.8 ┆ 4.0 │
     #> └──────┴──────┴─────┘
     ```

     ```r
     ### NEW
     dat <- as_polars_df(head(mtcars, 3))
     my_exprs <- list(pl$col("drat") + 1, "mpg", "cyl")
     dat$select(!!!my_exprs)
     #> shape: (3, 3)
     #> ┌──────┬──────┬─────┐
     #> │ drat ┆ mpg  ┆ cyl │
     #> │ ---  ┆ ---  ┆ --- │
     #> │ f64  ┆ f64  ┆ f64 │
     #> ╞══════╪══════╪═════╡
     #> │ 4.9  ┆ 21.0 ┆ 6.0 │
     #> │ 4.9  ┆ 21.0 ┆ 6.0 │
     #> │ 4.85 ┆ 22.8 ┆ 4.0 │
     #> └──────┴──────┴─────┘
     ```

     This also affects `pl$col()`:

     ```r
     ### OLD
     pl$col(c("foo", "bar"), "baz")
     #> polars Expr: cols(["foo", "bar", "baz"])
     ```

     ```r
     ### NEW
     pl$col(c("foo", "bar"), "baz")
     #> Error in `pl$col()`:
     #> ! Evaluation failed in `$col()`.
     #> Caused by error in `pl$col()`:
     #> ! Invalid input for `pl$col()`.
     #> • `pl$col()` accepts either single strings or Polars data types.

     pl$col(!!!c("foo", "bar"), "baz")
     #> cols(["foo", "bar", "baz"])
     ```

     Another important change in functions that accept dynamic dots is that
     additional arguments are prefixed with `.`. For example, `<lazyframe>$group_by()` now
     takes dynamic dots, meaning that the argument `maintain_order` is renamed
     `.maintain_order` (for now, we add a warning if we detect an argument named
     `maintain_order` in the dots).

  2. to force some arguments to be named. We now throw an error if an argument
     is not named while it should be, for example:

     ```r
     df <- pl$DataFrame(a = 1:4)
     df$with_columns(pl$col("a")$shift(1, 3))
     #> Error in `df$with_columns()`:
     #> ! Evaluation failed in `$with_columns()`.
     #> Caused by error:
     #> ! Evaluation failed in `$with_columns()`.
     #> Caused by error:
     #> ! Evaluation failed in `$shift()`.
     #> Caused by error:
     #> ! `...` must be empty.
     #> ✖ Problematic argument:
     #> • ..1 = 3
     #> ℹ Did you forget to name an argument?

     df$with_columns(pl$col("a")$shift(1, fill_value = 3))
     #> shape: (4, 1)
     #> ┌─────┐
     #> │ a   │
     #> │ --- │
     #> │ f64 │
     #> ╞═════╡
     #> │ 3.0 │
     #> │ 1.0 │
     #> │ 2.0 │
     #> │ 3.0 │
     #> └─────┘
     ```

- Related to the extended use of dynamic dots, `pl$DataFrame()` and
  `pl$LazyFrame()` more accurately convert input to the correct datatype, for
  instance when the input is an R `data.frame`:

  ```r
  ### OLD
  pl$DataFrame(data.frame(x = 1, y = "a"))
  #> shape: (1, 2)
  #> ┌─────┬─────┐
  #> │ x   ┆ y   │
  #> │ --- ┆ --- │
  #> │ f64 ┆ str │
  #> ╞═════╪═════╡
  #> │ 1.0 ┆ a   │
  #> └─────┴─────┘
  ```

  ```r
  ### NEW
  pl$DataFrame(data.frame(x = 1, y = "a"))
  #> shape: (1, 1)
  #> ┌───────────┐
  #> │           │
  #> │ ---       │
  #> │ struct[2] │
  #> ╞═══════════╡
  #> │ {1.0,"a"} │
  #> └───────────┘

  pl$DataFrame(!!!data.frame(x = 1, y = "a"))
  #> shape: (1, 2)
  #> ┌─────┬─────┐
  #> │ x   ┆ y   │
  #> │ --- ┆ --- │
  #> │ f64 ┆ str │
  #> ╞═════╪═════╡
  #> │ 1.0 ┆ a   │
  #> └─────┴─────┘
  ```

  Use `as_polars_df()` and `as_polars_lf()` to convert existing R `data.frame`s
  to their polars equivalents.

- The class names `PTime` and `rpolars_raw_list` (used to handle time and binary
  variables) are removed. One should use the classes provided in packages
  hms and blob instead.

  ```r
  ### OLD
  r_df <- tibble::tibble(
    time = hms::as_hms(c("12:00:00", NA, "14:00:00")),
    binary = blob::as_blob(c(1L, NA, 2L)),
  )

  # R to Polars
  pl_df <- as_polars_df(r_df)
  pl_df
  #> shape: (3, 2)
  #> ┌─────────┬──────────────┐
  #> │ time    ┆ binary       │
  #> │ ---     ┆ ---          │
  #> │ f64     ┆ list[binary] │
  #> ╞═════════╪══════════════╡
  #> │ 43200.0 ┆ [b"\x01"]    │
  #> │ null    ┆ []           │
  #> │ 50400.0 ┆ [b"\x02"]    │
  #> └─────────┴──────────────┘

  # Polars to R
  tibble::as_tibble(pl_df)
  #> # A tibble: 3 × 2
  #>    time binary
  #>   <dbl> <list>
  #> 1 43200 <rplrs_r_ [1]>
  #> 2    NA <rplrs_r_ [0]>
  #> 3 50400 <rplrs_r_ [1]>
  ```

  ```r
  ### NEW
  r_df <- tibble::tibble(
    time = hms::as_hms(c("12:00:00", NA, "14:00:00")),
    binary = blob::as_blob(c(1L, NA, 2L)),
  )

  ## R to Polars
  pl_df <- as_polars_df(r_df)
  pl_df
  #> shape: (3, 2)
  #> ┌──────────┬─────────┐
  #> │ time     ┆ binary  │
  #> │ ---      ┆ ---     │
  #> │ time     ┆ binary  │
  #> ╞══════════╪═════════╡
  #> │ 12:00:00 ┆ b"\x01" │
  #> │ null     ┆ null    │
  #> │ 14:00:00 ┆ b"\x02" │
  #> └──────────┴─────────┘

  ## Polars to R
  tibble::as_tibble(pl_df)
  #> # A tibble: 3 × 2
  #>   time      binary
  #>   <time>    <blob>
  #> 1 12:00  <raw 1 B>
  #> 2    NA         NA
  #> 3 14:00  <raw 1 B>
  ```

### Other changes

- R objects that convert to a Series of length 1 are now treated like scalar
  values when converting to polars expressions:

  ```r
  ### OLD
  series <- pl$Series("foo", 1)
  pl$DataFrame(bar = 1:2)$with_columns(series)
  #> [...truncated...]
  #> Encountered the following error in Rust-Polars:
  #>     	Series foo, length 1 doesn't match the DataFrame height of 2
  #>
  #>     If you want expression: Series[foo] to be broadcasted, ensure it is a
  #>     scalar (for instance by adding '.first()').
  ```

  ```r
  ### NEW
  series <- pl$Series("foo", 1)
  pl$DataFrame(bar = 1:2)$with_columns(series)
  #> shape: (2, 2)
  #> ┌─────┬─────┐
  #> │ bar ┆ foo │
  #> │ --- ┆ --- │
  #> │ i32 ┆ f64 │
  #> ╞═════╪═════╡
  #> │ 1   ┆ 1.0 │
  #> │ 2   ┆ 1.0 │
  #> └─────┴─────┘
  ```

- `<expr>$map_batches()` still exists but its usage is discouraged. This function is
  not guaranteed to interact correctly with the streaming engine. To apply
  functions from external packages or custom functions that cannot be translated
  to polars syntax, we now recommend converting the data to a `data.frame` and
  using purrr (note that as of 1.1.0, purrr enables parallel computation).
  The vignette "Using custom functions" contains more details about this.
