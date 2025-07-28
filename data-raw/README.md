# Data files


### `freshwater-catch.xlsx` 

This file has the terminal freshwater mortality numbers by return year. Columns with headers highlighted in green are used in subsequent analysis and are shown in Winther et al. 2024 Appendix 2 Table 1. LW checked file against table 2025-05-13.

Notes: 
- Jack estimates at Tyee and in FN and Rec fisheries (based on length) include a large portion of age 4 fish. This file combines jack and large estimates, before age 3 fish are removed using age proportions (to account for age 4 fish in the original jack estimates based solely on length).
- Recreational catch is estimated differently across the time series. See notes in file and Winther et al. 2024 Appendix 2, page 120 for details https://waves-vagues.dfo-mpo.gc.ca/library-bibliotheque/41241046.pdf 
- "Tyee Catch large not corrected",	"Tyee catch jacks not corrected", and	"Tyee catch Jacks + Large" are from FOS, and can be accessed multiple ways. "Detailed Salmon Testfish Catch" has it divided into jacks and large. 
- "Tyee catch Jacks + Large" can also be found by downloading the "Skeena Tyee Multipanel Catch Summary Export" (SQL ID: 8886) report and summing the "CHINOOK_TOTAL" column. 


# Folders 

## `kitsumkalum/`

### `kitsumkalum-escapement.csv`

POPAN results with SE. Has total escapement and escapement by sex (female, male). 1984-2020 data is from Winther et al. 2021 table 14. 

### `brood-removals.csv`

Female brood removals from Kitsumkalum River. Years 1984-2019 are from "V20-4-KLM_&_Skeena_CalcSR_2024-01-15.xlsx" tab "Brood Removals" columns A:E. 

2020-2024 are compiled by Luke Warkentin from Kitsumkalum tagging/brood data and scale aging data. Code in kitsumkalum repo "scripts" folder. 

### `chinook-cwt-ERA-outfiles_2025-03-06_KLM-KLY.xlsx`

Output files from the Chinook Exploitation Rate Analysis (ERA) done by Chinook Technical Committee. Requested from Pacific Salmon Commission through official data request form.
Outputs for Coded Wire Tag (CWT) recoveries for KLM (Kitsumkalum fry releases) and KLY (Kitsumkalum yearling releases). Note that run reconstruction uses rates for fry releases (code KLM) and estimates of hatchery escapement for both KLM and KLY summed. 

From LT: For exploitation rates, the Calendar Year refers to the distributions of mortalities (reported catch and total) among fisheries and escapement in a catch year for a given stock.  The Brood Year ER is the cumulative impact of all fisheries on all ages for a given stock and brood year. For ER_total and ER_legal, ER total would include sublegal mortalities and potentially also include shaker mortality in the calculations whereas ER_legal would be the exploitation rate only on the legal fish

Tabs: 
- `Releases total`: CWT releases and total releases by stock and brood year. Used to expand the estimate of CWT tagged fish in escapement to estimate hatchery origin spawners.
- `Releases by tag`: CWT releases and total releases by stock and tag code. 
- `BY mat aeq cohor`: By stock and brood year:
    - `mat`: Maturation rate
    - `AEQ`: Adult equivalency rate
    - `Cohort_BNM`: Cohort abundance before natural mortality
    - `Cohort_ANM`: Cohort abundance after natural mortality
    - `escape`: Estimated CWT tagged fish in escapement (Kitsumkalum River), estimated from: Kitsumkalum POPAN, number of CWT adipose clipped fish encountered during mark recapture study, proportion of clipped to unclipped fish encountered during mark recapture study. 
- `CY mat aeq cohort`: Same as above, but by calendar year.
- `BY Morts and ERs`: 
- `CY Morts and ERs`: 
- `BY Simple ERs`: 
- `CY Simple ERs`: 
- `BY Survival`:
- `CY Survival`: 


### `fishery-lookup-CWT-ERA.csv`

Lookup table with the fishery codes from the ERA file (`chinook-cwt-ERA-outfiles_2025-03-06_KLM-KLY.xlsx`). Provides details on different fisheries. 


