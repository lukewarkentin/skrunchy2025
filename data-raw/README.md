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
    - `Stock`: release stage: KLM = fry release, KLY = yearling release
    - `Brood.Yr`: Brood year
    - ***`CWT_Release`***: number of fish released that were tagged with Coded Wire Tags (these were also adipose fin clipped)
    - ***`total_Release`***: Total number of fish released, including tagged fish. 
- `Releases by tag`: CWT releases and total releases by stock and tag code. 
- `BY mat aeq cohor`: Maturation rate, adult equivalency rate, cohort abundance, and escapement of CWT Chinook.
    - `Stock`: release stage: KLM = fry release, KLY = yearling release
    - `Brood.Yr`: Brood year
    - `age`: Age
    - **`mat`**: Maturation rate
    - **`AEQ`**: Adult equivalency rate
    - `Cohort_BNM`: Cohort abundance before natural mortality
    - `Cohort_ANM`: Cohort abundance after natural mortality
    - **`escape`**: Estimated CWT tagged fish in escapement (Kitsumkalum River), estimated from: Kitsumkalum POPAN, number of CWT adipose clipped fish encountered during mark recapture study, proportion of clipped to unclipped fish encountered during mark recapture study. This is later expanded using total/tagged releases to estimate total hatchery escapement. 
- `CY mat aeq cohort`: Same as above, but by calendar year.
- `BY Morts and ERs`: Estimated catch and exploitation rates in each fishery.  
    - `Stock`: release stage: KLM = fry release, KLY = yearling release
    - `Fishery`: Numeric code for fishery
    - `Fishery_Name`: US and Canadian fisheries encountering Chinook. Details can be found in `fishery-lookup-CWT-ERA.csv`
    - `by`: Brood year
    - `age`: Age
    - `CNR_legal_morts`: ???
    - `CNR_Sublegal_morts`: ???
    - `Total_shaker_morts`: ???
    - `Landed_catch`: Estimated number of landed CWT and adipose fin clipped Chinook in the fishery. 
    - **`ER_legal`**: Exploitation rate of legal sized Chinook. Most closely matches rates used in Winther et al. 2024. 
    - `ER_total`: ??? Exploitation rate including sub-legal mortalities and potentially shaker mortalities. 
- `CY Morts and ERs`: Same as above but buy calendar year. 
- `BY Simple ERs`: Harvest rates summarized by brood year and fishery category, in adult equivalents. 
    - `Type`: Reported = ???, Total= ???, terminal = only terminal fisheries. 
- `CY Simple ERs`: Same as above, but by calendar year method. 
- `BY Survival`: survival rates by age, estimated recoveries or all mortalities. Details???
- `CY Survival`: Same as above but calendar year method. Details???


### `fishery-lookup-CWT-ERA.csv`

Lookup table with the fishery codes from the ERA file (`chinook-cwt-ERA-outfiles_2025-03-06_KLM-KLY.xlsx`). Provides details on different fisheries. 

## `tyee-genetics/`

Contains files for weekly Chinook catch and GSI mixture results, by stat week, from Tyee Test Fishery. GSI results are for age 4-7 fish ony. Catch results are for adults (1984-2020) and adults age 4-7 (2021-2024). 

### `tyee-catch-by-stat-week-1984-2020.xlsx`

Weekly adult Chinook catch data to be matched up with re-run of msat GSI mixture analysis. Revised for accuracy by Ivan Winther. 
This table is taken from tab "Samples & catch 79-20" from file "1AB Skeena Esc 1979 to 2020 POPAN 2023-11-13 to LW&CM .xlsx", which was created by Ivan Winther for the publication: An assessment of Skeena River Chinook salmon using genetic stock identification 1984 to 2020 (https://publications.gc.ca/site/eng/9.901355/publication.html)
It contains weekly Tyee adult catch (revised weekly catch) by stat week. (LW added "(G)" to indicate which column to use in the updated run reconstruction)
The original file also had msat GSI mixture results for the samples from each stat week. These have been rerun by the Molecular Genetics Lab, and are joined to this data in an R script found in skrunchy2025/data-raw/tyee-genetics

