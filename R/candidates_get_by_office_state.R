#' Get candidates by the state in which they hold office
#'
#' @param state_ids Optional: vector of state abbreviations. Default is \code{NA}, for national elections.
#' @param office_ids Required: vector of office ids that candidates hold. See \link{\code{office_get_levels}} and \link{\code{office_get_offices_by_level}} for office ids.
#' @param election_years Optional: vector of election years in which the candidate held office. Default is the current year.
#' @param all Boolean: should all possible combinations of the variables be searched for, or just the exact combination of them in the order they are supplied?
#' @param verbose Should cases when no data is available be messaged?
#'
#' @return A dataframe of candidates and their attributes. If a given \code{state_id} + \code{office_id} + \code{election_year} combination returns no data, that row will be filled with \code{NA}s.
#' @export
#'
#' @examples
#' \dontrun{
#' candidates_get_by_office_state(c(NA, "NY", "CA"), c("1", "6"), verbose = TRUE)
#' }
candidates_get_by_office_state <- function(state_ids = NA,
                                           office_ids,
                                           election_years = lubridate::year(lubridate::today()),
                                           all = TRUE,
                                           verbose = TRUE) {
  req <- "Candidates.getByOfficeState?"

  state_ids %<>%
    as_char_vec()
  office_ids %<>%
    as_char_vec()
  election_years %<>%
    as_char_vec()

  if (all) {
    query_df <-
      expand.grid(
        state_id = state_ids,
        office_id = office_ids,
        election_year = election_years
      ) %>%
      mutate(
        query =
          elmers(
            "&stateId={state_id}&officeId={office_id}&electionYear={election_year}"
          )
      )
  } else {
    length_state_ids <- length(state_ids)
    length_office_ids <- length(office_ids)
    length_election_years <- length(election_years)
    lengths <-
      c(length_state_ids, length_office_ids, length_election_years) %>%
      magrittr::extract(
        ! . == 1
      )

    if (!identical(lengths)) {
      stop("If `all` is TRUE, lengths of inputs must be equivalent to each other, or 1.")
    }

    query_df <-
      tibble(
        state_id = state_ids,
        office_id = office_ids,
        election_year = election_years
      )
  }

  out <- tibble()

  for (i in 1:nrow(query_df)) {

    q <- query_df$query[i]
    state_id <- query_df$state_id[i]
    office_id <- query_df$office_id[i]
    election_year <- query_df$election_year[i]

    if (verbose) {
      elmers_message(
        "Requesting data for {{state_id: {state_id}, office_id: {office_id}, election_year: {election_year}}}."
      )
    }

    url <-
      construct_url(req, q)

    raw <- request(url)

    lst <-
      raw$candidateList$candidate

    if (is.null(lst)) {
      if (verbose) {
        elmers_message(
          "No results found for query {q}."
        )
      }

      # Other cols will be NA
      this <-
        tibble(
          office_id = office_id,
          state_id = state_id,
          election_year = election_year
        )
    } else {
      # Turn each element into a tibble and rowbind them
      this <- lst %>%
        purrr::map(as_tibble) %>%
        purrr::modify_depth(2, as.character) %>%
        bind_rows() %>%
        clean_df() %>%
        mutate(
          office_id = office_id,
          state_id = state_id,
          election_year = election_year
        ) %>%
        select(
          candidate_id,
          first_name,
          nick_name,
          middle_name,
          last_name,
          suffix,
          title,
          ballot_name,
          state_id,
          office_id,
          election_year,
          everything()
        )
    }

    out %<>%
      bind_rows(this)
  }
  out
}
