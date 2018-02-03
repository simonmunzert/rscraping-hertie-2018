### -----------------------------
### simon munzert
### social media data
### -----------------------------

## peparations -------------------

source("packages.r")
source("functions.r")

## getting live data from Twitter ---------------------------

# how to register at Twitter as developer, obtain and use access tokens
browseURL("https://mkearney.github.io/rtweet/articles/auth.html")

TwitterToR_twitterkey <- "uBoAsdknehdiosd8nkhk234aTIApT"  # <--- add your Twitter key here!
TwitterToR_twittersecret <- "myhHWkdjUhgaljsekh4ksfg8sK8tthJFl9fHJKLAnehkxi4nlYlQM" # <--- add your Twitter secret here!

save(TwitterToR_twitterkey,
     TwitterToR_twittersecret,
     file = paste0(normalizePath("~/"),"/rkeys.RDa")) # <--- this is where your keys are locally stored!

## name assigned to created app
appname <- "TwitterToR" # <--- add your Twitter App name here!

## api key (example below is not a real key)
load("/Users/munzerts/rkeys.RDa") # <--- adapt path here; see above!

## register app
twitter_token <- create_token(
  app = appname,
  consumer_key = TwitterToR_twitterkey,
  consumer_secret = TwitterToR_twittersecret)

## check if everything worked
rt <- search_tweets("merkel", n = 200, token = twitter_token)
View(rt)