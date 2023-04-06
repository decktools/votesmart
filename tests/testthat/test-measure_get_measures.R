skip_if_no_auth()

test_that("measure_get_measures", {
  vcr::use_cassette("measure_get_measures", {
    res <- measure_get_measures(1227)
  })

  n_cols <- length(names(res))

  expect(n_cols %in% c(1, 14), failure_message = "Wrong number of columns.")
})
