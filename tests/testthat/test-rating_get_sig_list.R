skip_if_no_auth()

test_that("rating_get_sig_list", {
  vcr::use_cassette("rating_get_sig_list_true", {
    res_true <-
      rating_get_sig_list(
        category_ids = c(2, sample(1:100, 2)),
        state_ids = c(NA, sample(state.abb, 2)),
        all = TRUE
      )
  })
  vcr::use_cassette("rating_get_sig_list_false", {
    res_false <-
      rating_get_sig_list(
        category_ids = c(2, sample(1:100, 2)),
        state_ids = c(NA, sample(state.abb, 2)),
        all = FALSE
      )
  })

  expect_length(
    names(res_true),
    4
  )
  expect_length(
    names(res_false),
    4
  )
})
