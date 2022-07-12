
#' create new dataframe
#'
#' @param data a data.frame or list of mixed vectors and Rseries of equal length.
#'
#' @return Rdataframe
#' @importFrom xptr xptr_address
#' @importFrom rlang abort
#'
#' @examples
#' minipolars:::new_df(iris)
#' #with namespace
#' pl::df(iris)
#' pl::df(list(some_column_name = c(1,2,3,4,5)))
new_df = function(data) {


  keys = names(data)

  #make sure keys(names) are defined or at least defined unspecified (NA)
  if(length(keys)==0) keys = rep(NA_character_, length(data))

  #on rust side replace undefined column name with newcolumn_[i]
  #if already series reuse that name
  make_column_name_gen = function() {
    col_counter = 0
    column_name_gen = function(x) {
      col_counter <<- col_counter +1
      paste0("newcolumn_",col_counter)
    }
  }
  name_generator = make_column_name_gen()


  if (inherits(data,"data.frame")) {
    return(minipolars:::Rdataframe$new_from_vectors(data))
  }

  ## if data.frame or list of something build directly into data.frme
  if (
    !is.list(data) ||
    !all(sapply(data,function(x) is.vector(x) || inherits(x,"Rseries")))
  ) {
    abort("data arg must inherit from data.frame or be a mixed list of vector and Rseries")
  }

  #all are vectors
  if (all(sapply(data,function(x) is.vector(x)))) {
    return(minipolars:::Rdataframe$new_from_vectors(data))
  }

  #if mixed Rseries and vectors
  if (any(sapply(data,function(x) is.vector(x)))) {

    #convert all non Rseries into Rseries
    for (i in seq_along(data)) {
      if(!inherits(data[[i]], "Rseries")) {
        key = keys[i]
        if(is.na(key) || nchar(key)==0) key = name_generator()
        data[[i]] = minipolars:::Rseries$new(
          x = data[[i]],
          key
        )
      }
    }

  }


  #get pointers to Rseries objects
  ptr_adrs = sapply(data, xptr::xptr_address)

  #reenocde unspecified name as ""
  keys_rustside = sapply(keys, function(x) if(is.na(x)) "" else x)

  #clone series, potential rename if key specified,  build dataframe from series
  minipolars:::Rdataframe$new_from_series(ptr_adrs, keys_rustside)

}
