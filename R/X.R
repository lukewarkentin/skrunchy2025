#' Return to Terrace
#'
#' Returns to Terrace of adult Chinook salmon (X) for population i and year y. Uses pooled genetic proportions and the number of Chinook returns to the Kitsumkalum River.
#'
#'
#' @format ## `X`
#'
#' A list with three elements. First element: Numeric, X which is an array of returns to Terrace with two dimensions: population (i) and year (y). Second element: numeric, sigma_X which is an array of SE of returns to Terrace of Chinook, with two dimensions: population (i) and year (y). Third element: dataframe with X, sigma_X, and year merged for plotting and reporting.
#'
#' @source data-raw/do-run-reconstruction.R
"X"
