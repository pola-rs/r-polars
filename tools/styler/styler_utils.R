# Prepare rpolars style (the function that output the set transformers and name/version)
rpolars_style = function() {
  # derive from tidyverse
  transformers = styler::tidyverse_style()
  transformers$style_guide_name = "rpolars_style"
  transformers$style_guide_version = "0.1.0"

  # reverse tranformer to make <- into =
  transformers$token$force_assignment_op = function(pd) {
    to_replace = pd$token == "LEFT_ASSIGN"
    pd$token[to_replace] = "EQ_ASSIGN"
    pd$text[to_replace] = "="
    pd
  }

  # Specify which tokens must be absent for a transformer to be dropped
  # https://styler.r-lib.org/reference/specify_transformers_drop.html?q=transformers%20_%20drop
  transformers$transformers_drop$token$force_assignment_op = "LEFT_ASSIGN"

  transformers
}


# a function to discover files changes via git
get_file_changes = function(
    # a list functions that generate file suggestions
    git_calls = list(

      # any file differing from main (or what ever branch desired)
      diff = \() system("git diff main --name-only", intern = TRUE),

      # any file that has been created / edited, compared to last commit
      status = \() {
        system("git status --porcelain", intern = TRUE) |>
          sapply(\(line) substr(line, start = 4, stop = 9999)) |>
          unname()
      }
    ),
    # a regex pattern to filer suggestions by
    pattern = "\\.R$|\\.Rmd$",
    # specific files never to style
    excludes = c("R/extendr-wrappers.R")) {
  lapply(
    git_calls,
    \(f) {
      f() |>
        (\(fns) fns[grepl(pattern, fns)])() |>
        setdiff(excludes)
    }
  )
}


style_files = function(
    paths_list = get_file_changes(),
    transformers = rpolars_style(),
    do_parallel = FALSE,
    ncpu = NULL,
    verbose = TRUE,
    ...) {
  if (verbose) {
    print(paths_list)
  }



  paths = unlist(paths_list)

  # do big files first for better load balancing
  paths = paths[order(file.info(paths)$size, decreasing = TRUE)]

  if (length(paths) == 0) {
    print("no files to style")
    return(NULL)
  }




  if (do_parallel) {
    ncpu = if (is.null(ncpu)) parallel::detectCores() else ncpu
    ncpu = min(ncpu, length(paths))
    cl = tryCatch(
      parallel::makeForkCluster(nnodes = ncpu),
      error = function(e) {
        if (verbose) {
          print("using psock cluster")
        }
        parallel::makePSOCKcluster(spec = ncpu)
      }
    )
    on.exit(parallel::stopCluster(cl))
    this_frame = (\() parent.frame())()
    parallel::clusterExport(cl, "transformers", envir = this_frame)
    outs = parallel::clusterApplyLB(
      cl,
      paths,
      \(path) capture.output(styler::style_file(path, transformers = transformers))
    )
    if (verbose) print(outs)
  } else {
    styler::style_file(paths, transformers = transformers, ...)
  }
}
