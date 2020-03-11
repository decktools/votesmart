
#' Get SIG (Special Interest Group) ratings for candidates
#'
#' @param candidate_ids A vector of candidate ids.
#' @param sig_ids A vector of SIG ids. Default is \code{""} for all SIGs.
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
  candidate_ids %<>%
    as_char_vec()

  sig_ids %<>%
    as_char_vec()

  if (all) {
    query_df <-
      expand_grid(
        candidate_id = candidate_ids,
        sig_id = sig_ids
      ) %>%
      mutate(
        query = elmers("&candidateId={candidate_id}&sigId={sig_id}")
      )
  } else {
    arg_lengths <-
      c(length(candidate_ids), length(sig_ids)) %>%
      magrittr::extract(
        !. == 1
      )

    if (length(arg_lengths) > 1 && (max(arg_lengths) - min(arg_lengths) != 0)) {
      stop("If `all` is FALSE, lengths of inputs must be equivalent to each other, or 1.")
    }

    query_df <-
      tibble(
        candidate_id = candidate_ids,
        sig_id = sig_ids
      ) %>%
      mutate(
        query = elmers("&candidateId={candidate_id}&sigId={sig_id}")
      )
  }

  r <- "Rating.getCandidateRating?"

  out <- tibble()

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
        query_df %>%
        select(-query) %>%
        na_if("")
    } else {
      this %<>%
        mutate(
          candidate_id = candidate_id
        ) %>%
        rename_all(
          stringr::str_remove,
          "categories_"
        ) %>%
        rename_all(
          stringr::str_remove,
          "_category"
        ) %>%
        # Distinct all the category values which are sometimes doubled up
        tidyr::pivot_longer(contains("category")) %>%
        group_by(rating_id) %>%
        distinct(value, .keep_all = TRUE) %>%
        tidyr::drop_na(value) %>%
        # Rename categories now that we've deduped
        mutate(
          name = elmers("category_name_{row_number()}"),
          value = elmers("category_id_{row_number()}")
        ) %>%
        # Back to wide format
        tidyr::pivot_wider() %>%
        ungroup() %>%
        select(
          rating_id,
          candidate_id,
          sig_id,
          rating,
          rating_name,
          timespan,
          rating_text,
          everything()
        )
    }

    out %<>%
      bind_rows(this)
  }
  out %>%
    distinct()
}
