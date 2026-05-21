# data-raw/do-run-reconstruction

# 1. Setup ---------------------------
library(skrunchy)
library(dplyr)
library(here)
library(dplyr)
library(skrunchy2025)
library(ggplot2)

# 2. Load processed inputs in data/ folder ----------------------

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
  n_iter = 100,
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
  add_6_7 = TRUE,
  B_star = B_star,
  H_star = H_star,
  tau_dot_M = tau_dot_M,
  phi_dot_M = phi_dot_M,
  r = r_use,
  phi_dot_E = phi_dot_E,
  Q = Q,
  name_key = variable_name_key,
  save_outputs = FALSE
)

d <- do.call(rbind, run_recon)

ds <- d |>
  group_by(i_population, y_return_year) |>
  summarize(
    mean_N = mean(N_total_run, na.rm = TRUE),
    p5 = quantile(N_total_run, 0.05, na.rm = TRUE),
    p95 = quantile(N_total_run, 0.95, na.rm = TRUE),
    .groups = "drop"
  )


ggplot(ds, aes(y = mean_N, x = y_return_year)) +
  geom_line() +
  geom_ribbon(aes(ymin = p5, ymax = p95), alpha = 0.2) +
  facet_wrap(~i_population, scales = "free_y") +
  theme_classic()
