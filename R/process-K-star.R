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
k_star_old <- pivot_longer(kat, cols = 2:5, names_to = "a", values_to = "K_star")




# Read in new age observation data ---------
# This was produced in kitsumkalum repo
# Age observations of wild Kitsumkalum chinook
a_new <- read.csv(here("data-raw", "kitsumkalum", "kitsumkalum-age-observations-by-sex-2021-2024.csv"))
# add a 0 observation for age 7 so that array has age 7 fish
a_new <- rbind( a_new, data.frame( "y" = 2024, "a" = 7, "s" = "M", "n" = 0))
# make age observations array
n <- df_to_array(a_new, value = "n", dimnames_order = c("s", "y", "a"), FUN = sum, default = 0)
n

omega_K <- get_omega(n[ ,, as.character(4:7)] )
omega_K$omega

apply(omega_K$omega[ "M",, ], 1, sum)
apply(omega_K$omega[ "F",, ], 1, sum)

omega_KM <- omega_K$omega[ "M",, ]
omega_KF <- omega_K$omega[ "F",,]

# read in hatchery contribution (need updated CTC model data)
# ctc <- read.csv()
# H_star <- as.array
# H <- H_star %>% group_by(return_year) %>% summarise(H = sum(hatchery_contribution))

# Get K_star for 2021-2024
kitsumkalum <- read.csv( here("data-raw","kitsumkalum", "kitsumkalum-escapement.csv"))
ks <- kitsumkalum[ kitsumkalum$year >= 2021, ]

get_K_star( K = ks$kitsumkalum_escapement, y_K = ks$year, K_M = ks$male_escapement,
            K_F = ks$female_escapement, omega_KM = omega_KM, omega_KF = omega_KF,
            H = H, H_star = H_star)

