skip_if_no_auth()

test_that("candidates_get_by_lastname", {
  last_names <- c("Pelosi", "Jeffries")
  election_years <- c(2016, lubridate::year(lubridate::today()))

  vcr::use_cassette("candidates_get_by_lastname_true", {
    res <-
      candidates_get_by_lastname(
        last_names,
        election_years,
        all = TRUE
      )
  })

  expect_gt(
    nrow(res),
    2
  )

  vcr::use_cassette("candidates_get_by_lastname_false", {
    lev_res <-
      candidates_get_by_lastname(
        last_names,
        election_years,
        all = FALSE
      )

    expect_gt(
      nrow(lev_res),
      2
    )
  })
})
