# Process Kitsumkalum spawners data.
# Total

# Save .rda data file of kitsumkalum spawners to data/ folder


library(here)
library(readxl)
library(tidyr)
library(skrunchy)
library(ggplot2)
library(dplyr)

# Process escapement data
kitsumkalum <- read.csv( here("data-raw","kitsumkalum", "kitsumkalum-escapement.csv"))

# Save data to data/ as .rda files
usethis::use_data(kitsumkalum, overwrite = TRUE)





