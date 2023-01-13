ExprDT_truncate = function(
  every,# str | timedelta, #support R difftime
  offset = NULL#: str | timedelta | None = None,
) {

  offset = offset %||% "0ns"

  .pr$Expr$dt_truncate(
    every,
    offset
  )

}
