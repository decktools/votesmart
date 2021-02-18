clean_df <- function(df) {
  df %>%
    rename_all(
      snakecase::to_snake_case
    ) %>%
    as_tibble() %>%
    na_if("") %>%
    na_if("NA") %>%
    # Remove \"s
    purrr::map_dfc(
      stringr::str_remove_all,
      '\\\"'
    ) %>%
    purrr::map_dfc(as.character) %>%
    purrr::map_dfc(stringr::str_squish)
}

clean_html <- function(x,
  split_on_nbsp = TRUE,
  split_on_newline = FALSE,
  remove_empty = TRUE) {
  if (split_on_nbsp) {
    x %<>%
      stringr::str_split("&nbsp") %>%
      purrr::as_vector()
  }

  if (split_on_newline) {
    x %<>%
      stringr::str_split("\\n") %>%
      purrr::as_vector()
  }

  x %<>%
    stringr::str_squish() %>%
    stringr::str_remove_all("[\\n\\r\\t]")

  if (remove_empty) {
    x %<>%
      magrittr::extract(
        !. == ""
      )
  }
  x
}

as_char_vec <- function(x) {
  x %>%
    purrr::as_vector() %>%
    as.character()
}

#' @importFrom gestalt %>>>%
elmers <- glue::glue %>>>% as.character

elmers_message <- elmers %>>>% message

expand_grid <- expand.grid %>>>% as_tibble %>>>% purrr::map_dfc(as.character)

transform_election_special <- function(tbl) {
  if ("election_special" %in% names(tbl)) {
    tbl %>%
      mutate(
        election_special =
          case_when(
            election_special == "f" ~ FALSE,
            is.na(election_special) ~ NA,
            TRUE ~ TRUE
          )
      )
  }
}

chunk_it <- function(tbl,
  n_per_chunk = NA,
  n_chunks = NA,
  list_it = FALSE) {
  if ((is.na(n_per_chunk) && is.na(n_chunks)) ||
    !is.na(n_per_chunk) && !is.na(n_chunks)) {
    stop("Exactly one of n_per_chunk or n_chunks must be set.")
  }

  if (!is.na(n_per_chunk)) {
    if (n_per_chunk > nrow(tbl)) {
      message("n_per_chunk is more than the number of rows. Only one chunk assigned.")
    }

    n_chunks <- ceiling(nrow(tbl) / n_per_chunk)
  } else {
    if (n_chunks > nrow(tbl)) {
      message("n_chunks is more than the number of rows. Assigning one chunk to each row.")
      n_chunks <- nrow(tbl)
    }
  }

  if (n_chunks == 1) {
    # Setting `breaks` to 1 in `cut` will break it
    tbl %<>%
      mutate(
        chunk = 1
      )
  } else {
    tbl %<>%
      mutate(
        chunk = cut(row_number(), n_chunks, labels = FALSE)
      )
  }

  if (list_it) {
    suppressWarnings(
      tbl %<>%
        tidyr::nest(-chunk) %>%
        pull(data)
    )
  }

  tbl
}

skip_if_no_auth <- function() {
  if (identical(Sys.getenv("VOTESMART_API_KEY"), "")) {
    testthat::skip("No authentication available")
  }
}
