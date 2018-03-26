### -----------------------------------------
### R practice session
### Simon Munzert
### -----------------------------------------


# load packages
library(stringr)
library(rvest)
library(maps)


### regular expressions --------------------

# 1. Refining "Blowin' In The Wind" 

# In the following you see the lyrics of Bob Dylan's "Blowin' In The Wind".
# a) Replace all words "man" and "friend" with "dog"!
# b) Extract all upper letters and collapse them into one vector!
# c) Replace all words with five or more letters with "blah"!
# d) Extract the first and the last word of each verse!

song <- c(
  "How many roads must a man walk down
  Before you call him a man?
  Yes, ’n’ how many seas must a white dove sail
  Before she sleeps in the sand?
  Yes, ’n’ how many times must the cannonballs fly
  Before they’re forever banned?
  The answer, my friend, is blowin’ in the wind
  The answer is blowin’ in the wind
  
  How many years can a mountain exist
  Before it’s washed to the sea?
  Yes, ’n’ how many years can some people exist
  Before they’re allowed to be free?
  Yes, ’n’ how many times can a man turn his head
  Pretending he just doesn’t see?
  The answer, my friend, is blowin’ in the wind
  The answer is blowin’ in the wind
  
  How many times must a man look up
  Before he can see the sky?
  Yes, ’n’ how many ears must one man have
  Before he can hear people cry?
  Yes, ’n’ how many deaths will it take till he knows
  That too many people have died?
  The answer, my friend, is blowin’ in the wind
  The answer is blowin’ in the wind")

str_replace_all(song, pattern = "\\bman\\b|\\bfriend\\b", replacement = "dog") %>% cat()
str_c(unlist(str_extract_all(song, "[[:upper:]]")), collapse="")
str_replace_all(song, "\\b[:alpha:]{5,}\\b", "blah")

verses <- str_split(song, "\\n", simplify = TRUE) %>% str_trim()
str_extract_all(verses, "^[:alpha:]+|[:alpha:]+.$")



### regex case study --------------------

# Mapping World Heritage in Danger

# get table
url <- "https://en.wikipedia.org/wiki/List_of_World_Heritage_in_Danger"
url_parsed <- read_html(url)
tables <- html_table(url_parsed, fill = TRUE) 
danger_table <- tables[[2]]

# select and rename columns
danger_table <- danger_table[,c(1,3,6,7)]
colnames(danger_table) <- c("name","locn","yins","yend")

# cleanse years
danger_table$yend
yend_clean <- unlist(str_extract_all(danger_table$yend, "^[[:digit:]]{4}"))
danger_table$yend <- as.numeric(yend_clean)

# get countries
danger_table$locn[1:5]
country <- str_extract(danger_table$locn, "[[:alpha:] ]+(?=[[:digit:]])")
country
danger_table$country <- country

# get coordinates
danger_table$locn[1:5]
reg_y <- "[/][ -]*[[:digit:]]*[.]*[[:digit:]]*[;]"
reg_x <- "[;][ -]*[[:digit:]]*[.]*[[:digit:]]*"
y_coords <- str_extract(danger_table$locn, reg_y) %>% str_sub(3, -2) %>% as.numeric()
danger_table$y_coords <- y_coords
x_coords <- str_extract(danger_table$locn, reg_x) %>% str_sub(3, -1) %>% as.numeric()
danger_table$x_coords <- x_coords
danger_table$locn <- NULL

# plot endangered heritage sites
pdf(file="heritage-map.pdf", height=3.3, width=7, family="URWTimes")
par(oma=c(0,0,0,0))
par(mar=c(0,0,0,0))
map("world", col = "darkgrey", lwd = .5, mar = c(0.1,0.1,0.1,0.1))
points(danger_table$x_coords, danger_table$y_coords, pch = 19, col = "black", cex = .8)
box()
dev.off()




## split-apply-combine -----------------------

# lapply(): applying a function over a list or vector; returning a list
# sapply() and vapply(): applying a function over a list or vector; returning a vector
# sapply() and vapply() are similar to lapply() but simplify their output to produce an atomic vector
# sapply() guesses, vapply() takes an additional argument specifying the output type

# 1. Below is a function that scales a vector so it falls in the range [0,1]. How would you apply it to every column of a data frame? How would you apply it to every numeric column of a data frame? Try to come up with solutions using both base R and plyr functions. Use the data.frames mtcars and iris as examples.
scale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1]) 
}
vec <- runif(10, 0, 10)
scale01(vec)


df <- mtcars
df[] <- lapply(df, scale01) # or:
df <- lapply(df, scale01) %>% as.data.frame

df <- iris
df_num <- sapply(df, is.numeric)
df[df_num] <- lapply(df[df_num], scale01) 


# 2. multiple inputs: Map()

# with lapply(), only one argument varies, the others are fixed
# sometimes, you want more arguments to vary
# here, Map() comes into play

# example: computation of mean vs. weighted mean
xs <- replicate(5, runif(10), simplify = FALSE)
ws <- replicate(5, rpois(10, 5) + 1, simplify = FALSE)

vapply(xs, mean, numeric(1))
Map(weighted.mean, xs, ws) %>% unlist

# if some of the arguments should be fixed and constant, use an anomymous function:
Map(function(x, w) weighted.mean(x, w, na.rm = TRUE), xs, ws)

# example: download HTML articles
rel_links <- read_html("https://en.wikipedia.org/wiki/Fourth_Merkel_cabinet") %>% html_nodes(xpath = "//table/tr/td[4]/a") %>% html_attr("href")
rel_links

folder <- "data/merkelcabinet/"
dir.create(folder)
urls <- paste0("https://en.wikipedia.org", rel_links)
names <- paste0(basename(urls), ".html")
pathnames <- paste0(folder, names)
Map(download.file, urls, pathnames)







## case study:  -----------------------

# fetch list of AJPS reviewers from PDFs
# locate them on a map


## tasks ------------------------

# downloading PDF files
# importing them into R (as plain text)
# extract information via regex
# geocoding


## directory ---------------------

wd <- ("./data/ajpsReviewers")
dir.create(wd)
setwd(wd)


## code ---------------------

## step 1: inspect page
url <- "http://ajps.org/list-of-reviewers/"
browseURL(url)


## step 2: retrieve pdfs
# get page
content <- read_html(url)
# get anchor (<a href=...>) nodes via xpath
anchors <- html_nodes(content, xpath = "//a")
# get value of anchors' href attribute
hrefs <- html_attr(anchors, "href")

# filter links to pdfs
pdfs <- hrefs[ str_detect(basename(hrefs), ".*\\d{4}.*pdf") ]
pdfs

# define names for pdfs on disk
pdf_names <- str_extract(basename(pdfs), "\\d{4}") %>% paste0("reviewers", ., ".pdf")
pdf_names

# download pdfs
for(i in seq_along(pdfs)) {
  download.file(pdfs[i], pdf_names[i], mode="wb")
}


## step 3: import pdf
rev_raw <- pdf_text("reviewers2015.pdf")
class(rev_raw)
rev_raw[1]


## step 4: tidy data

rev_all <- rev_raw %>% str_split("\\n") %>% unlist 
surname <- str_extract(rev_all, "[[:alpha:]-]+")
prename <- str_extract(rev_all, " [.[:alpha:]]+")
rev_df <- data.frame(raw = rev_all, surname = surname, prename = prename, stringsAsFactors = F)
rev_df$institution <- NA
for(i in 1:nrow(rev_df)) {
  rev_df$institution[i] <- rev_df$raw[i] %>% str_replace(rev_df$surname[i], "") %>% str_replace(rev_df$prename[i], "") %>% str_trim()
}
rev_df <- rev_df[-c(1,2),]
rev_df <- rev_df[!is.na(rev_df$surname),]
head(rev_df)



## step 5: geocode reviewers/institutions
# geocoding takes a while -> save results
# 2500 requests allowed per day
pos <- data.frame(lon = NA, lat = NA)
unique_institutions <- unique(rev_df$institution)
unique_institutions <- unique_institutions[!is.na(unique_institutions)]
if (!file.exists("institutions2015_geo.RData")){
  for (i in 1:length(unique_institutions)) {
    pos[i,] <- geocode(unique_institutions[i], source = "google", force = "FALSE")
  }
  pos$institution <- unique_institutions
  save(pos, file="institutions2015_geo.RData")
} else {
  load("institutions2015_geo.RData")
}
head(pos)

rev_geo <- merge(rev_df, pos, by = "institution", all = T)


## step 6: plot reviewers, worldwide
mapWorld <- borders("world")
map <-
  ggplot() +
  mapWorld +
  geom_point(aes(x=rev_geo$lon, y=rev_geo$lat) ,
             color="#F54B1A90", size=1,
             na.rm=T) +
  theme_bw() +
  coord_map(xlim=c(-180, 180), ylim=c(-70,80))
map


## step 7: plot reviewers, Italy
mapItaly <- get_map(location = 'Italy', zoom = 6)
map <-
  ggmap(mapItaly) +
  geom_point(data = rev_geo, aes(x= lon, y = lat) ,
             color="#F54B1A90", size = 1,
             na.rm=T)
map
