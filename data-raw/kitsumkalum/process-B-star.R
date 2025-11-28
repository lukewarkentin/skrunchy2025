B# Create rda file for brood removals

library(here)
library(skrunchy)


d <- read.csv(here("data-raw/brood-removals.csv"))

B_star <- df_to_array(d, value= "brood_removals", dimnames_order = c("y", "a"), FUN = sum, default = 0)




usethis::use_data(B_star, overwrite = TRUE)
