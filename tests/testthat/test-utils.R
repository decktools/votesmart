test_that("clean_df", {
  # Was throwing error like below when using na_if alone:
  #   "Can't convert `y` <character> to match type of `x` <tbl_df>"
  expect_no_error(clean_df(mtcars))
})

test_that("vs_na_if", {
  df <- tibble(x = c("", "not empty"), y = c("not empty", ""))
  expect_no_error(res <- vs_na_if(df))
  expect_equal(sum(is.na(res)), 2)
})
