make_profile_plot <- function(data, truncate_nodes) {
  check_installed("ggplot2")
  timings <- as.data.frame(data[[2]])
  timings$node <- factor(timings$node, levels = unique(timings$node))
  total_timing <- max(timings$end)
  if (total_timing > 10000000) {
    unit <- "s"
    total_timing <- paste0(total_timing / 1000000, "s")
    timings$start <- timings$start / 1000000
    timings$end <- timings$end / 1000000
  } else if (total_timing > 10000) {
    unit <- "ms"
    total_timing <- paste0(total_timing / 1000, "ms")
    timings$start <- timings$start / 1000
    timings$end <- timings$end / 1000
  } else {
    unit <- "\U00B5s"
    total_timing <- paste0(total_timing, "\U00B5s")
  }

  # for some reason, there's an error if I use rlang::.data directly in aes()
  .data <- rlang::.data

  plot <- ggplot2::ggplot(
    timings,
    ggplot2::aes(
      x = .data[["start"]], xend = .data[["end"]],
      y = .data[["node"]], yend = .data[["node"]]
    )
  ) +
    ggplot2::geom_segment(linewidth = 6) +
    ggplot2::xlab(
      paste0("Node duration in ", unit, ". Total duration: ", total_timing)
    ) +
    ggplot2::ylab(NULL) +
    ggplot2::theme(
      axis.text = ggplot2::element_text(size = 12)
    )

  if (truncate_nodes > 0) {
    plot <- plot +
      ggplot2::scale_y_discrete(
        labels = rev(paste0(strtrim(timings$node, truncate_nodes), "...")),
        limits = rev
      )
  } else {
    plot <- plot +
      ggplot2::scale_y_discrete(
        limits = rev
      )
  }

  # do not show the plot if we're running testthat
  if (!identical(Sys.getenv("TESTTHAT"), "true")) {
    print(plot)
  }
  plot
}
