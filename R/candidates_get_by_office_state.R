#' Get candidates by the state in which they hold office
#'
#' @param state_ids Optional: vector of state abbreviations. Default is \code{NA}, for national-level offices (e.g. US President and Vice President). For all other offices the \code{state_id} must be supplied.
#' @param office_ids Required: vector of office ids that candidates hold. See \code{\link{office_get_levels}} and \code{\link{office_get_offices_by_level}} for office ids.
#' @param election_years Optional: vector of election years in which the candidate held office. Default is the current year.
#' @param all Boolean: should all possible combinations of the variables be searched for, or just the exact combination of them in the order they are supplied?
#' @param verbose Should cases when no data is available be messaged?
#'
#' @return A dataframe of candidates and their attributes. If a given \code{state_id} + \code{office_id} + \code{election_year} combination returns no data, that row will be filled with \code{NA}s.
#' @export
#'
#' @examples
#' \dontrun{
#' candidates_get_by_office_state(
#'   state_ids = c(NA, "NY", "CA"),
#'   office_ids = c("1", "6"),
#'   verbose = TRUE
#' )
#' }
candidates_get_by_office_state <- function(
    state_ids = NA,
    office_ids,
    election_years = lubridate::year(lubridate::today()),
    all = TRUE,
    verbose = TRUE) {
  state_ids %<>%
    as_char_vec()
  office_ids %<>%
    as_char_vec()
  election_years %<>%
    as_char_vec()

  if (all) {
    query_df <-
      expand_grid(
        state_id = state_ids,
        office_id = office_ids,
        election_year = election_years
      ) %>%
      mutate(
        query =
          glue::glue(
            "&stateId={state_id}&officeId={office_id}&electionYear={election_year}"
          )
      )
  } else {
    arg_lengths <-
      c(length(state_ids), length(office_ids), length(election_years)) %>%
      magrittr::extract(
        !. == 1
      )

    if (length(arg_lengths) > 1 && (max(arg_lengths) - min(arg_lengths) != 0)) {
      stop("If `all` is FALSE, lengths of inputs must be equivalent to each other, or 1.")
    }

    query_df <-
      tibble(
        state_id = state_ids,
        office_id = office_ids,
        election_year = election_years
      ) %>%
      mutate(
        query =
          glue::glue(
            "&stateId={state_id}&officeId={office_id}&electionYear={election_year}"
          )
      )
  }

  r <- "Candidates.getByOfficeState?"

  out <- tibble()

  for (i in 1:nrow(query_df)) {
    q <- query_df$query[i]
    this_state_id <- query_df$state_id[i]
    this_office_id <- query_df$office_id[i]
    this_election_year <- query_df$election_year[i]

    if (verbose) {
      message(glue::glue(
        "Requesting data for {{state_id: {this_state_id}, office_id: {this_office_id}, election_year: {this_election_year}}}."
      ))
    }

    this <- get(
      req = r,
      query = q,
      level_one = "candidateList",
      level_two = "candidate"
    )

    if (all(is.na(this))) {
      if (verbose) {
        message(glue::glue(
          "No results found for query {q}."
        ))
      }

      # Other cols will be NA
      this <-
        query_df %>%
        select(-query) %>%
        rename(
          office_state_id = state_id
        ) %>%
        vs_na_if("")
    } else {
      # Turn each element into a tibble and rowbind them
      this %<>%
        mutate(
          # Sometimes these are off so set them explicitly
          office_state_id = office_state_id %>% coalesce(this_state_id),
          election_state_id = election_state_id %>% coalesce(this_state_id),
          office_id = office_id %>% coalesce(this_office_id),
          election_year = election_year %>% coalesce(this_election_year),
        ) %>%
        transform_election_special() %>%
        select(
          candidate_id,
          first_name,
          nick_name,
          middle_name,
          last_name,
          suffix,
          title,
          ballot_name,
          office_state_id,
          office_id,
          election_year,
          everything()
        )
    }

    out %<>%
      bind_rows(this)
  }
  out %>%
    distinct()
}
