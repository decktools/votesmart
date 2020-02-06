#' Get offices by level
#'
#' @param office_level_id
#'
#' @return A dataframe with columns \code{office_id, name, title, office_level_id, office_type_id, office_branch_id, short_title}.
#' @export
#'
#' @examples
#' \dontrun{
#' office_get_offices_by_level("F")
#'
#' office_get_levels() %>%
#'   pull(office_level_id) %>%
#'   .[1] %>%
#'   office_get_offices_by_level()
#' }
office_get_offices_by_level <- function(office_level_id) {
  out <- tibble()

  r <- get_req()

  for (l in office_level_id) {
    q <- elmers("&levelId={l}")

    this <-
      get(
        req = r,
        query = q,
        level_one = "offices",
        level_two = "office"
      )

    out %<>%
      bind_rows(this)
  }
  out %>%
    select(
      office_id,
      name,
      title,
      office_level_id,
      everything()
    ) %>%
    distinct()
}
