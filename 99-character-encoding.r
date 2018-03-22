### -----------------------------------------------------
### On character encoding in R
### Simon Munzert
### -----------------------------------------------------


# load packages
library(stringr)
library(rvest)


# background reading ---------

# some background on character encoding in general
browseURL("https://en.wikipedia.org/wiki/Character_encoding")

# some background on how RStudio handles character encoding
browseURL("https://support.rstudio.com/hc/en-us/articles/200532197-Character-Encoding")

# tutorial on how to deal with encodings in R (some of the code borrowed below)
browseURL("https://rstudio-pubs-static.s3.amazonaws.com/279354_f552c4c41852439f910ad620763960b6.html")



# how to query your locale and (maybe) change it ---------

# query your current locale
Sys.getlocale()

# query your locale for individual categories
localeCategories <- c("LC_COLLATE","LC_CTYPE","LC_MONETARY","LC_NUMERIC","LC_TIME")
setNames(sapply(localeCategories, Sys.getlocale), localeCategories)

# set your locale
Sys.setlocale("LC_ALL", 'en_US.UTF-8') # Mac users: this could help if Sys.getlocale() returns something else, for instance, "C"
Sys.setlocale(category = "LC_ALL", locale = "English_United States.1252") # Windows users: alternative
Sys.setlocale("LC_TIME", "German") # Windows users on a German locale

# alternatively, retrieve the language of your OS first, then set locale
(LANG <- Sys.getenv("LANG"))
if(nchar(LANG)) Sys.setlocale("LC_ALL", LANG)



# how to declare or convert encodings ---------

# sample from the list of available conversions
(encodings <- length(iconvlist()))
sample(iconvlist(), 10)

# an example string
small.frogs <- "Små grodorna, små grodorna är lustiga att se."
small.frogs

# check encoding
Encoding(small.frogs)

# declare (wrong) encoding - what happens?
Encoding(small.frogs) <- "latin1"
small.frogs

# declare (right) encoding again
Encoding(small.frogs) <- "utf8"
small.frogs # in this case, we could restore the original string

# more on reading or setting encodings for a character vector in R
?Encoding

# translate the encoding
small.frogs.latin1 <- iconv(small.frogs, from = "utf8", to = "latin1")
Encoding(small.frogs.latin1)

