# Merge old and new Skeena Tyee Test Fishery biodata / sampling data / age.

# These are from an older access database and a newer (current) access database.

# See scripts written by Michael Folkes for error fixing:
# https://gitlab.com/MichaelFolkes/biodata/-/blob/main/scripts/biosample_dbase_newkeys_v2.R?ref_type=heads
# https://gitlab.com/MichaelFolkes/biodata/-/blob/main/scripts/biosample_data_2014-2020_errors.R?ref_type=heads

library(here)
library(readxl)
library(ggplot2)
library(dplyr)
library(skrunchy)


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
file1a <- "1973-2013-tyee-biodata-all-cols.xlsx"
path1 <- c("data-raw/tyee-sampling-biodata-ages")


#d1 <- read_xlsx( here("data", "tyee-sampling-biodata-ages", path1) , col_types = "text", .name_repair = fix_names )
d1 <- read_xlsx(
  here(path1, file1a),
  col_types = "text",
  .name_repair = fix_names
)
d1 <- d1[d1$species == "124", ] # keep chinook only


# new columns for etag, cwt in original data
d1$etag <- d1$head_number

# remove unneccessary columns
cols_not_use <- c(
  "wab_code",
  "stream_name",
  "vtp",
  "agency",
  "freshwater_sample_site_location",
  "longitude",
  "latitude",
  "rab_code",
  "site_code",
  "sub-area",
  "reach_number",
  "fish_wheel_number",
  "first_year_freshwater_circulii_count",
  "second_year_freshwater_circilii_count",
  "third_year_freshwater_circulii_count",
  "lifestage",
  "fish_number",
  "maturity",
  "fin_ray_box_number",
  "fin_ray_number", # only in 1996
  #"otolith_box_number", "otolith_number",
  "body_weight_gm", # 1973 - 1994 sporadically
  "rd/drs",
  "grade",
  "gonad_sample_number",
  "gonad_weight_gm",
  "fecundity_estimate_type",
  "fecundity_estimate", # 1975-1977 only
  "egg_retention",
  "carcass_condition",
  "skin_colour",
  "external_tag_colour",
  "external_tag",
  "external_tag_2nd_tag",
  "radiotag_frequency",
  "coded_fin_mark",
  "head_code",
  "head_number",
  #"cwt_code", # these might be superfluous for this data
  "external_damage",
  "hook_location",
  "stomach_sample",
  "stomach_volume_cc",
  "type_of_parasite_sample",
  "parasite_sample_number",
  "presence_of_philonema_species_worms",
  "disease_type",
  "disease_preservation",
  "trap_fishing",
  "water_level",
  "comments",
  "field174",
  "field176",
  "field178"
)
d1 <- d1[, !names(d1) %in% cols_not_use]

# Sampling event day different than catch day for 2 records:
dif_sample_catch_day <- d1[
  as.integer(d1$day_catch) - as.integer(d1$day_sampling_event) > 0,
]
# weird, catch day after sampling event day???
d1 <- d1[!is.na(d1$species), ] # remove NA rows
# fix typo
d1$location_name <- sub("SLEENA", "SKEENA", d1$location_name) # one typo in 1996


file2 <- "2014-2025-tyee-chinook-biodata-2026-08-10.xlsx"

d2 <- read_xlsx(
  here(path1, file2),
  col_types = "text",
  .name_repair = fix_names
)
cols_not_use2 <- c("months_catch", "field1")
d2 <- d2[, !names(d2) %in% cols_not_use2]


# Pull out etag number and make new column
d2$etag <- ifelse(
  grepl("[[:digit:]]{7}", d2$comments),
  stringr::str_extract(d2$comments, "[[:digit:]]{5,7}"),
  NA
)


unique(d2$comments[d2$year_catch > 2013])

# Check column names
n1 <- names(d1)
n2 <- names(d2)
n1
n2
length(n1)
length(n2)

union(n1, n2)
intersect(n1, n2)

setdiff(n1, n2)
setequal(n1, n2)

is.element(n1, n2)
is.element(n2, n1)

nd1 <- data.frame(names = n1, data = "old")
nd2 <- data.frame(names = n2, data = "new")

dm <- merge(nd1, nd2, by = "names", all = TRUE, suffixes = c("old", "new"))
#write.csv( dm, here("data-out", "biodata-names-compare.csv"), row.names = FALSE)

# bind data frames
str(d1)
str(d2)

d <- dplyr::bind_rows(d1, d2)
str(d)
unique(d$age)
table(d$age)
d$catch_date <- lubridate::ymd(paste(d$year_catch, d$month_catch, d$day_catch))
d$catch_jday <- lubridate::yday(d$catch_date)
d$total_age <- get_total_age(d$age)

d$hypural_length_mm <- as.numeric(d$hypural_length_mm)
d$nose_fork_length_mm <- as.numeric(d$nose_fork_length_mm)

d$year_catch <- as.integer(d$year_catch)

d$decade <- floor(d$year_catch / 10) * 10


write.csv(d, here(path1, "biodata-merge-no-fix.csv"), row.names = FALSE)


# FLAG - CORRECTIONS TO MAKE IN ACCESS DATABASE(S)
# age = "32."
# Odd ages: "Mixed Fish", "S2" (in 2021)
# POH length = 6650
# nose fork length = 5006
# unrealistic nose fork ~ POH lengths
# POH very small (3, 17, 55, 77)
# In 2021, 2022, and 2024, there are fish with ETAG numbers but no ages
# These should have correct CWT ages in the age column.

as.numeric("1M")

# check n in biodata vs. catch from FOS
table(d[d$year_catch == "1987", ]$catch_date)
# FOS report: "Testfish - Catch Summary by Date"
# Shows that there were more fish caught on some days than there are records in the biodata.
# statweek totals match G in Winther et al. 2024 excel analysis,
# File "1AB Skeena Esc 1979 to 2020 POPAN 2023-11-13 to LW&CM .xlsx" column D

# Therefore can't use biodata alone to get G, test fishing catch for each week.
# But the test fishing catch may or may not include jacks based on length?

# FOS Report: "Testfish Gillnet Multipanel Catch Summary Export" has more fish than "Testfish - Catch Summary by Date". Why?
# Does the latter ignore head / bit fish??? Does the latter ignore jacks?

# FOS report: "Testfish - Daily Test Fishing"
# By set data. May or may not include jacks based on length?

# get records that were actually aged
aged <- d[!is.na(as.numeric(d$age)), ]

# look at sex
unique(d$sex)

# 2019 was entered in EU age????
euage <- aged[grep("^0.*|^1.*", aged$age), ]
unique(euage$year_catch)

table(d[d$year_catch == "2019", "age"])

# Fin ray number
# only in 1996

# Note from Ivan Winther file "1979-2020 Skeena Test Chinook full DNA probs matched to Tyee data 2023-11-26.xlsx"
# Sheet "Full_Ids and scale 79-13"
# Where he matched biodata to indidual msat genetic data:
# 2009-2011 Vials wrong
# 2011 JD's wrong	(julian days)
# may have to fix those to join with MGL genetic reruns for msat?

# Years where it appears there is a daily cap of number of fish in biodata per day:
# 1987, 1989, 1990, 1991, 1992, 1993

# gillnet type

# Seine in 1988?

table(d$vessel_name, d$year_catch)
ggplot(d, aes(x = catch_jday, fill = vessel_name)) +
  geom_bar() +
  facet_wrap(~year_catch, scales = "free_y")
ggplot(d, aes(x = catch_jday, fill = gillnet_type)) +
  geom_bar() +
  facet_wrap(~year_catch, scales = "free_y")


# plot

ggplot(aged, aes(x = as.factor(age))) +
  geom_histogram(stat = "count")
ggplot(aged, aes(x = as.numeric(year_catch), fill = sex)) +
  geom_histogram(stat = "count")
ggplot(aged, aes(x = as.numeric(year_catch), fill = age)) +
  geom_histogram(stat = "count")

ggplot(ws, aes(x = as.numeric(year_catch))) +
  geom_histogram()

ggplot(d, aes(x = as.numeric(year_catch))) +
  geom_histogram()


# Check if biodata sampling was capped per day in some years
names(d1)
ggplot(d1, aes(x = day_catch)) +
  geom_bar() +
  facet_wrap(~year_catch, scales = "free_y")

ggplot(d1, aes(x = day_catch)) +
  geom_bar() +
  facet_wrap(~year_catch)

table(d$total_age)
range(d$hypural_length_mm, na.rm = TRUE)

# Check POH vs age
d %>%
  filter(
    !year_catch == 2019,
    total_age %in% c(3, 4, 5, 6, 7, 8),
    hypural_length_mm < 1200
  ) %>%
  ggplot(., aes(x = hypural_length_mm, fill = as.factor(total_age))) +
  geom_density() +
  geom_vline(aes(xintercept = 450))

d %>%
  filter(
    !year_catch == 2019,
    age %in% c(31, 32, 41, 42),
    hypural_length_mm < 1200
  ) %>%
  ggplot(., aes(x = hypural_length_mm, colour = as.factor(age))) +
  geom_freqpoly(alpha = 0.5, binwidth = 10) +
  facet_wrap(~decade) +
  geom_vline(aes(xintercept = 450))


d %>%
  filter(!year_catch == 2019, age %in% c(32, 42), hypural_length_mm < 1200) %>%
  ggplot(., aes(x = hypural_length_mm, fill = as.factor(age))) +
  geom_density(alpha = 0.5) +
  facet_wrap(~decade) +
  geom_vline(aes(xintercept = 450))

d %>%
  filter(!year_catch == 2019, age %in% c(32, 42), hypural_length_mm < 1200) %>%
  ggplot(., aes(x = hypural_length_mm, fill = as.factor(age))) +
  geom_density(alpha = 0.5) +
  geom_vline(aes(xintercept = 450))

# Check NF length vs age
d %>%
  filter(
    !year_catch == 2019,
    total_age %in% c(3, 4, 5, 6, 7, 8),
    nose_fork_length_mm < 1200
  ) %>%
  ggplot(., aes(x = nose_fork_length_mm, fill = as.factor(total_age))) +
  geom_density() +
  geom_vline(aes(xintercept = 550))

d %>%
  filter(
    !year_catch == 2019,
    age %in% c(31, 32, 41, 42),
    nose_fork_length_mm < 1200
  ) %>%
  ggplot(., aes(x = nose_fork_length_mm, colour = as.factor(age))) +
  geom_freqpoly(alpha = 0.5, binwidth = 10) +
  facet_wrap(~decade) +
  geom_vline(aes(xintercept = 550))


d %>%
  filter(
    !year_catch == 2019,
    age %in% c(32, 42),
    nose_fork_length_mm < 1200
  ) %>%
  ggplot(., aes(x = nose_fork_length_mm, fill = as.factor(age))) +
  geom_density(alpha = 0.5) +
  facet_wrap(~decade) +
  geom_vline(aes(xintercept = 550))

d %>%
  filter(
    !year_catch == 2019,
    age %in% c(32, 42),
    nose_fork_length_mm < 1200
  ) %>%
  ggplot(., aes(x = nose_fork_length_mm, fill = as.factor(age))) +
  geom_density(alpha = 0.5) +
  geom_vline(aes(xintercept = 550))

# POH vs NF
d %>%
  filter(nose_fork_length_mm < 1200, hypural_length_mm < 1200) %>%
  ggplot(., aes(y = nose_fork_length_mm, x = hypural_length_mm)) +
  geom_point() +
  geom_smooth(method = "lm") +
  facet_wrap(~decade)

d %>%
  filter(
    nose_fork_length_mm < 1200,
    hypural_length_mm < 1200,
    age %in% c(32, 42, 52, 62)
  ) %>%
  ggplot(., aes(y = nose_fork_length_mm, x = hypural_length_mm)) +
  geom_point(aes(colour = as.factor(age))) +
  geom_smooth(method = "lm") +
  facet_wrap(~decade)
