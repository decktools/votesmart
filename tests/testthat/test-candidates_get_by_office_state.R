test_that("candidates_get_by_office_state", {
  yes_data <-
    candidates_get_by_office_state(c(NA, "NY", "CA"), c(1, 6))

  no_data <-
    candidates_get_by_office_state("NY", 5, 2020)

  expect_gte(
    nrow(yes_data),
    500
  )

  expect_equal(
    nrow(no_data),
    1
  )
})
