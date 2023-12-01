#' Create Field
#'
#' A Field is composed of a name and a DataType. Fields are used in Structs-
#' datatypes and Schemas to represent everything of the Series/Column except the
#' raw values.
#'
#' @name RField_class
#'
#' @param name Field name
#' @param datatype DataType
#'
#' @include after-wrappers.R
#' @return A object of with DataType `"RField"` containing its name and its
#' DataType.
#' @examples
#' pl$Field("city_names", pl$Utf8)
pl$Field = function(name, datatype) {
  .pr$RField$new(name, datatype)
}


#' S3 method to print a Field
#'
#' @param x An object of type `"RField"`
#' @param ... Not used.
#'
#' @return No value returned, it prints in the console.
#' @export
#' @rdname Field_print
#'
#' @examples
#' print(pl$Field("foo", pl$List(pl$UInt64)))
print.RPolarsRField = function(x, ...) {
  x$print()
  invisible(x)
}


#' Auto complete $-access into a polars object
#'
#' Called by the interactive R session internally
#'
#' @param x Name of a `RPolarsRField` object
#' @param pattern String used to auto-complete
#'
#' @export
#' @keywords internal
.DollarNames.RPolarsRField = function(x, pattern = "") {
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


## internal bookkeeping of methods which should behave as properties
RField.property_setters = new.env(parent = emptyenv())


#' Get/set Field name
#'
#' @rdname RField_name
#' @examples
#' field = pl$Field("Cities", pl$Utf8)
#' field$name
#'
#' field$name = "CityPoPulations" #<- is fine too
#' field
RField_name = method_as_property(function() {
  .pr$RField$get_name(self)
}, setter = TRUE)

RField.property_setters$name = function(self, value) {
  .pr$RField$set_name_mut(self, value)
}

#' Get/set Field datatype
#'
#' @rdname RField_datatype
#'
#' @keywords DataFrame
#' @examples
#' field = pl$Field("Cities", pl$Utf8)
#' field$datatype
#'
#' field$datatype = pl$Categorical #<- is fine too
#' field$datatype
RField_datatype = method_as_property(function() {
  .pr$RField$get_datatype(self)
}, setter = TRUE)

RField.property_setters$datatype = function(self, value) {
  .pr$RField$set_datatype_mut(self, value)
}

#' @export
"$<-.RPolarsRField" = function(self, name, value) {
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
