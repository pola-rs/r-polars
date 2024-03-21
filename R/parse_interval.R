# to pl_duration from other R types, add more if need
as_pl_duration = function(x) {
  pcase(
    is_string(x), x,
    inherits(x, "difftime"), difftime_to_pl_duration(x),
    # add more types here
    or_else = stop("unknown conversion into pl_duration from: ", x)
  )
}

# impl this converison
difftime_to_pl_duration = function(dft) {
  value = as.numeric(dft)
  u = attr(dft, "units")
  unit = pcase(
    !is_string(u), stop("difftime units should be a string not a: ", u),
    u == "secs", "s",
    u == "mins", "m",
    u == "hours", "h",
    u == "days", "d",
    u == "weeks", "w",
    u == "years", "y",
    or_else = stop("unknown difftime units: ", u)
  )
  paste0(value, unit)
}
