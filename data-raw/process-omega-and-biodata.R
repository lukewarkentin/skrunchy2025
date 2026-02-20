# Create age proportion data from biodata merged with GSI data omega and omega_J

# Also create a table of biodata - date, age, sex, length, CU for


library(here)
library(lubridate)
library(skrunchy)
library(dplyr)
library(readxl)
library(ggplot2)



# Read in data for 1984-2020
# From Winther et al. 2024 report.
# Exported from skeena-chinook-escapement-gsi/scripts/save-data-for-skrunchy2025-tyee-weekly-and-ages.R
# Original file: "1979-2020 Skeena Test Chinook full DNA probs matched to Tyee data 2023-11-26.xlsx", sheet: "probs by fish 79-2020"

# read in biodata with age, sex, length, CU
bd_old <- readRDS( here("data-raw/tyee-data-1984-2020/tyee-biodata-age-sex-length-CU-1984-2020.rda") )
# read in age proportion data (no jacks)
# omega_old <- readRDS( here("data-raw/tyee-data-1984-2020/omega-1984-2020.rda") )
# # read in age proportion data (with jacks)
# omega_J_old <-readRDS( here("data-raw/tyee-data-1984-2020/omega-J-1984-2020.rda") )
# # Read in age observation data
# age_obs_old <- readRDS( here( "data-raw/tyee-data-1984-2020/age-obs-1984-2020.rda"))

# new data, 2021-2024

# Individual genetic data, read in each year and then combine

# Genetics data 2021-2024 - FLAG: Need to use rerun data. Below uses original runs -----------
# 2021-2024
# 2021 - need data file from Chelsea - including jacks

# FLAG use file I have now.
file <- "SNP_PID20210126_Skeena_TF(21)_sc355_2021-11-30.xlsx"
res_tab <- "repunits_table_ids"
ext_tab <- "extraction_sheet"

d2021_res <- read_xlsx( here("data-raw", "tyee-genetics", "gsi-results-include-jacks", file), sheet= res_tab)
d2021_ext <-  read_xlsx( here("data-raw", "tyee-genetics", "gsi-results-include-jacks", file), sheet= ext_tab)
d2021 <- merge(d2021_res, d2021_ext, by = c("indiv", "ID_Source"), all.x = TRUE)

names(d2021) <- sub("Catch\\.Year", "CatchYear", names(d2021))
names(d2021) <- sub("CatchJulianDate", "CatchJulDate", names(d2021))
names(d2021) <- sub("^CatchDate$", "CatchDate\\.\\.YYYY\\.MM\\.DD\\.", names(d2021))
names(d2021) <- sub("SampleName\\.S\\.G\\.", "SampleName", names(d2021))

# remove leading 0 from scale numbers
d2021$Vial <- sub("-0", "-", d2021$Vial)



# 2022
# Read in gsi individual assignments, includes jacks
file <- "PID20220083_Skeena_TF_GN(22)_sc444_2022-11-14.xlsx"
res_tab <- "repunits_table_ids"
ext_tab <- "extraction_sheet"

d2022_res <- read_xlsx( here("data-raw", "tyee-genetics", "gsi-results-include-jacks", file), sheet= res_tab)
d2022_ext <-  read_xlsx( here("data-raw", "tyee-genetics", "gsi-results-include-jacks", file), sheet= ext_tab)
d2022 <- merge(d2022_res, d2022_ext, by = c("indiv", "ID_Source"), all.x = TRUE)

names(d2022) <- sub("Catch\\.Year", "CatchYear", names(d2022))
names(d2022) <- sub("CatchJulianDate", "CatchJulDate", names(d2022))
names(d2022) <- sub("^CatchDate$", "CatchDate\\.\\.YYYY\\.MM\\.DD\\.", names(d2022))
names(d2022) <- sub("SampleName\\.S\\.G\\.", "SampleName", names(d2022))

# scale book was mis-typed
d2022$Vial <- sub("^102500-", "1025000-", d2022$Vial)




# Note 8 fish that have NA..... for Vial?


# 2023
file <- "PID20230073_Skeena_TF(23)_sc499_2023-11-10_combined.xlsx"
res_tab <- "repunits_table_ids"
ext_tab <- "extraction_sheet"
d2023_res <- read_xlsx( here("data-raw", "tyee-genetics", "gsi-results-include-jacks", file), sheet= res_tab)
d2023_ext <-  read_xlsx( here("data-raw", "tyee-genetics", "gsi-results-include-jacks", file), sheet= ext_tab)
d2023 <- merge(d2023_res, d2023_ext, by = c("indiv", "ID_Source"), all.x = TRUE)

# remove leading 0 from scale numbers
d2023$Vial <- sub("-0", "-", d2023$Vial)

# 2024
file <- "PID20240073(1)-20240073(2)_Skeena_TF(24)_and_more_sc592-608_2024-11-26_NF_combined-includes-jacks.xlsx"
res_tab <- "repunits_table_ids"
ext_tab <- "extraction_sheet"
d2024_res <- read_xlsx( here("data-raw", "tyee-genetics", "gsi-results-include-jacks", file), sheet= res_tab)
d2024_ext <-  read_xlsx( here("data-raw", "tyee-genetics", "gsi-results-include-jacks", file), sheet= ext_tab)
d2024 <- merge(d2024_res, d2024_ext, by = c("indiv", "ID_Source"), all.x = TRUE)
# remove leading 0 from scale numbers
d2024$Vial <- sub("-0", "-", d2024$Vial)

# Combine 2021-2024 individual genetic assignment data
names(d2021)
names(d2022)
names(d2023)
names(d2024)
names_use <-  c( "indiv" ,  "ID_Source",
                 "collection"  ,    "mixture_collection",
                 "PBT_brood_year"    ,  "repunit.1",
                 "prob.1", "StockCode" ,    "CatchYear",
                 "CatchJulDate" ,  "Fish",
                 "Vial"  ,    "Tray",
                 "CatchDate..YYYY.MM.DD."  ,
                 "SampleName"   , "Comments"   )


#dlistd2024#dlistd2022_res#dlist <- list(d2021, d2022, d2023, d2024)
dlist <- list( d2021[ ,names_use], d2022[ , names_use], d2023[ , names_use], d2024[ , names_use] )

gsi <- do.call(rbind, dlist)
table(gsi$repunit.1, useNA = "ifany")

# merge with better names
key <- read.csv( here( "data-raw", "key-simple.csv"))

gsi1 <- merge(gsi, key, by.x = "repunit.1", by.y = "cu_snp_short", all.x = TRUE)


# Biodata to match with 2021-2024 genetics data -----------
# read in tyee biodata with ages from 2014-2024, select 2021-2024
file <- "2014-2024-tyee-chinook-biodata-2025-04-10.xlsx"
bd <- read_xlsx( here( "data-raw", "tyee-sampling-biodata-ages", file), na = c("N/A", "NA"))
# select 2021-2024
bd1 <- bd[ bd$`YEAR (CATCH)` >= 2021,  ]
bd1$`SCALE BOOK NUMBER` <- sub("^102500$", "1025000", bd1$`SCALE BOOK NUMBER`) # 2022 was mistyped
bd1$scale_book_scale <- paste( bd1$`SCALE BOOK NUMBER`, bd1$`SCALE NUMBER`, sep = "-")


# Merge 2021-2024 genetic data with 2021-2024 biodata -------------
md <- merge( bd1, gsi1, by.x = c("scale_book_scale", "YEAR (CATCH)"), by.y = c("Vial", "CatchYear"), all.x = TRUE)

# FLAG: for later fixes
#  2 non matching rows in 2021
# 15 non matchign rows in 2022

table(md$cu_snp, md$`YEAR (CATCH)`)

hist(md$prob.1)
ggplot(md, aes( x = prob.1) ) +
  geom_histogram() +
  facet_wrap( ~ repunit.1, scales = "free_y")

# Check
table(md$repunit.1, useNA = "ifany")
# check merge. Check scale numbers 1202030-01 vs. -1
#Some didn't merge maybe?

# fix names
fix_names <- function(nms) {
  nms0 <- gsub("VESSEL\\(CFV\\)", "VESSEL_CFV", nms)
  nms1 <- tolower(gsub("\\s", "_", nms0))
  nms2 <- gsub("\\)|\\(", "", nms1)
  nms3 <- gsub("color", "colour", nms2)
  nms4 <- gsub("dna_vial", "vial", nms3)
  nms4
}
names(md) <- fix_names(names(md))


str(md)

md$a <- get_total_age(md$age)
md$y <- as.integer(md$year_catch)
md$date <- ymd( paste(md$year_catch, md$month_catch, md$day_catch, sep = "="))
str(md)

md$max_CU_prob_sum <- md$`prob.1`/100

md$hypural_length_mm <- as.numeric(md$hypural_length_mm)
md$nose_fork_length_mm <- as.numeric(md$nose_fork_length_mm)
md$sex <- as.integer(md$sex)
cols_exp <- c("date", "i", "y", "sex", "a", "nose_fork_length_mm", "hypural_length_mm", "max_CU_prob_sum" )



md_exp <- md[ names(md) %in% cols_exp]

str(md_exp)

# Merge 1984-2020 data with 2021-2024 data ---------------

bdall <- rbind(bd_old, md_exp)
unique(bdall$sex)
bdall$sex <- ifelse( bdall$sex == 1, "m", ifelse(bdall$sex == 2, "f", "u"))

# Plot observations by year, by CU
ggplot(bdall, aes( x = y)) +
  geom_bar() +
  facet_wrap( ~ i, scales = "free_y") +
  theme_bw()

# Plot observations by year, by CU
ggplot(bdall, aes( x = yday(date))) +
  geom_bar() +
  facet_wrap( ~ y) +
  theme_bw()

tyee_biodata_age_sex_length_CU <- bdall

# Make age observation data and age proportion data (omega and omega_J)------------

# Use corrected GR age to get age proportions.
at <- table(bdall$i, bdall$y, bdall$a, dnn = c("i", "y", "a"))
# add aggregate column for summarizing for Skeena
bdall$aggregate <- "Skeena"
atskeena <- table(bdall$aggregate, bdall$y, bdall$a, dnn = c("i", "y", "a"))
aarrcu <- as.array(at)
aarrskeena <- as.array(atskeena)
aarr <- abind(aarrcu, aarrskeena, along=1, use.dnns = TRUE)
dimnames(aarr)
aarr

# save age observations n for example runs ----------
pops_keep <- c("Kitsumkalum", "Large Lakes", "Lower Skeena", "Middle Skeena",
               "Upper Skeena", "Zymoetz")
age_obs <- aarr[ c("Skeena", pops_keep), , c("4", "5", "6", "7")]

# bring in Kitsumkalum age obs from spawning ground sampling, mark-recap program.
load( here("data/n_age_kitsumkalum.rda"))
kitsumkalum_age_obs <- n_age_kitsumkalum

#gurl <- "https://github.com/lukewarkentin/skrunchy2025/raw/refs/heads/main/data-raw/kitsumkalum/misc/kitsumkalum-age-observations.RDS"
#kitsumkalum_age_obs <- readRDS( url(gurl) )


# # For Kitsumkalum, replace Tyee age obs with Kitsumkalum river age obs - FLAG might not want to do this.
# age_obs_check <- age_obs
# age_obs["Kitsumkalum",, ] <- kitsumkalum_age_obs
# # check
# plot(as.vector(age_obs["Kitsumkalum",, ]) ~ as.vector(kitsumkalum_age_obs))
# # looks good. Check other CUs
# plot(as.vector(age_obs[-2,, ]) ~ as.vector( age_obs_check[ -2,, ] ))
# # looks good

# # make age obs for 6 = 6+7
age_obs[ ,, c("6") ] <- age_obs[ ,,c("6") ] + age_obs[ ,, c("7") ]
# remove age 7 age obs
age_obs <- age_obs[ ,, -4 ]
dimnames(age_obs)

n_age_observations <- age_obs

# Get omega age proportions, ages 4-7 ----------
omega <- get_omega( aarr[ c("Skeena", pops_keep), , c("4", "5", "6", "7")] , save_csv = FALSE)
omega$omega[,,"7"]
dimnames(omega$omega)
omega
# Get omega age proportions including jacks, ages 3-7
omega_J <- get_omega( aarr[ c("Skeena", pops_keep), , c("3", "4", "5", "6", "7")] , save_csv = FALSE)
omega_J$omega[,,"7"]
dimnames(omega_J$omega)
omega_J



# save merged biodata file ------------
usethis::use_data(tyee_biodata_age_sex_length_CU, overwrite = TRUE )

# Save omega and omega_J and age observations
usethis::use_data( omega, overwrite = TRUE)
usethis::use_data( omega_J, overwrite = TRUE)
usethis::use_data( n_age_observations, overwrite = TRUE)

