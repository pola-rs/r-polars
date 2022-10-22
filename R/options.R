
##all minipolars sessions options saved to here
minipolars_optenv = new.env(parent = emptyenv())
minipolars_optreq = list() #all requirement functions put in here

# WRITE ALL DEFINED OPTIONS BELOW HERE



#' @rdname minipolars_options
#' @name strictly_immutable
#' @aliases strictly_immutable
#' @param strictly_immutable bool, default = TRUE, keep minipolars strictly immutable.
#' Polars/arrow is in general pro "immutable objects". However pypolars API has some minor exceptions.
#' All settable property elements of classes are mutable.
#' Why?, I guess python just do not have strong stance on immutability.
#' R strongly suggests immutable objects, so why not make polars strictly immutable where little performance costs?
#' However, if to mimic pypolars as much as possible, set this to FALSE.
#'
minipolars_optenv$strictly_immutable = TRUE #set default value
minipolars_optreq$strictly_immutable = list( #set requirement functions of default value
  is_bool = rlang::is_bool
)

#' @rdname minipolars_options
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
#' pl$set_minipolars_options(named_exprs = TRUE)
#' pl$DataFrame(iris)$with_columns(
#'   pl$col("Sepal.Length")$abs(), #not named expr will keep name "Sepal.Length"
#'   SW_add_2 = (pl$col("Sepal.Width")+2)
#' )
minipolars_optenv$named_exprs = FALSE #set default value
minipolars_optreq$named_exprs = list( #set requirement functions of default value
  is_bool = rlang::is_bool
)


#' @rdname minipolars_options
#' @name no_messages
#' @aliases no_messages
#' @details who likes minipolars package messages? use this option to turn them off.
#' @param no_messages bool, default = FALSE,
#' turn of messages
minipolars_optenv$no_messages = FALSE #set default value
minipolars_optreq$no_messages = list( #set requirement functions of default value
  is_bool = rlang::is_bool
)




## END OF DEFINED OPTIONS


#' minipolars options
#' @description  get, set, reset minipolars options
#' @rdname minipolars_options
#' @name get_minipolars_options
#' @aliases  minipolars_options
#'
#'
#' @return current settings as list
#' @details modifing list takes no effect, pass it to pl$set_minipolars_options
#' get/set/resest interact with internal env `minipolars:::minipolars_optenv`
#'
#'
#' @examples  pl$get_minipolars_options()
pl$get_minipolars_options = function() {
  as.list(minipolars_optenv)
}


#' @rdname minipolars_options
#' @name set_minipolars_options
#' @importFrom  rlang is_bool is_function
#' @return current settings as list
#' @details setting an options may be rejected if not passing opt_requirements
#' @examples
#' pl$set_minipolars_options(strictly_immutable = FALSE)
#' pl$get_minipolars_options()
#'
#'
#' #setting strictly_immutable = 42 will be rejected as
#' tryCatch(
#'   pl$set_minipolars_options(strictly_immutable = 42),
#'   error= function(e) print(e)
#' )
#'
pl$set_minipolars_options = function(
  ...
) {

  #check opts
  opts = list(...)
  if(is.null(names(opts)) || !all(nzchar(names(opts)))) abort("all options passed must be named")
  unknown_opts = setdiff(names(opts),names(minipolars_optenv))
  if(length(unknown_opts)) {
    abort(paste("unknown option(s) was passed:",paste(unknown_opts,collapse=", ")))
  }

  #update options
  for(i in names(opts)) {
    opt_requirements = minipolars_optreq[[i]]
    stopifnot(
      !is.null(opt_requirements),
      is.list(opt_requirements),
      all(sapply(opt_requirements,is_function)),
      all(nzchar(names(opt_requirements)))
    )

    for (j in  names(opt_requirements)) {
      opt_check = opt_requirements[[j]]
      opt_value = opts[[i]]
      opt_result = opt_check(opt_value)
      if(!isTRUE(opt_result)) {
        abort(paste(
          "option:",i," must satisfy requirement named",j,
          "with function\n", paste(capture.output(print(opt_check)),collapse="\n")
        ))
      }
    }

    minipolars_optenv[[i]] = opts[[i]]
  }

  #return current option set invisibly
  invisible(pl$get_minipolars_options())
}



minipolars_opts_defaults = as.list(minipolars_optenv)
#' @rdname minipolars_options
#' @name reset_minipolars_options
#' @examples
#' #reset options like this
#' pl$reset_minipolars_options()
pl$reset_minipolars_options = function() {
  rm(list=ls(envir = minipolars_optenv),envir = minipolars_optenv)
  for(i in names(minipolars_opts_defaults)) {
    minipolars_optenv[[i]] = minipolars_opts_defaults[[i]]
  }
  invisible(NULL)
}


#' @rdname minipolars_options
#' @name reset_minipolars_options
#' @return list named by options of requirement function input must satisfy
#' @examples
#' #use get_minipolars_opt_requirements() to requirements
#' get_minipolars_opt_requirements()
pl$get_minipolars_opt_requirements = function() {
  minipolars_optreq
}


#' internal keeping of state at runtime
#' @name minipolars_runtime_flags
#' @description This environment is used internally for the package to remember
#' what has been going on. Currently only used to throw one-time warnings()
runtime_state = new.env(parent = emptyenv())




