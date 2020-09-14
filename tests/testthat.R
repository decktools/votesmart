library(testthat)
library(votesmart)

abrams_id <- 67385
aoc_id <- 180416
pelosi_id <- 26732
obama_id <- 9490
pete_id <- 127151
warren_id <- 141272

test_check("votesmart")

if (nchar(Sys.getenv("VOTESMART_API_KEY")) > 0) {
  test_check("votesmart")
} else {
  message("API key not found.")
}
