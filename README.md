
<p align="center">

<img src="https://media.giphy.com/media/pD4mUFQR0ovmg/giphy.gif" alt="galaxy_gif">

</p>

<!-- badges: start -->

[![Travis build
status](https://travis-ci.com/decktools/votesmart.svg?token=G3ZELzKsL1syAMRqs54K&branch=master)](https://travis-ci.com/decktools/votesmart)
[![CRAN
status](https://www.r-pkg.org/badges/version/votesmart)](https://CRAN.R-project.org/package=votesmart)
<!-- badges: end -->

# votesmart <img src="./man/img/deck_logo.png" alt="deck" height="35px" align="right" />

This package is a wrapper around the
[VoteSmart](https://justfacts.votesmart.org/)
[API](http://api.votesmart.org/docs/) written by your friendly
neighborhood progressive tech organization, 🌟 [*Deck
Technologies*](https://www.deck.tools/) 🌟. Feel free to use this package
in any way you like.

VoteSmart provides information on US political candidates’ positions on
issues, votes on bills, and ratings by third party organizations, among
other data.

### Installation

``` r
devtools::install_github("decktools/votesmart", build_vignettes = TRUE)
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

For more in-depth examples of how these all fit together, check out the
vignette with:

    vignette("votesmart")

A short example:

``` r
library(votesmart)

(warrens <- candidates_get_by_lastname("warren", election_years = 2012))
#> Requesting data for {last_name: warren, election_year: 2012, stage_id: }.
#> # A tibble: 8 x 32
#>   candidate_id first_name nick_name middle_name last_name suffix title
#>   <chr>        <chr>      <chr>     <chr>       <chr>     <chr>  <chr>
#> 1 139104       Adam       <NA>      Lee         Warren    <NA>   <NA> 
#> 2 103860       Dennis     <NA>      <NA>        Warren    <NA>   <NA> 
#> 3 141272       Elizabeth  <NA>      Ann         Warren    <NA>   Sena…
#> 4 117839       Harry      <NA>      Joseph      Warren    <NA>   Repr…
#> 5 138202       Pete       <NA>      <NA>        Warren    <NA>   <NA> 
#> 6 137066       Stephen    <NA>      <NA>        Warren    <NA>   <NA> 
#> 7 135832       Tom        <NA>      <NA>        Warren    <NA>   <NA> 
#> 8 139311       Wesley     <NA>      G.          Warren    <NA>   <NA> 
#> # … with 25 more variables: ballot_name <chr>, stage_id <chr>,
#> #   election_year <chr>, preferred_name <chr>, election_parties <chr>,
#> #   election_status <chr>, election_stage <chr>, election_district_id <chr>,
#> #   election_district_name <chr>, election_office <chr>,
#> #   election_office_id <chr>, election_state_id <chr>,
#> #   election_office_type_id <chr>, election_special <lgl>, election_date <chr>,
#> #   office_parties <chr>, office_status <chr>, office_district_id <chr>,
#> #   office_district_name <chr>, office_state_id <chr>, office_id <chr>,
#> #   office_name <chr>, office_type_id <chr>, running_mate_id <chr>,
#> #   running_mate_name <chr>
```

Taking Elizabeth Warren’s `candidate_id`, we can see how she’s rated by
SIGs on a variety of issues.

``` r
(id <- 
  warrens %>% 
  filter(first_name == "Elizabeth") %>% 
  pull(candidate_id)
)
#> [1] "141272"

(ratings <- 
  rating_get_candidate_ratings(
    candidate_ids = id,
  )
)
#> Requesting data for {candidate_id: 141272, sig_id: }.
#> # A tibble: 514 x 17
#>    rating_id candidate_id sig_id rating rating_name timespan rating_text
#>    <chr>     <chr>        <chr>  <chr>  <chr>       <chr>    <chr>      
#>  1 11196     141272       2884   74     Presidenti… 2020     Senator El…
#>  2 11199     141272       2709   100    Climate Te… 2020     Senator El…
#>  3 11366     141272       101    90     Positions … 2020     Senator El…
#>  4 11438     141272       2804   83     Presidenti… 2020     Senator El…
#>  5 11450     141272       2884   85     Presidenti… 2020     <NA>       
#>  6 11452     141272       2884   87     Presidenti… 2020     Senator El…
#>  7 11504     141272       2859   80     Climate Sc… 2020     Senator El…
#>  8 11601     141272       2811   95     Presidenti… 2020     Senator El…
#>  9 11629     141272       2983   62     Presidenti… 2020     Senator El…
#> 10 11422     141272       2167   92     Positions … 2019-20… <NA>       
#> # … with 504 more rows, and 10 more variables: category_name_1 <chr>,
#> #   category_name_2 <chr>, category_name_3 <chr>, category_name_4 <chr>,
#> #   category_name_5 <chr>, category_name_6 <chr>, category_name_7 <chr>,
#> #   category_name_8 <chr>, category_name_9 <chr>, category_name_10 <chr>
```

``` r
ratings %>% 
  filter(
    category_name_2 %in% 
      c("Environment", 
        "Fiscally Conservative",
        "Education", 
        "Civil Liberties and Civil Rights", 
        "Campaign Finance") 
  ) %>% 
  group_by(category_name_2) %>% 
  summarise(
    avg_rating = mean(as.numeric(rating), na.rm = TRUE)
  ) %>% 
  arrange(category_name_2)
#> # A tibble: 5 x 2
#>   category_name_2                  avg_rating
#>   <chr>                                 <dbl>
#> 1 Campaign Finance                     100   
#> 2 Civil Liberties and Civil Rights      84.5 
#> 3 Education                             82.5 
#> 4 Environment                           91.1 
#> 5 Fiscally Conservative                  9.58
```

#### Summary of Functions

**`candidates_get_by_lastname`**

Get a dataframe of candidates given a vector of `last_name`s,
`election_year`s (optional, defaulting to current year), and `stage_id`s
(optional)

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

**`rating_get_candidate_ratings`**

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
    
      - The functions in this package allow multiple inputs to be
        specified for each argument, but requests are sent one at a time
        for each combination of inputs

<br>

Feel free to reach out in the
[Issues](https://github.com/decktools/votesmart/issues) with any bugs or
feature requests\! 💫
