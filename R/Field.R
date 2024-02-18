#' Create Field
#'
#' A Field is composed of a name and a data type.
#' Fields are used in Structs-datatypes and Schemas to represent everything of
#' the Series/Column except the raw values.
#'
#' @section Active Bindings:
#'
#' ## datatype
#'
#' `$datatype` returns the [data type][pl_dtypes] of the Field.
#'
#' `$datatype = <RPolarsDataType>` sets the [data type][pl_dtypes] of the Field.
#'
#' ## name
#'
#' `$name` returns the name of the Field.
#'
#' `$name = "new_name"` sets the name of the Field.
#'
#' @aliases RField_class RPolarsRField
#'
#' @param name Field name
#' @param datatype [DataType][pl_dtypes]
#'
#' @return A object of with the data type `"Field"` containing its name and its
#' [data type][pl_dtypes].
#' @examples
#' field = pl$Field("city_names", pl$String)
#'
#' field
#' field$datatype
#' field$name
#'
#' # Set the new data type
#' field$datatype = pl$Categorical
#' field$datatype
#'
#' # Set the new name
#' field$name = "CityPoPulations"
#' field
pl_Field = function(name, datatype) {
  .pr$RField$new(name, datatype)
}


# Active bindings

RField_name = method_as_active_binding(
  \() .pr$RField$get_name(self),
  setter = TRUE
)


RField_datatype = method_as_active_binding(
  \() .pr$RField$get_datatype(self),
  setter = TRUE
)


#' S3 method to print a Field
#'
#' @noRd
#' @param x An object of type `"RField"`
#' @param ... Not used.
#'
#' @return No value returned, it prints in the console.
#' @export
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
#' @noRd
.DollarNames.RPolarsRField = function(x, pattern = "") {
  get_method_usages(RPolarsRField, pattern = pattern)
}


#' Print a polars Field
#'
#' @noRd
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


RField.property_setters$name = function(self, value) {
  .pr$RField$set_name_mut(self, value)
}


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
  if (polars_options()$strictly_immutable) self = .pr$RField$clone(self)
  func = RField.property_setters[[name]]
  func(self, value)
  self
}
