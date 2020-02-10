clean_df <- function(df) {
  df %>%
    rename_all(
      snakecase::to_snake_case
    ) %>%
    as_tibble() %>%
    na_if("")
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

# Take the v heterogeneous categories list col and tidy it into the same nested tibble format
explode_column <- function(tbl, col = "categories") {
  for (i in 1:nrow(tbl)) {
    if (length(tbl[[col]][i][[1]]) == 0) {
      tbl[[col]][i] %<>%
        tibble(
          category_id = NA,
          category_name = NA
        ) %>%
        list()
    } else {
      if (purrr::vec_depth(tbl[[col]][i]) > 3) {
        tbl[[col]][i] %<>%
          purrr::flatten()
      }

      tbl[[col]][i] %<>%
        purrr::map_df(bind_rows) %>%
        distinct() %>%
        rename_all(
          snakecase::to_snake_case
        ) %>%
        rename(
          category_name = name
        ) %>%
        list()
    }
  }
  tbl
}
