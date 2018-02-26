### -----------------------------
## simon munzert
## web scraping
### -----------------------------


## load packages -----------------

library(rvest)
library(stringr)



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




