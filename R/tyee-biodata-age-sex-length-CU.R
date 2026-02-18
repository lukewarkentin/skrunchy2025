#' Table with Chinook biodata from Skeena River Tyee Test fishery.
#'
#' This has one row per fish, date caught, sex, length, total age (Gilbert-Rich), and Conservation Unit from genetic analysis, with probability of assignment.
#'
#' Note that for 1984-2020, this file only includes fish that were aged and had genetic analysis. There were more fish actually caught, and sampled.
#' For 2021-2024, this includes all fish that were sampled at Tyee.
#'
#' Genetics for 1984-2020 is based on msat, and 2021-2024 is based on SNP.
#'
#'
#' @format ## `tyee_biodata_age_sex_length_CU`
#' Data frame with these columns:
#' \describe{
#'   \item{y}{Return year}
#'   \item{i}{Population}
#'   \item{sex}{Sex}
#'   \item{nose_fork_length_mm}{Nose fork length in mm}
#'   \item{hypural_length_mm}{Post-orbital hypural length in mm}
#'   \item{date}{Date caught}
#'   \item{max_CU_prob_sum}{For msat (1984), sum of probability of assignements to collections (when updated should just be to CU, no summing necessary). For SNP (2021-2024), just probability of assignment to CU (no summing).}
#'   \item{a}{Age}
#' }
#' @source data-raw/process-omega-and-biodata.R
"tyee_biodata_age_sex_length_CU"
