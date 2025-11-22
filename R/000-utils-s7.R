# Maybe replaced with https://github.com/RConsortium/S7/pull/433
# Mostly copied from the ellmer package
# https://github.com/tidyverse/ellmer/blob/22c93f2bdab57e19275ba47789193d58e8982f96/R/utils-S7.R

prop_bool <- function(default = NULL, allow_null = FALSE, allow_na = FALSE) {
  force(allow_null)
  force(allow_na)

  new_property(
    class = if (allow_null) NULL | class_logical else class_logical,
    default = default,
    validator = function(value) {
      if (allow_null && is.null(value)) {
        return()
      }

      if (length(value) != 1) {
        if (allow_na) {
          sprintf(
            "must be a single %s or %s, not %s.",
            format_code("TRUE"),
            format_code("FALSE"),
            obj_type_friendly(value)
          )
        } else {
          sprintf(
            "must be a single %s, %s or %s, not %s.",
            format_code("TRUE"),
            format_code("FALSE"),
            format_code("NA"),
            obj_type_friendly(value)
          )
        }
      } else if (!allow_na && is.na(value)) {
        sprintf(
          "must be a single %s or %s, not %s.",
          format_code("TRUE"),
          format_code("FALSE"),
          format_code("NA")
        )
      }
    }
  )
}
