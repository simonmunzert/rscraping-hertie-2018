### -----------------------------
### simon munzert
### tapping wikipedia
### -----------------------------

## peparations -------------------

source("packages.r")

#install.packages(c("WikipediR", "WikidataR", "pageviews"))
library("WikipediR")
library("WikidataR")
library("pageviews")

## overview of Wikipedia/Wikidata APIs ---------------------------------

# Media Wiki action API
# use case: rich queries, editing and content access.
browseURL("https://www.mediawiki.org/wiki/API:Main_page")

# MediaWiki REST API
# use case: high-volume content access.
browseURL("https://www.mediawiki.org/api/rest_v1/")

# Wikidata
browseURL("https://www.wikidata.org/wiki/Wikidata:Main_Page")


# The WikipediR package
browseURL("https://cran.r-project.org/web/packages/WikipediR/vignettes/WikipediR.html")

# The WikidataR package
browseURL("https://cran.r-project.org/web/packages/WikidataR/vignettes/Introduction.html")


## primer to the WikipediR package ----------------------------

# get page content
content <- page_content("de","wikipedia", page_name = "Brandenburger_Tor", as_wikitext = TRUE)
str(content)
content$parse$wikitext %>% unlist %>% cat

# get page links (careful: max 500 links)
links <- page_links("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500, namespaces = 0)
unlist(links) %>% as.character() %>% str_subset("[^0]")

# get page backlinks (links referring to a given web resource; careful: max 500 backlinks)
backlinks <- page_backlinks("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500, namespaces = 0)
unlist(backlinks) %>%  .[names(.) == "title"] %>% as.character

# get external links
extlinks <- page_external_links("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500)
extlinks[[1]]$extlinks

# metadata on article
metadata <- page_info("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE) 
metadata[[1]] %>% t() %>% as.data.frame

# which categories in page
cats <- categories_in_page("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE)
cats[[1]]$categories



## primer to the WikidataR package ----------------------------

# WikiData is a free, collaborative, multilingual database
# supports Wikis of the Wikimedia movement (such as Wikipedia or Wikimedia Commons) by offering standardized storage and access to data
# basic logic:
  # basic objects are stored as items with a unique item number, starting with "Q". 
    # example: Douglas Adams --> Q42
browseURL("https://www.wikidata.org/wiki/Q42")
  # objects are described using statements, which detail certain properties, starting with "P"
    # example: "educated at" --> P69
  # properties themselves have values, which are again values
    # example: "St. John's College" --> Q691283

# access to data on WikiData:
  # via WikiData API (see later)
  # via SPARQL query interface at
browseURL("https://query.wikidata.org/")
  # via Reasonator (slightly more comfortable view on the data)
browseURL("https://tools.wmflabs.org/reasonator/?q=Q42")


# find item
wd_item <- find_item("Brandenburger Tor", language = "de")
wd_item[[1]]$id

browseURL("https://www.wikidata.org/wiki/Q82425")

# get item based on item id
tor_item <- get_item("82425")
str(tor_item)

# extract claims ("features")
extract_claims(tor_item, "P17")

# extract properties
browseURL("https://www.wikidata.org/wiki/Q183")
property <- get_property("Q82425")
str(property)






## functions to automate collection of wikipedia articles --------

# search Wikipedia with search term
searchWikiFun <- function(term = NULL, limit = 100, title.only = TRUE, wordcount.min = 500) {
  # API doc at https://www.mediawiki.org/wiki/API:Search
  term <- URLencode(term)
  url <- sprintf("https://de.wikipedia.org/w/api.php?action=query&list=search&srsearch=%s&srlimit=%d&format=json", term, limit)
  wiki_search_parsed <- jsonlite::fromJSON(url)$query$search
  wiki_search_parsed <- dplyr::filter(wiki_search_parsed, wordcount >= wordcount.min)
  if(title.only == FALSE) {
    return(wiki_search_parsed)
  } else{
    return(wiki_search_parsed$title)
  }
}


# download pageview statistics with wikipediatrend package
pageviewsDownload <- function(pages = NULL, folder = "~", from = "2015070100", to = "2018040100", language = "de") {
  pageviews_list <- list()
  pageviews_filenames_raw <- vector()
  for (i in seq_along(pages)) {
    filename <- paste0("wp_", pages[i], "_", language, ".csv")
    if (!file.exists(paste0(folder, filename))) {
      pageviews_list[[i]] <- try(article_pageviews(project = "de.wikipedia", article =  URLencode(pages[i]), start = from, end = to))
      try(write.csv(pageviews_list[[i]], file = paste0(folder, filename), row.names = FALSE))
    }
    pageviews_filenames_raw[i] <- filename
  } 
}

# test
pages_search <- searchWikiFun(term = "Arbeitslosigkeit", limit = 100, wordcount.min = 500)
dir.create("data/wikipageviews")
pageviewsDownload(pages = pages_search, folder = "data/wikipageviews/", from = "2017070100", to = "2018040100", language = "de")



## getting pageviews from Wikipedia ---------------------------

## IMPORTANT: If you want to gather pageviews data before July 2015, you need the statsgrokse package. Check it out here:
browseURL("https://github.com/cran/statsgrokse")

ls("package:pageviews")

trump_views <- article_pageviews(project = "en.wikipedia", article = "Donald Trump", user_type = "user", start = "2015070100", end = "2017040100")
head(trump_views)
clinton_views <- article_pageviews(project = "en.wikipedia", article = "Hillary Clinton", user_type = "user", start = "2015070100", end = "2017040100")

plot(ymd(trump_views$date), trump_views$views, col = "red", type = "l")
lines(ymd(clinton_views$date), clinton_views$views, col = "blue")

german_parties_views <- article_pageviews(
  project = "de.wikipedia", 
  article = c("Christlich Demokratische Union Deutschlands", "Christlich-Soziale Union in Bayern", "Sozialdemokratische Partei Deutschlands", "Freie Demokratische Partei", "Bündnis 90/Die Grünen", "Die Linke", "Alternative für Deutschland"),
  user_type = "user", 
  start = "2015090100", 
  end = "2017040100"
)
table(german_parties_views$article)

parties <- unique(german_parties_views$article)
dat <- filter(german_parties_views, article == parties[1])
plot(ymd(dat$date), dat$views, col = "black", type = "l")
dat <- filter(german_parties_views, article == parties[2])
lines(ymd(dat$date), dat$views, col = "blue")
dat <- filter(german_parties_views, article == parties[3])
lines(ymd(dat$date), dat$views, col = "red")
dat <- filter(german_parties_views, article == parties[7])
lines(ymd(dat$date), dat$views, col = "brown")

