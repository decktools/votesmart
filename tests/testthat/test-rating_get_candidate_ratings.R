skip_if_no_auth()

abrams_id <- 67385
aoc_id <- 180416
pelosi_id <- 26732
obama_id <- 9490
pete_id <- 127151
warren_id <- 141272
fixup_id <- 21706 # Response doesn't end with `}}`
weird_id <- 19241

test_that("rating_get_candidate_ratings", {
  sig_ids <- c(2167, 2880)

  candidate_ids <- c(pelosi_id, aoc_id)

  vcr::use_cassette("rating_get_candidate_ratings", {
    res <- rating_get_candidate_ratings(
      candidate_ids,
      sig_ids
    )
  })

  expect_true(
    "rating_id" %in% names(res)
  )

  vcr::use_cassette("rating_get_candidate_ratings_weird", {
    weird_res <- rating_get_candidate_ratings(weird_id)
  })

  expect_true(
    "rating_id" %in% names(weird_res)
  )

  vcr::use_cassette("rating_get_candidate_ratings_dimensions", {
    expect_gte(
      ncol(rating_get_candidate_ratings("180416", sig_ids = "2880")),
      3
    )
  })

  expect_error(
    rating_get_candidate_ratings(
      candidate_ids %>% c(pete_id),
      sig_ids,
      all = FALSE
    )
  )
})
