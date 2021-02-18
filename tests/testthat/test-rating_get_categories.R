skip_if_no_auth()

test_that("rating_get_categories", {
  res <-
    rating_get_categories(
      sample(state.abb, 3)
    )

  expect_gt(
    nrow(res),
    20
  )
})
