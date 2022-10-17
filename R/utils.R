

#' simulate a package
#'
#' simulate loading a namespace or attaching a package. designed to make reprexes easy. The input function's closer env is set to
#' the namespace and no fancy feature such as registering S3 methods is supported
#'
#' @source https://stackoverflow.com/a/67994010/4026830
#'
#' @param name string, name of fake package
#' @param exported named list of exported functions
#' @param unexported named list of unexported functions
#' @param attach whether to attach the fake package
#' @importFrom  namespace makeNamespace
#'
#' @noRd
fake_package <- function(name, exported = NULL, unexported = NULL, attach = TRUE) {
  # fetch and eval call to create `makeNamespace`
  #eval(body(loadNamespace)[[c(8, 4, 4)]])

  #cler old ns
  ns_registered = namespace::getRegisteredNamespace(name)
  if(!is.null(ns_registered))  rm(list=name,envir =namespace:::.getNameSpaceRegistry())

  # create an empty namespace
  ns <- namespace::makeNamespace(name)

  # makethis namespace the closure env of our input functions
  exported <- lapply(exported, `environment<-`, ns)
  unexported <- lapply(unexported, `environment<-`, ns)
  # place these in the namespace
  list2env(exported, ns)
  list2env(unexported, ns)
  # export relevant functions
  namespaceExport(ns, names(exported))
  if(attach) {
    # copy exported funs to "package:pkg" envir of the search path
    attach(exported, name = paste0("package:", name))
  }
  invisible()
}



check_no_missing_args = function(
  fun, args, warn =TRUE
) {

  expected_args = names(formals(fun))
  missing_args = expected_args[!expected_args %in% names(args)]
  if(length(missing_args)) {
    if(warn) warning(paste(
      "Internally following arguments are not exposed:",
      paste(missing_args,collapse=", ")
    ))
    return(FALSE)
  }
  return(TRUE)
}

#' more strict than expect_identical
expect_strictly_identical = function(object,expected,...) {
  testthat::expect(identical(object,expected),
                   failure_message  = paste(
                     "not identical\n object:",testthat::capture_output(str(object)),
                     "\n expected:",testthat::capture_output(str(expected))),
                   ...
  )
}

#' rust-like unwrapping of result. Useful to keep error handling on the R side.
#'
#' @param result a list here either element ok or err is NULL, or both if ok is litteral NULL
#' @param class class of thrown error
#' @param call context of error
#' @param ... not used
#'
#' @return the ok-element of list , or a error will be thrown
#' @export
#'
#' @examples unwrap(list(ok="foo",err=NULL))
unwrap = function(result, class="rust result error",call=sys.call(1L),...) {

  #if not a result
  if(!is.list(result) || !all(names(result) %in% c("ok","err"))) {
    abort("internal error: cannot unwrap non result",.internal = TRUE)
  }

  #if result is ok (ok can be be valid null, hence OK if both ok and err is null)
  if(is.null(result$err)) {
    return(result$ok)
  }

  #if result is error
  if( is.null(result$ok) && !is.null(result$err)) {
    return(abort(
      result$err,
      class = class,
      call=NULL,
      footer=paste(
        "when calling:\n",
        paste(capture.output(print(call)),collapse="\n"))
      ))
  }

  #if not ok XOR error, then roll over
  abort("internal error: result object corrupted",.internal = TRUE)
}


#' Verify user selected method/attribute exists
#' @description internal function to check method call of env_classes
#'
#' @param Class_env env_class object (the classes created by extendr-wrappers.R)
#' @param Method_name name of method requested by user
#' @param call context to throw user error, just use default
#'
#' @return invisible(NULL)
#'
#' @examples unwrap(list(ok="foo",err=NULL))
verify_method_call = function(Class_env,Method_name,call=sys.call(1L)) {

  if(!Method_name %in% names(Class_env)) {
    abort(
      paste(
        Method_name,"is not a method/attribute of the class",
        as.character(as.list(match.call())$Class_env)
      ),
      class = "syntax error",
      call=NULL,
      footer=paste(
        "when calling:\n",
        paste(capture.output(print(call)),collapse="\n")
      )
    )
  }
  invisible(NULL)
}



#' Simple SQL CASE WHEN implementation for R
#'
#' @description Inspired by data.table::fcase + dplyr::case_when. Used instead of base::switch internally.
#'
#' @param ... odd arugments are bool statements, a next even is returned if prior bool statement is the first true
#' @param or_else return this if no bool statements were true
#'
#' @return any return given first true bool statement otherwise value of or_else
#' @export
#'
#' @examples
#' n=5
#' pcase(
#'  n<5,"nope",
#'  n>6,"yeah",
#'  or_else = abort(paste("failed to have a case for n=",n))
#')
pcase = function(..., or_else = NULL) {
  #get unevaluated args except header-function-name and or_else
  l = head(tail(as.list(sys.call()),-1),-1)
  #evaluate the odd args, if TRUE, evaluate and return the next even arg
  for ( i in seq_len(length(l)/2)) {
    if(isTRUE(eval(l[[i*2-1]],envir = parent.frame()))) {
      return(eval(l[[i*2]],envir = parent.frame()))
    }
  }
  or_else
}


#' Move environment element from one env to another
#'
#' @param from_env env from
#' @param element_names names of elements to move, if named names, then name of name is to_env name
#' @param remove bool, actually remove element in from_env
#' @param to_env env to
#'
#' @details envs are mutable
#' @return NULL
#'
move_env_elements = function(from_env, to_env, element_names, remove = TRUE) {

  names_from = element_names
  names_to = if(is.null(names(element_names))) {
    #no names defined use same name in from and to
    names_from
  } else {
    #one or more names defined, use if named else use names_from
    ifelse(nchar(names(element_names))>0L,names(element_names),names_from)
  }

  for (i in seq_along(element_names)) {
    name_to = names_to[i]
    name_from = names_from[i]
    to_env[[name_to]] = from_env[[name_from]]
    if(remove) rm(list = name_from, envir = from_env)
  }

  invisible(NULL)
}

##internal function to convert a list of dataframes into a rust VecDataFrame
l_to_vdf = function(l) {
  if(!length(l)) abort("cannot concat empty list l")
  do_inherit_DataFrame = sapply(l,inherits,"DataFrame")
  if(!all(do_inherit_DataFrame)) {
    abort(paste(
      "element no(s) of concat param l:",
      paste(
        which(!do_inherit_DataFrame),
        collapse = ", "
      ),
      "are not minipolars DataFrame(s)"
    ))
  }

  vdf = .pr$VecDataFrame$with_capacity(length(l))
  errors = NULL
  for (item in l) {
    tryCatch(vdf$push(item),error = function(e) {errors <<- as.character(e)})
    if(!is.null(errors)) abort(errors)
  }

  vdf
}


#' remove private method
#'
#' @description  extendr places the naked internal calls to rust in env-classes. This function
#' can be used to delete them and replaces them with the public methods. Which are any function
#' matching pattern typically '^CLASSNAME' e.g. '^DataFrame_' or '^Series_'. Likely only used in
#' zzz.R
#' @param env class envrionment to modify. Envs are mutable so return needed
#' @param class_pattern a regex string matching declared public functions of that class
#'
#' @examples
#' replace_private_with_pub_methods(minipolars:::DataFrame, "^DataFrame")
replace_private_with_pub_methods = function(env, class_pattern,keep=c()) {
  cat("\n\n setting public methods for ",class_pattern)

  #get these
  class_methods = ls(parent.frame(), pattern = class_pattern)
  names(class_methods) = sub(class_pattern, "", class_methods)
  #name_methods_DataFrame = sub(class_pattern, "", class_methods)

  #any NULL signals use internal extendr implementation directly
  use_internal_bools = sapply(class_methods, function(method)  {
    x = get(method)

    if(is_string(x)) {
      if(x=="use_extendr_wrapper") return(TRUE)
      warning(paste("unknown flag for",method,x))
    }
    FALSE
  })

  #keep internals flagged with "use_internal_method"
  null_keepers = names(class_methods)[use_internal_bools]
  cat("\n reuse internal method :\n",paste(null_keepers,collapse=", "))

  #remove any internal method from class, not to keep
  remove_these = setdiff(ls(env),c(keep,null_keepers))
  rm(list=remove_these,envir = env)
  cat(
    "\nInternal methods not in use or replaced :\n",
    paste(setdiff(remove_these,names(class_methods)),collapse=", ")
  )

  #write any all class methods, where not using internal directly
  cat("\n insert derived methods:\n")
  for(i in which(!use_internal_bools)) {
    method = class_methods[i]
    cat(method,", ")
    env[[names(method)]] = get(method)
  }
  invisible(NULL)
}


#' construct protoArrayExpr
#'
#' @param l list of Expr or string
#'
#' @return extptr to ProtoExprArray with all exprs or strings
#'
#' @examples construct_protoArrayExpr(list("column_a",pl$col("column_b")))
construct_protoArrayExpr = function(l) {
  pra = minipolars:::ProtoExprArray$new()
  for (i  in l) {
    if(is_string(i)) {
      pra$push_back_str(i)
      next
    }
    if(inherits(i,"Expr")) {
      pra$push_back_rexpr(i)
      next
    }
    abort(paste("element:",i, "is neither string nor expr"))
  }
  pra
}

#' construct protoArrayExpr
#'
#' @param l list of Expr or string
#'
#' @return extptr to ProtoExprArray with all exprs or strings
#'
#' @examples construct_protoArrayExpr(list("column_a",pl$col("column_b")))
construct_DataTypeVector = function(l) {
  dtv = minipolars:::DataTypeVector$new()

  for (i  in seq_along(l)) {
    if(inherits(l[[i]],"DataType")) {
      dtv$push(names(l)[i],l[[i]])
      next
    }
    abort(paste("element:",i, "is not a DateType"))
  }
  dtv
}

#' Generate autocompletion suggestions for object
#'
#' @param env environment to extract usages from
#' @param pattern string passed to ls(pattern) to subset methods by pattern
#' @importFrom rlang is_function
#' @details used internally for auto completion in .DollarNames methods
#' @return method usages
#'
#' @examples get_method_usages(minipolars:::DataFrame, pattern="col")
get_method_usages = function(env,pattern="") {

  found_names = ls(env,pattern=pattern)
  objects = mget(found_names,envir = env)

  facts = list(
    is_property = sapply(objects,\(x) inherits(x,"property")),
    is_setter = sapply(objects,\(x) inherits(x,"setter")),
    is_method = sapply(objects,\(x)  !inherits(x,"property") & is_function(x))
  )

  suggestions = sort(c(
    found_names[facts$is_property],
    paste0(found_names[facts$is_setter],"<-"),
    paste0(found_names[facts$is_method],"()")
  ))

  suggestions
}

#' print recursively an environment, used in some documentation
#'
#' @param api env
#' @param name  name of env
#'
print_env =  function(api,name,max_depth=10) {
  indent_count = 1
  indentation = paste0(rep("  ",indent_count))
  show_api = function(value,name) {


    if(is.environment(value) || is.list(value)) {
      cat("\n\n",indentation,name,"(",class(value),"):")
      indent_count <<- indent_count + 1
      indentation <<- paste0(rep("  ",indent_count))
      if(indent_count>max_depth) {
        cat("\n",indentation,"not exploring deeper, increase max_depth or some circular reference?")
        return()
      }

      for(name in ls(value))  {
        show_api(get(name,envir=as.environment(value)),name)
      }
      cat("\n")
      indent_count <<- indent_count - 1
      indentation <<- paste0(rep("  ",indent_count))
    } else {
      cat("\n",indentation,"[",name,";",class(value),"]")
    }

  }
  show_api(api,name)

}
