
#' Get candidate data by Levenshtein distance from last name
#'
#' From the API docs, \url{http://api.votesmart.org/docs/Candidates.html}, "This method grabs a list of candidates according to a fuzzy lastname match."
#'
#' The actual Levenshtein distance of the result from the \code{last_name} provided is not available from the API.
#'
#' @param last_names Vector of candidate last names
#' @param election_years Vector of election years. Default is the current year.
#' @param stage_ids The \code{stage_id} of the election (\code{"P"} for primary or \code{"G"} for general). See also \code{\link{election_get_election_by_year_state}}.
#' @param all Boolean: should all possible combinations of the variables be searched for, or just the exact combination of them in the order they are supplied?
#' @param verbose Should cases when no data is available be messaged?
#'
#' @return A dataframe of candidates and their attributes. If a given \code{last_name} + \code{election_year} + \code{stage_id} combination returns no data, that row will be filled with \code{NA}s.
#' @export
#'
#' @examples
#' \dontrun{
#' candidates_get_by_levenshtein(c("Bookr", "Klobucar"), 2020)
#' }
candidates_get_by_levenshtein <- function(last_names,
  election_years = lubridate::year(lubridate::today()),
  stage_ids = "",
  all = TRUE,
  verbose = TRUE) {
  last_names %<>%
    as_char_vec()
  election_years %<>%
    as_char_vec()
  stage_ids %<>%
    as_char_vec()

  if (all) {
    query_df <-
      expand_grid(
        last_name = last_names,
        election_year = election_years,
        stage_id = stage_ids
      ) %>%
      mutate(
        query =
          elmers(
            "&lastName={last_name}&electionYear={election_year}&stageId={stage_id}"
          )
      )
  } else {
    arg_lengths <-
      c(length(last_names), length(election_years), length(stage_ids)) %>%
      magrittr::extract(
        !. == 1
      )

    if (length(arg_lengths) > 1 && (max(arg_lengths) - min(arg_lengths) != 0)) {
      stop("If `all` is FALSE, lengths of inputs must be equivalent to each other, or 1.")
    }

    query_df <-
      tibble(
        last_name = last_names,
        election_year = election_years,
        stage_id = stage_ids
      ) %>%
      mutate(
        query =
          elmers(
            "&lastName={last_name}&electionYear={election_year}&stageId={stage_id}"
          )
      )
  }

  r <- "Candidates.getByLevenshtein?"

  out <- tibble()

  for (i in 1:nrow(query_df)) {
    q <- query_df$query[i]
    last_name <- query_df$last_name[i]
    election_year <- query_df$election_year[i]
    stage_id <- query_df$stage_id[i]

    if (verbose) {
      elmers_message(
        "Requesting data for {{last_name: {last_name}, election_year: {election_year}, stage_id: {stage_id}}}."
      )
    }

    this <- get(
      req = r,
      query = q,
      level_one = "candidateList",
      level_two = "candidate"
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
        mutate(
          election_year = election_year,
          stage_id = stage_id
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
          stage_id,
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
