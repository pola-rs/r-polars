
# """
#     Aggregate multiple Dataframes/Series to a single DataFrame/Series.
#     Parameters
#     ----------
#     items
#         DataFrames/Series/LazyFrames to concatenate.
#     rechunk
#         Make sure that all data is in contiguous memory.
#     how : {'vertical', 'diagonal', 'horizontal'}
#         Only used if the items are DataFrames.
#         - Vertical: applies multiple `vstack` operations.
#         - Diagonal: finds a union between the column schemas and fills missing column
#             values with null.
#         - Horizontal: stacks Series horizontally and fills with nulls if the lengths
#             don't match.
#     parallel
#         Only relevant for LazyFrames. This determines if the concatenated
#         lazy computations may be executed in parallel.
#     Examples
#     --------
#     >>> df1 = pl.DataFrame({"a": [1], "b": [3]})
#     >>> df2 = pl.DataFrame({"a": [2], "b": [4]})
#     >>> pl.concat([df1, df2])
#     shape: (2, 2)
#     ┌─────┬─────┐
#     │ a   ┆ b   │
#     │ --- ┆ --- │
#     │ i64 ┆ i64 │
#     ╞═════╪═════╡
#     │ 1   ┆ 3   │
#     ├╌╌╌╌╌┼╌╌╌╌╌┤
#     │ 2   ┆ 4   │
#     └─────┴─────┘
#    """
#' concat polar objects
#'
#' @param l list of DataFrame, or Series, LazyFrame or Expr
#' @param rechunk perform a rechunk at last
#' @param how choice of bind direction "vertical"(rbind) "horizontal"(cbind) "diagnoal" diagonally
#' @param parallel BOOL default TRUE, only used for LazyFrames
#'
#' @return DataFrame, or Series, LazyFrame or Expr
#' @export
#'
#' @examples
#' #vertical
#'  l_ver = lapply(1:10, function(i) {
#'l_internal = list(
#'  a = 1:5,
#'  b = letters[1:5]
#')
#'pl$DataFrame(l_internal)
#'})
#'pl$concat(l_ver, how="vertical")
#'
#'
#'#horizontal
#'l_hor = lapply(1:10, function(i) {
#'  l_internal = list(
#'    1:5,
#'    letters[1:5]
#'  )
#'  names(l_internal) = paste0(c("a","b"),i)
#'  pl$DataFrame(l_internal)
#'})
#'pl$concat(l_hor, how = "horizontal")
#'
#'
#'#diagonal
#'pl$concat(l_hor, how = "diagonal")
concat = function(
    l, #list of DataFrames or Series or lazyFrames or expr
    rechunk = TRUE,
    how  = c("vertical","horizontal","diagnoal"),
    parallel = TRUE #not used yet
) {

  ## Check inputs
  how = match.arg(how[1], c("vertical","horizontal","diagonal"))

  # dispatch on item class and how
  first = l[[1]]
  result = pcase(
    inherits(first,"DataFrame"), {
      vdf = l_to_vdf(l)
      pcase(
        how == "vertical",   minipolars:::concat_df(vdf),
        how == "diagonal",    minipolars:::diag_concat_df(vdf),
        how == "horizontal", minipolars:::hor_concat_df(vdf),
        or_else = abort("internal errror")
      )
    },

    inherits(first,"Series"), {
      abort("not implemented Series")
    },

    inherits(first,"Expr"), {
      abort("not implemented Expr")
    },

    #TODO implement Series, Expr, Lazy etc
    or_else = abort(paste0("type of first list element: '",class(first),"' is not supported"))
  )

  unwrap(result)
}



