breaking changes list

Expr_is_in` operation no longer supported for dtype `null`
pl$lit(NULL)$is_in(pl$lit(NULL))$lit_to_s() #e.g. like this

#this statement is no longer true but null
 (pl$lit(NA_real_) == pl$lit(NA_real_))$lit_to_s()

# this statement was before false but now true
pl$lit(NA_real_)$is_in(pl$lit(NULL))$lit_to_s()

#sink_ipc + sink_parquet
flip two last named args no_optimization + slice_pushdown

#pl$approx_unique and <Expr>$approx_unique -> $approx_n_unique()

#sum on a zero length vector now yields 0 and not null
pl$lit(numeric(0))$sum()$lit_to_s()

#Expr_take is refactored to accept more input via implicit conversions see examples

#when-then-otherwise refactored. Internal state classes are now
"When", "Then", "ChainedWhen", "ChainedThen".
input for `$when()` is now called condition
input for `$then()` and `$otherwise` are now called statement and
a statement as a string is now assumed to be a column name. Wrap in
`pl$lit(my_str)` if statement was a literal string.


# pl$range low-high is now called start end
# plain numeric is no longer a valid input for start-end it must be POSIXc POSIXt
# Ptime or other supported format
it is no longer possible to to use time_unit and time_zone to recast time, they can only
be used to desgignate unit and zone of naive time types. Instead use cast and with after to
modify time_unit and time_zone and/or the corrosponding values.
pl$date_range no longer support any mixed timezone types

