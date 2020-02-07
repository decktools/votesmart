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

get <- function(req, query, level_one, level_two) {
  url <- construct_url(req, query)

  raw <- request(url)

  lst <-
    # Data is contained two levels down. These have different names for each endpoint.
    raw[[level_one]][[level_two]]

  # We've gotten an error that there's no data
  if (is.null(lst)) {
    return(NA)
  }

  # Case where there will only be one row once we make into a tibble
  if (length(lst[[1]]) == 1) {
    out <-
      lst %>%
      as_tibble()
  # Otherwise there are multiple rows
  } else {
    out <-
      lst %>%
      purrr::map(as_tibble) %>%
      bind_rows()
  }

  out %>%
    clean_df()
}
