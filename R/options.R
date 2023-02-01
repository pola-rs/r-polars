
# R runtime options
##all rpolars sessions options saved to here
rpolars_optenv = new.env(parent = emptyenv())
rpolars_optreq = list() #all requirement functions put in here

# WRITE ALL DEFINED OPTIONS BELOW HERE



#' @rdname rpolars_options
#' @name strictly_immutable
#' @aliases strictly_immutable
#' @param strictly_immutable bool, default = TRUE, keep rpolars strictly immutable.
#' Polars/arrow is in general pro "immutable objects". However pypolars API has some minor exceptions.
#' All settable property elements of classes are mutable.
#' Why?, I guess python just do not have strong stance on immutability.
#' R strongly suggests immutable objects, so why not make polars strictly immutable where little performance costs?
#' However, if to mimic pypolars as much as possible, set this to FALSE.
#'
rpolars_optenv$strictly_immutable = TRUE #set default value
rpolars_optreq$strictly_immutable = list( #set requirement functions of default value
  is_bool = function (x) {
    is.logical(x) && length(x)==1 && !is.na(x)
  }
)

#' @rdname rpolars_options
#' @name named_exprs
#' @aliases named_exprs
#' @param named_exprs bool, default = FALSE,
#' allow named exprs in e.g. select, with_columns, groupby, join.
#' a named expresion will be extended with $alias(name)
#' wildcards or expression producing multiple are problematic due to name collision
#' the related option in py-polars is currently called 'pl.Config.with_columns_kwargs'
#' and only allow named exprs in with_columns (or potentially any method derived there of)
#'
#' @examples
#' #rename columns by naming expression, experimental requires option named_exprs = TRUE
#' pl$set_rpolars_options(named_exprs = TRUE)
#' pl$DataFrame(iris)$with_columns(
#'   pl$col("Sepal.Length")$abs(), #not named expr will keep name "Sepal.Length"
#'   SW_add_2 = (pl$col("Sepal.Width")+2)
#' )
rpolars_optenv$named_exprs = FALSE #set default value
rpolars_optreq$named_exprs = list( #set requirement functions of default value
  is_bool = function (x) {
    is.logical(x) && length(x)==1 && !is.na(x)
  }
)


#' @rdname rpolars_options
#' @name no_messages
#' @aliases no_messages
#' @details who likes rpolars package messages? use this option to turn them off.
#' @param no_messages bool, default = FALSE,
#' turn of messages
rpolars_optenv$no_messages = FALSE #set default value
rpolars_optreq$no_messages = list( #set requirement functions of default value
  is_bool = function (x) {
    is.logical(x) && length(x)==1 && !is.na(x)
  }
)

#' @rdname rpolars_options
#' @name do_not_repeat_call
#' @details do not print the call causing the error in error messages
#' @param do_not_repeat_call bool, default = FALSE,
#' turn of messages
rpolars_optenv$do_not_repeat_call = FALSE #set default value
rpolars_optreq$do_not_repeat_call = list( #set requirement functions of default value
  is_bool = function (x) {
    is.logical(x) && length(x)==1 && !is.na(x)
  }
)


## END OF DEFINED OPTIONS


#' rpolars options
#' @description  get, set, reset rpolars options
#' @rdname rpolars_options
#' @name get_rpolars_options
#' @aliases  rpolars_options
#'
#'
#' @return current settings as list
#' @details modifing list takes no effect, pass it to pl$set_rpolars_options
#' get/set/resest interact with internal env `rpolars:::rpolars_optenv`
#'
#'
#' @examples  pl$get_rpolars_options()
pl$get_rpolars_options = function() {
  as.list(rpolars_optenv)
}


#' @param ... any options to modify
#'
#' @param return_replaced_options return previous state of modified options
#' Convenient for temporarily swapping of options during testing.
#'
#' @rdname rpolars_options
#' @name set_rpolars_options
#' @return current settings as list
#' @details setting an options may be rejected if not passing opt_requirements
#' @examples
#' pl$set_rpolars_options(strictly_immutable = FALSE)
#' pl$get_rpolars_options()
#'
#'
#' #setting strictly_immutable = 42 will be rejected as
#' tryCatch(
#'   pl$set_rpolars_options(strictly_immutable = 42),
#'   error= function(e) print(e)
#' )
#'
pl$set_rpolars_options = function(
  ...,
  return_replaced_options = TRUE
) {

  #check opts
  opts = list2(...)
  if(is.null(names(opts)) || !all(nzchar(names(opts)))) stopf("all options passed must be named")
  unknown_opts = setdiff(names(opts),names(rpolars_optenv))
  if(length(unknown_opts)) {
    stopf(paste("unknown option(s) was passed:",paste(unknown_opts,collapse=", ")))
  }

  #update options
  replaced_opts_list = list()
  for(i in names(opts)) {
    opt_requirements = rpolars_optreq[[i]]
    stopifnot(
      !is.null(opt_requirements),
      is.list(opt_requirements),
      all(sapply(opt_requirements,is.function)),
      all(nzchar(names(opt_requirements)))
    )

    for (j in  names(opt_requirements)) {
      opt_check = opt_requirements[[j]]
      opt_value = opts[[i]]
      opt_result = opt_check(opt_value)
      if(!isTRUE(opt_result)) {
        stopf(paste(
          "option:",i," must satisfy requirement named",j,
          "with function\n", paste(capture.output(print(opt_check)),collapse="\n")
        ))
      }
    }

    replaced_opts_list[[i]] = rpolars_optenv[[i]]
    rpolars_optenv[[i]] = opts[[i]]
  }

  if(return_replaced_options) {
    return(replaced_opts_list)
  }

  #return current option set invisible
  invisible(pl$get_rpolars_options())
}



rpolars_opts_defaults = as.list(rpolars_optenv)
#' @rdname rpolars_options
#' @name reset_rpolars_options
#' @examples
#' #reset options like this
#' pl$reset_rpolars_options()
pl$reset_rpolars_options = function() {
  rm(list=ls(envir = rpolars_optenv),envir = rpolars_optenv)
  for(i in names(rpolars_opts_defaults)) {
    rpolars_optenv[[i]] = rpolars_opts_defaults[[i]]
  }
  invisible(NULL)
}


#' @rdname rpolars_options
#' @name reset_rpolars_options
#' @return list named by options of requirement function input must satisfy
#' @examples
#' #use get_rpolars_opt_requirements() to requirements
#' pl$get_rpolars_opt_requirements()
pl$get_rpolars_opt_requirements = function() {
  rpolars_optreq
}


#' internal keeping of state at runtime
#' @name rpolars_runtime_flags
#' @description This environment is used internally for the package to remember
#' what has been going on. Currently only used to throw one-time warnings()
runtime_state = new.env(parent = emptyenv())




