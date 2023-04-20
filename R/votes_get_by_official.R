#' Get votes by official
#'
#' @param candidate_ids Vector of candidate_ids (required). See \link{candidates_get_by_lastname}, \link{candidates_get_by_levenshtein}, and \link{candidates_get_by_office_state}.
#' @param office_ids Vector of office_ids. See \link{office_get_offices_by_level}.
#' @param category_ids Vector of category_ids. See \link{rating_get_categories}.
#' @param years Vector of years in which the vote was taken.
#' @param all Boolean: should all possible combinations of the variables be searched for, or just the exact combination of them in the order they are supplied?
#' @param verbose Should cases when no data is available be messaged?
#'
#' @return A dataframe of candidates' votes on bills and their attributes. If a given input combination returns no data, that row will be filled with \code{NA}s.
#' @export
#'
#' @examples
#' \dontrun{
#' aoc <- candidates_get_by_lastname(
#'   "ocasio-cortez",
#'   election_years = "2018"
#' )
#' votes_get_by_official(aoc$candidate_id)
#' }
votes_get_by_official <- function(
    candidate_ids,
    office_ids = "",
    category_ids = "",
    years = "",
    all = TRUE,
    verbose = TRUE) {
  candidate_ids %<>%
    as_char_vec()
  office_ids %<>%
    as_char_vec()
  category_ids %<>%
    as_char_vec()
  years %<>%
    as_char_vec()

  if (all) {
    query_df <-
      expand_grid(
        candidate_id = candidate_ids,
        office_id = office_ids,
        category_id = category_ids,
        year = years
      ) %>%
      mutate(
        query =
          glue::glue(
            "&candidateId={candidate_id}&officeId={office_id}&categoryId={category_id}&year={year}"
          )
      )
  } else {
    arg_lengths <-
      c(length(candidate_ids), length(office_ids), length(category_ids), length(years)) %>%
      magrittr::extract(
        !. == 1
      )

    if (length(arg_lengths) > 1 && (max(arg_lengths) - min(arg_lengths) != 0)) {
      stop("If `all` is FALSE, lengths of inputs must be equivalent to each other, or 1.")
    }

    query_df <-
      tibble(
        candidate_id = candidate_ids,
        office_id = office_ids,
        category_id = category_ids,
        year = years
      ) %>%
      mutate(
        query =
          glue::glue(
            "&candidateId={candidate_id}&officeId={office_id}&categoryId={category_id}&year={year}"
          )
      )
  }

  r <- "Votes.getByOfficial?"

  out <- tibble()

  for (i in 1:nrow(query_df)) {
    q <- query_df$query[i]
    candidate_id <- query_df$candidate_id[i]
    office_id <- query_df$office_id[i]
    category_id <- query_df$category_id[i]
    year <- query_df$year[i]

    if (verbose) {
      message(glue::glue(
        "Requesting data for {{candidate_id: {candidate_id}, office_id: {office_id}, category_id: {category_id}, year: {year}}}."
      ))
    }

    this <- get(
      req = r,
      query = q,
      level_one = "bills",
      level_two = "bill"
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
          category_id_1 = category_id
        ) %>%
        vs_na_if("")
    } else {
      # Turn each element into a tibble and rowbind them
      this %<>%
        mutate(
          candidate_id = candidate_id,
          year = year
        ) %>%
        rename_all(
          stringr::str_remove, "categories_category_"
        ) %>%
        select(
          bill_id,
          candidate_id,
          bill_number,
          title,
          vote,
          office_id,
          everything()
        )
    }

    out %<>%
      bind_rows(this)
  }
  out %>%
    distinct()
}
