#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @return The left hand side object with the right hand side applied to it. Does not reassign this value to the left hand side.
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

#' Assignment pipe operator
#'
#' See \code{magrittr::\link[magrittr:compound]{\%<>\%}} for details.
#'
#' @name %<>%
#' @rdname assignment_pipe
#' @keywords internal
#' @return The left hand side object with the right hand side applied to it. Does  reassign this value to the left hand side.
#' @export
#' @importFrom magrittr %<>%
#' @usage lhs \%<>\% rhs
NULL
