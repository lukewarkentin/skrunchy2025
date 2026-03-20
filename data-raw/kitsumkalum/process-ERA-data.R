# Read in and process Chinook ERA model outputs

# This includes hatchery escapement data, exploitation rates, maturation rates, and AEQ rates.

# Note on marked releases (KLM = fry): releases started in 1979, had low numbers
# in 1979-1981 (marked 48091, 44273, 52693), no releases in 1982.
# 1983 also had low releases (marked = 30716).
# Releases (stock = KLM) of >100,000 fry in 1984-present. Minimum fry releases = 101,360.
# Average fry releases of ~179,000 1984-present.

# These are the values in the run reconstruction that are produced by this script:

# H - hatchery spawners
# H_star - hatchery spawners
# tau_dot_M - terminal marine exploitation rate (note, may also include Tyee)
# phi_dot_M - preterminal net total mortality harvest rate of mature fish
#       (0 for age 3-4, sum of ALASKA N and CENTRL N for age 5-6)
# r - maturation rate
# phi_dot_E - preterminal total mortality exploitation rate (including immature fish)
#       -for age 5-6 fish, sum of ER for all other fisheries (excludes ALASKA N and CENTRAL N)
#       -for age 3-4 fish, sum of ER for all other fisheries and ALASKA N and CENTRL N)
# Q - Adult equivalency rate

# Important notes on QAQC:
# Have to estimate missing values for brood year 1982, ages 4 (ry = 1986), 5 (ry = 1987), and 6 (ry = 1988)
# and for brood year 1978, return year 1984, age 6
# Values to estimate based on averages etc. for other years:
# tau_dot_M
# phi_dot_M
# r
# phi_dot_E
# Q
# IW methods: used averages or single values from (mainly) subsequent years.
#   (file "V20-4-KLM_&_Skeena_CalcSR_2024-01-15.xlsx", tab "Review-Cohrt Anal Rates")
# - For Q, r, phi_dot_E, it was average values for brood years 1984-1986
# - For phi_dot_M, it was single value from brood year 1983. Not sure why IW used 1983 only for this value.
#     - NOTE: for this analysis, choosing to use the same average of brood years 1984-1986 as used for the other values.
# - For tau_dot_M, it was average of values for brood years:
#     - 1984, 1985, and 1987 for age 6 (by 1986 has a 0 value)
#     - 1984, 1985, 1986 for age 5
#     - 1981, 1984, 1985, 1986 for age 4.
#         - Note: I am going to drop brood year 1981 to be consistent.
# - For return year 1984, age 6 (brood year 1978, no releases), all values were
#   the same as for return year 1988, age 6.
#
# For estimating these missing rates, I think IW avoided using release cohorts from
# 1979-1981, 1983 because these years didn't have as many releases as 1984-present.
# Thus, would expect more "typical" rates from brood year 1984-onwards
#
# Also: IW calculated average age 4 maturation rate (r) for brood year 1999
# (return year 2003) due to exceptionally low value derived from actual data (raw value = 0.0012)
# using average of brood years 1987, 1988, 2000, 2001

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


# Start with H and H_star --------------
# Read in CWT (hatchery origin) escapement data
file <- "chinook-cwt-ERA-outfiles_2025-03-06_KLM-KLY.xlsx"
# escapement
sheet <- "BY mat aeq cohort"
by_mat_aeq_cohort <- read_xlsx(path = here(path, file), sheet = sheet)
# Check that escapement is identical between calendar year and brood year methods.
# Yes, it is.
# cy_mat_aeq_cohort <- read_xlsx( path = here(path, file), sheet = "CY mat aeq cohort")
# check <- merge(by_mat_aeq_cohort, cy_mat_aeq_cohort, by = c("Stock", "Brood.Yr", "age"), all = TRUE, suffixes = c("_by", "_cy"))
# range(check$escape_by - check$escape_cy)
# Go ahead with by method for escapement
by_mat_aeq_cohort$Brood.Yr <- as.integer(by_mat_aeq_cohort$Brood.Yr)

# Expand cwt escapement with mark rates by brood year, stock
sheet <- "Releases total"
releases_total <- read_xlsx(path = here(path, file), sheet = sheet)
releases_total$expansion_factor <- releases_total$total_Release /
  releases_total$CWT_Release
releases_total$Brood.Yr <- as.integer(releases_total$Brood.Yr)

esc <- merge(
  by_mat_aeq_cohort,
  releases_total[, c(1, 2, 5)],
  by = c("Stock", "Brood.Yr")
)
esc$escape_expanded <- esc$escape * esc$expansion_factor
esc$return_year <- esc$Brood.Yr + esc$age

esc_sum <- esc %>%
  group_by(return_year, age) %>%
  summarise(H_star = round(sum(escape_expanded, na.rm = TRUE))) %>%
  filter(age >= 4)


names(esc_sum)[grep("return_year", names(esc_sum))] <- "y"
names(esc_sum)[grep("age", names(esc_sum))] <- "a"


H_star <- df_to_array(
  esc_sum,
  "H_star",
  dimnames_order = c("y", "a"),
  FUN = sum,
  default = 0
)
H_star <- H_star[as.character(1984:2024), ]


esc_sum_total <- esc_sum %>%
  group_by(y) %>%
  summarise(H = sum(H_star, na.rm = TRUE))

H <- esc_sum_total$H
names(H) <- esc_sum_total$y
H
H <- H[as.character(1984:2024)]

# tau_dot_M   -   Terminal marine exploitation rate -------------
# Sum of TNBC TERM N and TNBC TERM S
# check if there are differences between BY and CY for age-specific ER rates
sheet <- "BY Morts and ERs "
by_er <- read_xlsx(path = here(path, file), sheet = sheet)
by_er$age <- as.integer(by_er$age)
# compare with cy_er
cy_er <- read_xlsx(path = here(path, file), sheet = "CY Morts and ERs ")
check <- merge(
  by_er,
  cy_er,
  by.x = c("Stock", "Fishery", "Fishery_Name", "by", "age"),
  by.y = c("Stock", "Fishery", "Fishery_Name", "cy", "age"),
  all = TRUE,
  suffixes = c("_by", "_cy")
)
check1 <- check[check$age > 3, ]
ggplot(check1, aes(y = ER_legal_by, x = ER_legal_cy)) +
  geom_point()
range(check1$ER_legal_by - check1$ER_legal_cy)
hist(check1$ER_legal_by - check1$ER_legal_cy)
check1$dif <- abs(check1$ER_legal_by - check1$ER_legal_cy)
# some very small differences, mainly identical. Use brood year for now. Not too concerned about that one.

# ER total is misnamed. It is actually the ER from incidental mortality (shaker, non-retention, etc)
# make a new variable named ER that is actually the legal catch + Incidental mortality
by_er$ER <- by_er$ER_legal + by_er$ER_total
# Make tau_dot_M
# Use Terminal Northern BC Terminal Net fisheries (includes river gap slough, terminal gillnet and seine fisheries (not happening anymore))
#           FLAG - need to confirm if this uses Tyee test fishery recoveries!!!! Don't want to double count them
# and Terminal Northern BC Terminal Sport fisheries (areas 3-4?)
tau_dot_M_fisheries <- c("TNBC TERM N", "TNBC TERM S")

tau_dot_M_df <- by_er %>%
  filter(Fishery_Name %in% tau_dot_M_fisheries, Stock == "KLM", age >= 4) %>%
  group_by(by, age) %>%
  summarise(tau_dot_M = sum(ER, na.rm = TRUE)) %>%
  mutate(y = by + age)

# rename to skrunchy var names
names(tau_dot_M_df)[grep("age", names(tau_dot_M_df))] <- "a"
# convert to array
tau_dot_M_raw <- df_to_array(
  tau_dot_M_df,
  value = "tau_dot_M",
  dimnames_order = c("y", "a"),
  FUN = sum,
  default = 0
)

# sub rollmean for hi values
tau_dot_M <- process_rates(tau_dot_M_raw)
tau_dot_M

plot(as.vector(tau_dot_M_raw))
points(as.vector(tau_dot_M), col = "red")


# For brood year 1982 (no releases), replace with averages of brood years 1984-1986
tau_dot_M["1986", "4"] <- mean(tau_dot_M[as.character(1988:1990), "4"])
tau_dot_M["1987", "5"] <- mean(tau_dot_M[as.character(1989:1991), "5"])
# For age 6, use brood years 1984, 1985, 1987 (1986 has 0 value)
tau_dot_M["1988", "6"] <- mean(tau_dot_M[
  as.character(c(1990, 1991, 1993)),
  "6"
])
# Return year 1984, age 6 (brood year 1978, no releases), use same as replacement value for return year 1988
tau_dot_M["1984", "6"] <- mean(tau_dot_M[
  as.character(c(1990, 1991, 1993)),
  "6"
])
tau_dot_M <- tau_dot_M[as.character(1984:2024), ]

# phi_dot_M - preterminal net total mortality harvest rate of mature fish ----------
#       (0 for age 3-4, sum of ALASKA N and CENTRL N for age 5-6)
phi_dot_M_fisheries <- c("ALASKA N", "CENTRL N")

phi_dot_M_df <- by_er %>%
  filter(Fishery_Name %in% phi_dot_M_fisheries, Stock == "KLM", age >= 4) %>%
  group_by(by, age) %>%
  summarise(phi_dot_M = sum(ER, na.rm = TRUE)) %>%
  mutate(y = by + age)

# rename to skrunchy var names
names(phi_dot_M_df)[grep("age", names(phi_dot_M_df))] <- "a"
# convert to array
phi_dot_M_raw <- df_to_array(
  phi_dot_M_df,
  value = "phi_dot_M",
  dimnames_order = c("y", "a"),
  FUN = sum,
  default = 0
)
plot(as.vector(phi_dot_M_raw))
# sub rollmean for hi values
phi_dot_M <- process_rates(phi_dot_M_raw)
# for age 4, replace all values with 0s. This is because these are considered immature fish.
phi_dot_M[, "4"] <- 0
phi_dot_M

# For brood year 1982 (no releases), replace with with averages of brood years 1984-1986
#phi_dot_M[ "1986", "4" ] <- phi_dot_M[ "1987", "4"] # not needed, all values for age 4 are 0
phi_dot_M["1987", "5"] <- mean(phi_dot_M[as.character(1989:1991), "5"])
phi_dot_M["1988", "6"] <- mean(phi_dot_M[as.character(1990:1992), "6"])
# Return year 1984, age 6 (brood year 1978, no releases), use same as replacement value for return year 1988
phi_dot_M["1984", "6"] <- mean(phi_dot_M[as.character(1990:1992), "6"])
# clip to time series
phi_dot_M <- phi_dot_M[as.character(1984:2024), ]
phi_dot_M

# r - maturation rate -----------------
esc1 <- esc %>% filter(age > 3, Stock == "KLM")
names(esc1)[grep("return_year", names(esc1))] <- "y"
names(esc1)[grep("age", names(esc1))] <- "a"

r <- df_to_array(esc1, value = "mat", dimnames_order = c("y", "a"), FUN = sum)
r[, "6"] <- 1 # should be 1 for all age 6 cohorts
r
# there are some 0 values for age 4, 5 in return year 1984, 1986, 1987. What to do with those?
# For brood year 1982 (no releases), replace with averages of brood years 1984-1986
r["1986", "4"] <- mean(r[as.character(1988:1990), "4"])
r["1987", "5"] <- mean(r[as.character(1989:1991), "5"])
# brood year 1979, return year 1984, age 5 had r = 0. Replace with average of brood year 1984-1986
r["1984", "5"] <- mean(r[as.character(1989:1991), "5"])
# brood year 1983, return year 1987, age 4 had r = 0. Replace with average of brood year 1984-1986
r["1987", "4"] <- mean(r[as.character(1988:1990), "4"])
r
r <- r[as.character(1984:2024), ]
r
r == 0

# phi_dot_E - preterminal total mortality exploitation rate (including immature fish) ----------------
#       for age 5-6 fish, sum of ER for all other fisheries (excludes ALASKA N and CENTRAL N)
#       for age 3-4 fish, sum of ER for all other fisheries and ALASKA N and CENTRL N)

# Read in fisheries key with LW notes
file <- "fishery-lookup-CWT-ERA-notes.csv"
fkey <- read.csv(here(path, file))
names(fkey)
# Fisheries to use for preterminal exploitation rate
phi_dot_E_fisheries_age56 <- fkey$FisheryName[
  fkey$used_for_preterminal_ER_phi_dot_E_age5_6 == "yes"
]
# add net fisheries for age 4 fish (considered immature). These were used for
# preterminal net harvest rate of mature fish (phi_dot_M) above, for age 5-6 fish,
# but set at 0 for age 4 fish. Include them here so that mortality of age 4 fish can be
# adjsuted for maturation rate and adult equivalents.
phi_dot_E_fisheries_age4 <- c(phi_dot_E_fisheries_age56, "ALASKA N", "CENTRL N")
# summarise for age 5-6 fish
phi_dot_E_df_age56 <- by_er %>%
  filter(
    Fishery_Name %in% phi_dot_E_fisheries_age56,
    Stock == "KLM",
    age >= 5
  ) %>%
  group_by(by, age) %>%
  summarise(phi_dot_E = sum(ER, na.rm = TRUE)) %>%
  mutate(y = by + age)
# summarise for age 4 fish
phi_dot_E_df_age4 <- by_er %>%
  filter(
    Fishery_Name %in% phi_dot_E_fisheries_age4,
    Stock == "KLM",
    age == 4
  ) %>%
  group_by(by, age) %>%
  summarise(phi_dot_E = sum(ER, na.rm = TRUE)) %>%
  mutate(y = by + age)
# combine age 4 and age 5-6 rates
phi_dot_E_df <- rbind(phi_dot_E_df_age4, phi_dot_E_df_age56)
# rename to skrunchy var names
names(phi_dot_E_df)[grep("age", names(phi_dot_E_df))] <- "a"
# convert to array
phi_dot_E_raw <- df_to_array(
  phi_dot_E_df,
  value = "phi_dot_E",
  dimnames_order = c("y", "a"),
  FUN = sum,
  default = 0
)
# sub rollmean for hi values
phi_dot_E <- process_rates(phi_dot_E_raw)

# For brood year 1982 (no releases), replace with averages of brood years 1984-1986
phi_dot_E["1986", "4"] <- mean(phi_dot_E[as.character(1988:1990), "4"])
phi_dot_E["1987", "5"] <- mean(phi_dot_E[as.character(1989:1991), "5"])
phi_dot_E["1988", "6"] <- mean(phi_dot_E[as.character(1990:1992), "6"])
# Return year 1984, age 6 (brood year 1978, no releases), use same as replacement value for return year 1988
phi_dot_E["1984", "6"] <- mean(phi_dot_E[as.character(1990:1992), "6"])
# clip years
phi_dot_E <- phi_dot_E[as.character(1984:2024), ]

# Q - Adult equivalency rate ----------------

Q <- df_to_array(esc1, value = "AEQ", dimnames_order = c("y", "a"), FUN = sum)
Q[, "6"] <- 1 # should be 1 for all age 6 cohorts
Q

# For brood year 1982 (no releases), replace with averages of brood years 1984-1986
Q["1986", "4"] <- mean(Q[as.character(1988:1990), "4"])
Q["1987", "5"] <- mean(Q[as.character(1989:1991), "5"])
Q <- Q[as.character(1984:2024), ]
Q

# Create master table of all rates after QAQC
# function to combine arrays into data frame
comb_arr <- function(x) {
  # Check list has names
  if (is.null(names(x))) {
    stop("List must be named.")
  }

  # Convert each array to data frame using its list name
  l_df <- Map(
    function(arr, nm) {
      array2DF(arr, responseName = nm)
    },
    x,
    names(x)
  )

  # Merge all data frames by the first two dimension columns
  combdf <- Reduce(
    function(d1, d2) {
      merge(d1, d2, by = c("y", "a"), all = TRUE)
    },
    l_df
  )

  combdf$y <- as.numeric(combdf$y)
  combdf$a <- as.numeric(combdf$a)
  combdf$b <- combdf$y - combdf$a
  return(combdf)
}

listarr <- list(
  "H_star" = H_star,
  "tau_dot_M" = tau_dot_M,
  "phi_dot_M" = phi_dot_M,
  "r" = r,
  "phi_dot_E" = phi_dot_E,
  "Q" = Q
)
ERA_w <- comb_arr(listarr)
ERA_l <- ERA_w %>%
  pivot_longer(., cols = 3:8, names_to = "var", values_to = "value")
ERA_data_processed <- list(df_wide = ERA_w, df_long = ERA_l)
names(ERA_data_processed)

png(
  here("fig/all_ERA_data_processed.png"),
  width = 10,
  height = 6,
  units = "in",
  res = 600
)
ggplot(ERA_l, aes(y = value, x = y, colour = factor(a), group = a)) +
  geom_point() +
  geom_line() +
  facet_wrap(~var, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  scale_x_continuous(breaks = seq(1985, 2025, 5)) +
  xlab("Return year") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
dev.off()

# ggplot(ERA_l, aes( y= value, x = b, colour = factor(a), group = a)) +
#   geom_point() + geom_line() +
#   facet_wrap(~ var, scales = "free_y") +
#   geom_hline( aes( yintercept = 0)) +
#   scale_x_discrete( breaks = seq(1985, 2025, 5)) +
#   xlab( "Brood year") +
#   theme_classic() +
#   theme( axis.text.x = element_text ( angle = 90, vjust = 0.5))

# Save rds data files
r_maturation_rate <- r
usethis::use_data(
  H_star,
  H,
  tau_dot_M,
  phi_dot_M,
  r_maturation_rate,
  phi_dot_E,
  Q,
  ERA_data_processed,
  overwrite = TRUE
)

write.csv(
  ERA_data_processed$df_wide,
  here("data/ERA_data_processed.csv"),
  row.names = FALSE
)
