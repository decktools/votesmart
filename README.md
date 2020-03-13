
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

### An Example

A key feature of VoteSmart’s data is the ratings that Special Interest
Groups (SIGs) give to candidates on various issues.

Let’s say we want to know how Elizabeth Warren tends to be rated on a
few issues.

We’ll first want to know what her VoteSmart `candidate_id` is. We can
search for her using `candidates_get_by_lastname`:

``` r
library(votesmart)

warrens <- candidates_get_by_lastname("warren", election_years = 2012)
#> Requesting data for {last_name: warren, election_year: 2012, stage_id: }.

kable(warrens)
```

| candidate\_id | first\_name | nick\_name | middle\_name | last\_name | suffix | title          | ballot\_name        | stage\_id | election\_year | preferred\_name | election\_parties | election\_status | election\_stage | election\_district\_id | election\_district\_name | election\_office | election\_office\_id | election\_state\_id | election\_office\_type\_id | election\_special | election\_date | office\_parties | office\_status | office\_district\_id | office\_district\_name | office\_state\_id | office\_id | office\_name | office\_type\_id | running\_mate\_id | running\_mate\_name |
| :------------ | :---------- | :--------- | :----------- | :--------- | :----- | :------------- | :------------------ | :-------- | :------------- | :-------------- | :---------------- | :--------------- | :-------------- | :--------------------- | :----------------------- | :--------------- | :------------------- | :------------------ | :------------------------- | :---------------- | :------------- | :-------------- | :------------- | :------------------- | :--------------------- | :---------------- | :--------- | :----------- | :--------------- | :---------------- | :------------------ |
| 139104        | Adam        | NA         | Lee          | Warren     | NA     | NA             | Adam Lee Warren     |           | 2012           | Adam            | Republican        | Lost             | Primary         | NA                     | NA                       | Attorney General | 12                   | MO                  | S                          | FALSE             | 08/07/2012     | NA              | NA             | NA                   | NA                     | NA                | NA         | NA           | NA               | NA                | NA                  |
| 103860        | Dennis      | NA         | NA           | Warren     | NA     | NA             | Dennis C. Warren    |           | 2012           | Dennis          | Republican        | Withdrawn        | General         | 28446                  | 16                       | State Senate     | 9                    | ID                  | L                          | FALSE             | 11/06/2012     | NA              | NA             | NA                   | NA                     | NA                | NA         | NA           | NA               | NA                | NA                  |
| 141272        | Elizabeth   | NA         | Ann          | Warren     | NA     | Senator        | Elizabeth A. Warren |           | 2012           | Elizabeth       | Democratic        | Won              | General         | NA                     | NA                       | U.S. Senate      | 6                    | MA                  | C                          | FALSE             | 11/06/2012     | Democratic      | active         | 20512                | Sr                     | MA                | 6          | U.S. Senate  | C                | NA                | NA                  |
| 117839        | Harry       | NA         | Joseph       | Warren     | NA     | Representative | Harry Warren        |           | 2012           | Harry           | Republican        | Won              | General         | 25520                  | 77                       | State House      | 8                    | NC                  | L                          | FALSE             | 11/06/2012     | Republican      | active         | 25519                | 76                     | NC                | 8          | State House  | L                | NA                | NA                  |
| 138202        | Pete        | NA         | NA           | Warren     | NA     | NA             | Pete Warren         |           | 2012           | Pete            | Republican        | Removed          | Primary         | 21842                  | 30                       | State House      | 8                    | FL                  | L                          | FALSE             | 08/14/2012     | NA              | NA             | NA                   | NA                     | NA                | NA         | NA           | NA               | NA                | NA                  |
| 137066        | Stephen     | NA         | NA           | Warren     | NA     | NA             | Stephen Warren      |           | 2012           | Stephen         | Republican        | Lost             | Primary         | 27865                  | 22B                      | State House      | 8                    | ID                  | L                          | FALSE             | 05/15/2012     | NA              | NA             | NA                   | NA                     | NA                | NA         | NA           | NA               | NA                | NA                  |
| 135832        | Tom         | NA         | NA           | Warren     | NA     | NA             | Tom Warren          |           | 2012           | Tom             | Democratic        | Lost             | General         | 25782                  | 76                       | State House      | 8                    | OH                  | L                          | FALSE             | 11/06/2012     | NA              | NA             | NA                   | NA                     | NA                | NA         | NA           | NA               | NA                | NA                  |
| 139311        | Wesley      | NA         | G.           | Warren     | NA     | NA             | Wesley G. Warren    |           | 2012           | Wesley          | Republican        | Lost             | General         | 21874                  | 62                       | State House      | 8                    | FL                  | L                          | FALSE             | 11/06/2012     | NA              | NA             | NA                   | NA                     | NA                | NA         | NA           | NA               | NA                | NA                  |

Filtering to her first name and taking her `candidate_id`, we can now
grab Warren’s ratings by all SIGs with `rating_get_candidate_ratings`.

``` r
(id <- 
  warrens %>% 
  filter(first_name == "Elizabeth") %>% 
  pull(candidate_id)
)
#> [1] "141272"

ratings <- 
  rating_get_candidate_ratings(
    candidate_ids = id,
  )
#> Requesting data for {candidate_id: 141272, sig_id: }.
#> Warning: `cols` is now required.
#> Please use `cols = c(category_id_1, category_name_1, category_id_2, category_name_2, 
#>     category_id_3, category_name_3, category_id_4, category_name_4, 
#>     category_id_5, category_name_5)`

kable(ratings %>% sample_n(3))
```

| rating\_id | candidate\_id | sig\_id | rating | rating\_name                        | timespan | rating\_text                                                                                            | category\_id\_1 | category\_name\_1         | category\_id\_2 | category\_name\_2 | category\_id\_3 | category\_name\_3              | category\_id\_4 | category\_name\_4 | category\_id\_5 | category\_name\_5 |
| :--------- | :------------ | :------ | :----- | :---------------------------------- | :------- | :------------------------------------------------------------------------------------------------------ | :-------------- | :------------------------ | :-------------- | :---------------- | :-------------- | :----------------------------- | :-------------- | :---------------- | :-------------- | :---------------- |
| 7500       | 141272        | 265     | 100    | Positions (Sept. 2013)              | 2013     | Senator Elizabeth Warren supported the interests of the Population Connection 100 percent in 2013.      | 75              | Abortion and Reproductive | 98              | NA                | 31              | Marriage, Family, and Children | NA              | NA                | NA              | NA                |
| 11446      | 141272        | 1627    | 50     | Freedom Index                       | 2019     | Senator Elizabeth Warren supported the interests of the The John Birch Society 50 percent in 2019.      | 17              | Conservative              | 30              | Environment       | 86              | Fiscally Conservative          | 37              | Guns              | NA              | NA                |
| 11366      | 141272        | 101     | 90     | Positions (Presidential Candidates) | 2020     | Senator Elizabeth Warren supported the interests of the Council for a Livable World 90 percent in 2020. | 22              | Defense                   | 32              | Foreign Affairs   | 61              | National Security              | NA              | NA                | NA              | NA                |

And compute on them:

``` r
ratings %>% 
  filter(
    category_name_1 %in% 
      c("Environment", 
        "Fiscally Conservative",
        "Education", 
        "Civil Liberties and Civil Rights", 
        "Campaign Finance") 
  ) %>% 
  group_by(category_name_1) %>% 
  summarise(
    avg_rating = mean(as.numeric(rating), na.rm = TRUE)
  ) %>% 
  arrange(category_name_1)
#> # A tibble: 5 x 2
#>   category_name_1                  avg_rating
#>   <chr>                                 <dbl>
#> 1 Campaign Finance                     100   
#> 2 Civil Liberties and Civil Rights      84.5 
#> 3 Education                             88.3 
#> 4 Environment                           91.1 
#> 5 Fiscally Conservative                  9.58
```

For more in-depth examples of how these all fit together, check out the
vignette with:

    vignette("votesmart")

### Available Functions

*These functions are named after the `snake_case`d version of the API
[endpoints](http://api.votesmart.org/docs/).*

**If you see an endpoint you want to be made available in this package
that isn’t yet, feel free to submit an
[issue](https://github.com/decktools/votesmart/issues) or a [pull
request](https://github.com/decktools/votesmart/pulls)\!**

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
