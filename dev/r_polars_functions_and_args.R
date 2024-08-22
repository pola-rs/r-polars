library(dplyr)
library(reactable)

dicts = list()

families = c("LazyFrame", "DataFrame")

get_args = function(fun) {
  args = tryCatch(
    formalArgs(fun),
    error = function(e) NULL
  )
  args[args != "self"]
}

all_polars_obj = ls(getNamespace("polars"), all.names = TRUE)

for (fam in families) {
  fns = all_polars_obj[startsWith(all_polars_obj, paste0(fam, "_"))]
  for (fun in fns) {
    args = get_args(fun = fun)
    if (length(args) == 0) next
    dicts[[paste0(fun)]] = data.frame(fun = fun, args = args)
  }
}

r_pol_funs <- data.table::rbindlist(dicts) |>
  as_tibble()

py_pol_funs <- data.table::fread("dev/py_polars_functions_and_args.csv") |>
  as_tibble()

dat <- py_pol_funs |>
  left_join(r_pol_funs, suffix = c("_py", "_r"), keep = TRUE)


reactable(
  dat,
  defaultPageSize = nrow(dat),
  defaultColDef = colDef(
    align = "left",
    minWidth = 70
  ),
  columns = list(
    fun_r = colDef(
      style = function(value) {
        color = ifelse(is.na(value), "#ffb3b3", "white")
        list(background = color)
      }
    ),
    args_r = colDef(
      style = function(value) {
        color = ifelse(is.na(value), "#ffb3b3", "white")
        list(background = color)
      }
    )
  ),
  theme = reactableTheme(
    headerStyle = list(
      "&:hover[aria-sort]" = list(background = "hsl(0, 0%, 96%)"),
      "&[aria-sort='ascending'], &[aria-sort='descending']" = list(background = "hsl(0, 0%, 96%)"),
      borderColor = "#555"
    ),
    style = list(
      fontFamily = "Work Sans, Helvetica Neue, Helvetica, Arial, sans-serif",
      fontSize = "1.25rem",
      "a" = list(
        color = "#000000",
        textDecoration = "none",
        "&:hover, &:focus" = list(
          textDecoration = "underline",
          textDecorationThickness = "1px"
        )
      ),
      ".number" = list(
        color = "#666666",
        fontFamily = "Source Code Pro, Consolas, Monaco, monospace"
      ),
      ".tag" = list(
        padding = "0.125rem 0.25rem",
        color = "hsl(0, 0%, 40%)",
        fontSize = "1.25rem",
        border = "1px solid hsl(0, 0%, 24%)",
        borderRadius = "2px",
        textTransform = "uppercase"
      )
    )
  )
)

