test_that("votes_get_by_official", {
  do_all <- sample(c(TRUE, FALSE), 1)

  category_ids <- c(sample(1:100, 3), "")

  res <-
    votes_get_by_official(
      c(abrams_id, warren_id, aoc_id, obama_id),
      office_ids = "",
      category_ids = category_ids,
      all = do_all
    )

  expect_gte(
    ncol(res),
    20
  )
})
