skip_if_no_auth()

test_that("rating_get_sig_list", {
  do_all <- sample(c(TRUE, FALSE), 1)

  res <-
    rating_get_sig_list(
      category_ids = c(2, sample(1:100, 2)),
      state_ids = c(NA, sample(state.abb, 2)),
      all = do_all
    )

  expect_length(
    names(res),
    4
  )
})
