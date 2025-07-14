# Read in Chinook ERA model results, get Kitsumkalum hatchery spawners by age and year

# Note that all brood year 2019 releases were untagged and unclipped.
# CWT_Release column does not reflect this for brood year 2019.
# FLAG: Was escape column for 2019 brood year done using pseudo-recoveries?


library(readxl)
library(here)
library(dplyr)
library(skrunchy)

# Read in most recent 2025 data----------
path <- "data-raw/kitsumkalum"
file <- "chinook-cwt-ERA-outfiles_2025-03-06_KLM-KLY.xlsx"
# escapement
sheet <- "BY mat aeq cohort"
by_mat_aeq_cohort <- read_xlsx( path = here(path, file), sheet = sheet)

# Check that expanding based on mark rate is correct
sheet <- "Releases total"
releases_total <- read_xlsx( path = here(path, file), sheet = sheet)
releases_total$expansion_factor <- releases_total$total_Release / releases_total$CWT_Release
# merge releases tab with CWT in escapement tab
esc <- merge( by_mat_aeq_cohort, releases_total[ , c(1,2,5)] , by = c("Stock", "Brood.Yr") )
# Change variable names
names(esc)[grep("Brood.Yr", names(esc))] <- "b"
names(esc)[grep("age", names(esc))] <- "a"
esc$b <- as.integer(esc$b)
# expand estimated CWTs in escapement using total release/ marked release factor
esc$escape_expanded <- esc$escape * esc$expansion_factor
# add return year column
esc$y <- esc$b + esc$a

# summarize to get hatchery contribution to escapement by year and age
esc_s <- esc %>% group_by( y, a) %>% summarise( H_star = sum(escape_expanded, na.rm = TRUE))
esc_s <- esc_s %>% filter( !a == 2)
# make array
H_star <- df_to_array(esc_s, value = "H_star", dimnames_order = c("y", "a"), FUN = sum)
dimnames(H_star)

usethis::use_data(H_star, overwrite = TRUE)
