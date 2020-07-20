test_that("measure_get_measures_by_year_state", {
  do_all <- sample(c(TRUE, FALSE), 1)

  res <-
    measure_get_measures_by_year_state(
      years = sample(2015:2017),
      state_ids = c(NA, sample(state.abb, 2)),
      all = do_all
    )

  expect_length(
    names(res),
    5
  )
})
