# ------------------------------------------------------------------
# environment.R installs then loads every package we need
# ------------------------------------------------------------------
options(repos = c(CRAN = "https://cloud.r-project.org"))
pkgs <- c(
  "dplyr","ggplot2","tidyr","xml2","rvest","httr",
  "tibble","stringr","tidytext","tokenizers","widyr",
  "viridis","scales"
)

to_install <- pkgs[ !(pkgs %in% installed.packages()[,"Package"]) ]
if (length(to_install))
  install.packages(to_install)
