# library(rlang)
# make_fun <- function(args) {
#   args <- rep_named(args, list(missing_arg()))
#   new_function(args, quote({
#     mc <- match.call(expand.dots = FALSE)
#     cl <- tail(as.list(mc), -1)
#     glue::glue(
#       "{names(cl)}: {cl}"
#     )
#   }))
# }
# foo <- make_fun(c("g", "h"))
# foo(g = "a")
# #> g: a
# foo(h = "b")
# #> h: b
# foo(i = "c")
# #> Error in foo(i = "c"): unused argument (i = "c")
# (df <- tibble(
#   name = c("f_1", "f_2"),
#   args = list(c("a", "b"), c("c", "d"))
# ))
# #> # A tibble: 2 x 2
# #>   name  args
# #>   <chr> <list>
# #> 1 f_1   <chr [2]>
# #> 2 f_2   <chr [2]>
# walk2(df$name, df$args, ~ assign(x = .x, make_fun(.y), envir = globalenv()))
# f_1(a = "a")
# #> a: a
# f_1(b = "b")
# #> b: b
# f_1(c = "c")
# #> Error in f_1(c = "c"): unused argument (c = "c")
#
# f_2(c = "c")
# #> c: c
# f_2(d = "d")
# #> d: d
# f_2(e = "e")
#
#
#
#
#
#
#
# # Set up the base function
# get_data <- function(nm, ...) {
#
#   req <- elmers("{nm}?")
#
#   inputs <-
#     match.call(expand.dots = FALSE)
#
#   args <- inputs$... %>% names()
#   values <- inputs$... %>% purrr::as_vector()
#
#   if (all) {
#     query_df <-
#       expand.grid(
#
#       )
#   } else {
#
#   }
#
#   query <- elmers("&{args}={values}")
#
#   url <-
#     construct_url(req, query)
#
#   raw <- request(url)
# }
#
# # For each of the endoints, pipe each endpoint name through as .x, so the function's name is that `nm`
# endpoint_input_mapping_nested$endpoint %>%
#   purrr::walk(~ assign(
#   x = .x,
#   value = purrr::partial(get_data),
#   envir = .GlobalEnv)
# )
#
#
# construct_funs <- function(tbl = endpoint_input_mapping_nested) {
#
#   for (i in 1:nrow(endpoint_input_mapping_nested)) {
#     nm <- endpoint_input_mapping_nested$endpoint[i]
#
#     inputs <- endpoint_input_mapping_nested[i, ] %>%
#       tidyr::unnest(inputs) %>%
#       pull(input)
#
#     # args <-
#     #   alist(a = "")
#
#     assign(
#       x = nm,
#       value = purrr::partial(get_data),
#       envir = .GlobalEnv
#     )
#
#     # formals(nm) <- args
#   }
# }
#
#
#
# construct_funs <- function(tbl = endpoint_input_mapping_nested) {
#   for (i in 1:nrow(endpoint_input_mapping_nested)) {
#     inputs <- endpoint_input_mapping_nested[i, ] %>%
#       tidyr::unnest(inputs) %>%
#       pull(input)
#
#     if (all(is.na(inputs))) inputs <- NULL
#
#     inputs_c <- stringr::str_c(inputs, collapse = ", ")
#
#     eval(
#       parse(
#         text =
#           elmers(
#             "{endpoint_input_mapping_nested$endpoint[i]} <- function({inputs_c}) {{'foo'}}"
#           )
#       )
#     )
#   }
# }
#
