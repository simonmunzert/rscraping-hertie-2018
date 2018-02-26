### -----------------------------
### simon munzert
### tapping wikipedia
### -----------------------------

## peparations -------------------

source("packages.r")

#install.packages(c("WikipediR", "WikidataR", "pageviews", "statsgrokse"))
library("WikipediR")
library("WikidataR")
library("pageviews")
library("statsgrokse")

## overview of Wikipedia/Wikidata APIs ---------------------------------

# Media Wiki action API
# usecase: rich queries, editing and content access.
browseURL("https://www.mediawiki.org/wiki/API:Main_page")

# MediaWiki REST API
# usecase: high-volume content access.
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
content$parse$wikitext

# get page links
links <- page_links("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500, namespaces = 0)
unlist(links) %>% as.character() %>% str_subset("[^0]")

# get page backlinks
backlinks <- page_backlinks("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500, namespaces = 0)
unlist(backlinks) %>%  .[names(.) == "title"] %>% as.character

# get external links
page_external_links("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500)

# metadata on article
page_info("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE)

# which categories in page
categories_in_page("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE)



## primer to the WikidataR package ----------------------------

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
property <- get_property("Q183")
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


# quick assessment of pages' recent pageview statistics
pagesMinPageviews <- function(pages = NULL, start = "2016090100", end = "2016093000", min.dailyviewsavg = 50) {
  pageviews_list <- list()
  pageviews_mean <- numeric()
  for (i in seq_along(pages)) {
    pageviews_list[[i]] <- try(article_pageviews(project = "de.wikipedia", article = URLencode(pages[i]), start = start, end = end, reformat = TRUE))
    pageviews_mean[i] <- try(mean(pageviews_list[[i]]$views, na.rm = TRUE))
  }
  pageviews_mean_df <- data.frame(page = pages, pageviews_mean = num(pageviews_mean), stringsAsFactors = FALSE)
  pages_minviews <- dplyr::filter(pageviews_mean_df, pageviews_mean >= min.dailyviewsavg) %>% extract2("page")
  return(pages_minviews)
}

# download pageview statistics with wikipediatrend package
pageviewsDownload <- function(pages = NULL, folder = "~", from = "2015070100", to = "2017040100", language = "de") {
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
pagenames_arbeitslosigkeit <- pagesMinPageviews(pages = pages_search, start = "2016090100", end = "2016093000", min.dailyviewsavg = 50)
dir.create("data/wikipageviews")
pageviewsDownload(pages = pagenames_arbeitslosigkeit, folder = "data/wikipageviews/", from = "2015070100", to = "2017040100", language = "de")





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

