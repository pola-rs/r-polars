# all functions in here are directly copied or adapted to mimic rlang functions
# The purpose is to make rpolars have no install dependencies at all.

#to reimplement list2(...) in rust would be great to allow trailing commas
# no highlevel implemetaion seems stable e.g. http://r-de-jeu.blogspot.com/2013/03/r-and-last-comma.html



`%||%` = function (x, y)  {
  if (is.null(x)) y else x
}

`%|||%` = function (x, y)  {
  if (!length(x)) y else x
}

is_bool = function (x) {
  is.logical(x) && length(x)==1 && !is.na(x)
}

#TODO if needed base is_integerish on ok-result from rust utils try_f64_into_i64
# is_integerish = function(x) {
#   is.numeric(x) && all(!is.na(x)) && isTRUE(all(as.integer(x)==x))
# }

is_scalar_integerish = function(x) {
  is.numeric(x) && length(x)==1L && !is.na(x) && isTRUE(as.integer(x)==x)
}

is_string = function(x) {
  is.character(x) && length(x)==1L && !is.na(x)
}

detect_void_name = function (x) {
  x == "" | is.na(x)
}

is_named = function (x) {
  nms <- names(x)
  if (is.null(nms)) {
    return(FALSE)
  }
  if (any(detect_void_name(nms))) {
    return(FALSE)
  }
  TRUE
}
