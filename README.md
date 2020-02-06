
<p align="center">

<img src="https://media.giphy.com/media/pD4mUFQR0ovmg/giphy.gif" alt="galaxy_gif">

</p>

# votesmart

This package is a wrapper around the
[VoteSmart](https://justfacts.votesmart.org/)
[API](http://api.votesmart.org/docs/).

VoteSmart provides information on US political candidates’ positions on
issues, votes on bills, and ratings by third party organizations, among
other data.

## Installation

``` r
devtools::install_github("decktools/votesmart")
```

## API Keys

You’ll need a VoteSmart API key in order to use this package. You can
register for one [here](https://votesmart.org/share/api#.XjxqEjJKjOQ).

Store your key in an environment variable named `VOTESMART_API_KEY` with

    Sys.setenv(VOTESMART_API_KEY = "<your_key>")

You can check that it’s there with

    Sys.getenv("VOTESMART_API_KEY")

This key is never stored in your R session’s global environment.

## Available Functions

*These functions are named after the `snake_case`d version of the API
[endpoints](http://api.votesmart.org/docs/).*

Some of these functions are necessary precursors to obtain data you
might want. For instance, in order to get candidates’ ratings by SIGs,
you’ll need to get `office_level_id`s in order to get `office_id`s,
which is a required argument to get candidate information using
`candidates_get_by_office_state`.

Below is a summary of the functions currently available.

**`candidates_get_by_office_state`**

Get a dataframe of candidates by the state in which they ran for office
given a vector of `state_id`s (optional), `office_id`s, and
`election_year`s (optional)

**`office_get_levels`**

Get the VoteSmart `office_level_id`s and their associated names
(federal, state, local)

**`office_get_offices_by_level`**

Get `office_id`s and their associated names (e.g. `"President"`) for a
given `office_level_id`

**`rating_get_candidate_ratings`**

Get SIG (Special Interest Group) ratings for candidates given a
`candidate_id` and a `sig_id` (optional)

**`rating_get_categories`**

Get rating `category_id`s and their associated `name`s (e.g.
`"Abortion"`, `"Environment"`) given a vector of `state_id`s (optional)

**`rating_get_sig_list`**

Get a dataframe of SIG (Special Interest Group) given a rating
`category_id` and a `state_id` (optional)

## Package Data

Not all endpoints are yet available through this package.

You can see a full dataframe of the VoteSmart endpoints and their
associated arguments with

    data("endpoint_input_mapping")

or

    data("endpoint_input_mapping_nested")
