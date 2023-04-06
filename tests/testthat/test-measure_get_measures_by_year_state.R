skip_if_no_auth()

test_that("measure_get_measures_by_year_state", {
  vcr::use_cassette("measure_get_measures_by_year_state", {
    res <-
      measure_get_measures_by_year_state(
        years = c(2015, 2020, 2016, 2018, 2017, 2019),
        state_ids = c(NA, c("AR", "NH", "MD", "ID", "KY")),
        all = TRUE
      )
  })

  expect_length(
    names(res),
    5
  )
})
