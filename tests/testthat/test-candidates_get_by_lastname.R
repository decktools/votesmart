skip_if_no_auth()

test_that("candidates_get_by_lastname", {
  do_all <- sample(c(TRUE, FALSE), 1)

  last_names <- c("Pelosi", "Jeffries")
  election_years <- c(2016, lubridate::year(lubridate::today()))

  res <-
    candidates_get_by_lastname(
      last_names,
      election_years,
      all = do_all
    )

  expect_gt(
    nrow(res),
    2
  )

  lev_res <-
    candidates_get_by_lastname(
      last_names,
      election_years,
      all = do_all
    )

  expect_gt(
    nrow(lev_res),
    2
  )
})
