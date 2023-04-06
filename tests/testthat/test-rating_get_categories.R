skip_if_no_auth()

test_that("rating_get_categories", {
  vcr::use_cassette("rating_get_categories", {
    res <-
      rating_get_categories(
        c("IN", "FL", "PA")
      )
  })

  expect_gt(
    nrow(res),
    20
  )
})
