#' R6 Class polar_lazy_frame
#'
#' high-level wrapper class for Rpolarframe
lazy_polar_frame <- R6::R6Class(
  "lazy_polar_frame",
  private = list(
    pf = NULL
  ),
  public = list(

    #' @description
    #' wrap low-level LazyFrame in new R6 lazy_polar_frame object.
    #' @param data LazyFrame
    #' @return A new `lazy_polar_frame` object.
    initialize = function(data) {
      #lowerlevel through init
      if(identical(class(data),"LazyFrame")) {
        private$pf = data
        return(self)
      }
      abort(paste("cannot initialize lazy_polar_frame with:",class(data)))
    },

    #' @description
    #' collect lazy_polar_frame. This triggers computation.
    #' @return A new `polar_frame`
    collect = function() {
      polar_frame$new(private$pf$collect())
    },

    #' @description
    #' select on lazy_polar_frame.
    #' @param ... any  Exprs or strings
    #' @return A new `lazy_polar_frame` object with selection.
    select = function(...) {
      pra = construct_ProtoExprArray(...) #construct on rust side array of expressions and strings (not yet interpreted as exprs)
      lazy_polar_frame$new(private$pf$select(pra)) #perform eager selection and return new polar_frame
    },

    #' @description
    #' filter on lazy_polar_frame.
    #' @param rexpr any single Expr
    #' @return A new `lazy_polar_frame` object with applied filter.
    filter = function(rexpr) {
      lazy_polar_frame$new(private$pf$filter(rexpr))
    },

    #' @description
    #' groupby on lazy_polar_frame.
    #' @param ... any single Expr or string naming a column
    #' @return A new `lazy_polar_frame` object with applied filter.
    groupby = function(...) {
      pra = construct_ProtoExprArray(...)
      lazy_groupby$new(private$pf$groupby(pra))
    },


    #' @description
    #' print the optimized plan of a polar_lazy_frame
    #' @return NULL
    describe_optimized_plan = function() {
      private$pf$describe_optimized_plan()
      invisible(self)
    },

    #' @description
    #' print non-optimized plan of a polar_lazy_frame
    #' @return NULL
    print = function() {
      print(private$pf)
      invisible(self)
    }


   )
)



#' R6 Class polar_groupby
#'
#' high-level wrapper class for Rpolarsgroupby
lazy_groupby <- R6::R6Class(
  classname = "lazy_polar_groupby",
  private = list(
    pf = NULL
  ),
  public = list(

    #' @description
    #' wrap low-level LazyGroupBy in new R6 lazy_goupby object.
    #' @param data LazyGroupBy
    #' @return A new `lazy_groupby` object.
    initialize = function(data) {

      #lowerlevel through init
      if(identical(class(data),"LazyGroupBy")) {
        private$pf = data
        return(self)
      }

      abort(paste("cannot initialize lazy_polar_groupby with:",class(data)))

    },

    #' @description
    #' aggregate a polar_lazy_groupby
    #' @param ... any Expr or string
    #' @return A new `lazy_polar_frame` object.
    agg = function(...) {
      pra = construct_ProtoExprArray(...)
      lazy_polar_frame$new(private$pf$agg(pra))
    },

    #' @description
    #' one day this will apply
    #' @param f lambda function to apply
    #' @return A new `lazy_polar_frame` object.
    apply = function(f) {

      abort("this function is not yet implemented")

      if(!is.function(f)) abort("apply takes only a function as argument")
      lazy_polar_frame$new(private$pf$apply(fun))
    },

    #' @description
    #' get n rows of head of group
    #' @param n integer number of rows to get
    #' @importFrom rlang is_integerish
    #' @return A new `lazy_polar_frame` object.
    head = function(n=1L) {
      if(!is_integerish(n) && n>=1L) abort("n rows must be a whole positive number")
      lazy_polar_frame$new(private$pf$head(n))
    },

    #' @description
    #' get n tail rows of group
    #' @param n integer number of rows to get
    #' @return A new `lazy_polar_frame` object.
    tail = function(n = 1L) {
      if(!is_integerish(n) && n>=1L) abort("n rows must be a whole positive number")
      lazy_polar_frame$new(private$pf$tail(n))
    },

    #' @description
    #' prints opague groupby, not much to show
    #' @return NULL
    print = function() {
      print(private$pf)
      invisible(self)
    }

  )
)
