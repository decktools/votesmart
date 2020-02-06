get_key <- function() {
  Sys.getenv("VOTESMART_API_KEY")
}

clean_df <- function(df) {
  df %>%
    rename_all(
      snakecase::to_snake_case
    ) %>%
    tibble::as_tibble() %>%
    dplyr::na_if("")
}

get <- function(req, query, level_one, level_two) {
  url <- construct_url(req)

  lst <-
    raw[[level_one]][[level_two]]

  if (is.null(lst)) {
    return(NA)
  }

  lst %>%
    purrr::map(as_tibble) %>%
    purrr::modify_depth(2, as.character) %>%
    bind_rows() %>%
    clean_df()
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
