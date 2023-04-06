skip_if_no_auth()

test_that("election_get_election_by_year_state", {
  vcr::use_cassette("election_get_election_by_year_state", {
    national <-
      election_get_election_by_year_state(
        years = c(2016, 2009, 2012, 2014),
        all = TRUE
      )

    state <-
      election_get_election_by_year_state(
        # NY has multiple elements in lst$stage and MT only has one
        state_ids = c("NY", "MT", "ND"),
        years = c(2017, 2017, 2010),
        all = FALSE
      )
  })

  expect_length(setdiff(names(state), names(national)), 0)
  expect_length(setdiff(names(national), names(state)), 0)

  expect_true(
    "election_id" %in% names(national)
  )

  expect_true(
    "election_id" %in% names(state)
  )
})
