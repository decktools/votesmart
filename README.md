
<p align="center">

<img src="https://media.giphy.com/media/pD4mUFQR0ovmg/giphy.gif" alt="galaxy_gif">

</p>

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/decktools/votesmart.svg?branch=master)](https://travis-ci.org/decktools/votesmart)
[![CRAN
status](https://www.r-pkg.org/badges/version/votesmart)](https://CRAN.R-project.org/package=votesmart)
<!-- badges: end -->

# votesmart <img src="./img/deck_logo.png" alt="deck" height="35px" align="right" />

<!-- # votesmart -->

This package is a wrapper around the
[VoteSmart](https://justfacts.votesmart.org/)
[API](http://api.votesmart.org/docs/) provided by your friendly
neighborhood progressive tech organization, 🌟 [*Deck
Technologies*](https://www.deck.tools/) 🌟. Feel free to use this package
in any way you like.

VoteSmart provides information on US political candidates’ positions on
issues, votes on bills, and ratings by third party organizations, among
other data.

### Installation

``` r
devtools::install_github("decktools/votesmart")
```

### API Keys

You’ll need a VoteSmart API key in order to use this package. You can
register for one [here](https://votesmart.org/share/api#.XjxqEjJKjOQ).

Store your key in an environment variable named `VOTESMART_API_KEY` with

    Sys.setenv(VOTESMART_API_KEY = "<your_key>")

You can check that it’s there with

    Sys.getenv("VOTESMART_API_KEY")

This key is never stored in your R session’s global environment.

### Available Functions

*These functions are named after the `snake_case`d version of the API
[endpoints](http://api.votesmart.org/docs/).*

**If you see an endpoint you want to be made available in this package
that isn’t yet, feel free to submit an
[issue](https://github.com/decktools/votesmart/issues) or a [pull
request](https://github.com/decktools/votesmart/pulls)\!**

For examples of how these all fit together, check out the vignette with:

    vignette("votesmart")

#### Summary of Functions

**`candidates_get_by_last_name`**

Get a dataframe of candidates given a vector of `last_name`s,
`election_year`s (optional), and `stage_id`s (optional)

**`candidates_get_by_levenshtein`**

Get a dataframe of fuzzy-matched candidates given a vector of
`last_name`s, `election_year`s (optional), and `stage_id`s (optional)

**`candidates_get_by_office_state`**

Get a dataframe of candidates by the state in which they ran for office
given a vector of `state_id`s (optional), `office_id`s, and
`election_year`s (optional)

**`election_get_election_by_year_state`**

Get a dataframe of election ids and their attributes given a vector of
`year`s and `state_id`s (optional).

**`office_get_levels`**

Get the VoteSmart `office_level_id`s and their associated names
(federal, state, local)

**`office_get_offices_by_level`**

Get `office_id`s and their associated names (e.g. `"President"`) for a
given `office_level_id`

**`rating_get_candidate_rating`**

Get SIG (Special Interest Group) ratings for candidates given a
`candidate_id` and a `sig_id` (optional)

**`rating_get_categories`**

Get rating `category_id`s and their associated `name`s (e.g.
`"Abortion"`, `"Environment"`) given a vector of `state_id`s (optional)

**`rating_get_sig`**

Get information about a vector of SIGs (Special Interest Groups) given a
`sig_id`

**`rating_get_sig_list`**

Get a dataframe of SIG (Special Interest Group) given a rating
`category_id` and a `state_id` (optional)

**`votes_get_by_official`**

Get a dataframe of the way officials have voted on bills given a
`candidate_id`, an `office_id` (optional), a `category_id` (optional)
and a `year` the vote occurred (optional)

#### Package Data

Only a subset of all of the VoteSmart endpoints have yet been made
available through this package.

You can see a full dataframe of the VoteSmart endpoints and their
associated arguments with

    data("endpoint_input_mapping")

or

    data("endpoint_input_mapping_nested")

### Other Details

  - This package currently contains no rate limiting infrastructure as
    there is very little information about what rate limits VoteSmart
    imposes, if any

  - The VoteSmart API does not allow for bulk requests, i.e. a single
    request can only contain one value for each parameter
    
      - The funcitons in this package allow multiple inputs to be
        specified for each argument, but requests are sent one at a time
        for each combination of inputs

<br>

Feel free to reach out in the
[Issues](https://github.com/decktools/votesmart/issues) with any bugs or
feature requests\! 💫
