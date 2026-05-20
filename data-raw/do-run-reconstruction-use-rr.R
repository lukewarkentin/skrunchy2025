# data-raw/do-run-reconstruction

# 1. Setup ---------------------------
library(skrunchy)
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


# 3. Run reconstruction using rr() wrapper function --------------------
run_recon <- rr(
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
  save_outputs = TRUE
)

head(run_recon[[1]])
check <- run_recon[[2]]
run_recon[[3]]
