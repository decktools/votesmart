## Test environments
* local R installation, R 4.0.0
* ubuntu 16.04 (on travis-ci), R 4.0.0
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 3 notes

This is a new release.

Found the following (possibly) invalid URLs:
  URL: https://www.deck.tools/
    From: README.md
    Status: 503
    Message: Service Unavailable

* This URL resolves in a browser and returns a 200 response with httr::GET("https://www.deck.tools/")

* Added Deck Technologies to Authors@R as copyright holder and funder
