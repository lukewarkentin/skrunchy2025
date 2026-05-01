#' Preterminal post-fishery abundance
#'
#' Preterminal post-fishery abundance, which is the abundance of the
#' cohort after non-net fisheries (e.g., troll), after accounting for maturation rate but
#' before preterminal net (gillnet, seine) fishery harvest of mature fish. Of the fish that survived
#' non-net ocean fisheries, the number of fish that matured into the mature run.
#'
#' @format ## `A_phi`
#' An array with three dimensions:
#' \describe{
#'   \item{i}{Population}
#'   \item{y}{Year}
#'   \item{a}{Age}
#' }
#' @source data-raw/do-run-reconstruction.R
"A_phi"
