### -----------------------------
## simon munzert
## web scraping
### -----------------------------

## load packages -----------------
library(rvest)


## parse HTML --------------------

# parse with read_html
parsed_doc <- read_html("https://google.com") 
parsed_doc

# inspect parsed object
class(parsed_doc)
html_structure(parsed_doc)
as_list(parsed_doc)


## basic XPath grammar -----------------

# import running example
parsed_doc <- read_html("http://www.r-datacollection.com/materials/ch-4-xpath/fortunes/fortunes.html") 
parsed_doc

# absolute paths
html_nodes(parsed_doc, xpath = "/html/body/div/p/i")

# relative paths
html_nodes(parsed_doc, xpath = "//body//p/i")
html_nodes(parsed_doc, xpath = "//p/i")
html_nodes(parsed_doc, xpath = "//i")

# wildcard (for ONE node)
html_nodes(parsed_doc, xpath = "/html/body/div/*/i")
html_nodes(parsed_doc, xpath = "/html/body/*/i") # does not work

# navigational operators
html_nodes(parsed_doc, xpath = "//title/..")

# pipe operator
html_nodes(parsed_doc, xpath = "//address | //title")


## expressing node relationships in XPath ------------

# ancestor
html_nodes(parsed_doc, xpath = "//a/ancestor::div")
html_nodes(parsed_doc, xpath = "//a/ancestor::div//i")

# sibling
html_nodes(parsed_doc, xpath = "//p/preceding-sibling::h1")

# Parent
html_nodes(parsed_doc, xpath = "//title/parent::*")


## predicates in XPath ------------------------

# numeric
html_nodes(parsed_doc, xpath = "//div/p[position()=1]")
html_nodes(parsed_doc, xpath =  "//div/p[last()]")
html_nodes(parsed_doc, xpath = "//div/p[last()-1]")
html_nodes(parsed_doc, xpath = "//div[count(.//a)>0]")
html_nodes(parsed_doc, xpath = "//div[count(./@*)>2]")
html_nodes(parsed_doc, xpath = "//*[string-length(text())>50]")
html_nodes(parsed_doc, xpath = "//div[not(count(./@*)>2)]")

# text-based
html_nodes(parsed_doc, xpath = "//div[@date='October/2011']")
html_nodes(parsed_doc, xpath = "//*[contains(text(), 'magic')]")
html_nodes(parsed_doc, xpath = "//div[starts-with(./@id, 'R')]")
html_nodes(parsed_doc, xpath = "//div[substring-after(./@date, '/')='2003']//i")


## content extraction -------------------------

# values
html_nodes(parsed_doc, xpath = "//title") %>% html_text()

# attributes
html_nodes(parsed_doc, xpath = "//div") %>% html_attrs() # all attributes

html_nodes(parsed_doc, xpath = "//div") %>% html_attr("lang") # single attribute

