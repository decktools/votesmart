#' Get information on a SIG (Special Interest Group) by its ID
#'
#' @param sig_ids Vector of SIG ids.
#' @param verbose Should cases when no data is available be messaged?
#'
#' @return A dataframe with the columns \code{sig_id, name, description, state_id, address, city, state, zip, phone_1, phone_2, fax, email, url, contact_name}.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' rating_get_sig_list(2) %>%
#'   dplyr::pull(sig_id) %>%
#'   sample(3) %>%
#'   rating_get_sig()
#' }
rating_get_sig <- function(sig_ids,
  verbose = TRUE) {
  sig_ids %<>%
    as_char_vec()

  query_df <-
    tibble(
      sig_id = sig_ids
    ) %>%
    mutate(
      query =
        elmers(
          "&sigId={sig_id}"
        )
    )

  r <- "Rating.getSig?"

  out <- tibble()

  for (i in 1:nrow(query_df)) {
    sig_id <- query_df$sig_id[i]
    q <- query_df$query[i]

    elmers_message(
      "Requesting data for {{sig_id: {sig_id}}."
    )

    this <-
      get(
        req = r,
        query = q,
        level_one = "sig",
        level_two = NA
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
        select(-parent_id) %>%
        select(
          sig_id, name, description, everything()
        )
    }

    out %<>%
      bind_rows(this)
  }
  out %>%
    distinct()
}
