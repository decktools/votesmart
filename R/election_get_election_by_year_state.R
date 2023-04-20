#' Get election info by election year and state
#'
#' @param years A vector of election years.
#' @param state_ids A vector of state abbreviations.
#' @param all Boolean: should all possible combinations of the variables be searched for, or just the exact combination of them in the order they are supplied?
#' @param verbose Should cases when no data is available be messaged?
#'
#' @return A dataframe of candidates and their attributes. If a given \code{year} + \code{state_id} returns no data, that row will be filled with \code{NA}s.
#' @export
#'
#' @examples
#' \dontrun{
#' election_get_election_by_year_state(years = c(2016, 2017))
#' }
election_get_election_by_year_state <- function(
    years =
      lubridate::year(lubridate::today()),
    state_ids = "",
    all = TRUE,
    verbose = TRUE) {
  years %<>%
    as_char_vec()
  state_ids %<>%
    as_char_vec()

  if (all) {
    query_df <-
      expand_grid(
        year = years,
        state_id = state_ids
      ) %>%
      mutate(
        query =
          glue::glue(
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
          glue::glue(
            "&year={year}&stateId={state_id}"
          )
      )
  }

  r <- "Election.getElectionByYearState?"

  out <- tibble()

  for (i in 1:nrow(query_df)) {
    q <- query_df$query[i]
    year <- query_df$year[i]
    state_id <- query_df$state_id[i]

    if (verbose) {
      message(glue::glue(
        "Requesting data for {{year: {year}, state_id: {state_id}}}."
      ))
    }

    this <- get_election(
      req = r,
      query = q
    )

    if (all(is.na(this))) {
      if (verbose) {
        message(glue::glue(
          "No results found for query {q}."
        ))
      }

      this <-
        query_df %>%
        select(-query) %>%
        rename(
          election_year = year
        ) %>%
        vs_na_if("")
    } else {
      this %<>%
        mutate(
          election_year = year
        ) %>%
        select(
          election_id,
          election_year,
          state_id,
          name,
          everything()
        )
    }

    out %<>%
      bind_rows(this)
  }
  out %>%
    distinct()
}
