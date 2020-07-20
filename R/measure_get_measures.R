
measure_get_measures_by_year_state <- function(years =
                                                 lubridate::year(lubridate::today()),
                                               state_ids = state.abb,
                                               all = TRUE,
                                               verbose = TRUE) {

  r <-  "Measure.getMeasuresByYearState?"


  if (all) {
    query_df <-
      expand_grid(
        year = years,
        state_id = state_ids
      ) %>%
      mutate(
        query =
          elmers(
            "&year={year}&stateId={state_id}"
          )
      )
  } else {
    arg_lengths <-
      c(length(years), length(state_ids)) %>%
      magrittr::extract(
        !. == 1
      )

    if (length(arg_lengths) > 1 && (max(arg_lengths) - min(arg_lengths) != 0)) {
      stop("If `all` is FALSE, lengths of inputs must be equivalent to each other, or 1.")
    }

    query_df <-
      tibble(
        year = years,
        state_id = state_ids,
        query =
          elmers(
            "&year={year}&stateId={state_id}"
          )
      )
  }

    out <- tibble()

    for (i in 1:nrow(query_df)) {
      q <- query_df$query[i]
      year <- query_df$year[i]
      state_id <- query_df$state_id[i]

      if (verbose) {
        elmers_message(
          "Requesting data for {{year: {year}, state_id: {state_id}}}."
        )
      }

      this <- get(
        req = r,
        query = q,
        level_one = "measures",
        level_two = "measure"
      )

      if (all(is.na(this))) {
        if (verbose) {
          elmers_message(
            "No results found for query {q}."
          )
        }

        this <-
          query_df %>%
          select(-query) %>%
          rename(
            election_year = year,
            state_id = state_id
          ) %>%
          na_if("")
      } else {
        this %<>%
          mutate(
            election_year = year,
            state_id = state_id
          ) %>%
          select(
            measure_id,
            election_year,
            state_id,
            title,
            outcome
          )
      }

      out %<>%
        bind_rows(this)
    }

    out %>%
      distinct()
}

measure_get_measures <- function(measure_ids,
                           verbose = TRUE) {
  measure_ids %<>%
    as_char_vec()

  query_df <-
    tibble(
      measure_id = measure_ids
    ) %>%
    mutate(
      query =
        elmers(
          "&measureId={measure_id}"
        )
    )

  r <- "Measure.getMeasure?"

  out <- tibble()

  for (i in 1:nrow(query_df)) {
    measure_id <- query_df$measure_id[i]
    q <- query_df$query[i]

    elmers_message(
      "Requesting data for {{measure_id: {measure_id}}."
    )

    this <-
      get(
        req = r,
        query = q,
        level_one = "measure",
        level_two = NA
      )

    if (all(is.na(this))) {
      if (verbose) {
        elmers_message(
          "No results found for query {q}."
        )
      }

      this <-
        query_df %>%
        select(-query) %>%
        na_if("")
    }

    out %<>%
      bind_rows(this)
  }
  out %>%
    distinct()
}
