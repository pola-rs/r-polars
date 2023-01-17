
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

# more strict than expect_identical
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
#' @param call context of error or string
#'
#' @return the ok-element of list , or a error will be thrown
#' @export
#'
#' @examples
#'
#' unwrap(list(ok="foo",err=NULL))
#'
#' tryCatch(
#'   unwrap(ok=NULL, err = "something happen on the rust side"),
#'   error = function(e) as.character(e)
#' )
unwrap = function(result, call=sys.call(1L)) {

  #if not a result
  if(
    !inherits(result,"Result") && ( #trust the class
      !is.list(result) ||
      !all(names(result) %in% c("ok","err"))
    )
  ) {
    stopf("Internal error: cannot unwrap non result")
  }

  #if result is ok (ok can be be valid null, hence OK if both ok and err is null)
  if(is.null(result$err)) {
    return(result$ok)
  }

  #if result is error
  if(is.null(result$ok) && !is.null(result$err)) {
    stopf(
      paste(
        result$err,
        paste(
          "\nwhen calling:\n",
          paste(
            capture.output(print(call)),collapse="\n")
        )
    ))
  }

  #if not ok XOR error, then roll over
  stopf("Internal error: result object corrupted")
}

#' Internal preferred function to throw errors
#'
#' @param err error msg string
#' @param call calling context
#' @keywords internals
#'
#' @return throws an error
#'
#' @examples
#' f = function() rpolars:::pstop("this aint right!!")
#' tryCatch(f(), error = \(e) as.character(e))
pstop = function(err, call=sys.call(1L)) {
  unwrap(list(ok=NULL,err=err),call=call)
}


#' Verify user selected method/attribute exists
#' @description internal function to check method call of env_classes
#'
#' @param Class_env env_class object (the classes created by extendr-wrappers.R)
#' @param Method_name name of method requested by user
#' @param call context to throw user error, just use default
#'
#' @return invisible(NULL)
verify_method_call = function(Class_env,Method_name,call=sys.call(1L)) {

  if(!Method_name %in% names(Class_env)) {
    stopf(
      paste(
        "syntax error:",
        Method_name,"is not a method/attribute of the class",
        as.character(as.list(match.call())$Class_env),
        "\n when calling:\n",
        paste(capture.output(print(call)),collapse="\n")
      )
    )
  }
  invisible(NULL)
}


# #highly experimental work around to use list2 without rlang
# ok.comma <- function(FUN, which=0) {
#   function(...) {
#     #browser()
#     arg.list <- as.list(sys.call(which=which))[-1L]
#     len <- length(arg.list)
#     if (len > 1L) {
#       last <- arg.list[[len]]
#       if (missing(last)) {
#         arg.list <- arg.list[-len]
#       }
#     }
#     do.call(FUN, arg.list,envir=parent.frame(which+1))
#   }
# }
# list2 = ok.comma(list)
# list3 = ok.comma(list,which = 2)


#disable trailing commas for now
list2 = list






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
#' n = 7
#' pcase(
#'  n<5,"nope",
#'  n>6,"yeah",
#'  or_else = stopf(paste("failed to have a case for n=",n))
#')
pcase = function(..., or_else = NULL) {
  #get unevaluated args except header-function-name and or_else
  l = head(tail(as.list(sys.call()),-1L),-1L)
  #evaluate the odd args, if TRUE, evaluate and return the next even arg
  for ( i in seq_len(length(l)/2L)) {
    if(isTRUE(eval(l[[i*2L-1L]],envir = parent.frame()))) {
      return(eval(l[[i*2L]],envir = parent.frame()))
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
  if(!length(l)) stopf("cannot concat empty list l")
  do_inherit_DataFrame = sapply(l,inherits,"DataFrame")
  if(!all(do_inherit_DataFrame)) {
    stopf(paste(
      "element no(s) of concat param l:",
      paste(
        which(!do_inherit_DataFrame),
        collapse = ", "
      ),
      "are not rpolars DataFrame(s)"
    ))
  }

  vdf = .pr$VecDataFrame$with_capacity(length(l))
  errors = NULL
  for (item in l) {
    tryCatch(vdf$push(item),error = function(e) {errors <<- as.character(e)})
    if(!is.null(errors)) stopf(errors)
  }

  vdf
}


clone_env_one_level_deep = function(env) {
  newenv <- new.env(parent = env)
  for (i in ls(envir=env)) newenv[[i]] = env[[i]]
  newenv
}

#' remove private method
#'
#' @description  extendr places the naked internal calls to rust in env-classes. This function
#' can be used to delete them and replaces them with the public methods. Which are any function
#' matching pattern typically '^CLASSNAME' e.g. '^DataFrame_' or '^Series_'. Likely only used in
#' zzz.R
#'
#' @param env class envrionment to modify. Envs are mutable so no return needed
#' @param class_pattern a regex string matching declared public functions of that class
#' @param keep list of unmentioned methods to keep in public api
#' @param remove_f bool if true, will move methods, not copy
#'
replace_private_with_pub_methods = function(env, class_pattern,keep=c(), remove_f = FALSE) {
  if(build_debug_print) cat("\n\n setting public methods for ",class_pattern)

  #get these
  class_methods = ls(parent.frame(), pattern = class_pattern)
  names(class_methods) = sub(class_pattern, "", class_methods)
  #name_methods_DataFrame = sub(class_pattern, "", class_methods)

  #any string-flag signals use internal extendr implementation directly
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
  if(build_debug_print) cat("\n reuse internal method :\n",paste(null_keepers,collapse=", "))

  #remove any internal method from class, not to keep
  remove_these = setdiff(ls(env),c(keep,null_keepers))
  rm(list=remove_these,envir = env)
  if(build_debug_print) cat(
    "\nInternal methods not in use or replaced :\n",
    paste(setdiff(remove_these,names(class_methods)),collapse=", ")
  )

  #write any all class methods, where not using internal directly
  if(build_debug_print) cat("\n insert derived methods:\n")
  for(i in which(!use_internal_bools)) {
    method = class_methods[i]
    if(build_debug_print) cat(method,", ")
    env[[names(method)]] = get(method)
  }

  if(remove_f) {
    rm(list=class_methods, envir = parent.frame())
  }


  invisible(NULL)
}


#' construct protoArrayExpr
#'
#' @param l list of Expr or string
#'
#' @return extptr to ProtoExprArray with all exprs or strings
#'
#' @examples rpolars:::construct_protoArrayExpr(list("column_a",pl$col("column_b")))
construct_protoArrayExpr = function(l) {
  pra = ProtoExprArray$new()
  if (!is.list(l)) l = list(l)
  for (i  in l) {
    if(is_string(i)) {
      pra$push_back_str(i)
      next
    }
    if(inherits(i,"Expr")) {
      pra$push_back_rexpr(i)
      next
    }
    stopf(paste("element:",i, "is neither string nor expr"))
  }
  pra
}

#' construct protoArrayExpr
#'
#' @param l list of Expr or string
#'
#' @return extptr to ProtoExprArray with all exprs or strings
#'
#' @examples rpolars:::construct_protoArrayExpr(list("column_a",pl$col("column_b")))
construct_DataTypeVector = function(l) {
  dtv = DataTypeVector$new()

  for (i  in seq_along(l)) {
    if(inherits(l[[i]],"RPolarsDataType")) {
      dtv$push(names(l)[i],l[[i]])
      next
    }
    stopf(paste("element:",i, "is not a DateType"))
  }
  dtv
}

#' Generate autocompletion suggestions for object
#'
#' @param env environment to extract usages from
#' @param pattern string passed to ls(pattern) to subset methods by pattern
#' @details used internally for auto completion in .DollarNames methods
#' @return method usages
#'
#' @examples rpolars:::get_method_usages(rpolars:::DataFrame, pattern="col")
get_method_usages = function(env,pattern="") {

  found_names = ls(env,pattern=pattern)
  objects = mget(found_names,envir = env)

  facts = list(
    is_property = sapply(objects,\(x) inherits(x,"property")),
    is_setter = sapply(objects,\(x) inherits(x,"setter")),
    is_method = sapply(objects,\(x)  !inherits(x,"property") & is.function(x))
  )

  paste0_len = function(...,collapse=NULL,sep="") {
    dot_args = list2(...)
    #any has zero length, return zero length
    if(any(!sapply(dot_args,length))) {
      character()
    } else {
      paste(...,collapse=collapse,sep=sep)
    }

  }

  suggestions = sort(c(
    found_names[facts$is_property],
    paste0_len(found_names[facts$is_setter],"<-"),
    paste0_len(found_names[facts$is_method],"()")
  ))

  suggestions
}

#' print recursively an environment, used in some documentation
#'
#' @param api env
#' @param name  name of env
#' @param max_depth numeric/int max levels to recursive iterate through
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



#' Reverts wrapping in I
#'
#' @param X any Robj wrapped in `I()``
#' @details
#' https://stackoverflow.com/questions/12865218/getting-rid-of-asis-class-attribute
#' @return X without any AsIs subclass
unAsIs <- function(X) {
  if("AsIs" %in% class(X)) {
    class(X) <- class(X)[-match("AsIs", class(X))]
  }
  X
}


#' restruct an object where structs where previously unnested
#' @details  this function should be repalced with rust code writing this output
#' directly before nesting
#' @param l list
#' @return restructed list
restruct_list = function(l) {

  #recursive find all struct tags in list
  explore_structs = function(x, coords) {
    if(is.list(x)) {
      if(isTRUE(attr(x,"is_struct"))) {
        structs_found_list <<- c(structs_found_list,list(coords))
      }
      for(i in seq_along(x)) explore_structs(x[[i]], coords = c(coords,i))
    }
  }
  structs_found_list = list()
  explore_structs(l,integer())

  #sort structs from deepest to shallowest
  if(!length(structs_found_list)) return(l)
  structs_found_list = structs_found_list |> (\(x) x[order(-sapply(x,length))])()

  val = NULL # to satisyfy R CMD check no undefined global
  #restruct all tags in list
  for (x in structs_found_list) {
    l_access_str = paste0("l",paste0("[[",x,"]]",collapse = ""))
    get_code_tokens = paste0("val <- ", l_access_str)
    eval(parse(text = get_code_tokens))
    listmapply = function(...) mapply(FUN=list,...,SIMPLIFY = FALSE)
    new_val = do.call(listmapply,val)
    set_code_tokens = paste0(l_access_str," <- new_val")
    eval(parse(text = set_code_tokens))
  }

  l
}


#' Bundle class methods into an environment (subname space)
#'
#' @param class_pattern regex to select functions
#' @param subclass_env  optional subclass of
#' @param remove_f drop sourced functions from package ns after bundling into sub ns
#'
#' @return
#' A function which returns a subclass environment of bundled class functions.
#'
#' @details
#' This function is used to emulate py-polars subnamespace-methods
#' All functions coined 'macro'-functions use eval(parse()) but only at package build time
#' to solve some tricky self-referential problem. If possible to deprecate a macro in a clean way
#' , go ahead.
#'
#' @examples
#'
#' #macro_new_subnamespace() is not exported, export for this toy example
#' #macro_new_subnamespace = rpolars:::macro_new_subnamespace
#'
#' ##define some new methods prefixed 'MyClass_'
#' #MyClass_add2 = function() self + 2
#' #MyClass_mul2 = function() self * 2
#'
#' ##grab any sourced function prefixed 'MyClass_'
#' #my_class_sub_ns = macro_new_subnamespace("^MyClass_", "myclass_sub_ns")
#'
#' #here adding sub-namespace as a expr-class property/method during session-time,
#' #which only is for this demo.
#' #instead sourced method like Expr_arr() at package build time instead
#' #env = rpolars:::Expr #get env of the Expr Class
#' #env$my_sub_ns = method_as_property(function() { #add a property/method
#' # my_class_sub_ns(self)
#' #})
#' #rm(env) #optional clean up
#'
#' #add user defined S3 method the subclass 'myclass_sub_ns'
#' #print.myclass_sub_ns = function(x, ...) { #add ... even if not used
#' #   print("hello world, I'm myclass_sub_ns")
#' #   print("methods in sub namespace are:")
#' #  print(ls(x))
#' #  }
#'
#' #test
#' # e = pl$lit(1:5)  #make an Expr
#' #print(e$my_sub_ns) #inspect
#' #e$my_sub_ns$add2() #use the sub namespace
#' #e$my_sub_ns$mul2()
#'
macro_new_subnamespace = function(class_pattern, subclass_env = NULL, remove_f = TRUE) {

  # get all methods within class
  class_methods = ls(parent.frame(), pattern = class_pattern)
  names(class_methods) = sub(class_pattern, "", class_methods)

  string = paste(sep="\n",
    "function(self) {",
    "  env = new.env()",
    paste(collapse="\n",sapply(seq_along(class_methods), function(i) {
      f_name =  class_methods[i]
      m_name   = names(class_methods)[i]
      f = get(f_name)
      paste0("  env$",m_name," = ",paste(capture.output(dput(f)), collapse = "\n"))
    })),
    "  class(env) = c(subclass_env, class(env))",
    "  env",
    "}"
  )

  if(remove_f) {
    rm(list=class_methods, envir = parent.frame())
  }

  if(build_debug_print) cat("new subnamespace: ", class_pattern, "\n", string)
  eval(parse(text=string))

}



#' expect grepl error
#' @param expr an R expression to test
#' @param expected_err a string pattern passed to grepl
#' @details expr must raise an error and expected_err pattern must match
#' against the error text with grepl()
#' @return invisble NULL
#'
#' @examples
#' # passes as "carrot" is in "orange and carrot"
#' rpolars:::expect_grepl_error(stop("orange and carrot"),"carrot")
expect_grepl_error = function(expr, expected_err = NULL) {
  err = NULL
  err = tryCatch(expr, error = function(e) {as.character(e)})
  found = grepl(expected_err,err)[1]
  if(!found) {
    testthat::expect_identical(err, expected_err)
  }
  invisible(NULL)
}
