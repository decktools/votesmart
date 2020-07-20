
#' Get a dataframe of ballot measures by year and state
#'
#' More information about these ballot measures can be found using the \code{\link{measure_get_measures}} function.
#'
#' @param years A vector of election years.
#' @param state_ids A vector of state abbreviations.
#' @param all Boolean: should all possible combinations of the variables be searched for, or just the exact combination of them in the order they are supplied?
#' @param verbose Should cases when no data is available be messaged?
#'
#' @return A dataframe of ballot measures and their attributes. If a given \code{year} + \code{state_id} returns no data, that row will be filled with \code{NA}s.
#' @export
#'
#' @examples
#' \dontrun{
#' measure_get_measures_by_year_state(years = c(2016, 2018), state_ids = c("MO", "IL", "VT"))
#' }
measure_get_measures_by_year_state <- function(years =
                                                 lubridate::year(lubridate::today()),
                                               state_ids = state.abb,
                                               all = TRUE,
                                               verbose = TRUE) {

  r <-  "Measure.getMeasuresByYearState?"


  if (all) {
    query_df <-
      expand_grid(
        year = years,
        state_id = state_ids
      ) %>%
      mutate(
        query =
          elmers(
            "&year={year}&stateId={state_id}"
          )
      )
  } else {
    arg_lengths <-
      c(length(years), length(state_ids)) %>%
      magrittr::extract(
        !. == 1
      )

    if (length(arg_lengths) > 1 && (max(arg_lengths) - min(arg_lengths) != 0)) {
      stop("If `all` is FALSE, lengths of inputs must be equivalent to each other, or 1.")
    }

    query_df <-
      tibble(
        year = years,
        state_id = state_ids,
        query =
          elmers(
            "&year={year}&stateId={state_id}"
          )
      )
  }

  out <- tibble()

  for (i in 1:nrow(query_df)) {
    q <- query_df$query[i]
    year <- query_df$year[i]
    state_id <- query_df$state_id[i]

    if (verbose) {
      elmers_message(
        "Requesting data for {{year: {year}, state_id: {state_id}}}."
      )
    }

    this <- get(
      req = r,
      query = q,
      level_one = "measures",
      level_two = "measure"
    )

    if (all(is.na(this)) || nrow(this) == 0) {
      if (verbose) {
        elmers_message(
          "No results found for query {q}."
        )
      }

      this <-
        query_df %>%
        slice(i) %>%
        select(-query) %>%
        rename(
          election_year = year,
          state_id = state_id
        ) %>%
        na_if("")
    } else {
      this %<>%
        mutate(
          election_year = year,
          state_id = state_id
        ) %>%
        select(
          measure_id,
          election_year,
          state_id,
          title,
          outcome
        )
    }

    out %<>%
      bind_rows(this)
  }

  out %>%
    distinct()
}
