### -----------------------------
### simon munzert
### scraping static webpages
### -----------------------------

## peparations -------------------

setwd("/Users/simonmunzert/GitHub/rscraping-hu-2017")
source("packages.r")
source("functions.r")


## breaking up the HTML ----------

## What's HTML?

# HyperText Markup Language
# markup language = plain text + markups
# standard for the construction of websites
# relevance for web scraping: web architecture is important because it determines where and how information is stored


## browsing vs. scraping

# browsing
  # 1. you click on something
  # 2. browser sends request to server that hosts website
  # 3. server returns resource (often an HTML document)
  # 4. browser interprets HTML and renders it in a nice fashion

# scraping with R
  # 1. you manually specify a resource
  # 2. R sends request to server that hosts website
  # 3. server returns resource
  # 4. R parses HTML (i.e., interprets the structure), but does not render it in a nice fashion
  # 5. it's up to you to tell R which parts of the structure to focus on and what content to extract


## inspect the source code in your browser ---------------

browseURL("https://www.nytimes.com/")

# Chrome:
  # 1. right click on page
  # 2. select "view source"

# Firefox:
  # 1. right click on page
  # 2. select "view source"

# Microsoft Edge:
# 1. right click on page
# 2. select "view source"

# Safari
  # 1. click on "Safari"
  # 2. select "Preferences"
  # 3. go to "Advanced"
  # 4. check "Show Develop menu in menu bar"
  # 5. click on "Develop"
  # 6. select "show page source"
  # 7. alternatively to 5./6., right click on page and select "view source"


## a quick primer to CSS selectors ----------

## What's CSS?

# Cascading Style Sheets
# style sheet language to give browsers information of how to render HTML document by providing more info on, e.g., layout, colors, and fonts
# CSS code can be stored within an HTML document or in an external CSS file
# the good thing for us: selectors, i.e. patterns used to specify which elements to format in a certain way, can be used to address the elements we want to extract information from
# works via tag name (e.g., <h2>, <p>, ...) or element attributes "id" and "class"

## How does it work?
browseURL("http://flukeout.github.io/") # let's play this together until plate 8 or so!



## a quick primer to XPath ------------------

# XPath is a query language for selecting nodes from an XML-style document (including HTML)
# provides just another way of extracting data from static webpages
# you can also use XPath with R
# can be more powerful than CSS selectors
# learning XPath takes probably a day (and some practice) 
# you'll probably not need it very often, so we don't talk about it here
# if you want to know more, consult the book--we give it an extensive treatment



## the rvest package ----------

## overview 

  # see also: https://github.com/hadley/rvest
  # convenient package to scrape information from web pages
  # builds on other packages, such as xml2 and httr
  # provides very intuitive functions to import and process webpages


## basic workflow of scraping with rvest

# 1. specify URL
url <- "https://www.nytimes.com"

# 2. download static HTML behind the URL and parse it into an XML file
url_parsed <- read_html(url)
class(url_parsed)
html_structure(url_parsed)
as_list(url_parsed)

# 3. extract specific nodes with CSS (or XPath)
headings_nodes <- html_nodes(url_parsed, css = ".story-heading")

# 4. extract content from nodes
headings <- html_text(headings_nodes)
headings <- str_replace_all(headings, "\\n|\\t|\\r", "") %>% str_trim()
head(headings)
length(headings)
str_detect(headings, "Trump") %>% table()

headlines <- read_html("https://www.nytimes.com") %>% html_nodes(css = ".story-heading") %>% html_text()



## extract data from tables --------------

## HTML tables 
  # ... are a special case for scraping because they are already very close to the data structure you want to build up in R
  # ... come with standard tags and are usually easily identifiable

## scraping HTML tables with rvest

url <- "https://en.wikipedia.org/wiki/Joint_Statistical_Meetings"
browseURL(url)
url_parsed <- read_html(url)
tables <- html_table(url_parsed, fill = TRUE)
tables
meetings <- tables[[2]]
class(meetings)
head(meetings)
table(meetings$Location) %>% sort()

## note: HTML tables can get quite complex. there are more flexible solutions than html_table() on the market (e.g., package "htmltab") 



### working with SelectorGadget ----------

# to learn about it, visit
vignette("selectorgadget")

# to install it, visit
browseURL("http://selectorgadget.com/")
# and follow the advice below: "drag this link to your bookmark bar: >>SelectorGadget>> (updated August 7, 2013)"

## SelectorGadget is magic. Proof:
browseURL("https://www.nytimes.com")

url <- "https://www.nytimes.com"
css <-  ".story-heading"
url_parsed <- read_html(url)
html_nodes(url_parsed, css = css) %>% html_text


## dealing with multiple pages ----------

# often, we want to scrape data from multiple pages
# in such scenarios, automating the scraping process becomes  r e a l l y  powerful
# my philosophy: download first, then import and extract information. minimizes server load and saves time


## example: fetching and analyzing jstatsoft download statistics

# set temporary working directory
setwd(wd)
tempwd <- ("data/jstatsoftStats")
dir.create(tempwd)
setwd(tempwd)

browseURL("http://www.jstatsoft.org/")

# construct list of urls
baseurl <- "http://www.jstatsoft.org/article/view/v"
volurl <- paste0("0", seq(1,78,1))
volurl[1:9] <- paste0("00", seq(1, 9, 1))
brurl <- paste0("0", seq(1,9,1))
urls_list <- paste0(baseurl, volurl)
urls_list <- paste0(rep(urls_list, each = 9), "i", brurl)
names <- paste0(rep(volurl, each = 9), "_", brurl, ".html")

# download pages
folder <- "html_articles/"
dir.create(folder)
for (i in 1:length(urls_list)) {
  if (!file.exists(paste0(folder, names[i]))) {
    download.file(urls_list[i], destfile = paste0(folder, names[i])) # , method = "libcurl" might be needed on windows machine
    Sys.sleep(runif(1, 0, 1))
  }
}

# check success
list_files <- list.files(folder, pattern = "0.*")
list_files_path <-  list.files(folder, pattern = "0.*", full.names = TRUE)
length(list_files)

# delete non-existing articles
files_size <- sapply(list_files_path, file.size)
table(files_size) %>% sort()
delete_files <- list_files_path[files_size == 23460]
sapply(delete_files, file.remove)
list_files_path <-  list.files(folder, pattern = "0.*", full.names = TRUE) # update list of files

# import pages and extract content
authors <- character()
title <- character()
statistics <- character()
numViews <- numeric()
datePublish <- character()
for (i in 1:length(list_files_path)) {
  html_out <- read_html(list_files_path[i])
  table_out <- html_table(html_out, fill = TRUE)[[6]]
  authors[i] <- table_out[1,2]
  title[i] <- table_out[2,2]
  statistics[i] <- table_out[4,2]
  numViews[i] <- statistics[i] %>% str_extract("[[:digit:]]+") %>% as.numeric()
  datePublish[i] <- statistics[i] %>% str_extract("[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}.$") %>% str_replace("\\.", "")
}


# construct data frame
dat <- data.frame(authors = authors, title = title, numViews = numViews, datePublish = datePublish)
head(dat)

# plot download statistics
dattop <- dat[order(dat$numViews, decreasing = TRUE),]
dattop[1:10,]
summary(dat$numViews)
plot(density(dat$numViews, from = 0), yaxt="n", ylab="", xlab="Number of views", main="Distribution of article page views in JStatSoft")



## dealing with GET forms ----------

# Filling out forms in the browser:
  # fill out the form,
  # push the submit, ok, start or the like! button. 
  # let the browser execute the action specified in the source code of the form and send the data to the server,
  # and let the browser receive the returned resources after the server has evaluated the inputs. 

# Using forms in scraping practice:
  # recognize that forms are involved,
  # determine the method used to transfer the data,
  # determine the address to send the data to,
  # determine the inputs to be sent along,
  # build a valid request and send it out, and
  # process the returned resources. 

# set up session
browseURL("http://www.whoishostingthis.com/tools/user-agent/")
uastring <- "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
session <- html_session("http://www.google.com", user_agent(uastring))

# inspect form
search <- html_form(session)[[1]]
search

# set form parameters
form <- set_values(search, q = "pubs firenze")
google_search <- submit_form(session, form)
url_parsed <- read_html(google_search)
hits_text <- html_nodes(url_parsed, css = ".r a") %>% html_text()
hits_links <- html_nodes(url_parsed, css = ".r a") %>% html_attr("href") 


## another example: WordNet Search
# inspect webpage
url <- "http://wordnetweb.princeton.edu/perl/webwn"
browseURL(url)
url_parsed <- read_html(url)
html_form(url_parsed)
wordnet <- html_form(url_parsed)[[1]]

# test it online with "data"
session <- html_session(url, user_agent(uastring))
wordnet_form <- set_values(wordnet, s = "data")
wordnet_search <- submit_form(session, wordnet_form)
url_parsed <- read_html(wordnet_search)
url_parsed %>% html_nodes("li") %>% html_text()

session <- html_session(url, user_agent(uastring))
wordnet_form <- set_values(wordnet, s = "data", o2 = "1")
wordnet_search <- submit_form(session, wordnet_form)
url_parsed <- read_html(wordnet_search)
url_parsed %>% html_nodes("li") %>% html_text()



## dealing with POST forms ----------

# GET appends form data into the URL in name/value pairs
# the length of a URL is limited (about 3000 characters)
# never use GET to send sensitive data! (will be visible in the URL)
# useful for form submissions where a user wants to bookmark the result
# GET is better for non-secure data, like query strings in Google

# POST appends form data inside the body of the HTTP request (data is not shown is in URL)
# has no size limitations
# form submissions with POST cannot be bookmarked


## POST forms 
# goal: gathering data from read-able at http://read-able.com/
url <- "http://read-able.com/"
browseURL(url)

url_parsed <- read_html(url)
html_form(url_parsed)
readable <- html_form(url_parsed)[[2]]

sentence <- '"It is a capital mistake to theorize before one has data. Insensibly one begins to twist facts to suit theories, instead of theories to suit facts." - Arthur Conan Doyle, Sherlock Holmes'
readable_form <- set_values(readable, directInput = sentence)
session <- html_session(url, user_agent(uastring))
readable_search <- submit_form(session, readable_form)
url_parsed <- read_html(readable_search)
html_table(url_parsed)







### glossary: rvest's main functions --------------
read_html()
html_nodes()
html_text()
html_attr()
html_attrs()

read_xml()
xml_nodes()
xml_text()
xml_attr()
xml_attrs()

html_table()
html_form()
set_values()
submit_form()

guess_encoding()
repair_encoding()

html_session()
jump_to()
follow_link()
back()
forward()





######################
### HOMEWORK       ###
######################

# 1. repeat playing CSS diner and complete all levels!

# 2. go to the following website
browseURL("https://www.jstatsoft.org/about/editorialTeam")
# a) which CSS identifiers can be used to describe all names of the editorial team?
# b) write a corresponding CSS selector that targets them!

# 3. revisit the jstatsoft.org website from above and use rvest to extract the names! Bonus: try and extract the full lines including the affiliation, and count how many of the editors are at a statistics or mathematics department or institution!
url <- "https://www.jstatsoft.org/about/editorialTeam"

# 4. scrape the table tall buildings (300m+) currently under construction from the following page. How many of those buildings are currently built in China? and in which city are most of the tallest buildings currently built?
browseURL("https://en.wikipedia.org/wiki/List_of_tallest_buildings_in_the_world")

# 5. Go to http://en.wikipedia.org/wiki/List_of_MPs_elected_in_the_United_Kingdom_general_election,_1992 and extract the table containing the elected MPs int the United Kingdom general election of 1992. Which party has most Sirs?

# 6. Create code that scrapes and cleans all headlines from the main pages of sueddeutsche.de and spiegel.de!

# 7. use SelectorGadget to identify a CSS selector that helps extract all article author names from Buzzfeed's main page! Next, use rvest to scrape these names!

# 8. Go to http://earthquaketrack.com/ and make a request for data on earthquakes in "Florence, Italy". Try to parse the results into one character vector! Hint: After filling out a form, you might have to look for a follow-up URL and parse it in a second step to arrive at the data you need.

# 9. The English Wikipedia features an entry with a list of political scientists around the world: https://en.wikipedia.org/wiki/List_of_political_scientists. Make use of this list to (1) download all articles of the listed scientists to your hard drive, (2) gather the network structure behind these articles and visualize it, and (3) identify the top 10 of political scientists that have the most links from other political scientists pointing to their page!

