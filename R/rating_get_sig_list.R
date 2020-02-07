#' Get SIG (Special Interest Group) list by category and state
#'
#' @param category_ids Vector of category ids.
#' @param state_ids Vector of state abbreviations. Default \code{NA} for national.
#' @param all Boolean: should all possible combinations of the variables be searched for, or just the exact combination of them in the order they are supplied?
#' @param verbose Should cases when no data is available be messaged?
#'
#' @return A dataframe with the columns \code{sig_id, name, category_id, state_id, parent_id}.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' rating_get_categories() %>%
#'   pull(category_id) %>%
#'   sample(3) %>%
#'   rating_get_sig_list()
#' }
rating_get_sig_list <- function(category_ids,
  state_ids = NA,
  all = TRUE,
  verbose = TRUE) {
  out <- tibble()

  r <- "Rating.getSigList?"

  if (all) {
    query_df <-
      expand.grid(
        category_id = category_ids,
        state_id = state_ids
      ) %>%
      mutate(
        query =
          elmers(
            "&categoryId={category_id}&stateId={state_id}"
          )
      )
  } else {
    length_category_ids <- length(category_ids)
    length_state_ids <- length(state_ids)
    lengths <-
      c(length_category_ids, length_state_ids) %>%
      magrittr::extract(
        !. == 1
      )

    if (!identical(lengths)) {
      stop("If `all` is FALSE, lengths of inputs must be equivalent to each other, or 1.")
    }

    query_df <-
      tibble(
        category_id = category_ids,
        state_id = state_ids
      ) %>%
      mutate(
        query =
          elmers(
            "&categoryId={category_id}&stateId={state_id}"
          )
      )
  }

  for (i in 1:nrow(query_df)) {
    category_id <- query_df$category_id[i]
    state_id <- query_df$state_id[i]
    q <- query_df$query[i]

    elmers_message(
      "Requesting data for {{category_id: {category_id}, state_id: {state_id}}}."
    )

    this <-
      get(
        req = r,
        query = q,
        level_one = "sigs",
        level_two = "sig"
      )

    if (all(is.na(this))) {
      if (verbose) {
        elmers_message(
          "No results found for query {q}."
        )
      }

      this <-
        tibble(
          category_id = category_id,
          state_id = state_id
        )
    } else {
      this %<>%
        mutate(
          category_id = category_id,
          state_id = state_id
        ) %>%
        select(
          sig_id, name, category_id, state_id, parent_id
        )
    }

    out %<>%
      bind_rows(this)
  }
  out %>%
    distinct()
}
