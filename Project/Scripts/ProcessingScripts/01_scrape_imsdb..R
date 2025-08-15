
#!/usr/bin/env Rscript
# ---------------------------------------------------------------
# 01_scrape_imsdb.R download raw screenplay HTML
# ---------------------------------------------------------------
setwd("~/Desktop/lab-5-tier-text")
source("environment.R")

library(rvest); library(httr); library(xml2); library(stringr); library(tibble)
url <- "http://imsdb.com/scripts/Star-Wars-Revenge-of-the-Sith.html"
res <- GET(url, user_agent("Mozilla/5.0"))
stop_for_status(res) # halt if e.g. 404 or 403

html <- read_html(res)
scr <- html_node(html, "td.scrtext") # screenplay div
raw <- xml_text(scr, trim = FALSE) # keep line-breaks

dir.create("Project/Data/InputData", recursive = TRUE, showWarnings = FALSE) #adding this because cannot locate file

writeLines(raw, "Project/Data/InputData/revenge_sith_raw.txt")

