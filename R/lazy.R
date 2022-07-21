##notice here lazy_polar_frame inherits from polar_frame
# in rust code, both lazy and non lazy have the trait 'frame' I think ...
# maybe at some time the R6 class structure have to be refactored into a super class 'frame'
# where both lazy and non lazy polar frame inherits from
lazy_polar_frame <- R6::R6Class(
  "lazy_polar_frame",
  inherit = polar_frame,
  private = list(
    pf = NULL
  ),
  public = list(
    initialize = function(data) {

      #lowerlevel through init
      if(identical(class(data),"Rlazyframe")) {
        private$pf = data
        return(self)
      }

      abort(paste("cannot initialize lazy_polar_frame with:",class(data)))

    },

    ##collect lazy_polar_frame and return polar_frame
    collect = function() {
      polar_frame$new(private$pf$collect())
    }


   )
)
