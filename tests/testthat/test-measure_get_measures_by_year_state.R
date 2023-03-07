skip_if_no_auth()

test_that("measure_get_measures_by_year_state", {
  # do_all <- sample(c(TRUE, FALSE), 1)
  do_all <- TRUE

  vcr::use_cassette("measure_get_measures_by_year_state", {
    res <-
      measure_get_measures_by_year_state(
        # years = sample(2015:2020),
        years = c(2015, 2020, 2016, 2018, 2017, 2019),
        # state_ids = c(NA, sample(state.abb, 5)),
        state_ids = c(NA, c("AR", "NH", "MD", "ID", "KY")),
        all = do_all
      )
  })

  expect_length(
    names(res),
    5
  )
})
