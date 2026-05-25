# Create rda file for brood removals

library(here)
library(skrunchy)


d <- read.csv(here("data-raw/kitsumkalum/brood-removals.csv"))
d <- d[d$y <= 2024, ]

B_star <- df_to_array(
  d,
  value = "brood_removals",
  dimnames_order = c("y", "a"),
  FUN = sum,
  default = 0
)


usethis::use_data(B_star, overwrite = TRUE)
