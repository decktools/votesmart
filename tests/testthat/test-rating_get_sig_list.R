test_that("rating_get_sig_list", {
  do_all <- sample(c(TRUE, FALSE), 1)

  res <-
    rating_get_sig_list(
      category_ids = sample(1:100, 3),
      state_ids = c(NA, sample(state.abb, 2)),
      all = do_all
    )

  expect_length(
    names(res),
    5
  )
})
