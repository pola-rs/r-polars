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

prop_string <- function(default = NULL, allow_null = FALSE, allow_na = FALSE) {
  force(allow_null)
  force(allow_na)

  new_property(
    class = if (allow_null) NULL | class_character else class_character,
    default = default,
    validator = function(value) {
      if (allow_null && is.null(value)) {
        return()
      }

      if (length(value) != 1) {
        sprintf(
          "must be a single string, not %s.",
          obj_type_friendly(value)
        )
      } else if (!allow_na && is.na(value)) {
        "must not be missing."
      }
    }
  )
}

# TODO: check integerish
prop_number_whole <- function(
  default = NULL,
  min = NULL,
  max = NULL,
  allow_null = FALSE,
  allow_na = FALSE
) {
  force(allow_null)
  force(allow_na)

  new_property(
    class = if (allow_null) NULL | class_numeric else class_numeric,
    default = default,
    validator = function(value) {
      if (allow_null && is.null(value)) {
        return()
      }

      if (length(value) != 1) {
        sprintf(
          "must be a single whole number, not %s.",
          obj_type_friendly(value)
        )
      } else if (!allow_na && is.na(value)) {
        "must not be missing."
      } else if (value != trunc(value)) {
        sprintf(
          "must be a whole number, not %s.",
          obj_type_friendly(value)
        )
      } else if (!is.null(min) && value < min) {
        sprintf(
          "must be at least %s, not %s.",
          format_code(min),
          format_code(value)
        )
      } else if (!is.null(max) && value > max) {
        sprintf(
          "must be at most %s, not %s.",
          format_code(max),
          format_code(value)
        )
      }
    }
  )
}

prop_list_of_rexpr <- function(allow_null = FALSE, names = c("any", "all", "none")) {
  names <- arg_match0(names, c("any", "all", "none"))

  new_property(
    class = if (allow_null) NULL | class_list else class_list,
    validator = function(value) {
      if (allow_null && is.null(value)) {
        return()
      }
      if (!is_list_of_polars_rexpr(value)) {
        sprintf("must be a list of %s.", format_cls("PlRExpr"))
      }
      if (names == "all" && any(names2(value) == "")) {
        "must be a named list."
      } else if (names == "none" && any(names2(value) != "")) {
        "must be an unnamed list."
      }
    }
  )
}

parse_to_rexpr_list <- function(obj) {
  if (is.null(obj)) {
    NULL
  } else {
    parse_into_list_of_expressions(!!!obj)
  }
}
