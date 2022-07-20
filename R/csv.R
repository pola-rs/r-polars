




#' read csv lazuliy
#'
#' @param path
#' @param sep
#' @param has_header
#' @param ignore_errors
#' @param skip_rows
#' @param n_rows
#' @param cache
#' @param overwrite_dtype
#' @param low_memory
#' @param comment_char
#' @param quote_char
#' @param null_values
#' @param infer_schema_length
#' @param rechunk
#' @param skip_rows_after_header
#' @param encoding
#' @param row_count_name
#' @param row_count_offset
#' @param parse_dates
#'
#' @return
#' @export
#'
#' @examples
lazy_csv_reader = function(
  path = "my.csv",
  sep = ",",
  has_header = TRUE,
  ignore_errors = FALSE,
  skip_rows = 0,
  n_rows = NULL,
  cache = FALSE,
  overwrite_dtype = NULL,  #minipolars:::RdatatypeVector$new()$print()
  low_memory = FALSE,
  comment_char = NULL,
  quote_char = '"',
  null_values = NULL,
  infer_schema_length = 100,
  rechunk = TRUE,
  skip_rows_after_header = 0,
  encoding = "utf8-lossy",
  row_count_name = "myrowcounter",
  row_count_offset = 42,
  parse_dates = FALSE
) {

  args = as.list(environment())

  #convert named list of Rdatatype's to RdatatypeVector
  owdtype = args$overwrite_dtype
  if(!is.null(owdtype)) {
    ##TODO support also unnamed list, like will be interpreted as positional dtypes args by polars.
    if( is.list(owdtype) && rlang::is_named(owdtype)) {

      datatype_vector = minipolars:::RdatatypeVector$new() #mutable
      mapply(
        name = names(owdtype),
        type = unname(owdtype),
        FUN = function(name, type) {
          print(name)
          print(type)
          datatype_vector$push(name,type)
        }
      )
      args$overwrite_dtype = datatype_vector

    }
    abort("could not interpret overwrite_dtype, must be a named list of Rdatatypes")
  }


  #convert string or un/named  char vec into RNullValues obj
  nullvals = args$null_values
  if(!is.null(nullvals)) {
    ##TODO support also unnamed list, like will be interpreted as positional dtypes args by polars.
    RNullValues = NULL
    if(is_string(nullvals)) {
      RNullValues = minipolars:::RNullValues$new_all_columns(nullvals)
    }

    if(is.character(nullvals) && !is_named(nullvals)) {
      RNullValues = minipolars:::RNullValues$new_columns(nullvals)
    }

    if(is.character(nullvals) && is_named(nullvals)) {
      RNullValues = minipolars:::RNullValues$new_named(null_values)
    }
    if(is.null(RNullValues)) {
      abort("null_values arg must be a string OR unamed char vec OR named char vec")
    }
    args$null_values = RNullValues
  }

  ##call low level function with args
  check_no_missing_args(minipolars:::new_csv_r,args)
  do.call(minipolars:::new_csv_r,args)
}
