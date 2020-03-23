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

request <- function(url, verbose = FALSE) {
  if (verbose) {
    elmers_message(
      "Requesting: {url}."
    )
  }

  resp <-
    httr::GET(url) %>%
    httr::stop_for_status()

  status <- httr::http_status(resp)

  httr::content(resp)
}

try_request <-
  purrr::possibly(
    request,
    otherwise = NA,
    quiet = FALSE
  )

# Special treatment for election_get_election_by_year_state
get_election <- function(req, query) {
  url <- construct_url(req, query)

  raw <- try_request(url)

  if (is.na(raw)) {
    message("Error requesting data.")
    return(NA)
  }

  lst <-
    raw$elections$election

  # We've gotten an error that there's no data
  if (is.null(lst)) {
    return(NA)
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

  if (is.na(raw)) {
    message("Error requesting data.")
    return(NA)
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

  # We've gotten an error that there's no data
  if (is.null(lst)) {
    return(NA)
  }

  # Case where there will only be one row once we make into a tibble
  if (length(lst[[1]]) == 1) {
    out <-
      lst %>%
      as_tibble()

    if ("categories" %in% names(out)) {
      out$category_id <- out$categories$category$categoryId
      out$category_name <- out$categories$category$name
    }

    # Otherwise there are multiple rows
  } else {
    out <-
      lst %>%
      # Not tibble because that will give us a list-col we have to explode
      purrr::map(as.data.frame) %>%
      # So that we don't end up combining factor and character in bind_rows
      purrr::modify_depth(2, as.character) %>%
      bind_rows() %>%
      as_tibble()
  }

  out %>%
    clean_df() %>%
    purrr::map_dfc(as.character) %>%
    purrr::map_dfc(stringr::str_squish) %>%
    na_if("")
}
