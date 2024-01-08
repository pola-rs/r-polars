#' The rpolars style
#' Prepare rpolars style (the function that output the set transformers and name/version)
#' @return transformers - see styler package
#' @examples rpolars_style()
rpolars_style = function() {
  # derive from tidyverse
  transformers = styler::tidyverse_style()
  transformers$style_guide_name = "rpolars_style"
  transformers$style_guide_version = "0.1.1"

  # reverse tranformer to make <- into =
  transformers$token$force_assignment_op = function(pd) {
    to_replace = pd$token == "LEFT_ASSIGN"

    # pretect against changing globalAssign operator, which does not have a unique defined token.
    if (any(to_replace)) {
      to_replace = to_replace & pd$text != "<<-"
    }

    pd$token[to_replace] = "EQ_ASSIGN"
    pd$text[to_replace] = "="
    pd
  }

  # Specify which tokens must be absent for a transformer to be dropped
  # https://styler.r-lib.org/reference/specify_transformers_drop.html?q=transformers%20_%20drop
  transformers$transformers_drop$token$force_assignment_op = "LEFT_ASSIGN"

  transformers
}


#'  discover files changes via git
#' @param git_calls  system calls to git
#' @param branch  a branch to git diff agains, also setable via env var "GIT_DIF_TARGET".
#' If NULL and "GIT_DIF_TARGET" is not set, defaults to "main"
#'
#' @param pattern any found path must match on this pattern
#'
#' @param excludes any found path cannot be mentioned in here
#'
#' @return list char vectors for each call of found files
#'
#' @examples
get_file_changes = function(
    # a list functions that generate file suggestions
    git_calls = list(

      # any file differing from main (or what ever branch desired)
      diff = \() system(paste("git diff ", Sys.getenv("GIT_DIF_TARGET"), " --name-only"), intern = TRUE),

      # any file that has been created / edited, compared to last commit
      status = \() {
        system("git status --porcelain", intern = TRUE) |>
          sapply(\(line) substr(line, start = 4, stop = 9999)) |>
          unname()
      },

      # any untracked file, e.g. any not yet committed to repo
      untracked = \() system("git ls-files --others --exclude-standard", intern = TRUE)
    ),
    # track branch
    branch = NULL,
    # a regex pattern to filer suggestions by
    pattern = "\\.R$|\\.Rmd$",
    # specific files never to style
    excludes = c("R/extendr-wrappers.R")) {
  # temporarily set GIT_DIF_TARGET
  old_env = Sys.getenv("GIT_DIF_TARGET")
  on.exit({
    Sys.setenv("GIT_DIF_TARGET" = old_env)
  })
  if (is.null(branch)) {
    Sys.setenv("GIT_DIF_TARGET" = "main")
  } else {
    Sys.setenv("GIT_DIF_TARGET" = branch)
  }

  # for all git calls
  lapply(
    git_calls,
    \(f) {
      f() |> # execute call
        (\(fnames) fnames[grepl(pattern, fnames)])() |> # filter filenames on pattern
        setdiff(excludes) # exclude specific filenames
    }
  )
}



#' rpolars style all changed files
#'
#' @param paths_list char vec or list of char vecs of paths to files to style. Default is
#' get_file_changes(), which is all changed files according to git.
#' @param transformers what style transformers to use, default is rpolars_style().
#' @param do_parallel bool should styling be performed in parallel
#' @param ncpu set number of cpu to use. Also limited of number of files to style.
#' @param verbose print alot
#' @param ... args passed to get_file_changes() or if parallel FALSE styler::style_file
#' @param branch which branch to compare changes to
#'
#' @return NULL
#'
#' @examples
#' style_files()
style_files = function(
    paths_list = NULL,
    transformers = rpolars_style(),
    do_parallel = TRUE,
    ncpu = NULL,
    verbose = TRUE,
    branch = "main",
    ...) { # ... current supported in paralllel

  if (is.null(paths_list)) {
    paths_list = get_file_changes(branch = branch, ...)
  }

  if (verbose) {
    print(paths_list)
  }

  paths = unlist(paths_list) |>
    unique()

  # do big files first for better load balancing
  paths = paths[order(file.info(paths)$size, decreasing = TRUE)]

  if (length(paths) == 0) {
    print("no files to style")
    return(NULL)
  }

  if (do_parallel) {
    ncpu = if (is.null(ncpu)) parallel::detectCores() else ncpu
    ncpu = min(ncpu, length(paths))
    if (verbose) print(paste("ncpu = ", ncpu))

    cl_init_time = system.time({
      cl = tryCatch(
        parallel::makeForkCluster(nnodes = ncpu),
        error = function(e) {
          if (verbose) {
            print("using psock cluster")
          }
          parallel::makePSOCKcluster(ncpu)
        }
      )
    })
    on.exit(parallel::stopCluster(cl))

    if (verbose) {
      print(paste("time to start cluster: ", round(cl_init_time[3], 3), "seconds"))
    }

    this_frame = (\() parent.frame())()
    parallel::clusterExport(cl, c("transformers", "verbose"), envir = this_frame)
    outs = parallel::clusterApplyLB(
      cl,
      paths,
      # TODO support ... args in parallel, or just add explicitly
      \(path) capture.output({
        t = system.time({
          styler::style_file(path, transformers = transformers)
        })
        if (verbose) {
          cat(paste(".   ", round(t[3], 2), "seconds\n"))
        }
      })
    )
    if (verbose) lapply(outs, cat, sep = "\n")
  } else {
    styler::style_file(paths, transformers = transformers, ...)
  }
  invisible(NULL)
}

#' rpolars style entire package
#' @return NULL
#' style_entire_pkg()
style_entire_pkg = function() {
  list.files(".", full.names = TRUE, pattern = "\\.R$|\\.Rmd$", recursive = TRUE) |>
    setdiff("./R/extendr-wrappers.R") |>
    style_files()
}
