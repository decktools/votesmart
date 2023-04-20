# Create a mapping between each endpoint and its available inputs

base_url <- "http://api.votesmart.org/docs/"

# Grab the base_endpoints, which we'll use to get each base_endpoint's doc page with {base_url}{base_endpoint}.html
raw <-
  base_url %>%
  xml2::read_html() %>%
  rvest::html_nodes("#menu") %>%
  rvest::html_text()

squished <- raw %>%
  stringr::str_extract("Objects\n.*") %>%
  stringr::str_remove("Objects\n") %>%
  stringr::str_squish()

capitals <-
  squished %>%
  stringr::str_extract_all("[A-Z]") %>%
  .[[1]] %>%
  magrittr::extract(
    !. == ""
  )

lowercase <-
  squished %>%
  stringr::str_split("[A-Z]") %>%
  .[[1]] %>%
  magrittr::extract(
    !. == ""
  )

base_endpoints <-
  glue::glue("{capitals}{lowercase}") %>%
  stringr::str_squish() %>%
  magrittr::extract(
    !. %in% c("Ballot", "Candidate") # Ballot is covered by Measure and Candidate is covered by CandidateBio
  )

base_endpoints[which(base_endpoints == "Bio")] <- "CandidateBio"

# Construct each doc page to scrape
pages_tbl <-
  tibble(
    base_endpoint = base_endpoints,
    url = glue::glue("{base_url}{base_endpoint}.html")
  )

# Grab each endpoint and the possible inputs to it
get_endpoints <- function(tbl = pages_tbl) {
  out <- tibble()

  for (i in 1:nrow(tbl)) {
    url <- tbl$url[i]
    base_endpoint <- tbl$base_endpoint[i]

    message(glue::glue(
      "Getting endpoints beginning with {base_endpoint}."
    ))

    endpoints <-
      url %>%
      xml2::read_html() %>%
      rvest::html_nodes("#content h4") %>%
      rvest::html_text() %>%
      stringr::str_remove_all("\\(\\)")

    inputs <-
      url %>%
      xml2::read_html() %>%
      rvest::html_nodes("#content") %>%
      rvest::html_text() %>%
      clean_html() %>%
      stringr::str_extract_all("Input:.*\\*") %>%
      stringr::str_split("Input") %>%
      .[[1]] %>%
      stringr::str_remove("Output.*") %>%
      .[2:length(.)] %>%
      # May want to store the defaults which are in parens somewhere
      stringr::str_remove_all("\\(.*") %>%
      stringr::str_remove_all("[: ]") %>%
      stringr::str_split(",")

    this <-
      tibble(
        endpoint = endpoints,
        input = inputs
      ) %>%
      tidyr::unnest(input)

    out %<>%
      bind_rows(this)
  }
  out %>%
    mutate(
      required = case_when(
        stringr::str_detect(
          input, "\\*"
        ) ~ TRUE,
        TRUE ~ FALSE
      ),
      input = stringr::str_remove(input, "\\*")
    ) %>%
    empty_to_na("none")
}

endpoint_input_mapping <- get_endpoints()

# One row per endpoint
endpoint_input_mapping_nested <-
  endpoint_input_mapping %>%
  tidyr::nest(inputs = c(input, required))
