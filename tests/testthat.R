library(testthat)
library(votesmart)

pkgs <- installed.packages() %>%
  dplyr::as_tibble() %>%
  dplyr::pull(Package)

if ("bonanza" %in% pkgs) {
  Sys.setenv(VOTESMART_API_KEY = bonanza::secrets.get("VOTESMART_API_KEY"))
  test_check("votesmart")
} else {
  message("API key not found.")
}
