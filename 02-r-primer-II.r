# ************************************************
### simon munzert
### introduction to R
# ************************************************

source("packages.r")


# ************************************************
# PIPING -----------------------------------------

# what is piping?
# structures sequences of data operations as "pipes, i.e. left-to-right (as opposed to from the inside and out)
# serves the natural way of reading ("do this, then this, then this, ...")
# avoids nested function calls
# improves "cognitive performance" of code writers and readers
# minimizes the need for local variables and function definitions
# why name "magrittr"?
browseURL("https://upload.wikimedia.org/wikipedia/en/b/b9/MagrittePipe.jpg")


# traditional way of writing code
dat <- babynames 
dim(dat)
dat_filtered <- filter(dat, name == "Kim")
dat_grouped <- group_by(dat_filtered, year, sex)
dat_sum <- summarize(dat_grouped, total = sum(n))
qplot(year, total, color = sex, data = dat_sum, geom = "line") +
  ggtitle('People named "Kim"')

# traditional, even more awkward way of writing code
dat <- summarize(group_by(filter(babynames, name == "Kim"), year, sex), total = sum(n))
qplot(year, total, color = sex, data = dat, geom = "line") +  ggtitle('People named "Kim"')

# magrittr style of piping code
babynames %>%
  filter(name %>% equals("Kim")) %>%  # check out ?extract2 for Aliases
  group_by(year, sex) %>%
  summarize(total = sum(n)) %>%
  qplot(year, total, color = sex, data = ., geom = "line") %>%
  add(ggtitle('People named "Kim"')) %>% # add() is an alias for "+"
  print

# syntax and vocabulary
# by default, the left-hand side (LHS) will be piped in as the first argument of the function appearing on the right-hand side (RHS)
# %>% may be used in a nested fashion, e.g. it may appear in expressions within arguments.
# when the LHS is needed at a position other than the first, one can use the dot,'.', as placeholder
# whenever only one argument is needed--the LHS--, the parentheses can be omitted



# ************************************************
# EXERCISE: PIPING ------------------------------

# 1. Rewrite the following bunch of code using magrittr pipes!

babynames1 <- mutate(babynames, name_short = substr(name, 1, 3))
babynames1$ste <- babynames1$name_short == "Ste"
babynames_ste <- filter(babynames1, ste == TRUE)
babynames_ste_grouped <- group_by(babynames_ste, year, sex)
babynames_ste_grouped <- summarize(babynames_ste_grouped, total = sum(n))
qplot(year, total, color = sex, data = babynames_ste_grouped, geom = "line") + ggtitle('Names starting with "Ste"')


# 2. Rewrite the following bunch of code using magrittr pipes!
arrange(select(filter(babynames, year == 2015, sex == "F"), name, n), desc(n))[1:10,]



# ************************************************
# DEALING WITH VECTORS -----------------------

# numeric vectors
x <- c(4,8,15,16,23,42)
x
length(x)
summary(x)

# character vectors
countries <- c("Germany", "France", "Netherlands", "Belgium")
countries
paste("Hello", "world!", sep = ", ")
paste0("Hello", "world!")
c(countries, "Poland")
mode(countries)

# logical vectors
x > 15
x == sqrt(225)

# logical and relational operators
# <,>,>=,<=,==,!=, is.na(), & (logical AND), | (logical OR), ! (logical NOT)

# missing values
y <- c(1,10,NA,7,NA,11)
sum(y)
sum(y, na.rm = TRUE)
!is.na(y) # not: y == NA
y*3

# seq and rep
seq(1, 10, 2)
seq_along(x)
rep(c(1, 2, 3), 3)
rep(c(1, 2, 3), each = 2)

# sorting
vec1 <- c(2, 20, -5, 1, 200)
sort(vec1) 
order(vec1, decreasing = FALSE)
vec1[order(vec1)]
vec3 <- c(1,10,NA,7,NA,11)
vec4 <- vec3[!is.na(vec3)]
vec4


# vectors with mixed element types are not possible
z <- c(1,2,"Bavaria", 4)
z
str(z)

# variables
zz <- c(1,2,Bavaria,4,5,6) # error
Bavaria <- 3
zz <- c(1,2,Bavaria,4,5,6)
zz
str(zz)

# transform vector type
zzchar <- as.character(zz)
zznum <- as.numeric(zzchar)

# combine vectors
xzz <- c(x,zz)

# subsetting
countries[2]
xzz[1:6] # xzz[seq(1,6)], xzz[c(1,2,3,4,5,6)]
xzz[c(2, 5, 10)]
xzz[-1]
xzz[Bavaria]
xzz[seq(0, 10, by = 2)]
xzz[c(TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE)]
y
y[is.na(y)]
y[!is.na(y)]
y[y>5 | is.na(y)]

countries
countries[3] <- "Switzerland"
countries

xzz
xzz[c(1, 3, 5)] <- c(100,110,120)
xzz_new <- xzz
xzz_new[xzz <= 100] <- 0
xzz_new[xzz > 100] <- 1
xzz_new


# ************************************************
# EXERCISE: VECTORS ------------------------------

# 1. Create a vector x with elements [0,4,8,12,16,20].

# 2. Create a vector y with elements [3,3,3,4,4,4,4,5,5,5,5,5].

# 3. Combine the first five elements of x with elements 2 to 12 of vector y to create a new vector z.

# 4. What's the sum of all numbers between 1 and 100?

# 5. What's the sum of all odd numbers between 1 and 100 squared?



# ************************************************
# LISTS ------------------------------------------

list1 <- list(vec1, vec2, babynames[1:5,])
list1
list1[[1]]
list1[[3]][,2]
names(list1)
names(list1) <- c("Vector1", "Vector2", "Data.Frame1")
list1$Vector1[1]




# ************************************************
# LOOPS AND SPLIT-APPLY-COMBINE ------------------

# Looping patters for a for loop:
  # loop over elements: for (x in xs)
  # loop over numeric indices: for (i in seq_along(xs))
  # loop over the names: for (nm in names())
song <- character()
for(i in 1:length(LETTERS)) {
  song[i] <- paste0("Verse ", i, ": If you're happy and you know it, shout out ", LETTERS[i], "!")
}
song

# To apply a function over a list or vector, a set of other useful functions exists
apply()
lapply()
sapply()

# Workflow:
  # 1. take input (list, data frame, array)
  # 2. split it (e.g., data frame into columns)
  # 3. apply function to the single parts
  # 4. combine it into new object
# often more efficient than a for loop

# apply(): operating on matrices and arrays
(a <- matrix(1:20, nrow = 5))
apply(a, 1, mean)
apply(a, 2, mean)

head(mtcars)
select(mtcars, gear, carb) %>% apply(1, mean)

# lapply(): applying a function over a list or vector; returning a list
# sapply(): applying a function over a list or vector; similar to lapply() but simplifies output to produce an atomic vector

lapply(mtcars, is.numeric) %>% unlist
sapply(mtcars, is.numeric)




# ************************************************
# FILE MANAGEMENT --------------------------------

# interacting with the file system can be very useful to keep your research reproducible
# example tasks:
  # fully implement a workflow based on relative, not absolute paths
  # create a rigid folder structure
  # download files in a specific folder
  # check whether file exists
  # remove temporarily stored files


## functions for folder management ---------
(current_folder <- getwd())
dir.create("data")
dir.create("data/r-data")

# get all pre-compiled data sets
dat <- as.data.frame(data(package = "datasets")$results)
head(dat)
dat$Item %<>% str_replace(" \\(.+\\)", "")

# store data sets in local folder
for (i in 1:50) {
  try(df_out <- dat$Item[i] %>% as.character %>% get)
  save(df_out, file = paste0("data/r-data/", dat$Item[i], ".RData"))
}

# inspect folder
dir("data/r-data")
filenames <- dir("data/r-data", full.names = TRUE)
dir("data/r-data", pattern = "US")
dir("data/r-data", pattern = "US", ignore.case = TRUE)

# check if folder exists
dir.exists("data")


## functions for file management --------
?files

# get basename (= returns the lowest level in a path)
filenames
basename(filenames)
url <- "http://www.mzes.uni-mannheim.de/d7/en/news/media-coverage/ist-die-wahlforschung-in-der-krise-der-undurchschaubare-buerger"
basename(url)

# get dirname (returns all but the lower level in a path)
dirname(url)

# get file information
file_inf <- file.info(dir(recursive = F))
?file.info
file_inf[difftime(Sys.time(), file_inf[,"mtime"], units = "days") < 7 , 1:4]

# identify file extension
tools::file_ext(filenames)

# check if file exists
file.exists(filenames)
file.exists("voterfile.RData")

# rename file
filenames_lower <- tolower(filenames)
file.rename(filenames, filenames_lower)

# remove file
file.remove(filenames_lower[1])

# copy file
file.copy(filenames_lower[2], to = "copy.rdata")
file.remove("copy.rdata")




# ************************************************
# FUNCTIONS --------------------------------------

# function that returns the mean of a vector
my_mean <- function(my_vector) {
  mean <- sum(my_vector)/length(my_vector) 
  mean
}
my_mean(c(1, 2, 3))
my_mean
my_mean(babynames)

# another function that finds the remainder after division ("modulo operation)"
remainder <- function(num = 10, divisor = 4) {
  remain <- num %% divisor
  remain
}
remainder()


# implement conditions
has_name <- function(x) {
  nms <- names(x)
  if (is.null(nms)) {
    rep(FALSE, length(x))
  } else {
    !is.na(nms) & nms != ""
  }
}
has_name(c(1, 2, 3))
has_name(mtcars)


# using anonymous functions
sapply(mtcars, function(x) length(unique(x)))



# When to use functions: example -------------

# generate a sample dataset 
set.seed(1014) 
df <- data.frame(replicate(6, sample(c(1:5, -99), 6, rep = TRUE))) 
names(df) <- letters[1:6] 
df

# how to replace -99 with NA?
df$a[df$a == -99] <- NA
df$b[df$b == -99] <- NA
df$c[df$c == -98] <- NA
df$d[df$d == -99] <- NA
df$e[df$e == -99] <- NA
df$f[df$g == -99] <- NA

# build function
missing_fixer <- function(x, na.value) { 
  x[x == na.value] <- NA
  x
}

# lapply is called a "functional" because it takes a function as an argument
df[] <- lapply(df, missing_fixer, na.value = -99) # littler trick to make sure we get back a data frame, not a list

# easy to generalize to a subset of columns
df[1:3] <- lapply(df[1:3], missing_fixer, na.value = -99)
df


