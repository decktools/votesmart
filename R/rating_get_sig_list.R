#' Get SIG (Special Interest Group) list by category and state
#'
#' @param category_ids Vector of category ids.
#' @param state_ids Vector of state abbreviations. Default \code{NA} for national.
#' @param all Boolean: should all possible combinations of the variables be searched for, or just the exact combination of them in the order they are supplied?
#' @param verbose Should cases when no data is available be messaged?
#'
#' @return A dataframe with the columns \code{sig_id, name, category_id, state_id}.
#' @export
#'
#' @examples
#' \dontrun{
#' rating_get_categories() %>%
#'   dplyr::pull(category_id) %>%
#'   sample(3) %>%
#'   rating_get_sig_list()
#' }
rating_get_sig_list <- function(
    category_ids,
    state_ids = NA,
    all = TRUE,
    verbose = TRUE) {
  category_ids %<>%
    as_char_vec()

  state_ids %<>%
    as_char_vec()

  if (all) {
    query_df <-
      expand_grid(
        category_id = category_ids,
        state_id = state_ids
      ) %>%
      mutate(
        query =
          glue::glue(
            "&categoryId={category_id}&stateId={state_id}"
          )
      )
  } else {
    arg_lengths <-
      c(length(category_ids), length(state_ids)) %>%
      magrittr::extract(
        !. == 1
      )

    if (length(arg_lengths) > 1 && (max(arg_lengths) - min(arg_lengths) != 0)) {
      stop("If `all` is FALSE, lengths of inputs must be equivalent to each other, or 1.")
    }

    query_df <-
      tibble(
        category_id = category_ids,
        state_id = state_ids
      ) %>%
      mutate(
        query =
          glue::glue(
            "&categoryId={category_id}&stateId={state_id}"
          )
      )
  }

  r <- "Rating.getSigList?"

  out <- tibble()

  for (i in 1:nrow(query_df)) {
    category_id <- query_df$category_id[i]
    state_id <- query_df$state_id[i]
    q <- query_df$query[i]

    message(glue::glue(
      "Requesting data for {{category_id: {category_id}, state_id: {state_id}}}."
    ))

    this <-
      get(
        req = r,
        query = q,
        level_one = "sigs",
        level_two = "sig"
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
        vs_na_if("")
    } else {
      this %<>%
        mutate(
          category_id = category_id,
          state_id = state_id
        ) %>%
        select(
          sig_id, name, category_id, state_id
        )
    }

    out %<>%
      bind_rows(this)
  }
  out %>%
    distinct()
}
