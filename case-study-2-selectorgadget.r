### -----------------------------------------------
### Case Study: Mapping Breweries in Germany
### Simon Munzert
### -----------------------------------------------


##  goal

# 1. gather headlines from the New York Times using SelectorGadget
# 2. import them into R
# 3. analyze them using R


## load packages

library(rvest)
library(stringr)
library(quanteda)


# step 1: parse page
url <- "http://www.nytimes.com"
html_parsed <- read_html(url, encoding = "UTF-8")

# step 2: construct and apply XPath expression using SelectorGadget (in browser)
xpath <- '//*[contains(concat( " ", @class, " " ), concat( " ", "story-heading", " " ))]'
headings <- html_nodes(html_parsed, xpath = xpath) %>% html_text()
headings

# step 3: clean data
headings <- str_replace_all(headings, "\\n" , " ") %>% str_trim()
headings

# step 4: plot data in word cloud
headings_dfm <- dfm(headings, remove = stopwords(), remove_punct = TRUE)
textplot_wordcloud(headings_dfm)
