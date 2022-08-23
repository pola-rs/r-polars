

#' R6 Class polar_rame
#'
#' It's real
polar_frame = R6::R6Class("polar_frame",
  cloneable = TRUE,
  private = list(
    # pf lower level extendr object that interfaces with polars in rust.
    pf = NULL,
    groupby_input = NULL,

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
      cat("polars dataframe: ")
      private$pf$print()
      invisible(self)
    },

    #' @description
    #' Create a new polar_frame
    #' @param data obj inheriting data.frame or list of vectors or Rseries
    #' @return A new `polar_frame` object.
    initialize = function(data) {


      #polar frame
      if(isFALSE(data)) {
        private$pf = FALSE #shallow
        return(self)
      }

      #pass through init
      if(is_polar_frame(data)) {
        private$pf = data$.__enclos_env__$private$pf #shallow
        return(self)
      }

      #normal initialization from data
      if(is_polar_data_input(data)) {
        private$pf =  minipolars:::new_pf(data)
        return(self)
      }

      #lowerlevel through init
      if(identical(class(data),"Rdataframe")) {
        private$pf = data
        return(self)
      }



      abort(paste("cannot initialize polar_frame with:",class(data)))
    },

    #' @description
    #'polar_frame to lazy polar_frame.

    #' @return A new `lazy_frame` object with applied selection.
    lazy = function() {
      lazy_polar_frame$new(private$pf$lazy())
    },

    #' @description
    #' select on polar_Frame.
    #' @param ... any Rexpr or any strings naming any_column (translated into Rexpr col(any_colum)))
    #' @return A new `polar_frame` object with applied selection.
    select = function(...) {

      #construct on rust side array of expressions and strings (not yet interpreted as exprs)
      pra = construct_ProtoRexprArray(...)

      #perform eager selection and return new polar_frame
      polar_frame$new(private$pf$select(pra))
    },

    #' @description
    #' select on polar_Frame.
    #' @param rexpr any single Rexpr
    #' @return A new `polar_frame` object with applied filter.
    filter = function(rexpr) {

      #perform eager filtering
      new_df = private$pf$lazy()$filter(rexpr)$collect()

      #and return new polar_frame
      polar_frame$new(new_df)
    },

    #' @description
    #' groupby on polar_Frame.
    #' @param ... any Rexpr or string to groupby
    #' @return A new `polar_frame` object with applied filter.
    groupby = function(...) {
      out = polar_frame$new(private$pf)
      out$.__enclos_env__$private$groupby_input =  construct_ProtoRexprArray(...)

      out
    },

    #' @description
    #' groupby on polar_Frame.
    #' @param ... any Rexpr to aggregate with
    #' @return A new `polar_frame` object with applied aggregation.
    agg = function(...) {

      agg_input = construct_ProtoRexprArray(...)

      new_df = private$pf$groupby_agg(
        private$groupby_input,
        agg_input
      )

      #and return new polar_frame
      polar_frame$new(new_df)
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
        all(sapply(data,function(x) is.vector(x) ||
                     inherits(x,"Rseries") ||
                     inherits(x,"polars_series")
        ))
    )

}

is_polar_frame = function(x) {
  identical(class(x), c("polar_frame","R6"))
}

#' @export
as.data.frame.polar_frame <- function(x) x$as_data_frame()

#' @export
plot.polar_frame <- function(x,...) {
  plot(x$as_data_frame(),...)
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
  if(is_polar_frame(data)) {
    abort("assertion failed, this function should never handle polar_frame")
  }

  #input guard
  if(!is_polar_data_input(data)) {
    abort("input must inherit data.frame or be a list of vectors and/or  Rseries")
  }

  if (inherits(data,"data.frame")) {
    data = as.data.frame(data)
  }

  #closure to generate new names
  make_column_name_gen = function() {
    col_counter = 0
    column_name_gen = function(x) {
      col_counter <<- col_counter +1
      paste0("newcolumn_",col_counter)
    }
  }
  name_generator = make_column_name_gen()

  #step 0, downcast any polars_series to Rseries
  data = lapply(data, function(x) {
    if(inherits(x,"polars_series")) x$private else x
  })

  ##step1 handle column names
  #keys are tentative new column names
  #fetch keys from names, if missing set as NA
  keys = names(data)
  if(length(keys)==0) keys = rep(NA_character_, length(data))

  ##step2
  #if missing key use series name or generate new
  keys = mapply(data,keys, FUN = function(column,key) {

    if(is.na(key) || nchar(key)==0) {
      if(inherits(column, "Rseries")) {
        key = column$name()
      } else {
        key = name_generator()
      }
    }
    return(key)
  })

  ##step 3
  #check for conflicting names, to avoid silent overwrite
  if(any(duplicated(keys))) {
    abort(
      paste(
        "conflicting column names not allowed:",
        paste(unique(keys[duplicated(keys)]),collapse=", ")
      )
    )
  }

  ##step 4
  #build polar_frame one column at the time
  pf = minipolars:::Rdataframe$new_with_capacity(length(data));
  mapply(data,keys, FUN = function(column, key) {
    if(inherits(column, "Rseries")) {
      column$rename_mut(key)
      pf$set_column_from_rseries(column)
    } else {
      pf$set_column_from_robj(column,key)
    }
    return(NULL)
  })

  return(pf)
}
