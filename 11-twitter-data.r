### -----------------------------
### simon munzert
### social media data
### -----------------------------

## peparations -------------------

source("packages.r")
library(rtweet)


## mining Twitter with R ----------------

## about the Twitter APIs

  # two APIs types of interest:
  # REST APIs --> reading/writing/following/etc., "Twitter remote control"
browseURL("https://dev.twitter.com/rest/public/search")
  # "The Twitter Search API searches against a sampling of recent Tweets published in the past 7 days."
  # Streaming APIs --> low latency access to 1% of global stream - public, user and site streams
browseURL("https://dev.twitter.com/streaming/overview")
browseURL("https://dev.twitter.com/streaming/overview/request-parameters")

## R packages that connect to Twitter API

  # twitteR: connects to REST API; weird design decisions regarding data format
  # streamR: connects to Streaming API; works very reliably, connection setup a bit difficult
  # rtweet: connects to both REST and Streaming API, nice data formats, still under active development


## authentication with rtweet ----------------
  
## how to get started

# 1. register as a developer at https://dev.twitter.com/ - it's free
# 2. create a new app at https://apps.twitter.com/ - choose a random name
# 3. go to "Keys and Access Tokens" and keep the displayed information ready

# again: how to register at Twitter as developer, obtain and use access tokens
browseURL("https://mkearney.github.io/rtweet/articles/auth.html")

## name assigned to created app
appname <- "TwitterToR" # <--- add your Twitter App name here!

## api key (example below is not a real key)
load("/Users/simonmunzert/rkeys.RDa") # <--- adapt path here; see above!

## register app
twitter_token <- create_token(
  app = appname,
  consumer_key = TwitterToR_twitterkey,
  consumer_secret = TwitterToR_twittersecret,
  set_renv = TRUE) # set to false if authentication does not work properly


## search Tweets with the rtweet package --------------

# some advice for search:
browseURL("https://developer.twitter.com/en/docs/tweets/search/guides/standard-operators")


merkel <- search_tweets("merkel", n = 1000, include_rts = FALSE, lang = "de")

storch_bad <- search_tweets(URLencode("storch :("), n = 100, include_rts = FALSE, lang = "de", token = twitter_token)
storch_good <- search_tweets(URLencode("storch :)"), n = 100, include_rts = FALSE, lang = "de", token = twitter_token)
storch_images <- search_tweets(URLencode("storch filter:images"), n = 100, include_rts = FALSE, lang = "de", token = twitter_token)

names(merkel)
View(storch_images)

## plot time series of tweets frequency
ts_plot(merkel, by = "hours", theme = "spacegray", main = "Tweets about Merkel")


# check rate limits
rate_limits(token = twitter_token) %>% View()


## streaming Tweets with the rtweet package -----------------

# set keywords used to filter tweets
q <- paste0("merkel,trump,macron")

# parse directly into data frame
twitter_stream <- stream_tweets(q = q, timeout = 30, token = twitter_token)

# set up directory and JSON dump
rtweet.folder <- "data/rtweet-data"
dir.create(rtweet.folder)
streamname <- "politicians"
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
              timeout = 30,
              file_name = filename,
              #language = "de",
              token = twitter_token)

# parse from json file
rt <- parse_stream(filename)

# inspect tweets data
names(rt)
head(rt)

# inspect users data
users_data(rt) %>% head()
users_data(rt) %>% names()


## mining twitter accounts with the rtweet package ------

user_df <- lookup_users("RDataCollection")
names(user_df)
user_timeline_df <- get_timeline("RDataCollection")
names(user_timeline_df)
user_favorites_df <- get_favorites("RDataCollection")
names(user_favorites_df)


## discover followers/friends of course participants ------------------

user_id <- lookup_users("simonsaysnothin")$user_id
followers <- get_followers("simonsaysnothin")
friends <- get_friends("simonsaysnothin")

twitter_names <- c("AnaKubli", "annapellegatta", "caromatamoros", "cusimanof",
                   "dgohla", "jonvrushi", "luciacizmaziova", "nadinaiacob",
                   "PresRamirez", "RubenZoest", "simonsaysnothin", "sjash87",
                   "donata64", "RummelJa", "bernstmeng")

# retrieve user ids, followers, friends
user_id_list <- list()
user_followers <- list()
user_friends <- list()
for (i in seq_along(twitter_names)) {
  user_id_list[[i]] <- lookup_users(twitter_names[i])$user_id
  user_followers[[i]] <- get_followers(twitter_names[i])
  user_friends[[i]] <- get_friends(twitter_names[i])
}

# user id df
user_id_df <- data.frame(name = twitter_names, user_id = unlist(user_id_list), stringsAsFactors = FALSE)

# user friends df
user_friends_df <- do.call(rbind.fill, user_friends[1:14])
names(user_friends_df) <- c("name", "friend_id")
user_friends_df <- merge(user_friends_df, user_id_df, by = "name", all.x = TRUE)

# user followers df
user_followers_list <- list()
for(i in 1:14) {
  user_followers_list[[i]] <- data.frame(name = twitter_names[i], user_followers = user_followers[[i]]$user_id, stringsAsFactors = FALSE)
}
user_followers_df <- do.call(rbind.fill, user_followers_list)
names(user_followers_df) <- c("name", "follower_id")
user_followers_df <- merge(user_followers_df, user_id_df, by = "name", all.x = TRUE)

table(user_friends_df$friend_id) %>% sort(decreasing = T) %>% .[1:10] %>% names
lookup_users("252087644")$name
lookup_users("813286")$name
lookup_users("127908397")$name
lookup_users("5988062")$name
lookup_users("14677919")$name
lookup_users("4111954900")$name
lookup_users("807095")$name



## what else to do with twitter (and facebook) data? ------------------

# sooo much. for some inspiration, check out
browseURL("http://pablobarbera.com/big-data-upf/")



