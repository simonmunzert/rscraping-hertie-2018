### -----------------------------
### simon munzert
### social media data
### -----------------------------

## peparations -------------------

source("packages.r")



## mining Twitter with R ----------------

## about the Twitter APIs

  # two APIs types of interest:
  # REST APIs --> reading/writing/following/etc., "Twitter remote control"
browseURL("https://dev.twitter.com/rest/public/search")
  # "The Twitter Search API searches against a sampling of recent Tweets published in the past 7 days."
  # Streaming APIs --> low latency access to 1% of global stream - public, user and site streams
browseURL("https://dev.twitter.com/streaming/overview")
browseURL("https://dev.twitter.com/streaming/overview/request-parameters")

## how to get started

  # 1. register as a developer at https://dev.twitter.com/ - it's free
  # 2. create a new app at https://apps.twitter.com/ - choose a random name
  # 3. go to "Keys and Access Tokens" and keep the displayed information ready
  
  # again: how to register at Twitter as developer, obtain and use access tokens
  browseURL("https://mkearney.github.io/rtweet/articles/auth.html")

## R packages that connect to Twitter API

  # twitteR: connects to REST API; weird design decisions regarding data format
  # streamR: connects to Streaming API; works very reliably, connection setup a bit difficult
  # rtweet: connects to both REST and Streaming API, nice data formats, still under active development


library(rtweet)
## name assigned to created app
appname <- "TwitterToR"
## api key (example below is not a real key)
load("/Users/munzerts/rkeys.RDa")
key <- TwitterToR_twitterkey
## api secret (example below is not a real key)
secret <- TwitterToR_twittersecret
twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret)

rt <- search_tweets("merkel", n = 1000, include_rts = TRUE, lang = "de", token = twitter_token)
tauber_bad <- search_tweets(URLencode("tauber :("), n = 100, include_rts = FALSE, lang = "de", token = twitter_token)
tauber_good <- search_tweets(URLencode("tauber :)"), n = 100, include_rts = FALSE, lang = "de", token = twitter_token)
tauber_good <- search_tweets(URLencode("tauber filter:images"), n = 100, include_rts = FALSE, lang = "de", token = twitter_token)

names(rt)
View(rt)

## plot time series of tweets frequency
ts_plot(rt, by = "hours", theme = "spacegray", main = "Tweets about Merkel")



## streaming Tweets with the rtweet package -----------------

# set keywords used to filter tweets
q <- paste0("clinton,trump,hillaryclinton,imwithher,realdonaldtrump,maga,electionday")
q <- paste0("schulz,merkel,btw17,btw2017")

# parse directly into data frame
twitter_stream_ger <- stream_tweets(q = q, timeout = 30, token = twitter_token)

# set up directory and JSON dump
rtweet.folder <- "data/rtweet-data"
dir.create(rtweet.folder)
streamname <- "btw17"
filename <- file.path(rtweet.folder, paste0(streamname, "_", format(Sys.time(), "%F-%H-%M-%S"), ".json"))

# create file with stream's meta data
streamtime <- format(Sys.time(), "%F-%H-%M-%S")
metadata <- paste0(
  "q = ", q, "\n",
  "streamtime = ", streamtime, "\n",
  "filename = ", filename)
metafile <- gsub(".json$", ".txt", filename)
cat(metadata, file = metafile)

# sink stream into JSON file
stream_tweets(q = q, parse = FALSE,
              timeout = 3600,
              file_name = filename,
              language = "de",
              token = twitter_token)

# parse from json file
rt <- parse_stream(filename)

# inspect tweets data
names(rt)
head(rt)

# inspect users data
users_data(rt) %>% head()
users_data(rt) %>% names()


## mining tweets with the rtweet package ------

rt <- parse_stream("data/rtweet-data/btw17_2017-07-03-13-02-52.json")
merkel <- str_detect(rt$text, regex("merkel", ignore_case = TRUE))
schulz <- str_detect(rt$text, regex("schulz", ignore_case = TRUE))
mentions_df <- data.frame(merkel,schulz)
colMeans(mentions_df, na.rm = TRUE)


## mining twitter accounts with the rtweet package ------

user_df <- lookup_users("RDataCollection")
names(user_df)
user_timeline_df <- get_timeline("RDataCollection")
names(user_timeline_df)
user_favorites_df <- get_favorites("RDataCollection")
names(user_favorites_df)



## what else to do with twitter data? ------------------

# sooo much. for some inspiration, check out
browseURL("http://pablobarbera.com/big-data-upf/")

