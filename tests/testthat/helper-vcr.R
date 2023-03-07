library("vcr") # *Required* as vcr is set up on loading
vcr::vcr_configure(
  dir = "../fixtures",
  filter_sensitive_data =
    list("<<votesmart_key>>" = Sys.getenv("VOTESMART_API_KEY")),
  preserve_exact_body_bytes = TRUE
)
vcr::check_cassette_names()
