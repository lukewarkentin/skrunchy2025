# Read in and process Chinook ERA model outputs

# This includes hatchery escapement data, exploitation rates, maturation rates, and AEQ rates.

# These are the values in the run reconstruction that are produced by this script:

# H - hatchery spawners
# H_star - hatchery spawners
# tau_dot_M - terminal marine exploitation rate (note, may also include Tyee)
# phi_dot_M - preterminal net total mortality harvest rate of mature fish
#       (0 for age 3-4, sum of ALASKA N and CENTRL N for age 5-6)
# r - maturation rate
# phi_dot_E - preterminal total mortality exploitation rate (including immature fish)
#       for age 5-6 fish, sum of ER for all other fisheries (excludes ALASKA N and CENTRAL N)
#       for age 3-4 fish, sum of ER for all other fisheries and ALASKA N and CENTRL N)
# Q - Adult equivalency rate

# Notes
# This uses the older xlsx output file. There is a newer rds file output
# but I still don't have enough information to use that.

# Note that all brood year 2019 releases were untagged and unclipped.
# CWT_Release column does not reflect this for brood year 2019.
# FLAG: Was escape column for 2019 brood year done using pseudo-recoveries?

library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(skrunchy)
library(ggplot2)
library(zoo)

path <- "data-raw/kitsumkalum"


# Start with H and H_star
# Read in CWT (hatchery origin) escapement data
file <- "chinook-cwt-ERA-outfiles_2025-03-06_KLM-KLY.xlsx"
# escapement
sheet <- "BY mat aeq cohort"
by_mat_aeq_cohort <- read_xlsx( path = here(path, file), sheet = sheet)
# Check that escapement is identical between calendar year and brood year methods.
# Yes, it is.
# cy_mat_aeq_cohort <- read_xlsx( path = here(path, file), sheet = "CY mat aeq cohort")
# check <- merge(by_mat_aeq_cohort, cy_mat_aeq_cohort, by = c("Stock", "Brood.Yr", "age"), all = TRUE, suffixes = c("_by", "_cy"))
# range(check$escape_by - check$escape_cy)
# Go ahead with by method for escapement
by_mat_aeq_cohort$Brood.Yr <- as.integer(by_mat_aeq_cohort$Brood.Yr)

# Expand cwt escapement with mark rates by brood year, stock
sheet <- "Releases total"
releases_total <- read_xlsx( path = here(path, file), sheet = sheet)
releases_total$expansion_factor <- releases_total$total_Release / releases_total$CWT_Release
releases_total$Brood.Yr <- as.integer(releases_total$Brood.Yr)

esc <- merge( by_mat_aeq_cohort, releases_total[ , c(1,2,5)] , by = c("Stock", "Brood.Yr") )
esc$escape_expanded <- esc$escape * esc$expansion_factor
esc$return_year <- esc$Brood.Yr + esc$age

esc_sum <- esc %>% group_by( return_year, age) %>% summarise( H_star = round(sum(escape_expanded, na.rm= TRUE))) %>%
  filter( age >=4, return_year >= 1984)


names(esc_sum)[ grep("return_year", names(esc_sum))] <- "y"
names(esc_sum)[ grep("age", names(esc_sum))] <- "a"


H_star <- df_to_array( esc_sum, "H_star", dimnames_order = c("y", "a"), FUN = sum, default = 0 )
str(H_star)
str(ex_H_star)
class(H_star)


esc_sum_total <- esc_sum %>% group_by(y) %>% summarise(H = sum(H_star, na.rm=TRUE))

H <- esc_sum_total$H
names(H) <- esc_sum_total$y
H
str(H)
str(ex_H)

# tau_dot_M   -   Terminal marine exploitation rate
# Sum of TNBC TERM N and TNBC TERM S
# check if there are differences between BY and CY for age-specific ER rates
sheet <- "BY Morts and ERs "
by_er <- read_xlsx( path = here(path, file), sheet = sheet)
by_er$age <- as.integer(by_er$age)
# compare with cy_er
cy_er <- read_xlsx( path = here(path, file), sheet = "CY Morts and ERs ")
check <- merge(by_er, cy_er, by.x = c("Stock", "Fishery", "Fishery_Name", "by", "age"), by.y = c("Stock", "Fishery", "Fishery_Name", "cy", "age"), all = TRUE, suffixes = c("_by", "_cy"))
check1 <- check[ check$age>3, ]
ggplot(check1, aes( y = ER_legal_by, x = ER_legal_cy)) +
  geom_point()
range(check1$ER_legal_by - check1$ER_legal_cy)
hist(check1$ER_legal_by - check1$ER_legal_cy )
check1$dif <- abs( check1$ER_legal_by - check1$ER_legal_cy )
# some very small differences, mainly identical. Use brood year for now. Not too concerned about that one.

# ER total is misnamed. It is actually the ER from incidental mortality (shaker, non-retention, etc)
# make a new variable named ER that is actually the legal catch + Incidental mortality
by_er$ER <- by_er$ER_legal + by_er$ER_total
# Make tau_dot_M
# Use Terminal Northern BC Terminal Net fisheries (includes river gap slough, terminal gillnet and seine fisheries)
#           FLAG - need to confirm if this uses Tyee test fishery recoveries!!!! Don't want to double count them
# and Terminal Northern BC Terminal Sport fisheries (areas 3-4?)
tau_dot_M_fisheries <- c("TNBC TERM N", "TNBC TERM S")

tau_dot_M_df <- by_er %>% filter(Fishery_Name %in% tau_dot_M_fisheries, Stock == "KLM", age >=4 ) %>%
  group_by( by, age) %>%
  summarise( tau_dot_M = sum(ER, na.rm=TRUE)) %>% mutate(y = by + age)

# rename to skrunchy var names
names(tau_dot_M_df)[ grep("age", names(tau_dot_M_df))] <- "a"
# convert to array
tau_dot_M <- df_to_array( tau_dot_M_df, value = "tau_dot_M", dimnames_order = c("y", "a"), FUN = sum, default = 0)
# make array with NA for values >0.5, for rolling mean
tau_dot_M_drop_hi_vals <- ifelse(tau_dot_M < 0.5, tau_dot_M, NA)
# running mean of drop hi vals array
tau_dot_M_rollmean <- rollapply(tau_dot_M_drop_hi_vals, width = 5, FUN = mean,
                                by.column = TRUE,
                                na.rm=TRUE, fill = NA, partial = TRUE )
# sub rollmean for hi values
tau_dot_M_fix <- ifelse( tau_dot_M < 0.5, tau_dot_M, tau_dot_M_rollmean)

ggplot( array2DF(tau_dot_M_fix), aes( y = )

# Save rds data files

usethis::use_data(H_star, overwrite = TRUE)
usethis::use_data(H, overwrite = TRUE)







# # Temp, for newer R-generated, rds files ------------
# str(KLM)
# head(KLM$data_list$Recoveries)
# head(KLM$data_list$camp_fishery_era )
# head(KLM$data_list$ream_pnv_data )
# head(KLM$data_list$ream_cnr_data )
# head(KLM$data_list$ream_cnr_data_weighted )

