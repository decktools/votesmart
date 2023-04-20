#' Get categories that contain ratings by state
#'
#' @param state_ids A vector of state abbreviations. Defaults to \code{NA} for national.
#'
#' @return A dataframe with columns \code{category_id, name, state_id}.
#' @export
#'
#' @examples
#' \dontrun{
#' rating_get_categories("NM")
#' }
rating_get_categories <- function(state_ids = NA) {
  state_ids %<>%
    as_char_vec()

  r <- "Rating.getCategories?"

  out <- tibble()

  for (s in state_ids) {
    message(glue::glue(
      "Beginning to get categories for state {s}."
    ))

    q <- glue::glue("&stateId={s}")

    this <-
      get(
        req = r,
        query = q,
        level_one = "categories",
        level_two = "category"
      ) %>%
      mutate(
        state_id = s
      )

    out %<>%
      bind_rows(this)
  }
  out %>%
    distinct()
}
