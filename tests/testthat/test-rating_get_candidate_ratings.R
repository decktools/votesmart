
test_that("`get` can deal with multiple rows returned or just one", {
  pelosi_id <- "26732"

  pelosi_ratings <- rating_get_candidate_ratings(pelosi_id)

  single_row_id <- "20318"

  single_row_ratings <- rating_get_candidate_ratings(single_row_id)

  expect_gte(
    nrow(pelosi_ratings),
    100
  )

  expect_equal(
    nrow(single_row_ratings),
    1
  )
})
