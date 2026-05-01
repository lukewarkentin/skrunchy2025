#' Brood table with wild spawners and (wild) recruits by population and brood year.
#'
#' Recruits is the sum of the total run (including harvest) of all the fish that were spawned in a given brood year.
#'
#'
#' @format ## `brood_table`
#' Data frame with 5 columns
#' \describe{
#'   \item{b}{brood year}
#'   \item{i}{Population}
#'   \item{complete_brood}{Is the cohort from the brood year complete in the data set?}
#'   \item{R}{Recruits origating from the spawners in brood year i}
#'   \item{W_wild_spawners}{Spawners in the brood year}
#' }
#' @source data-raw/do-run-reconstruction.R
"brood_table"
