## This script can be used to parse R CMD check and evaluate a list of ignore rules.
## Known notes/warnings/errors which are fine, has a defined rule to filter them out.
## Remaining notes/errors/warnings will be raised as an concatenated error. Error does not
## have to be pretty. Developer shoud go read rcmdcheck report instead.


library(rcmdcheck)
print(R.version)
print(Sys.info())
print(getwd())

#define ignore rules for notes, warnings and errors
ignore_rules = list(
  notes = list(
    #if note contains this phrase then skip it by returning TRUE.
    #yes polars is huge way above 10Mb nothing to do about that
    ignore_lib_size = function(msg) {
      isTRUE(grepl("checking installed package size ... NOTE",msg))
    }
  ),
  warnings = list(),
  errors = list(

    #R4.3.x devel now requires no unquoted braces '{' in docs. This filter turns off that error
    # until fixed likely via PR #424
    ignore_lost_braces = function(msg) {
      isTRUE(grepl("Lost braces",msg))
    }
  )
)


#drop any filter if FILTER_CHECK_NO_FILTER = true
if (Sys.getenv("FILTER_CHECK_NO_FILTER") == "true") {
  ignore_rules$notes = list()
  ignore_rules$warnings = list()
  ignore_rules$errors = list()
}


#helper function
#iterate a msg_set, as notes, warnings, errors and drop those where an ignore rule returns TRUE
drop_ignored = function(msg_set, rule_list) {
  ignore_these = sapply(msg_set, function(note){
    any(sapply(rule_list,function(f) isTRUE(f(note))))
  }) |> as.logical()
  msg_set[!ignore_these]
}

#parse check report to object
check_report_path = c(
  Sys.getenv("rcmdcheck_path"),
  "./check/polars.Rcheck/"
) |> (\(x) {x[nzchar(x)]})()
check_obj = rcmdcheck::parse_check(check_report_path)


#filter remaining not-ignored msgs
remaining_erros = unlist(lapply(
  c(notes = "notes", warnings = "warnings", errors = "errors"),
  function(msg_type) {
    drop_ignored(check_obj[[msg_type]], ignore_rules[[msg_type]])
  }
))


#raise any remaining errors
if( length(remaining_erros)) {
  stop(remaining_erros)
  print("some errors where not ignored, and will be raised right now!")
} else {
  print(ignore_rules)
  print("Hey you deserve a Gold Medal!! No msgs from rcmdcheck you're not ignoring anyways")
}
