### `freshwater-catch.xlsx` 

This file has the terminal freshwater mortality numbers by return year. Columns with headers highlighted in green are used in subsequent analysis and are shown in Winther et al. 2024 Appendix 2 Table 1. LW checked file against table 2025-05-13.

Notes: 
- Jack estimates at Tyee and in FN and Rec fisheries (based on length) include a large portion of age 4 fish. This file combines jack and large estimates, before age 3 fish are removed using age proportions (to account for age 4 fish in the original jack estimates based solely on length).
- Recreational catch is estimated differently across the time series. See notes in file and Winther et al. 2024 Appendix 2, page 120 for details https://waves-vagues.dfo-mpo.gc.ca/library-bibliotheque/41241046.pdf 


# Folders 

## `kitsumkalum`

### `kitsumkalum-escapament.csv`

POPAN results with SE. Has total escapement and escapement by sex (female, male). 1984-2020 data is from Winther et al. 2021 table 14. 

### `kitsumkalum-escapement-by-age-1984-2020.csv`

Escapement of Kitsumkalum Chinook broken out into ages using age distribution on spawning grounds, by sex. Years 1984-2020 are available in Winther et al. 2021 Table 14, and from file "1979-2020 Skeena Test Chinook full DNA probs matched to Tyee data 2023-11-26.xlsx" tab "KLM" columns CB:CQ. These are based on the POPAN estimates of females and males separately with female and male age distributions, and hatchery contributions. 

### `brood-removals.csv`

Female brood removals from Kitsumkalum River. Years 1984-2019 are from "V20-4-KLM_&_Skeena_CalcSR_2024-01-15.xlsx" tab "Brood Removals" columns A:E. 

2020-2024 are compiled by Luke Warkentin from Kitsumkalum tagging/brood data and scale aging data. Code in kitsumkalum repo "scripts" folder. 
