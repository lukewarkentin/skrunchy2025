# skrunchy2025

This is a data and analysis package that updates the Skeena River run reconstruction for Chinook salmon, with data available in 2025. 
It contains the data needed to run the run reconstruction. 
It uses the functions in the skrunchy package: https://github.com/Pacific-salmon-assess/skrunchy. 

## Organization 

Raw data (`.csv` and `.xlsx` files) are included in the `data-raw` folder. A `README.md` file gives a brief explanation of each data file. 

The R scripts that read, format, and save the raw data are also saved in the `data-raw` folder. 

Processed data is saved as `.rda` files in the `data` folder. When the package is installed and loaded, these data are available to call.  

The `R` folder has documentation files for each `.rda` data object. 

The `scripts` folder has code that is run to do the run reconstruction on the data, using the `skrunchy` package. 

## Installation

You can install the development version of skrunchy2025 from [GitHub](https://github.com/) with:

```
install.packages("pak")
pak::pak("Pacific-salmon-assess/skrunchy")

# Alternative method:

install.packages("devtools")
library(devtools)
install_github("Pacific-salmon-assess/skrunchy")

```
