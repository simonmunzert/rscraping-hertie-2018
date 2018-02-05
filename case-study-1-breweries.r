### -----------------------------------------------
### Case Study: Mapping Breweries in Germany
### Simon Munzert
### -----------------------------------------------


##  goal

# 1. get list of breweries in Germany
# 2. import list in R
# 3. geolocate breweries
# 4. put them on a map


## load packages

library(rvest)
library(stringr)
library(ggmap)


## step 1: fetch list of cities with breweries

url <- "http://www.biermap24.de/brauereiliste.php"
browseURL(url)
content <- read_html(url)
anchors <- html_nodes(content, xpath = "//tr/td[2]")
cities <- html_text(anchors)
cities
cities <- str_trim(cities)
cities <- cities[str_detect(cities, "^[[:upper:]]+.")]
length(cities)
length(unique(cities))
sort(table(cities), decreasing = TRUE)[1:10]


## step 2: geocode cities

# geocoding takes a while -> save results in local cache file
# 2500 requests allowed per day
if (!file.exists("data/breweriesGermany/breweries_geo.RData")){
  pos <- geocode(unique(cities))
  geocodeQueryCheck()
  save(pos, file="data/breweriesGermany/breweries_geo.RData")
} else {
  load("data/breweriesGermany/breweries_geo.RData")
}
head(pos)


## step 3: plot breweries of Germany
brewery_map <- get_map(location=c(lon = mean(c(min(pos$lon), max(pos$lon))), lat = mean(c(min(pos$lat), max(pos$lat)))), zoom=6, maptype="hybrid")
p <- ggmap(brewery_map) + geom_point(data=pos, aes(x=lon, y=lat), col="red", size=.8)
p






