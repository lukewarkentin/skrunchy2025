# Process terminal freshwater mortality data

library(here)
library(readxl)
library(dplyr)


# Read in freshwater catch data
fix_names <- function(nms) {
  nms0 <- gsub("VESSEL\\(CFV\\)", "VESSEL_CFV", nms)
  nms1 <- tolower(gsub("\\s", "_", nms0))
  nms2 <- gsub("\\)|\\(", "", nms1)
  nms3 <- gsub("\\+", "plus", nms2)
  nms4 <- gsub("dna_vial", "vial", nms3)
  nms4
}

d <- read_xlsx(
  here("data-raw/freshwater-catch.xlsx"),
  range = "A1:P47",
  .name_repair = fix_names
)

names(d)
# rename variables
names(d) <- sub("tyee_catch_jacks_plus_large", "tyee", names(d))

names(d) <- sub(
  "fw_sport_catch_large_plus_jacks_above_terrace",
  "rec_catch_U",
  names(d)
)

names(d) <- sub("fw_sport_catch_below_terrace", "rec_catch_L", names(d))
names(d) <- sub("fw_sport_releases_below_terrace", "rec_release_L", names(d))

names(d) <- sub("fn_fw_catch_below_terrace", "FN_catch_L", names(d))

names(d) <- sub("fn_fw_catch_above_terrace", "FN_catch_U", names(d))

vars_keep <- c(
  "year",
  "tyee",
  "rec_catch_U",
  "rec_catch_L",
  "rec_release_L",
  "FN_catch_L",
  "FN_catch_U"
)

Tau <- d[d$year >= 1984, vars_keep]

usethis::use_data(Tau, overwrite = TRUE)
