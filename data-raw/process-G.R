# Create weekly tyee test fishery catch data, G, for 1984-2024

library(here)
library(lubridate)
library(skrunchy)
library(dplyr)
library(readxl)
library(ggplot2)


# 1984-2020 -------

# use Ivan's file from Winther et al. 2024 report
# Notes:
# This is from file “1AB Skeena Esc 1979 to 2020 POPAN 2023-11-13 to LW&CM .xlsx",
# tab "Samples & catch 79-20".
# Column D “revised weekly catch” mainly matches FOS report “Testfish - Catch Summary by Date”
# in all but a few years, which IW revised:
# 2009: samples were initially done every 10 days but have been corrected to weekly here.
# 2010: samples were done weekly but not in sync with stat weeks.
# 2012: revised catches corrected to the dates used by the MGL - not in sync with stat weeks

d1 <- read_xlsx( here("data-raw", "tyee-genetics", "tyee-catch-by-stat-week-1984-2020.xlsx"), skip = 10)

# Add Alaska style statistical week column for consistency with more recent years
d1$fix_date_range <- gsub("[[:space:]]{2}", " ", d1$`stwk dates from StAD and Test Fish database`)
unique(nchar(d1$fix_date_range))
d1$date_start <- ymd( paste( d1$YEAR,
                             match(  stringr::str_to_title(substr( d1$fix_date_range, 1,3)), month.abb), # get numeric month
                             as.numeric(substr( d1$fix_date_range, 5,6)),
                             sep= "-"))
d1$date_end <- ymd( paste( d1$YEAR,
                           match(  stringr::str_to_title(substr( d1$fix_date_range, 10,12)), month.abb), # get numeric month
                           as.numeric(substr( d1$fix_date_range, 14,15)),
                           sep= "-"))
# Check if stat week conversion worked
# d1$stat_week1 <- get_stat_week(d1$date_start)
# d1$stat_week2 <- get_stat_week(d1$date_end)
# identical(d1$stat_week1, d1$stat_week2 ) # yes, it did.
d1$stat_week <- get_stat_week(d1$date_start)
# rename
names(d1)[ grep("revised weekly catch \\(G)", names(d1)) ] <- "G"
names(d1)[ grep("YEAR", names(d1)) ] <- "y"
names(d1)[ grep("stat_week", names(d1)) ] <- "w"

# remove rows with NA weekly catch
d1 <- d1[ !is.na(d1$G), ]

# More notes:
# Multipanel catch report has slightly more observations. Includes
# bit/jacks? Don’t know right now.
# I think it includes jacks, that's why it is higher.

# Note:
# Below might not be consistent with past years, which used adult/jack assignments
# as done at Tyee based on length only (jacks <650 mm).
# Did Ivan go back and send MGL which fish were adults based on age to re-run for mixture?

# 2021-2024 ---------
fix_names <- function(nms) {
  nms0 <- gsub("VESSEL\\(CFV\\)", "VESSEL_CFV", nms)
  nms1 <- tolower(gsub("\\s", "_", nms0))
  nms2 <- gsub("\\)|\\(", "", nms1)
  nms3 <- gsub("color", "colour", nms2)
  nms4 <- gsub("dna_vial", "vial", nms3)
  nms4
}
# Read in data, use character class for all until done checking, fixing errors
# file1 <- "1973-2013-tyee-biodata.xlsx"
path <- c("data-raw/tyee-sampling-biodata-ages")
file <- "2014-2024-tyee-chinook-biodata-2025-04-10.xlsx"
d2 <- read_xlsx( here(path, file) , col_types = "text", .name_repair = fix_names)
cols_not_use2 <- c("months_catch", "field1")
d2 <- d2[ , !names(d2) %in% cols_not_use2]
str(d2)
d2$catch_date <- lubridate::ymd(paste(d2$year_catch, d2$month_catch, d2$day_catch))
d2$catch_jday <- lubridate::yday(d2$catch_date)
d2$total_age <- get_total_age(d2$age)

d2$hypural_length_mm <- as.numeric(d2$hypural_length_mm)
d2$nose_fork_length_mm <- as.numeric(d2$nose_fork_length_mm)

d2$year_catch <- as.integer(d2$year_catch)

# 2021-2024 only
d2 <- d2[ d2$year_catch > 2020, ]

d2$stat_week_new <- get_stat_week(d2$catch_date)

d2$stage <- get_stage(scale_age = d2$age, cwt_age = d2$total_age,
                      POH = d2$hypural_length_mm, comments = d2$comments,
                      jack_ages = c("32", "31", "1M"),
                      adult_ages = c("41", "42", "43", "51", "52", "53",
                                     "61", "62", "63", "71", "72", "73",
                                     "81", "82", "83",
                                     "2M", "3M", "4M", "5M" ),
                      jack_cutoff_length_POH = 450)

# Check get_stage() function
ggplot( d2, aes(x = hypural_length_mm)) +
  geom_histogram() +
  geom_vline( aes(xintercept = 450), colour= "dodgerblue") +
  facet_wrap( stage ~ age, drop=TRUE)

ggplot( d2[ d2$nose_fork_length_mm <1050, ], aes(x = nose_fork_length_mm)) +
  geom_histogram() +
  geom_vline( aes(xintercept = 500), colour= "dodgerblue") +
  geom_vline( aes(xintercept = 650), colour= "firebrick") +
  facet_wrap( stage ~ age, drop=TRUE)

# manually check
write.csv(d2, here("data-raw", "temp-check-get-stage.csv"), row.names = FALSE)

# Years with ETAGS but no corrected ages ******
# FLAG - need to revisit this. Need CWT corrected ages, at least for 2021-2024

d2a <- d2[ d2$stage == "adult", ]

table(d2$year_catch, d2$stat_week_new)
# Revised adult catch per stat week
d2sum <- d2a %>% group_by( stat_week_new, year_catch) %>%
                    summarise("G" = n() )
names(d2sum)[ grep("year_catch", names(d2sum)) ] <- "y"
names(d2sum)[ grep("stat_week_new", names(d2sum)) ] <- "w"

# Combine 1984-2020 and 2021-2024 data
dcomb <- rbind( d1[ , names(d1) %in% c("G", "y", "w")], d2sum[ , names(d2sum) %in% c("G", "y", "w")] )

# convert to array
G <- df_to_array(dcomb, "G", dimnames_order = c("w", "y"), function(x) {sum(x, na.rm=TRUE)} )
G <- G[ , as.character(1984:2024)]
G

usethis::use_data(G, overwrite = TRUE)


plot(  apply(G, 2, sum) ~ dimnames(G)$y )






# OBSOLETE:




# 2024  -------

file <- "2024-tyee-revised-adults-jacks.csv"
file_path <- "data-raw/tyee-sampling-biodata-ages"
d <- read.csv(here(file_path, file))
# remove jacks
d <- d[ d$revised_stage=="adult", ]
str(d)
d$date <- ymd(d$catch_date)
d$w <- epiweek(d$date)
d$jday <- yday(d$date)
d$wday <- wday(d$date, label=TRUE)
d$y <- d$year_catch
table(d$jday)
sort(unique(d$w))
table(d$w, d$year_catch)

ds <- d %>% group_by(y, w) %>% summarize(G = n())



G <- df_to_array( df = ds, value= "G", dimnames_order = c("w", "y"), FUN = sum)
G
dim(G)
dimnames(G)
#saveRDS(G, file = here("data", "2024_G.rda"))


