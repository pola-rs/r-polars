#NOTES FOR HACKING AUTOCOMPLETION

# unlockBinding("zip",env=environment(utils:::.DollarNames))
# > local({zip  = function(...) print("mehehhehe")},envir=(envir=environment(utils:::.DollarNames)))
# > utils:::zip()
