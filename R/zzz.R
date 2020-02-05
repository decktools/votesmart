#' @import bonanza dplyr httr nnet XML
#' @importFrom stats na.omit
#' @importFrom utils setTxtProgressBar txtProgressBar

get_key <- function() {
  Sys.getenv("VOTESMART_API_KEY")
}

.onLoad <- function(libname, pkgname) {
  message("Storing API key in global variable `pvs.key`.")
  pvs.key <<- get_key()
}
