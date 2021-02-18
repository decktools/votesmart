skip_if_no_auth()

test_that("candidates_get_by_office_state", {
  do_all <- sample(c(TRUE, FALSE), 1)

  yes_data <-
    candidates_get_by_office_state(
      state_ids = c(NA, "NY", "CA"),
      office_ids = c(1, 6, 10),
      election_years = 2020,
      all = do_all
    )

  no_data <-
    candidates_get_by_office_state(
      "NY", 5, 2030,
      all = !do_all
    )

  expect_gte(
    nrow(yes_data),
    100
  )

  expect_equal(
    nrow(no_data),
    1
  )
})
