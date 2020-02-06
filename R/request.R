BASE_URL <- "http://api.votesmart.org/"

# From the function calling this function, use the name of the function to construct the name of the endpoint
get_req <- function() {
  calling_fun <-
    deparse(sys.calls()[[sys.nframe() - 1]]) %>%
    .[1]

  calling_fun %<>%
    stringr::str_remove_all("\\(.*")

  first_word <-
    calling_fun %>%
    stringr::str_remove("_.*") %>%
    stringr::str_to_title()

  rest <-
    calling_fun %>%
    stringr::str_extract("_.*") %>%
    snakecase::to_lower_camel_case()

  elmers("{first_word}.{rest}?")
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
    raw[[level_one]][[level_two]]

  if (is.null(lst)) {
    return(NA)
  }

  if (purrr::vec_depth(lst) <= 2) {
    out <-
      lst %>%
      as_tibble()
  } else {
    out <-
      lst %>%
      purrr::map(as_tibble) %>%
      bind_rows()
  }

   out %>%
    clean_df()
}
