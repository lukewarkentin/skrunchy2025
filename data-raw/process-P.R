# Process genetic stock identification data from Tyee Test Fishery,
# weekly mixture data (P), and save as .rda file.

# This is used together with weekly Tyee gillnet catch to estimate annual proportions
# of the different CUs, to account for uneven catch/effort between weeks and
# changing CU proportions of the run throughout the season.

library(here)
library(readxl)
library(dplyr)
library(skrunchy)
library(tidyr)
library(lubridate)

# setup
file_path <- "data-raw/tyee-genetics/gsi-results-no-jacks"
# Note this does not rename Zymoetz as Zymoetz-Fiddler
k <- read.csv(here("data-raw", "key-simple.csv"))

# Keep only summer run populations above Tyee Test Fishery
# FLAG : SNP has Sicintine as separate from Upper Skeena
pops_keep <- c(
  "Kitsumkalum",
  "Large Lakes",
  "Lower Skeena",
  "Middle Skeena",
  "Upper Skeena",
  "Zymoetz",
  "Sicintine"
)

#################################
# 1984-2020 (microsattelite data)
#################################

P_1984_2020 <- readRDS(here("data-raw/tyee-data-1984-2020/P-1984-2020.rda"))
sigma_P_1984_2020 <- readRDS(here(
  "data-raw/tyee-data-1984-2020/sigma-P-1984-2020.rda"
))

# Convert to df so that they can be combined with 2021-2024 data, then converted to arrays (in case weeks are not even)
P_1984_2020_df <- array2DF(P_1984_2020, responseName = "P")
sigma_P_1984_2020_df <- array2DF(sigma_P_1984_2020, responseName = "sigma_P")
ds1984_2020 <- merge(
  P_1984_2020_df,
  sigma_P_1984_2020_df,
  by = c("w", "y", "i"),
  all = TRUE
)

# Waiting for MGL to rerun against current baseline by CU

#################################
# 2021 - SNP
#################################
# note that SNP file has weird numbers for stat weeks, 61-85. MSAT are 24-36 (stat week)
# E.g., in 2020, the second week of June (Sunday to Saturday) is 62. The first week of August is 81.

file <- "PID20210126_Skeena_TF(21)_sc355_2021-11-30-no-jacks-SNP.xlsx"
sheet_use <- "repunits_estimates"
skip_use <- 6
d <- read_xlsx(path = here(file_path, file), sheet = sheet_use, skip = skip_use)

# # read in inventory tab, has julian day ranges, to fix stat week weirdness
# dk <- as.data.frame(t(read_xlsx(path = here(file_path, file), sheet = "Inventory" , col_names = FALSE)))
# class(dk)
# names(dk) <- as.character( dk[1,])
# dk <- dk[ -1,]

# FLAG something weird going on with julian day, stat week and dates between msat and SNP
# results

# remove seasonal columns
seasonal_col <- c("rEst.Skeena_TF(21)", "sd.Skeena_TF(21)")
d1 <- d[, !names(d) %in% seasonal_col]

# Pivot columns for weekly mixture results - This is the function that makes it easy!!!
d1l <- d1 %>%
  pivot_longer(
    cols = grep("rEst|sd", names(d1)),
    names_sep = "\\.Skeena_TF\\(21\\)_wk",
    names_to = c(".value", "w")
  )

# d1l <- d1 %>% pivot_longer( cols= grep("rEst|sd", names(d1)),
#                             names_sep = "\\.",
#                             names_to = c(".value", "Collection"))
# # merge with key to get jday range of catch
# d1lm <- merge(d1l, dk[ , c("Collection", "Catch_JD")], by = "Collection", all = TRUE)
#
# d1lm$date_start <- as.Date( as.integer(substr(d1lm$Catch_JD, 1,3)) , origin = as.Date("2021-01-01"))
# d1lm$date_end <- as.Date( as.integer(substr(d1lm$Catch_JD, 5,7)) , origin = as.Date("2021-01-01"))
# d1lm$w <- get_stat_week( as.Date( as.integer(substr(d1lm$Catch_JD, 1,3)) , origin = as.Date("2021-01-01")) )
# d1lm$w_check <- get_stat_week( as.Date( as.integer(substr(d1lm$Catch_JD, 5,7)) , origin = as.Date("2021-01-01")) )

# new cu column using key to update names
d1l$i <- ifelse(
  d1l$CU_NAME %in% k$cu_snp,
  k$i[match(d1l$CU_NAME, k$cu_snp)],
  d1l$CU_NAME
)

# rename columns
names(d1l)[grep("^rEst.*", names(d1l))] <- "P"
names(d1l)[grep("^sd.*", names(d1l))] <- "sigma_P"

ds <- d1l[d1l$i %in% pops_keep, ]
ds$y <- "2021"

ds2021 <- ds
str(ds2021)
ds2021$w <- as.integer(ds2021$w)
# read in temporary stat week key. Convert Tyee stat week to Alaska stat week
stat_wk_key <- read_xlsx(
  here("data-raw/stat-week-calculator-2021.xlsx"),
  skip = 2,
  .name_repair = "universal"
)
str(stat_wk_key)
stat_wk_key$Tyee.Statweek <- as.integer(stat_wk_key$Tyee.Statweek)
# Correct data to Alaska stat week using key. Confirmed correct on
# https://mtalab.adfg.alaska.gov/CWT/reports/sbp_calendar.aspx
ds2021$w <- stat_wk_key$Alaska.StatWeek[match(
  ds2021$w,
  stat_wk_key$Tyee.Statweek
)]

colskeep <- c("w", "i", "y", "P", "sigma_P")
ds2021 <- ds2021[, colskeep]

ds %>% group_by(w) %>% summarize(sum = sum(P, na.rm = TRUE))

#################################
# 2022 - SNP
#################################

file <- "PID20220083_Skeena_TF_GN(22)_sc444_noJacks_2023-01-27.xlsx"
sheet_use <- "repunits_estimates"
skip_use <- 6
d <- read_xlsx(path = here(file_path, file), sheet = sheet_use, skip = skip_use)
seasonal_col <- c("rEst.Skeena_TF_GN(22)", "sd.Skeena_TF_GN(22)")
d1 <- d[, !names(d) %in% seasonal_col]


# Pivot columns for weekly mixture results - This is the function that makes it easy!!!
d1 <- d1 %>%
  pivot_longer(
    cols = grep("rEst|sd", names(d1)),
    names_sep = "\\.Skeena_TF_GN\\(22\\)_StWk",
    names_to = c(".value", "w")
  )
# new cu column using key to update names
d1$i <- ifelse(
  d1$CU_NAME %in% k$cu_snp,
  k$i[match(d1$CU_NAME, k$cu_snp)],
  d1$CU_NAME
)

# rename columns
names(d1)[grep("^rEst.*", names(d1))] <- "P"
names(d1)[grep("^sd.*", names(d1))] <- "sigma_P"

ds <- d1[d1$i %in% pops_keep, ]
ds$y <- "2022"

ds2022 <- ds
ds2022 <- ds2022[, colskeep]

ds %>% group_by(w) %>% summarize(sum = sum(P, na.rm = TRUE))


#################################
# 2023 - SNP
#################################

file <- "PID20230073_Skeena_TF(23)_sc499_2023-11-10_age4+_combined.xlsx"
sheet_use <- "repunits_estimates"
skip_use <- 6
d <- read_xlsx(path = here(file_path, file), sheet = sheet_use, skip = skip_use)
seasonal_col <- c("rEst.Skeena_TF(23)_Age4+", "sd.Skeena_TF(23)_Age4+")
d1 <- d[, !names(d) %in% seasonal_col]


# Pivot columns for weekly mixture results - This is the function that makes it easy!!!
d1 <- d1 %>%
  pivot_longer(
    cols = grep("rEst|sd", names(d1)),
    names_sep = "\\.Skeena_TF\\(23\\)_Age4\\+_StWk",
    names_to = c(".value", "w")
  )
# new cu column using key to update names
d1$i <- ifelse(
  d1$CU_NAME %in% k$cu_snp,
  k$i[match(d1$CU_NAME, k$cu_snp)],
  d1$CU_NAME
)

# rename columns
names(d1)[grep("^rEst.*", names(d1))] <- "P"
names(d1)[grep("^sd.*", names(d1))] <- "sigma_P"

ds <- d1[d1$i %in% pops_keep, ]
ds$y <- "2023"

ds2023 <- ds
ds2023 <- ds2023[, colskeep]

ds %>% group_by(w) %>% summarize(sum = sum(P, na.rm = TRUE))

#################################
# 2024 - SNP
#################################
# Read in GSI mixture analysis results. Note it is by stat week
file <- "PID20240073(1)-20240073(2)_Skeena_TF(24)_and_more_sc592-608_adults_2025-01-24_NF_week.xlsx"
sheet_use <- "repunits_estimates"
skip_use <- 6

d <- read_xlsx(path = here(file_path, file), sheet = sheet_use, skip = skip_use)
head(d)

# Pivot columns for weekly mixture results - This is the function that makes it easy!!!
d1 <- d %>%
  pivot_longer(
    cols = grep("rEst|sd", names(d)),
    names_sep = "\\.Skeena_TF\\(24\\)_week",
    names_to = c(".value", "w")
  )
# new cu column using key to update names
d1$i <- ifelse(
  d1$CU_NAME %in% k$cu_snp,
  k$i[match(d1$CU_NAME, k$cu_snp)],
  d1$CU_NAME
)

# rename columns
names(d1)[grep("^rEst.*", names(d1))] <- "P"
names(d1)[grep("^sd.*", names(d1))] <- "sigma_P"

ds <- d1[d1$i %in% pops_keep, ]
ds$y <- "2024"

ds2024 <- ds
ds2024 <- ds2024[, colskeep]

ds %>% group_by(w) %>% summarize(sum = sum(P, na.rm = TRUE))

###############
# Combine all years
###############

# Bind all data frames together
# (do before converting to array because not all years have the same weeks, and
# binding arrays with unequal dimensions is harder)
dfs <- grep("^ds[[:digit:]]{4}", names(.GlobalEnv), value = TRUE)
dfs_list <- do.call("list", mget(dfs))
P_df <- do.call(rbind, dfs_list)


# convert to arrays
P <- df_to_array(
  df = P_df,
  value = "P",
  dimnames_order = c("i", "w", "y"),
  FUN = sum
)
sigma_P <- df_to_array(
  df = P_df,
  value = "sigma_P",
  dimnames_order = c("i", "w", "y"),
  FUN = sum
)

P
sigma_P

# Combine Sicintine into Upper Skeena
dimnames(P)
P_test <- P
P_test["Upper Skeena", , ] <- P["Upper Skeena", , ] + P["Sicintine", , ]
plot(P["Upper Skeena", , ], P_test["Upper Skeena", , ])
P_test <- P_test[-grep("Sicintine", dimnames(P_test)$i), , ]
P <- P_test

sigma_P_test <- sigma_P
sigma_P_test["Upper Skeena", , ] <- sqrt(
  sigma_P["Upper Skeena", , ]^2 + sigma_P["Sicintine", , ]^2
)
plot(sigma_P["Upper Skeena", , ], sigma_P_test["Upper Skeena", , ])
sigma_P_test <- sigma_P_test[-grep("Sicintine", dimnames(sigma_P_test)$i), , ]
sigma_P <- sigma_P_test

# Save rda files
# weekly
usethis::use_data(P, overwrite = TRUE)
usethis::use_data(sigma_P, overwrite = TRUE)
