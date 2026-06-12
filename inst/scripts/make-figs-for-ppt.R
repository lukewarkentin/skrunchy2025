library(ggplot2)
library(latex2exp)
library(here)
library(dplyr)

#library(skrunchy2025) # turn on to knit, must have fresh install
# build_rmd(here("Rmd/run-reconstruction-1984-2024.Rmd"))
# Load all files in data/ folder
devtools::load_all(".") # Turn on to run in console

options(scipen = 999)

skeena_order <- c(
  "Lower Skeena",
  "Kitsumkalum",
  "Zymoetz",
  "Middle Skeena",
  "Large Lakes",
  "Upper Skeena",
  "Skeena Aggregate"
)

d <- run_reconstruction_table_summary
d$i_population <- sub(
  "^Skeena$",
  "Skeena Aggregate",
  d$i_population
)

png(
  here("inst/fig/total-run-spawners-harvest.png"),
  width = 8,
  height = 5,
  units = "in",
  res = 600
)
ggplot(
  d,
  aes(y = N_total_run / 1000, x = y_return_year)
) +
  geom_line(aes(colour = "Total Run")) +
  geom_hline(aes(yintercept = 0)) +
  ylab(TeX(
    "Total run, wild spawners, and harvest (000s)"
  )) +
  xlab("Return year") +
  coord_cartesian(expand = FALSE, clip = FALSE) +
  geom_line(aes(y = W_wild_spawners / 1000, colour = "Wild Spawners")) +
  geom_ribbon(
    aes(
      ymin = W_wild_spawners / 1000,
      ymax = N_total_run / 1000,
      fill = "Harvest + Incidental Mortality"
    ),
    colour = NULL,
    alpha = 0.2
  ) +
  # Manual color scale for lines
  scale_color_manual(
    name = "",
    values = c(
      "Total Run" = "black",
      "Wild Spawners" = "dodgerblue",
      "Harvest + Incidental Mortality" = "firebrick"
    )
  ) +
  # Manual fill scale for polygon
  scale_fill_manual(
    name = "",
    values = c(
      "Harvest + Incidental Mortality" = "firebrick"
    )
  ) +
  facet_wrap(~ factor(i_population, levels = skeena_order), scales = "free_y") +
  theme_classic() +
  theme(legend.position = c(0.8, 0.1), strip.background = element_blank()) # top-right inside plot)
dev.off()
