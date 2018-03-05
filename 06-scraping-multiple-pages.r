### -----------------------------
## simon munzert
## web scraping
### -----------------------------


## load packages -----------------

library(rvest)
library(stringr)


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
delete_files <- list_files_path[files_size == 27131]
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


