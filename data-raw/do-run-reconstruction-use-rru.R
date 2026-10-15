# data-raw/do-run-reconstruction

# 1. Setup ---------------------------
# install.packages("pak")
# pak::pak("Pacific-salmon-assess/skrunchy")
options(scipen = 999)

library(skrunchy)
library(dplyr)
library(tidyr)
library(here)
library(dplyr)
#library(skrunchy2025)
library(ggplot2)

# 2. Load processed inputs in data/ folder ----------------------
devtools::load_all(".")


# Pre process some data
kitsumkalum <- kitsumkalum[kitsumkalum$year <= 2024, ]
# Quick fix for r, age 4, year = 2003, very low
r_use <- r_maturation_rate
r_use["2003", "4"] <- mean(r_use[as.character(c(2001:2002, 2004:2005)), "4"])

# Get sample numbers
n_gsi_samples <- tyee_biodata_age_sex_length_CU |>
  filter(!is.na(i)) |>
  group_by(y) |>
  summarize(n = n())
n_age_samples <- apply(n_age_observations, c(1, 2), sum)
#n_age_samples_J <-

# 3. Run reconstruction using rr() wrapper function --------------------
run_recon <- rru_iterate(
  n_iter = 1000,
  seed = 1,
  n_gsi_samples = n_gsi_samples$n,
  n_age_samples = n_age_samples,
  n_age_samples_J = n_age_samples, # FLAG : update with slightly large sample sizes including jack ages
  P = P,
  sigma_P = sigma_P,
  G = G,
  K = kitsumkalum$kitsumkalum_escapement,
  sigma_K = kitsumkalum$sd,
  y_K = kitsumkalum$year,
  omega = omega$omega,
  omega_J = omega_J$omega["Skeena", , ],
  tyee = Tau$tyee,
  cv_freshwater_mortality = 0.2,
  use_tyee = FALSE,
  rec_catch_L = Tau$rec_catch_L,
  rec_release_L = Tau$rec_release_L,
  FN_catch_L = Tau$FN_catch_L,
  rec_catch_U = Tau$rec_catch_U,
  FN_catch_U = Tau$FN_catch_U,
  known_population = "Kitsumkalum",
  aggregate_population = "Skeena",
  lower_populations = c("Lower Skeena", "Zymoetz"),
  upper_populations = c("Upper Skeena", "Middle Skeena", "Large Lakes"),
  K_star = K_star,
  use_alternate_escapement_by_age = TRUE,
  population_use_age_from_river_samples = "Kitsumkalum",
  add_6_7 = TRUE,
  B_star = B_star,
  H_star = H_star,
  rate_resample_method = "lognormal",
  rate_resample_cv = 0.3,
  rate_resample_max_er = 0.5,
  tau_dot_M = tau_dot_M,
  phi_dot_M = phi_dot_M,
  r = r_use,
  phi_dot_E = phi_dot_E,
  Q = Q,
  name_key = variable_name_key,
  save_outputs = FALSE,
  save_outputs_iterate = TRUE
)

# Plot new summaries
# get df summary
#sdat <- run_recon[[1]]

sdat <- run_reconstruction_table_summary_with_uncertainty
fdat <- run_reconstruction_table_with_uncertainty


# Compare to conventional run recon numbers
od <- run_reconstruction_table_summary
odl <- pivot_longer(od, cols = 3:6, names_to = "variable", values_to = "old")
md <- merge(sdat, odl, by = c("i_population", "y_return_year", "variable"))
md$dif <- md$mean - md$old

# Compare full data
odf <- run_reconstruction_table
odfl <- pivot_longer(odf, cols = 5:27, names_to = "var", values_to = "old")
mfd <- merge(
  fdat,
  odfl,
  by.x = c("i_population", "y_return_year", "a_age", "var"),
  by.y = c("i_population", "y_return_year", "a_age", "var")
)
names(mfd)

mfd$dif = mfd$mean - mfd$old


ggplot(mfd, aes(y = mean, x = old, colour = i_population)) +
  geom_point() +
  geom_errorbar(aes(ymin = p5, ymax = p95)) +
  geom_abline(aes(slope = 1, intercept = 0)) +
  xlab("conventional methods") +
  ylab("uncertainty methods") +
  facet_wrap(~var, scales = "free") +
  theme_classic()

# Issue seems to start at p_proportion_wild_spawners
ggplot(mfd, aes(y = dif, x = y_return_year, colour = i_population)) +
  geom_point() +
  ylab("Difference") +
  facet_wrap(~var, scales = "free") +
  theme_classic()


ggplot(mfd, aes(y = dif, x = y_return_year)) +
  geom_point() +
  ylab("Difference") +
  facet_grid(i_population ~ var, scales = "free") +
  theme_classic()

mfd |>
  filter(i_population == "Kitsumkalum") |>
  ggplot(aes(y = dif, x = y_return_year)) +
  geom_point() +
  ylab("Difference") +
  geom_hline(aes(yintercept = 0)) +
  facet_wrap(~var, scales = "free") +
  theme_classic()

mfd |>
  filter(i_population == "Kitsumkalum", var == "p_proportion_wild_spawners") |>
  ggplot(aes(y = mean, x = y_return_year)) +
  geom_point() +
  geom_line() +
  geom_hline(aes(yintercept = 0)) +
  facet_wrap(~a_age) +
  theme_classic()

mfd |>
  filter(i_population == "Skeena", var == "p_proportion_wild_spawners") |>
  ggplot(aes(y = mean, x = y_return_year)) +
  geom_point() +
  geom_line() +
  geom_hline(aes(yintercept = 0)) +
  facet_wrap(~a_age) +
  theme_classic()

check <- mfd[which(mfd$mean == -Inf), ]

# issue with E_escapement

mfd |>
  filter(i_population == "Kitsumkalum", var == "E_star_escapement") |>
  ggplot(aes(y = dif, x = y_return_year)) +
  geom_line() +
  geom_point() +
  geom_hline(aes(yintercept = 0)) +
  facet_wrap(~a_age, scales = "free") +
  theme_classic()

mfd |>
  filter(var == "E_star_escapement") |>
  ggplot(aes(y = dif, x = y_return_year)) +
  geom_line() +
  geom_point() +
  geom_hline(aes(yintercept = 0)) +
  facet_grid(i_population ~ a_age, scales = "free") +
  theme_classic()

# Okay clearly an issue with p_proportion_wild_spawners - seems fixed?

mfd |>
  filter(i_population == "Kitsumkalum", var == "p_proportion_wild_spawners") |>
  ggplot(aes(y = dif, x = y_return_year)) +
  geom_line() +
  geom_point() +
  ylab("Difference") +
  geom_hline(aes(yintercept = 0)) +
  facet_wrap(~a_age, scales = "free") +
  theme_classic()


# Different age proportions from Tyee and Kitsumkalum river - effects
mfd |>
  filter(
    i_population == "Kitsumkalum",
    var == "phi_Q_preterminal_mortality_adult_equivalents"
  ) |>
  ggplot(aes(y = dif, x = y_return_year)) +
  geom_line() +
  geom_point() +
  ylab("Difference") +
  geom_hline(aes(yintercept = 0)) +
  facet_wrap(~a_age, scales = "free") +
  theme_classic()
# Yep! There it is. Much higher harvest of age 4 fish.
# This is probably because age proportion at tyee is younger than at Kitsumkalum

K_star
dput(K_star)
K_star_prop <- K_star / rowSums(K_star)

K_star_df <- array2DF(K_star_prop, responseName = "prop")
omega_df <- array2DF(omega$omega["Kitsumkalum", , ], responseName = "prop")
pcheck <- merge(
  K_star_df,
  omega_df,
  suffixes = c("_K", "_tyee"),
  by = c("y", "a")
)
pcheckl <- pivot_longer(
  pcheck,
  cols = 3:4,
  names_to = "source",
  values_to = "prop"
)

ggplot(pcheckl, aes(y = prop, x = y, group = source, colour = source)) +
  geom_hline(aes(yintercept = 0)) +
  geom_line() +
  facet_wrap(~a) +
  theme_classic()


plot(K_star_prop ~ omega$omega["Kitsumkalum", , ])
abline(a = 0, b = 1)

#run_recon[[2]][[1]]
#run_recon[[3]]$W_wild_spawners

# Plot summary
ggplot(
  sdat[sdat$variable == "W_wild_spawners", ],
  aes(y = mean, y_return_year)
) +
  geom_line() +
  ylab("Wild spawners (W)") +
  geom_ribbon(aes(ymin = p5, ymax = p95), alpha = 0.5) +
  facet_wrap(~i_population, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()


ggplot(
  sdat[sdat$variable == "harvest", ],
  aes(y = mean, y_return_year)
) +
  geom_line() +
  ylab("Harvest (includes IM)") +
  geom_ribbon(aes(ymin = p5, ymax = p95), alpha = 0.5) +
  facet_wrap(~i_population, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()

ggplot(
  sdat[sdat$variable == "N_total_run", ],
  aes(y = mean, y_return_year)
) +
  geom_line() +
  ylab("Total Run (N)") +
  geom_ribbon(aes(ymin = p5, ymax = p95), alpha = 0.5) +
  facet_wrap(~i_population, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()

ggplot(
  sdat[sdat$variable == "est_hr", ],
  aes(y = mean, y_return_year)
) +
  geom_line() +
  ylab("Harvest Rate (includes IM)") +
  geom_ribbon(aes(ymin = p5, ymax = p95), alpha = 0.5) +
  facet_wrap(~i_population) +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()

# Same but with old and new on same plot
png(
  here("inst/fig/rr-compare-wild-spawners.png"),
  width = 8,
  height = 5,
  units = "in",
  res = 600
)
ggplot(
  md[md$variable == "W_wild_spawners", ],
  aes(y = mean, y_return_year)
) +
  geom_line() +
  ylab("Wild spawners (W)") +
  xlab("Return year") +
  geom_ribbon(aes(ymin = p5, ymax = p95), alpha = 0.5) +
  geom_line(aes(y = old), colour = "red", linetype = 2) +
  facet_wrap(~i_population, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()
dev.off()

png(
  here("inst/fig/rr-compare-harvest.png"),
  width = 8,
  height = 5,
  units = "in",
  res = 600
)
ggplot(
  md[md$variable == "harvest", ],
  aes(y = mean, y_return_year)
) +
  geom_line() +
  ylab("Harvest (includes IM)") +
  xlab("Return year") +
  geom_ribbon(aes(ymin = p5, ymax = p95), alpha = 0.5) +
  geom_line(aes(y = old), colour = "red", linetype = 2) +
  facet_wrap(~i_population, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()
dev.off()

png(
  here("inst/fig/rr-compare-total-run.png"),
  width = 8,
  height = 5,
  units = "in",
  res = 600
)
ggplot(
  md[md$variable == "N_total_run", ],
  aes(y = mean, y_return_year)
) +
  geom_line() +
  ylab("Total Run (N)") +
  xlab("Return year") +
  geom_ribbon(aes(ymin = p5, ymax = p95), alpha = 0.5) +
  geom_line(aes(y = old), colour = "red", linetype = 2) +
  facet_wrap(~i_population, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()
dev.off()

png(
  here("inst/fig/rr-compare-hravest-rate.png"),
  width = 8,
  height = 5,
  units = "in",
  res = 600
)
ggplot(
  md[md$variable == "est_hr", ],
  aes(y = mean, y_return_year)
) +
  geom_line() +
  ylab("Harvest Rate (includes IM)") +
  xlab("Return year") +
  geom_ribbon(aes(ymin = p5, ymax = p95), alpha = 0.5) +
  geom_line(aes(y = old), colour = "red", linetype = 2) +
  facet_wrap(~i_population) +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()
dev.off()

# Compare with plots

# Appears to be slighly higher mean harvest, and also
# systematically higher harvest of Kitsumkalum CU only.
# need to troubleshoot
# Not CV on freshwater mortality values
# Not CV on resampling ocean exploitation rates
# Not a seed issue (tried with seed = 1 and = 200, similar results)
# When cvs are reduced to 0.001, the issue is only in Kitsumklaum and Skeena.
# Could this be because currently, rr() uses K_star, and rru() does not?

ggplot(md[md$variable == "W_wild_spawners", ], aes(x = old, y = mean)) +
  geom_point() +
  geom_errorbar(aes(ymin = p5, ymax = p95)) +
  ggtitle("Wild spawners (W)") +
  geom_abline(aes(slope = 1, intercept = 0)) +
  xlab("conventional methods") +
  ylab("uncertainty methods") +
  facet_wrap(~i_population, scales = "free") +
  theme_classic()

ggplot(md[md$variable == "harvest", ], aes(x = old, y = mean)) +
  geom_point() +
  ggtitle("Harvest (includes IM)") +
  geom_errorbar(aes(ymin = p5, ymax = p95)) +
  geom_abline(aes(slope = 1, intercept = 0)) +
  xlab("conventional methods") +
  ylab("uncertainty methods") +
  facet_wrap(~i_population, scales = "free") +
  theme_classic()

ggplot(md[md$variable == "N_total_run", ], aes(x = old, y = mean)) +
  geom_point() +
  ggtitle("Total Run (N)") +
  geom_errorbar(aes(ymin = p5, ymax = p95)) +
  geom_abline(aes(slope = 1, intercept = 0)) +
  xlab("conventional methods") +
  ylab("uncertainty methods") +
  facet_wrap(~i_population, scales = "free") +
  theme_classic()

ggplot(md[md$variable == "est_hr", ], aes(x = old, y = mean)) +
  geom_point() +
  ggtitle("Harvest rate (includes IM)") +
  geom_errorbar(aes(ymin = p5, ymax = p95)) +
  geom_abline(aes(slope = 1, intercept = 0)) +
  xlab("conventional methods") +
  ylab("uncertainty methods") +
  facet_wrap(~i_population, scales = "free") +
  theme_classic()

# Check into difference for Kitsumkalum

ggplot(
  md[md$variable == "harvest", ],
  aes(y = dif, y_return_year, group = i_population, colour = i_population)
) +
  geom_line() +
  ylab("Harvest (includes IM)") +
  #facet_wrap(~i_population, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()

ggplot(
  md[md$variable == "W_wild_spawners", ],
  aes(y = dif, y_return_year, group = i_population, colour = i_population)
) +
  geom_line() +
  ylab("W") +
  #facet_wrap(~i_population, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()

ggplot(
  md[md$variable == "W_wild_spawners", ],
  aes(y = dif, x = y_return_year, group = i_population)
) +
  geom_line(colour = "red") +
  ylab("W dif") +
  facet_wrap(~i_population, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()

ggplot(
  md[md$variable == "harvest", ],
  aes(y = dif, x = y_return_year, group = i_population)
) +
  geom_line(colour = "red") +
  geom_line(
    data = md[md$variable == "W_wild_spawners", ],
    aes(y = dif, x = y_return_year)
  ) +
  ylab("Harvest dif (red) and W dif (black)") +
  facet_wrap(~i_population, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()

ggplot(
  md,
  aes(
    y = dif,
    x = y_return_year,
    colour = variable,
    group = interaction(variable, i_population)
  )
) +
  geom_line() +
  ylab("Difference btwn methods") +
  facet_wrap(~i_population, scales = "free_y") +
  geom_hline(aes(yintercept = 0)) +
  theme_classic()
