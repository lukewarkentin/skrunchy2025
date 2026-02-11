#' Preterminal total mortality harvest rates rates of mature fish from net fisheries.
#'
#' Array of preterminal net total mortality harvest rates on mature fish from net fisheries (greater than or equal to 0, less than 1) with two dimensions: year (y) and age (a).
#' Preterminal net total mortality harvest rate on mature fish: seine and gillnet catch and incidental mortalities of mature fish. From CTC Chinook model output.
#' Values are 0 for age 3-4, sum of ALASKA N and CENTRL N for age 5-6.
#'
#' @format ## `phi_dot_M`
#' An array with two dimensions:
#' \describe{
#'   \item{y}{Year}
#'   \item{a}{Age}
#' }
#' @source data-raw/kitsumkalum/process-ERA-data.R
"phi_dot_M"
