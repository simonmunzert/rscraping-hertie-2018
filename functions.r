#
char <- function(x) as.character(x)
num <- function(x) as.numeric(x)

simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}

recode_partynames <- function(x, longnames = FALSE) {
  require(stringr)
  x_recoded <- x %>% str_replace("cdu", "Union") %>%
    str_replace("fdp", "FDP") %>% 
    str_replace("spd", "SPD") %>%
    str_replace("gru", "Grüne") %>%
    str_replace("lin", "Die Linke") %>%
    str_replace("afd", "AfD") %>%
    str_replace("oth", "Andere")
  if(longnames == TRUE) {
    x_recoded <- x_recoded %>% str_replace("Grüne", "B'90/Die Grünen") %>% str_replace("Union", "CDU/CSU") %>% str_replace("Linke", "Die Linke")
  }
  x_recoded
}

recode_years <- function(x) {
  x_recoded <- x %>% str_replace("19|20", "'")
  x_recoded
}

