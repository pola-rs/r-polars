###### Custom script:
######
###### - get the Rd files, convert them to markdown in "docs/docs/reference" and
######   put them in "mkdocs.yaml"
###### - run the examples in the "Reference" files
library(yaml)
library(here)
library(pkgload)

pkgload::load_all(".")

yml = read_yaml("altdoc/mkdocs_static.yml")

is_internal = function(file) {
  y = capture.output(tools::Rd2latex(file))
  z = grepl("\\\\keyword\\{", y)
  if (!any(z)) {
    return(FALSE)
  }
  reg = regmatches(y, gregexpr("\\{\\K[^{}]+(?=\\})", y, perl = TRUE))
  test = vapply(seq_along(y), function(foo) {
    z[foo] && ("internal" %in% reg[[foo]] || "docs" %in% reg[[foo]])
  }, FUN.VALUE = logical(1L))
  any(test)
}


##############
## Make docs hierarchy ##
##############

other = list.files("man", pattern = "\\.Rd")
other = Filter(\(x) !is_internal(paste0("man/", x)), other)
other = sub("Rd$", "md", other)
out = list()
# order determines order in sidebar
classes = c(
  "pl", "Series", "DataFrame", "LazyFrame", "GroupBy",
  "LazyGroupBy", "RollingGroupBy", "DynamicGroupBy", "ExprList", "ExprBin",
  "ExprCat", "ExprDT", "ExprMeta", "ExprName", "ExprStr", "ExprStruct",
  "ExprArr", "Expr", "IO", "RThreadHandle", "SQLContext", "S3"
)
for (cl in classes) {
  files = grep(paste0("^", cl, "_"), other, value = TRUE)
  tmp = sprintf("%s: man/%s", sub("\\.md", "", sub("[^_]*_", "", files)), files)
  cl_label = ifelse(cl == "pl", "Polars", cl)
  cl_label = ifelse(cl == "IO", "Input/Output", cl_label)
  cl_label = ifelse(cl == "S3", "S3 Methods", cl_label)
  out = append(out, setNames(list(tmp), cl_label))
  other = setdiff(other, files)
}
# expr: nested
nam = c(
  "Expr" = "All others",
  "ExprArr" = "Array",
  "ExprList" = "List",
  "ExprBin" = "Binary",
  "ExprCat" = "Categorical",
  "ExprDT" = "DateTime",
  "ExprMeta" = "Meta",
  "ExprName" = "Name",
  "ExprStr" = "String",
  "ExprStruct" = "Struct"
)

tmp = lapply(names(nam), \(n) setNames(list(out[[n]]), nam[n]))
out = out[!names(out) %in% names(nam)]
out[["Expressions"]] = tmp
# other
tmp = sprintf("%s: man/%s", sub("\\.md$", "", other), other)
hierarchy = append(out, setNames(list(tmp), "Other"))


##############
## Convert to yaml format ##
##############

hierarchy = append(list("Reference" = "reference_home.md"), hierarchy)

# Insert the links in the settings
yml$nav[[3]]$Reference = hierarchy


# Customize the search
plugins <- yml$plugins
if (is.character(plugins)) {
  plugins <- setNames(as.list(plugins), plugins)
  plugins[["search"]] <- list(
    separator = paste0("[\\s\\-]+|(", paste(classes, collapse = "_|"), "_)")
  )
} else if (is.list(plugins)) {
  for (i in seq_along(plugins)) {
    if (plugins[[i]] == "search") {
      plugins[[i]] <- list(
        search = list(
          separator = paste0("[\\s\\-]+|(", paste(classes, collapse = "_|"), "_)")
        )
      )
    }
  }
}
yml$plugins <- plugins


# These two elements should be lists in the yaml format, not single elements,
# otherwise mkdocs breaks
for (i in c("extra_css", "plugins")) {
  if (!is.null(yml[[i]]) && !is.list(length(yml[[i]]))) {
    yml[[i]] = as.list(yml[[i]])
  }
}

# Write the settings to the `altdoc/` directory
out = as.yaml(yml, indent.mapping.sequence = TRUE)
out = gsub("- '", "- ", out)
out = gsub("\\.md'", "\\.md", out)
cat(out, file = "altdoc/mkdocs.yml")
