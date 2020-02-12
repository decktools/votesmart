library(testthat)
library(votesmart)

abrams_id <- 67385
aoc_id <- 180416
pelosi_id <- 26732
obama_id <- 9490
pete_id <- 127151
warren_id <- 141272

pkgs <- installed.packages() %>%
  dplyr::as_tibble() %>%
  dplyr::pull(Package)

if ("bonanza" %in% pkgs) {
  Sys.setenv(VOTESMART_API_KEY = bonanza::secrets.get("VOTESMART_API_KEY"))
  test_check("votesmart")
} else {
  message("API key not found.")
}
