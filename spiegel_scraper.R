#!/usr/local/bin/Rscript
library(stringr)
library(magrittr)
library(httr)
setwd("/Users/simonmunzert/GitHub/rscraping-hertie-2018")
url <- "http://www.spiegel.de/schlagzeilen/"
url_out <- GET(url, add_headers(from = "eddie@datacollection.com"))
datetime <- str_replace_all(Sys.time(), "[ :]", "-")
content(url_out, as = "text") %>% write(file = str_c("data/spiegelHeadlines/headlines-spiegel-", datetime, ".html"))
