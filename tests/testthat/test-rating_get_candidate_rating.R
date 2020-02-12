test_that("rating_get_candidate_ratings", {

  sig_ids <- c(2167, 2880)

  candidate_ids <- c(pelosi_id, aoc_id)

  res <- rating_get_candidate_ratings(
    candidate_ids,
    sig_ids
  )

  expect_gte(
    ncol(res),
    50
  )

  expect_error(
    rating_get_candidate_ratings(
      candidate_ids[1],
      sig_ids,
      all = FALSE
    )
  )
})
