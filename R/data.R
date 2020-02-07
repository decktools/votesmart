#' Endpoint-Input Mapping
#'
#' Unnested tibble containing the mapping between each endpoint, the inputs it takes, and whether those inputs are required. One or more input rows per endpoint.
#'
#' @format A tibble with 108 rows and 3 variables:
#' \describe{
#'   \item{endpoint}{name of the API endpoint}
#'   \item{input}{one or multiple inputs that can be used in the request to that endpoint}
#'   \item{required}{boolean: whether that input is required for that endpoint}
#' }
#' @source \url{http://api.votesmart.org/docs/}
"endpoint_input_mapping"


#' Nested Endpoint-Input Mapping
#'
#' Nested tibble containing the mapping between each endpoint, the inputs it takes, and whether those inputs are required.
#'
#' @format A tibble with 70 rows and 2 variables:
#' \describe{
#'   \item{endpoint}{name of the API endpoint}
#'   \item{inputs}{a list column containing one or more inputs and a boolean indicating whether they are required for that endpoint. Can be unnested with \code{tidyr::unnest}}
#' }
#' @source \url{http://api.votesmart.org/docs/}
"endpoint_input_mapping_nested"
