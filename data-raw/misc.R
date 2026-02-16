library(here)


variable_name_key <- read.csv(here("data-raw/variable-name-key.csv"))


usethis::use_data(variable_name_key, overwrite = TRUE)

