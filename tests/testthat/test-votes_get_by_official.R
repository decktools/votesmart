skip_if_no_auth()

abrams_id <- 67385
aoc_id <- 180416
pelosi_id <- 26732
obama_id <- 9490
pete_id <- 127151
warren_id <- 141272

test_that("votes_get_by_official", {
  # do_all <- sample(c(TRUE, FALSE), 1)
  do_all <- TRUE

  # category_ids <- c(sample(1:100, 3), "")
  category_ids <- c("96", "10", "24", "")

  vcr::use_cassette("votes_get_by_official", {
    res <-
      votes_get_by_official(
        c(abrams_id, warren_id, aoc_id, obama_id),
        office_ids = "",
        category_ids = category_ids,
        all = do_all
      )
  })

  expect_gte(
    ncol(res),
    20
  )
})
