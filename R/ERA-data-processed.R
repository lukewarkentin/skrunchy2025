#' Summary table of variables derived from Chinook Technical Committee Exploitation Rate Analysis data
#'
#' Data frames (one wide format, one long format) of all the variables derived from CTC ERA output data.
#'
#'
#' @format ## `ERA_data_processed`
#' List with two elements:
#'
#' Element one: data frame with columns:
#' \describe{
#'   \item{y}{Year}
#'   \item{a}{Age}
#'   \item{H_star}{Hatchery origin spawners}
#'   \item{tau_dot_M}{Terminal marine exploitation rate}
#'   \item{phi_dot_M}{Preterminal net harvest rate of mature fish}
#'   \item{r}{Maturation rate}
#'   \item{phi_dot_E}{Preterminal exploitation rate (non-net fisheries)}
#'   \item{Q}{Adult equivalency rate}
#' }
#'
#' Element two: same data as element one but long format.
#'
#' @source data-raw/kitsumkalum/process-ERA-data.R
"ERA_data_processed"
