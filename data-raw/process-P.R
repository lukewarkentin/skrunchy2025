# Process genetic stock identification data from Tyee Test Fishery,
# weekly mixture data (P), and save as .rda file.

library(here)
library(readxl)
library(dplyr)
library(skrunchy)
library(tidyr)
library(lubridate)

# setup
file_path <- "data-raw/tyee-genetics"
# Note this does not rename Zymoetz as Zymoetz-Fiddler
k <- read.csv(here("data-raw", "key-simple.csv"))

# Keep only summer run populations above Tyee Test Fishery
# FLAG : SNP has Sicintine as separate from Upper Skeena
pops_keep <- c("Kitsumkalum", "Large Lakes", "Lower Skeena", "Middle Skeena",
               "Upper Skeena", "Zymoetz", "Sicintine")

#################################
# 1984-2020 (microsattelite data)
#################################

P_1984_2020 <- readRDS( here("data-raw/tyee-data-1984-2020/P-1984-2020.rda"))

# Need MGL to rerun against current baseline by CU




#################################
# 2021 - SNP
#################################
# note that SNP file has weird numbers for stat weeks, 61-85. MSAT are 24-36 (stat week)
# E.g., in 2020, the second week of June (Sunday to Saturday) is 62. The first week of August is 81.


file <- "PID20210126_Skeena_TF(21)_sc355_2021-11-30-no-jacks-SNP.xlsx"
sheet_use <- "repunits_estimates"
skip_use <- 6
d <- read_excel(path = here(file_path, file), sheet = sheet_use, skip = skip_use )

# FLAG something weird going on with julian day, stat week and dates between msat and SNP
# results

# remove seasonal columns
seasonal_col <- c("rEst.Skeena_TF(21)", "sd.Skeena_TF(21)")
d1 <- d[ , !names(d) %in% seasonal_col]

# Pivot columns for weekly mixture results - This is the function that makes it easy!!!
d1 <- d1 %>% pivot_longer( cols= grep("rEst|sd", names(d1)),
                          names_sep = "\\.Skeena_TF\\(21\\)_wk",
                          names_to = c(".value", "w"))
# new cu column using key to update names
d1$i <- ifelse( d1$CU_NAME %in% k$cu_snp,
                k$i[ match(d1$CU_NAME, k$cu_snp) ] ,
                d1$CU_NAME)

# rename columns
names(d1)[grep("^rEst.*", names(d1))] <- "P"
names(d1)[grep("^sd.*", names(d1))] <- "sigma_P"

ds <- d1[ d1$i %in% pops_keep, ]
ds$y <- "2021"

ds2021 <- ds

# read in temporary stat week key. Convert Tyee stat week to Alaska stat week
stat_wk_key <- read.csv(here("data-raw/stat-week-key-2021.csv"))
# Correct data to Alaska stat week using key. Confirmed correct on
# https://mtalab.adfg.alaska.gov/CWT/reports/sbp_calendar.aspx
ds2021$w <- stat_wk_key$Alaska.StatWeek[ match(ds2021$w, stat_wk_key$Tyee.Statweek) ]


ds %>% group_by(w) %>% summarize(sum = sum(P, na.rm=TRUE))

#################################
# 2022 - SNP
#################################

file <- "PID20220083_Skeena_TF_GN(22)_sc444_noJacks_2023-01-27.xlsx"
sheet_use <- "repunits_estimates"
skip_use <- 6
d <- read_excel(path = here(file_path, file), sheet = sheet_use, skip = skip_use )
seasonal_col <- c("rEst.Skeena_TF_GN(22)", "sd.Skeena_TF_GN(22)")
d1 <- d[ , !names(d) %in% seasonal_col]


# Pivot columns for weekly mixture results - This is the function that makes it easy!!!
d1 <- d1 %>% pivot_longer( cols= grep("rEst|sd", names(d1)),
                           names_sep = "\\.Skeena_TF_GN\\(22\\)_StWk",
                           names_to = c(".value", "w"))
# new cu column using key to update names
d1$i <- ifelse( d1$CU_NAME %in% k$cu_snp,
                k$i[ match(d1$CU_NAME, k$cu_snp) ] ,
                d1$CU_NAME)

# rename columns
names(d1)[grep("^rEst.*", names(d1))] <- "P"
names(d1)[grep("^sd.*", names(d1))] <- "sigma_P"

ds <- d1[ d1$i %in% pops_keep, ]
ds$y <- "2022"

ds2022 <- ds

ds %>% group_by(w) %>% summarize(sum = sum(P, na.rm=TRUE))


#################################
# 2023 - SNP
#################################

file <- "PID20230073_Skeena_TF(23)_sc499_2023-11-10_age4+_combined.xlsx"
sheet_use <- "repunits_estimates"
skip_use <- 6
d <- read_excel(path = here(file_path, file), sheet = sheet_use, skip = skip_use )
seasonal_col <- c("rEst.Skeena_TF(23)_Age4+", "sd.Skeena_TF(23)_Age4+")
d1 <- d[ , !names(d) %in% seasonal_col]


# Pivot columns for weekly mixture results - This is the function that makes it easy!!!
d1 <- d1 %>% pivot_longer( cols= grep("rEst|sd", names(d1)),
                           names_sep = "\\.Skeena_TF\\(23\\)_Age4\\+_StWk",
                           names_to = c(".value", "w"))
# new cu column using key to update names
d1$i <- ifelse( d1$CU_NAME %in% k$cu_snp,
                k$i[ match(d1$CU_NAME, k$cu_snp) ] ,
                d1$CU_NAME)

# rename columns
names(d1)[grep("^rEst.*", names(d1))] <- "P"
names(d1)[grep("^sd.*", names(d1))] <- "sigma_P"

ds <- d1[ d1$i %in% pops_keep, ]
ds$y <- "2023"

ds2023 <- ds

ds %>% group_by(w) %>% summarize(sum = sum(P, na.rm=TRUE))

#################################
# 2024 - SNP
#################################
# Read in GSI mixture analysis results. Note it is by stat week
file <- "PID20240073(1)-20240073(2)_Skeena_TF(24)_and_more_sc592-608_adults_2025-01-24_NF_week.xlsx"
sheet_use <- "repunits_estimates"
skip_use <- 6

d <- read_excel(path = here(file_path, file), sheet = sheet_use, skip = skip_use )
head(d)

# Pivot columns for weekly mixture results - This is the function that makes it easy!!!
d1 <- d %>% pivot_longer( cols= grep("rEst|sd", names(d)),
                            names_sep = "\\.Skeena_TF\\(24\\)_week",
                            names_to = c(".value", "w"))
# new cu column using key to update names
d1$i <- ifelse( d1$CU_NAME %in% k$cu_snp,
               k$i[ match(d1$CU_NAME, k$cu_snp) ] ,
               d1$CU_NAME)

# rename columns
names(d1)[grep("^rEst.*", names(d1))] <- "P"
names(d1)[grep("^sd.*", names(d1))] <- "sigma_P"

ds <- d1[ d1$i %in% pops_keep, ]
ds$y <- "2024"

ds2024 <- ds
ds %>% group_by(w) %>% summarize(sum = sum(P, na.rm=TRUE))

###############
# Combine all years
###############


# Bind all data frames together
# (do before converting to array because not all years have the same weeks, and
# binding arrays with unequal dimensions is harder)
dfs <- grep("^ds[[:digit:]]{4}$", names(.GlobalEnv),value=TRUE)
dfs_list <- do.call( "list" ,mget(dfs))
P_df <- do.call(rbind, dfs_list)

# convert to arrays
P <- df_to_array( df = P_df, value = "P", dimnames_order = c("i", "w", "y"), FUN = sum )
sigma_P <- df_to_array( df= P_df, value = "sigma_P", dimnames_order = c("i","w", "y"), FUN = sum )

P
sigma_P


# Save rda files
# weekly
usethis::use_data(P, overwrite = TRUE)
usethis::use_data(sigma_P, overwrite = TRUE)
