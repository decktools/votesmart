BASE_URL <- "http://api.votesmart.org/"

get_key <- function() {
  key <- Sys.getenv("VOTESMART_API_KEY")

  if (identical(key, "")) {
    message("No VOTESMART_API_KEY key found.")
  }
  key
}

construct_url <- function(req, query = "") {
  key <- get_key()

  elmers("{BASE_URL}{req}key={key}{query}&o=JSON")
}

try_parse_content <-
  purrr::possibly(
    httr::content,
    otherwise = tibble(),
    quiet = FALSE
  )

fixup_content <- function(resp) {
  httr::content(
    resp,
    as = "text",
    encoding = "UTF-8"
  ) %>%
    stringr::str_c("}}", collapse = TRUE) %>%
    jsonlite::fromJSON()
}

try_fixup_content <-
  purrr::possibly(
    fixup_content,
    otherwise = tibble(),
    quiet = FALSE
  )

request <- function(url, verbose = FALSE) {
  if (verbose) {
    elmers_message(
      "Requesting: {url}."
    )
  }

  resp <-
    httr::GET(url) %>%
    httr::stop_for_status()

  parsed <- try_parse_content(resp)

  if (identical(parsed, tibble())) {
    message("Error parsing JSON. Attempting to fix up raw.")

    parsed <- try_fixup_content(resp)

    if (identical(parsed, tibble())) {
      message("Unable to fix up raw.")
      return(tibble())
    } else {
      message("Successfully fixed raw.")
    }
  }
  parsed
}

try_request <-
  purrr::possibly(
    request,
    otherwise = tibble(),
    quiet = FALSE
  )

# Special treatment for election_get_election_by_year_state
get_election <- function(req, query) {
  url <- construct_url(req, query)

  raw <- try_request(url)

  if (identical(raw, tibble())) {
    message("Error requesting data.")
    return(tibble())
  }

  lst <-
    raw$elections$election

  # We've gotten an error that there's no data
  if (is.null(lst)) {
    return(tibble())
  }

  # Extra nested when state is NA
  if ("stage" %in% names(lst)) {
    # Only one element
    if (length(lst$stage$stageId) == 1) {
      lst$stage %<>%
        list
    }

    lst$stage %<>%
      purrr::map(as_tibble) %>%
      bind_rows() %>%
      purrr::map_dfc(as.character) %>%
      purrr::map_dfc(stringr::str_squish) %>%
      clean_df()

    # This stage name becomes name.1 in the state version and we take it out there, so do the same here
    if ("name" %in% names(lst$stage)) {
      lst$stage %<>%
        select(-name)
    }

    lst$stage %<>%
      list()

    out <-
      lst %>%
      as_tibble() %>%
      tidyr::unnest(stage) %>%
      rename(
        state_id_parent = state_id
      ) %>%
      select(
        # This isn't in the state equivalent
        -state_id_parent
      ) %>%
      clean_df()
  } else {
    out <-
      lst %>%
      purrr::map(purrr::flatten) %>%
      purrr::map(as.data.frame) %>%
      purrr::modify_depth(2, as.character) %>%
      bind_rows() %>%
      as_tibble() %>%
      select(-contains(".")) %>%
      clean_df()
  }
  out %>%
    rename(
      election_stage_id = election_electionstage_id
    )
}

get <- function(req, query, level_one, level_two) {
  url <- construct_url(req, query)

  raw <- try_request(url)

  if (identical(raw, tibble())) {
    message("Error requesting data.")
    return(tibble())
  }

  if (is.na(level_two)) {
    lst <-
      raw[[level_one]]

    if ("generalInfo" %in% names(lst)) {
      idx <- which(names(lst) == "generalInfo")
      lst <- lst[-idx]
    }
  } else {
    lst <-
      # Data is contained two levels down. These have different names for each endpoint.
      raw[[level_one]][[level_two]]
  }

  browser()

  # We've gotten an error that there's no data
  if (is.null(lst)) {
    return(tibble())
  }

  categories <-
    lst %>%
    roomba::roomba(c("categoryId", "name")) %>%
    distinct() %>%
    mutate(rn = row_number()) %>%
    rename(
      category_id = categoryId,
      category_name = name
    ) %>%
    tidyr::pivot_wider(names_from = "rn",
                       values_from = c("category_name", "category_id")
                      )

  previous_category_colnames <-
    c("categories", "categoryId", "name")

  out <-
    lst %>%
    select(-any_of(previous_category_colnames)) %>%
    bind_cols(categories)
#
#   # We've fixed up the request and already used jsonlite::toJSON to end up with a dataframe here
#   if (inherits(lst, "data.frame")) {
#     out <-
#       lst %>% as_tibble()
#
#     out$categories <- out$categories$category
#
#     return(out)
#   }

  out %>%
    clean_df()
}
