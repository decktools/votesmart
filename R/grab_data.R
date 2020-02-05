
# Set up the base function
get_data <- function(nm, ...) {

  req <- elmers("{nm}?")

  inputs <-
    match.call(expand.dots = FALSE)

  args <- inputs$... %>% names()
  values <- inputs$... %>% purrr::as_vector()

  if (all) {
    query_df <-
      expand.grid(

      )
  } else {

  }

  query <- elmers("&{args}={values}")

  url <-
    construct_url(req, query)

  raw <- request(url)
}

# For each of the endoints, pipe each endpoint name through as .x, so the function's name is that `nm`
endpoint_input_mapping_nested$endpoint %>%
  purrr::walk(~ assign(
  x = .x,
  value = purrr::partial(get_data),
  envir = .GlobalEnv)
)


construct_funs <- function(tbl = endpoint_input_mapping_nested) {

  for (i in 1:nrow(endpoint_input_mapping_nested)) {
    nm <- endpoint_input_mapping_nested$endpoint[i]

    inputs <- endpoint_input_mapping_nested[i, ] %>%
      tidyr::unnest(inputs) %>%
      pull(input)

    # args <-
    #   alist(a = "")

    assign(
      x = nm,
      value = purrr::partial(get_data),
      envir = .GlobalEnv
    )

    # formals(nm) <- args
  }
}



construct_funs <- function(tbl = endpoint_input_mapping_nested) {
  for (i in 1:nrow(endpoint_input_mapping_nested)) {
    inputs <- endpoint_input_mapping_nested[i, ] %>%
      tidyr::unnest(inputs) %>%
      pull(input)

    if (all(is.na(inputs))) inputs <- NULL

    inputs_c <- stringr::str_c(inputs, collapse = ", ")

    eval(
      parse(
        text =
          elmers(
            "{endpoint_input_mapping_nested$endpoint[i]} <- function({inputs_c}) {{'foo'}}"
          )
      )
    )
  }
}

