skip_if_no_auth()

test_that("election_get_election_by_year_state", {
  do_all <- sample(c(TRUE, FALSE), 1)

  national <-
    election_get_election_by_year_state(
      years = c(2016, sample(2008:2018, 3)),
      all = do_all
    )

  state <-
    election_get_election_by_year_state(
      # NY has multiple elements in lst$stage and MT only has one
      state_ids = c("NY", "MT", sample(state.abb, 1)),
      years = c(2017, sample(2008:2018, 2)),
      all = !do_all
    )

  expect_length(setdiff(names(state), names(national)), 0)
  expect_length(setdiff(names(national), names(state)), 0)

  expect_true(
    "election_id" %in% names(national)
  )

  expect_true(
    "election_id" %in% names(state)
  )
})
