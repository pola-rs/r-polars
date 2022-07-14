

#' R6 Class polar_rame
#'
#' It's real
polar_frame = R6::R6Class("polar_frame",
  cloneable = TRUE,
  private = list(
    # pf lower level extendr object that interfaces with polars in rust.
    pf = NULL,

    deep_clone = function(name, value) {
      #low level call rust side deep clone
      if (name == "pf") return(value$clone_extendr())
      value
    }

  ),
  public = list(

    #' @description
    #' print
    #' @return self `polar_frame` object.
    print = function() {
      private$pf$print()
      invisible(self)
    },

    #' @description
    #' Create a new polar_frame
    #' @param data obj inheriting data.frame or list of vectors or Rseries
    #' @return A new `polar_frame` object.
    initialize = function(data) {

      #normal initialization from data
      if(is_polar_data_input(data)) {
        private$pf =  minipolars:::new_pf(data)
        return(invisible(self))
      }

      #lowerlevel through init
      if(identical(class(data),"Rdataframe")) {
        private$pf = data
        return(invisible(self))
      }

      #pass through init
      if(is_polar_frame(data)) {
        # new_polar_frame = as_polar_frame(data)
        # private$pf = new_polar_frame$pf
        #TODO maybe possible to use 'self = new_polar_frame' instead
        return(invisible(data))
      }

      abort(paste("cannot initialize polar_frame with:",class(data)))
    },

    #' @description
    #' select on polar_Frame.
    #' @param ... any Rexpr or any strings naming any_column (translated into Rexpr col(any_colum)))
    #' @return A new `polar_frame` object with applied selection.
    #' @importFrom rlang is_string
    select = function(...) {

      #construct on rust side array of expressions and strings (not yet interpreted as exprs)
      pra = construct_ProtoRexprArray(...)

      #perform eager selection and return new polar_frame
      polar_frame$new(private$pf$select(pra))
    },

    #' @description
    #' return polar_frame as data.frame.
    #' @param ... any arg passed to as.data.frame, x and col.names are fixed
    #' @return A new `data.frame` object .
    as_data_frame = function(...) {
      as.data.frame(
        x = private$pf$as_rlist_of_vectors(),
        col.names = private$pf$colnames(),
        ...
      )
    }
  )
)


#' construct proto Rexpr array from args
#'
#' @param ...  any Rexpr or string
#'
#' @return ProtoRexprArray object
#'
#' @examples construct_ProtoRexprArray(pl::col("Species"),"Sepal.Width")
construct_ProtoRexprArray = function(...) {
  pra = minipolars:::ProtoRexprArray$new()
  args = list(...)
  for (i in args) {
    if (is_string(i)) {
      pra$push_back_str(i) #rust method
      next
    }
    if (inherits(i,"Rexpr")) {
      pra$push_back_rexpr(i) #rust method
      next
    }
    abort(paste("cannot handle object:", capture.output(str(i))))
  }

  pra
}

#' test if suitable to construct polar.frame
#'
#' @param robj any R object to test
#'
#' @return bool
#'
#' @examples is_polar_data_input(iris)
is_polar_data_input = function(x) {
  inherits(x,"data.frame") ||
    (
      is.list(x) ||
        all(sapply(data,function(x) is.vector(x) || inherits(x,"Rseries")))
    )

}

is_polar_frame = function(x) {
  identical(class(x), c("polar_frame","R6"))
}

as_polar_frame = function(x) {

  #pass through
  if (is_polar_frame(x)) {
    return(x)
  }

  #any class initialization
  if (is_polar_data_input(x)) {
    return(polar_frame$new(x))
  }

  #sub class conversion
  if (inherits(x,"polar_frame")) {
    if (class(x)[1]=="lazy_polar_frame") {
      abort("lazy to eager, not implemented yet")
    }
    abort(paste("subclass of polar_frame: ",class(x)), "cannot be converted to polar_frame yet")
  }

  #hmm dunno what to do with that x, give up.
  abort(paste("class:",class(x)), "cannot be converted to polar_frame")
}


#' create new dataframe
#'
#' @param data a data.frame or list of mixed vectors and Rseries of equal length.
#'
#' @return Rdataframe
#' @importFrom xptr xptr_address
#' @importFrom rlang abort
#'
#' @examples
#' minipolars:::new_pf(iris)
#' #with namespace
#' pl::pf(iris)
#' pl::pf(list(some_column_name = c(1,2,3,4,5)))
new_pf = function(data) {

  #input guard
  if(!is_polar_data_input(data)) {
    abort("input must inherit data.frame or be a list of vectors and/or  Rseries")
  }


  #make sure keys(column names) are defined or at least defined unspecified (NA)
  keys = names(data)
  if(length(keys)==0) keys = rep(NA_character_, length(data))

  #on rust side replace undefined column names with newcolumn_[i]
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
    return(minipolars:::Rdataframe$new_from_vectors(as.data.frame(data)))
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
