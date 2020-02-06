



office_get_levels <- function() {

  this <- get(
    req = "Office.getLevels?",
    query = "",
    level_one = "levels",
    level_two = "level"
  )
  this
}
