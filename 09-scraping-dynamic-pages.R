### -----------------------------
### simon munzert
### scraping dynamic webpages
### -----------------------------

## peparations -------------------

source("packages.r")



## setup R + RSelenium -------------------------

# install current version of Java SE Runtime Environment
browseURL("http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html")

# load RSelenium
library(RSelenium)

# set up connection via RSelenium package
# documentation: http://cran.r-project.org/web/packages/RSelenium/RSelenium.pdf

# check currently installed version of Java
system("java -version")
#system("java -jar selenium-server-standalone-3.4.0.jar")


## example --------------------------

# initiate Selenium driver
rD <- rsDriver()
remDr <- rD[["client"]]

# start browser, navigate to page
url <- "http://www.iea.org/policiesandmeasures/renewableenergy/"
remDr$navigate(url)

# open regions menu
xpath <- '//*[@id="main"]/div/form/div[1]/ul/li[1]/span'
regionsElem <- remDr$findElement(using = 'xpath', value = xpath)
regionsElem$clickElement() # click on button


# selection "European Union"
xpath <- '//*[@id="main"]/div/form/div[1]/ul/li[1]/ul/li[5]/label/input'
euElem <- remDr$findElement(using = 'xpath', value = xpath)
selectEU <- euElem$clickElement() # click on button

# set time frame
xpath <- '//*[@id="main"]/div/form/div[5]/select[1]'
fromDrop <- remDr$findElement(using = 'xpath', value = xpath) 
clickFrom <- fromDrop$clickElement() # click on drop-down menu
writeFrom <- fromDrop$sendKeysToElement(list("2000")) # enter start year


xpath <- '//*[@id="main"]/div/form/div[5]/select[2]'
toDrop <- remDr$findElement(using = 'xpath', value = xpath) 
clickTo <- toDrop$clickElement() # click on drop-down menu
writeTo <- toDrop$sendKeysToElement(list("2010")) # enter end year

# click on search button
xpath <- '//*[@id="main"]/div/form/button[2]'
searchElem <- remDr$findElement(using = 'xpath', value = xpath)
resultsPage <- searchElem$clickElement() # click on button

# store index page
output <- remDr$getPageSource(header = TRUE)
write(output[[1]], file = "iea-renewables.html")

# close connection
remDr$closeServer()

# parse index table
content <- read_html("iea-renewables.html", encoding = "utf8") 
tabs <- html_table(content, fill = TRUE)
tab <- tabs[[1]]

# add names
names(tab) <- c("title", "country", "year", "status", "type", "target")
head(tab)
