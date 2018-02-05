### -----------------------------
## simon munzert
## regular expressions and
## string manipulation
### -----------------------------


source("packages.r")


## string basics -----------------

# to create strings, both single and double quotes work
string1 <- 'This is a string'
string2 <- 'If I want to include a "quote" inside a string, I use single quotes'

# to include a literal single or double quote in a string you can use \ to escape it:
double_quote <- "\"" # or '"'
single_quote <- '\'' # or "'"

# many special characters around, see
?"'"

# printed representation of a string shows the escapes
double_quote
writeLines(double_quote) # shows raw contents of the string
cat(double_quote)

# not very consistent when it comes to UTF-8 code points
x <- "\u00b5"
x
writeLines(x)

# inspect text
x <- c("apple", "banana", "pear")
str_view(x, "an")
str_view_all(x, "an")
str_view_all(x, "a")



## string matching ----------

# example
raw.data <- "555-1239Moe Szyslak(636) 555-0113Burns, C. Montgomery555-6542Rev. Timothy Lovejoy555 8904Ned Flanders636-555-3226Simpson, Homer5553642Dr. Julius Hibbert"

name <- unlist(str_extract_all(raw.data, "[[:alpha:]., ]{2,}"))
name

phone <- unlist(str_extract_all(raw.data, "\\(?(\\d{3})?\\)?(-| )?\\d{3}(-| )?\\d{4}"))
phone
data.frame(name = name, phone = phone)


# running example
example.obj <- "1. A small sentence. - 2. Another tiny sentence."

# self match
str_extract(example.obj, "small")
str_extract(example.obj, "banana")

# multiple matches
(out <- str_extract_all(c("text", "manipulation", "basics"), "a")) 

# case sensitivity
str_extract(example.obj, "small")
str_extract(example.obj, "SMALL")
str_extract(example.obj, ignore.case("SMALL")) # wrong
str_extract(example.obj, regex("SMALL", ignore_case = TRUE))

# match empty space
str_extract(example.obj, "mall sent")

# match the beginning of a string
str_extract(example.obj, "^1")
str_extract(example.obj, "^2")

# match the end of a string
str_extract(example.obj, "sentence$")
str_extract(example.obj, "sentence.$")

# pipe operator
unlist(str_extract_all(example.obj, "tiny|sentence"))

# wildcard
str_extract(example.obj, "sm.ll")

# character class
str_extract(example.obj, "sm[abc]ll")

# character class: range
str_extract(example.obj, "sm[a-p]ll")

# character class: additional characters
unlist(str_extract_all(example.obj, "[uvw. ]"))

# pre-defined character classes
unlist(str_extract_all(example.obj, "[:punct:]"))
unlist(str_extract_all(example.obj, "[[:punct:]ABC]"))
unlist(str_extract_all(example.obj, "[^[:alnum:]]"))
# for more character classes, see
?base::regex

# additional shortcuts
unlist(str_extract_all(example.obj, "\\w+"))

# word edges
unlist(str_extract_all(example.obj, "e\\b")) 
unlist(str_extract_all(example.obj, "e\\B"))

# quantifier
str_extract(example.obj, "s[[:alpha:]][[:alpha:]][[:alpha:]]l")
str_extract(example.obj, "s[[:alpha:]]{3}l")
str_extract(example.obj, "A.+sentence")

# greedy quantification
str_extract(example.obj, "A.+sentence")
str_extract(example.obj, "A.+?sentence")

# quantifier with pattern sequence
unlist(str_extract_all(example.obj, "(.en){1,5}"))
unlist(str_extract_all(example.obj, ".en{1,5}"))

# meta characters
unlist(str_extract_all(example.obj, "\\."))
unlist(str_extract_all(example.obj, fixed(".")))

# meta characters in character classes
unlist(str_extract_all(example.obj, "[1-2]"))
unlist(str_extract_all(example.obj, "[12-]"))

# backreferencing
str_extract(example.obj, "([[:alpha:]]).+?\\1")
str_extract(example.obj, "(\\b[a-z]+\\b).+?\\1")

# grouped matches
str_extract_all(example.obj, "([^ ]+) (sentence)")
str_match_all(example.obj, "([^ ]+) (sentence)")

# assertions
unlist(str_extract_all(example.obj, "(?<=2. ).+")) # positive lookbehind: (?<=...)
unlist(str_extract_all(example.obj, ".+(?=2)")) # positive lookahead (?=...)
unlist(str_extract_all(example.obj, "(?<!Blah )tiny.+")) # negative lookbehind: (?<!...)
unlist(str_extract_all(example.obj, "sentence.+(?!Bla)")) # negative lookahead (?!...)

# do you think you can master regular expressions now?
browseURL("http://stackoverflow.com/questions/201323/using-a-regular-expression-to-validate-an-email-address/201378#201378") # think again


# a note on the stringi package
# source: [https://goo.gl/XzEQai]

# stringr is built on top of the stringi package. 
# stringr is convenient because it exposes a minimal set of functions, which have been carefully picked to handle the most common string manipulation functions. 
# stringi is designed to be comprehensive. It contains almost every function you might ever need: stringi has 234 functions (compare that to stringr's 42)
# packages work very similarly; translating knowledge is easy (try stri_ instead of str_)
library(stringi)
?stri_count_words
example.obj
stri_count_words(example.obj)
stri_stats_latex(example.obj)
stri_stats_general(example.obj)
stri_escape_unicode("\u00b5")
stri_unescape_unicode("\u00b5")
stri_rand_lipsum(3)
stri_rand_shuffle("hello")
stri_rand_strings(100, 10, pattern = "[humboldt]")



######################
### IT'S YOUR SHOT ###
######################

## 1. describe the types of strings that conform to the following regular expressions and construct an example that is matched by the regular expression.
str_extract_all("Phone 150$, PC 690$", "[0-9]+\\$") # example
"\\b[a-z]{1,4}\\b"
".*?\\.txt$"
"\\d{2}/\\d{2}/\\d{4}"
"<(.+?)>.+?</\\1>"

## 2. consider the mail address  chunkylover53[at]aol[dot]com.
# a) transform the string to a standard mail format using regular expressions.
# b) imagine we are trying to extract the digits in the mail address using [:digit:]. explain why this fails and correct the expression.
email <- "chunkylover53[at]aol[dot]com"



## string manipulation ----------

example.obj

# locate
str_locate(example.obj, "tiny")

# substring extraction
str_sub(example.obj, start = 35, end = 38)

# replacement
str_sub(example.obj, 35, 38) <- "huge"
str_replace(example.obj, pattern = "huge", replacement = "giant")

# splitting
str_split(example.obj, "-") %>% unlist
str_split_fixed(example.obj, "[[:blank:]]", 5) %>% as.character()

# manipulate multiple elements; example
(char.vec <- c("this", "and this", "and that"))

# detection
str_detect(char.vec, "this")

# keep strings matching a pattern
str_subset(char.vec, "this") # wrapper around x[str_detect(x, pattern)]

# counting
str_count(char.vec, "this")
str_count(char.vec, "\\w+")
str_length(char.vec)

# duplication
str_dup(char.vec, 3)

# padding and trimming
length.char.vec <- str_length(char.vec)
char.vec <- str_pad(char.vec, width = max(length.char.vec), side = "both", pad = " ")
char.vec
str_trim(char.vec)

# joining
str_c("text", "manipulation", sep = " ")
str_c(char.vec, collapse = "\n") %>% cat
str_c("text", c("manipulation", "basics"), sep = " ")

# approximate matching
agrepl("Donald Trump", "Donald Drumpf", max.distance = list(all = 3))
agrepl("Donald Trump", "Barack Obama", max.distance = list(all = 3))



######################
### HOMEWORK       ###
######################

# ADCR, Chapter 8, Problems 2, 3, 7, 8, and 9
# submit via Moodle until 23.05.

