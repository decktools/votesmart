skip_if_no_auth()

test_that("office_get_offices_by_level works", {
  vcr::use_cassette("office_get_offices_by_level", {
    res <- office_get_offices_by_level(c("F", "S"))
  })
  
  expect_gt(
    nrow(res),
    100
  )

  vcr::use_cassette("office_get_offices_by_level_error", {
    expect_error(office_get_offices_by_level("A"))
  })
})
