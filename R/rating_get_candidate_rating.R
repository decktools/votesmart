
#' Get SIG (Special Interest Group) ratings for candidates
#'
#' @param candidate_ids A vector of candidate ids.
#' @param sig_ids A vector of SIG ids. Default is \code{NA}.
#' @param all Boolean: should all possible combinations of the variables be searched for, or just the exact combination of them in the order they are supplied?
#' @param verbose Should cases when no data is available be messaged?
#'
#' @return A dataframe with the columns \code{rating_id, candidate_id, sig_id, rating, rating_name, timespan, categories, rating_text}.
#' @export
#'
#' @examples
#' \dontrun{
#' pelosi_id <- "26732"
#' rating_get_candidate_ratings(pelosi_id)
#' }
rating_get_candidate_ratings <- function(candidate_ids,
  sig_ids = "",
  all = TRUE,
  verbose = TRUE) {
  out <- tibble()

  # r <- get_req()
  r <- "Rating.getCandidateRating?"

  if (all) {
    query_df <-
      expand.grid(
        candidate_id = candidate_ids,
        sig_id = sig_ids
      ) %>%
      mutate(
        query = elmers("&candidateId={candidate_id}&sigId={sig_id}")
      )
  } else {
    lengths <-
      c(length(candidate_ids), length(sig_ids)) %>%
      magrittr::extract(
        !. == 1
      )

    if (!identical(lengths)) {
      stop("If `all` is FALSE, lengths of inputs must be equivalent to each other, or 1.")
    }

    query_df <-
      tibble(
        candidate_id = candidate_ids,
        sig_id = sig_ids
      ) %>%
      mutate(
        query =
          case_when(
            is.na(sig_id) ~ elmers("&candidateId={candidate_id}"),
            TRUE ~ elmers("&candidateId={candidate_id}&sigId={sig_id}")
          )
      )
  }

  for (i in 1:nrow(query_df)) {
    candidate_id <- query_df$candidate_id[i]
    sig_id <- query_df$sig_id[i]
    q <- query_df$query[i]

    elmers_message(
      "Requesting data for {{candidate_id: {candidate_id}, sig_id: {sig_id}}}."
    )

    this <-
      get(
        req = r,
        query = q,
        level_one = "candidateRating",
        level_two = "rating"
      )

    if (all(is.na(this))) {
      if (verbose) {
        elmers_message(
          "No results found for query {q}."
        )
      }

      this <-
        tibble(
          candidate_id = candidate_id,
          sig_id = sig_id
        )
    } else {
      this %>%
        mutate(
          candidate_id = candidate_id
        ) %>%
        select(
          rating_id,
          candidate_id,
          sig_id,
          rating,
          rating_name,
          timespan,
          categories,
          rating_text
        )
    }

    out %<>%
      bind_rows(this)
  }
  out %>%
    distinct()
}
