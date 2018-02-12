# ************************************************
### simon munzert
### introduction to R
# ************************************************

source("packages.r")


# ************************************************
# WHAT'S R? --------------------------------------

# - software environment for numeric and visual data analysis
# - statistical programming language based on S
# - open source
# - works on all main platforms (Windows, macOS, Linux)
# - under continuous development
# - masses of addons ('packages') available, ~4-8 new ones every day (currently more than 10,000 on CRAN)


# ************************************************
# BE PATIENT WITH R, AND WITH YOURSELF -----------

# (from http://socviz.co/gettingstarted.html#things-to-know-about-r)

# Like all programming languages, R does exactly what you tell it to, rather than exactly what you want it to. 
# This can make it frustrating to work with. It is as if one had an endlessly energetic, powerful, but also extremely literal-minded robot to order around. 
# No-one writes fluent, error-free code on the first go all the time. From simple typos to big misunderstandings, mistakes are a standard part of the activity of programming. 
# This is why error-checking, debugging, and testing are also a central part of programming. 
# So, just try to be patient with yourself and with R while you use it. Expect to make errors, and don’t worry when that happens. 
# You won’t break anything. Each time you figure out why a bit of code has gone wrong you will have learned a new thing about how the language works.



# ************************************************
# WORKING WITH RSTUDIO ---------------------------

### a first view
# - point-and-click menu
# - many windows, many buttons

### console input

# - R is ready when the console offers '>'
# - input is incomplete if R answers with '+' (you are likely to have forgotten a ')' or ']')
1 + 2 - 
  
# - R is 'case sensitve'
sum(1,2)
Sum(1,2)

# - the assignment operator '<-' stores something in the workspace. You can call this something again later. We can also  use '=' instead, but it is less common among R users and I do not recommend it
x <- log(10)
x

# - R uses English vocabulary, therefore we have to follow the English default in using commas and dots:
3.1415
3,1415

# - commas are very important when it comes to matrices and data frames: they separate row from column values
mat <- matrix(c("this", "is", "a", "matrix"), nrow = 2, byrow = TRUE)
mat[1,2]
mat[1,]
mat[,1]

# - we use # to comment in the code
# - the RStudio editor provides auto completion (use 'TAB')
# - very useful: recycle previous commands by using the arrow keys (up/down) in the console

# ## list of helpful shortcuts (replace CTRL with Command on a Mac)
# CTRL+1         point cursor in editor
# CTRL+2         point cursor in console
# ESC            interrupt R
# CTRL+F         search and replace
# CTRL+SHIFT+C   comment code (and undo commenting)
# CTRL+ENTER     execute code
# CTRL+S         save document


# ************************************************
# IMPORTING PACKAGES -----------------------------

# - in contrast to Stata, base R has a rather limited functionality
# - when we start R, we usually have to load a bunch of packages for our analysis

# overview of packages: 
browseURL("http://cran.r-project.org/web/packages/")

# - packages are installed once (usually after downloading them from CRAN)
# - installing packages in RStudio is straightforward
# - updating packages is straightforward, too
# - we can also use the console to install packages
install.packages("readr")

# packages are loaded for every session
library(readr)

# how to get more info about package? 
# - browse CRAN online!
browseURL("https://cran.rstudio.com/web/packages/readr/index.html")
# - inspect reference manual (often overly technical) or vignette (if available)

# how to learn about individual functions?
?read_csv


# ************************************************
# IMPORTING AND EXPORTING DATA -------------------

# importing rectangular spreadsheet data
library(readr)

# import and export comma-delimited files
wage1 <- read_csv("../data/wage1.csv")
names(wage1)
View(wage1)
write_csv(wage1, "../data/wage1-comma.csv")

# import and export semi-colon delimited files (Germans!)
write_delim(wage1, delim = ";", path = "../data/wage1-semicolon.csv")
wage1 <- read_csv2("../data/wage1-semicolon.csv")

# importing Stata files
library(haven)
wage1 <- read_dta("../data/wage1.dta")
head(wage1)


# ************************************************
# INSPECTING DATA --------------------------------

library(wooldridge)

# what's the data about? (works for packaged data frames only)
?wage1

View(wage1)

# summarize variables
summary(wage1)
summary(wage1$wage)

# simple histogram
hist(wage1$wage)

# simple bar chart
plot(as.factor(wage1$educ))

# simple scatterplot
plot(wage1$educ, wage1$wage)

# add smoothing spline
smoothingSpline = smooth.spline(wage1$educ, wage1$wage, spar = 0.3)
lines(smoothingSpline, col = "red")

# multidimensional inspection
plot(wage1[,1:5])

# linear regression
model_out <- lm(wage ~ educ + female, data = wage1)
summary(model_out)


# ************************************************
# MANIPULATING DATA FRAMES -----------------------

library(dplyr)

# dplyr provides an intuitive grammar of data manipulation
# - identifies the most important data manipulation tasks 
# - ...and makes them easy to use from R
# - important dplyr verbs:
    # select()    select columns
    # filter()    filter rows
    # arrange()   re-order or arrange rows
    # mutate()    create new columns
    # summarise() summarise values
    # group_by()  allows for group operations


### let's try it out with an interesting dataset!
library(nycflights13)
?flights
View(flights)
head(flights)
nrow(flights)
table(flights$origin)

# filter observations
flights_sub <- filter(flights, distance < 100)
table(flights_sub$dest)

flights_sub <- filter(flights, month == 1, day == 1, air_time > 60*7)
table(flights_sub$dest)
View(flights_sub)

# arrange rows (= sort by variable values)
flights_sub <- arrange(flights, air_time, distance) 
View(flights_sub)

flights_sub <- arrange(flights, desc(air_time), distance) 
View(flights_sub)

# select variables
flights_sub <-  select(flights, year, month, day) 
head(flights_sub)

names(flights)
flights_sub <-  select(flights, -(dep_delay:time_hour)) 
head(flights_sub)

flights_sub <-select(flights, contains("time"))
head(flights_sub)

?select_helpers

# rename variables
flights_sub <- rename(flights, tail_num = tailnum)
names(flights_sub)

# create variables (add new columns)
flights_sub <- mutate(flights, loss = arr_delay - dep_delay, 
                               speed = distance / air_time * 60)

# group observations
  # - verbs above are useful on their own, but...
  # - can be applied to groups of observations within a dataset
  # - group_by() helps you break down your dataset into specified groups of rows
  # - afterwards, applying verbs from above on the grouped object, they'll be automatically applied by group

flights_by_origin <- group_by(flights, origin)
class(flights_by_origin)

summarize(flights_by_origin, n_deps = n())
summarize(flights_by_origin, dep_delay = mean(dep_delay, na.rm = TRUE))

# here's a useful cheatsheet that points to other useful dplyr functions:
browseURL("hhttps://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf")






