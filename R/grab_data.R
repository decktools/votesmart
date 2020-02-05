
construct_funs <- function(tbl = endpoint_input_mapping_nested) {

  inputs <- endpoint_input_mapping_nested[1,] %>%
    tidyr::unnest(inputs) %>%
    pull(input)

  eval(
    parse(
      text =
        elmers(
          "{endpoint_input_mapping_nested$endpoint[1]} <- function({inputs}) {{'foo'}}"
        )
    )
  )

  Address.getCampaign()
}


grab_data <- function(tbl = endpoint_input_mapping_nested, endpt, ...) {

  row <-
    tbl %>%
    filter(
      endpoint == endpt
    )

  req <- elmers("{endpt}?")

  args <-
    row %>%
    tidyr::unnest(inputs) %>%
    pull(input)

  query_inputs <-
    elmers("&{args}=")

  inputs <-
    match.call(expand.dots = FALSE)

  query_value <-
    inputs$...[[args[1]]]

  query <- elmers("{query_inputs[1]}{query_value}")

  url <-
    construct_url(req, query)

  raw <- request(url)

  raw
}
