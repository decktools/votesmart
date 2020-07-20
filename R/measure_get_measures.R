
#' Get information on a ballot measure
#'
#' Ballot measure ids can be found with the \code{\link{measure_get_measures_by_year_state}} function.
#'
#' @param measure_ids Vector of ballot measure ids.
#' @param verbose Should cases when no data is available be messaged?
#'
#' @return A dataframe with the columns \code{measure_id, measure_code, title, election_date, election_type, outcome, yes_votes, no_votes, summary, summary_url, measure_text, text_url, pro_url, con_url}.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' measure_get_measures("1234")
#' }
measure_get_measures <- function(measure_ids,
  verbose = TRUE) {
  measure_ids %<>%
    as_char_vec()

  query_df <-
    tibble(
      measure_id = measure_ids
    ) %>%
    mutate(
      query =
        elmers(
          "&measureId={measure_id}"
        )
    )

  r <- "Measure.getMeasure?"

  out <- tibble()

  for (i in 1:nrow(query_df)) {
    measure_id <- query_df$measure_id[i]
    q <- query_df$query[i]

    elmers_message(
      "Requesting data for {{measure_id: {measure_id}}."
    )

    this <-
      get(
        req = r,
        query = q,
        level_one = "measure",
        level_two = NA
      )

    if (all(is.na(this))) {
      if (verbose) {
        elmers_message(
          "No results found for query {q}."
        )
      }

      this <-
        query_df %>%
        select(-query) %>%
        na_if("")
    } else {
      this %<>%
        transmute(
          measure_id,
          measure_code,
          title,
          election_date = lubridate::as_date(election_date),
          election_type,
          outcome,
          yes_votes = yes %>% as.integer(),
          no_votes = no %>% as.integer(),
          summary,
          summary_url,
          measure_text,
          text_url,
          pro_url,
          con_url
        )
    }

    out %<>%
      bind_rows(this)
  }
  out %>%
    distinct()
}
