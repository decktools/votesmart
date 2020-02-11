#' Get office levels
#'
#' These are currently: F for Federal, S for State, and L for Local.
#'
#' @return A dataframe with the columns \code{office_level_id} and \code{name}.
#' @export
#'
#' @examples
#' \dontrun{
#' office_get_levels()
#' }
office_get_levels <- function() {
  r <- "Office.getLevels?"

  out <- get(
    req = r,
    query = "",
    level_one = "levels",
    level_two = "level"
  )

  if (all(is.na(out))) {
    message("Error getting office levels.")
    return(tibble())
  }

  out
}
