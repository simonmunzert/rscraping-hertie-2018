### -----------------------------------------------------
### Case Study: Getting data from the IMDb using Selenium
### Simon Munzert
### -----------------------------------------------------


##  goal

# 1. gather movie data from the Internet Movie Database using Selenium
# 2. import them into R


## setup R + RSelenium -------------------------

# install current version of Java SE Development Kit
browseURL("http://www.oracle.com/technetwork/java/javase/downloads/jdk9-downloads-3848520.html")

# load RSelenium
library(RSelenium)
library(rvest)

# check currently installed version of Java
system("java -version")


## example --------------------------

# initiate Selenium driver
rD <- rsDriver()
remDr <- rD[["client"]]

# start browser, navigate to page
url <- "https://www.imdb.com/search/title"
remDr$navigate(url)

# enter keyword in title field
xpath <- '//*[@id="main"]/div[1]/div[2]/input'
titleElem <- remDr$findElement(using = 'xpath', value = xpath)
titleElem$sendKeysToElement(list("data")) # enter key word

# select requested title data
xpath <- '//*[@id="main"]/div[8]/div[2]/select/option[7]' # plot
titledatElem1 <- remDr$findElement(using = 'xpath', value = xpath)
titledatElem1$clickElement() # click on list element

xpath <- '//*[@id="main"]/div[8]/div[2]/select/option[10]' # technical info
titledatElem2 <- remDr$findElement(using = 'xpath', value = xpath)
titledatElem2$clickElement() # click on list element

# scroll to end of page (just for fun)
webElem <- remDr$findElement("css", "body")
webElem$sendKeysToElement(list(key = "end"))

# click on search button
xpath <- '//*[@id="main"]/p[3]/button'
searchElem <- remDr$findElement(using = 'xpath', value = xpath)
searchElem$clickElement() # click on button

# store index page
output <- remDr$getPageSource(header = TRUE)
write(output[[1]], file = "data/imdb-data-movies.html")

# close connection
remDr$closeServer()

# parse html
content <- read_html("data/imdb-data-movies.html") 
titles <- html_nodes(content, xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "lister-item-header", " " ))]//a') %>% html_text
head(titles)
