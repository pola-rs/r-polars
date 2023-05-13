#' Create Field
#' @include after-wrappers.R
#' @name pl_Field
#' @param name string name
#' @param datatype DataType
#' @keywords pl
#' @details A Field is not a DataType but a name + DataType
#' Fields are used in Structs-datatypes and Schemas to represent
#' everything of the Series/Column except the raw values.
#'
#' @return a list DataType with an inner DataType
#' @examples
#' # make a struct
#' pl$Field("city_names", pl$Utf8)
#'
#' # find any DataType bundled pl$dtypes
#' print(pl$dtypes)
#'
pl$Field = function(name, datatype) {
  .pr$RField$new(name, datatype)
}


#' Print a polars Field
#' @param x DataType
#' @param ... not used
#'
#' @return self
#' @export
#' @keywords internal
#'
#' @examples
#' print(pl$Field("foo", pl$List(pl$UInt64)))
print.RField = function(x, ...) {
  cat("")
  x$print()
  invisible(x)
}

#' @export
.DollarNames.RField = function(x, pattern = "") {
  get_method_usages(RField, pattern = pattern)
}


#' Print a polars Field
#'
#' @keywords internal
#' @return self
#'
#' @examples
#' print(pl$Field("foo", pl$List(pl$UInt64)))
RField_print = function() {
  .pr$RField$print(self)
  invisible(self)
}


# "properties"

## internal bookkeeping of methods which should behave as properties
RField.property_setters = new.env(parent = emptyenv())


#' get/set Field name
#' @description get/set Field name
#'
#' @return name
#' @keywords DataType
#'
#' @examples
#' field = pl$Field("Cities", pl$Utf8)
#'
#' # get name / datatype
#' field$name
#' field$datatype
#'
#' # set + get values
#' field$name = "CityPoPulations" #<- is fine too
#' field$datatype = pl$UInt32
#'
#' print(field)
RField_name = method_as_property(function() {
  .pr$RField$get_name(self)
}, setter = TRUE)
RField.property_setters$name = function(self, value) {
  .pr$RField$set_name_mut(self, value)
}

#' get/set columns (the names columns)
#' @description get/set column names of DataFrame object
#' @name DataFrame_columns
#' @rdname DataFrame_columns
#'
#' @return char vec of column names
#' @keywords DataFrame
#'
#' @examples
#' df = pl$DataFrame(iris)
#'
#' # get values
#' df$columns
#'
#' # set + get values
#' df$columns = letters[1:5] #<- is fine too
#' df$columns
RField_datatype = method_as_property(function() {
  .pr$RField$get_datatype(self)
}, setter = TRUE)
RField.property_setters$datatype = function(self, value) {
  .pr$RField$set_datatype_mut(self, value)
}

#' @export
"$<-.RField" = function(self, name, value) {
  name = sub("<-$", "", name)

  # stop if method is not a setter
  if (!inherits(self[[name]], "setter")) {
    pstop(err = paste("no setter method for", name))
  }

  # if(is.null(func)) pstop(err= paste("no setter method for",name)))
  if (polars_optenv$strictly_immutable) self <- .pr$RField$clone(self)
  func = RField.property_setters[[name]]
  func(self, value)
  self
}
