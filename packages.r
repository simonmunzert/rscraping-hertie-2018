
# install packages from CRAN
p_needed <- c("rvest", # scraping suite
              "httr", "httpuv", # suites to ease HTTP communication
              "RSelenium", # access Selenium API
              "pageviews", "aRxiv", "rtweet", "ROAuth", "gtrendsR", "ggmap", # access various web APIs
              "robotstxt", # parse robots.txt files
              "readr", # imports spreadsheet data
              "haven", # imports SPSS, Stata and SAS files
              "magrittr", #  for piping
              "plyr", # for consistent split-apply-combines
              "dplyr",  # provides data manipulating functions
              "stringr", # for string processing
              "lubridate", # work with dates
              "jsonlite", # parse JSON data
              "devtools", # developer tools
              "networkD3", # tools to process network data
              "ggplot2", # for graphics
              "tidyr", # for tidying data frames
              "broom", # for tidying model output
              "janitor", # for basic data tidying and examinations
              "reshape2", # reshape data 
              "xtable", # generate table output
              "stargazer", # generate nice model table
              "babynames", # US babynames dataset 
              "nycflights13" # data set on all 336776 flights departing from NYC in 2013
)
packages <- rownames(installed.packages())
p_to_install <- p_needed[!(p_needed %in% packages)]
if (length(p_to_install) > 0) {
  install.packages(p_to_install)
}
lapply(p_needed, require, character.only = TRUE)
