# Process data and produce age-specific escapement for Kitsumkalum River (K_star)


library(here)
library(readxl)
library(tidyr)
library(skrunchy)
library(ggplot2)
library(dplyr)



# Read in escapement by age, for male, female, and total, 1984-2020.
ka <- read_xlsx(here("data-raw/kitsumkalum/kitsumkalum-escapement-by-age-1984-2020.xlsx"), skip = 1)
# get just total
kat <- ka[ , c(1,12:15)]
names(kat) <- c("y", "4", "5", "6", "7")
K_star_old_df <- pivot_longer(kat, cols = 2:5, names_to = "a", values_to = "K_star")

K_star_old <- df_to_array(K_star_old_df, value = "K_star", dimnames_order = c("y", "a"), FUN = sum, default = 0)


# Get K_star for 2021-2024 --------

# Read in new age observation data, 2021-2024
# This was produced in the kitsumkalum repo
# Age observations of wild Kitsumkalum chinook
a_new <- read.csv(here("data-raw", "kitsumkalum", "kitsumkalum-age-observations-by-sex-2021-2024.csv"))
# add a 0 observation for age 7 so that array has age 7 fish
a_new <- rbind( a_new, data.frame( "y" = 2024, "a" = 7, "s" = "M", "n" = 0))
# make age observations array
n <- df_to_array(a_new, value = "n", dimnames_order = c("s", "y", "a"), FUN = sum, default = 0)
n
# Get age proportions of age 4-7 fish only
omega_K <- get_omega(n[ ,, as.character(4:7)] )
omega_K$omega

apply(omega_K$omega[ "M",, ], 1, sum)
apply(omega_K$omega[ "F",, ], 1, sum)

omega_KM <- omega_K$omega[ "M",, ]
omega_KF <- omega_K$omega[ "F",,]

# Read in escapement, total and male / female
# FLAG: need 2022 male, female escapement still
kitsumkalum <- read.csv( here("data-raw","kitsumkalum", "kitsumkalum-escapement.csv"))
ks <- kitsumkalum[ kitsumkalum$year >= 2021 & kitsumkalum$year <= 2024, ]

# read in hatchery contribution (need updated CTC model data)
H

# Get K_star for 2021-2024
K_star_new <- get_K_star( K = ks$kitsumkalum_escapement, y_K = ks$year, K_M = ks$male_escapement,
            K_F = ks$female_escapement, omega_KM = omega_KM, omega_KF = omega_KF,
            H = H[ names(H) %in% 2021:2024 ], H_star = H_star[ as.character(2021:2024),  ])
K_star_new
# bind old and new years together
dimnames(K_star_old)[[2]]

dimnames(K_star_new$K_star)[[2]]

K_star <- round(abind(K_star_old, K_star_new$K_star, along = 1 ))

K_star
dimnames(K_star)
dimnames(K_star) <- list( "y" = dimnames(K_star)[[1]], "a" = dimnames(K_star)[[2]])

# save data
usethis::use_data(K_star, overwrite = TRUE)

