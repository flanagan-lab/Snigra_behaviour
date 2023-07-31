# *Stigmatopora nigra* courtship behaviour analysis

This repository documents the analysis of behavioural data collected from video recordings of 10 mesocosms containing *S. nigra* males and females (which were run in 2020-2021). The goals of the study are to:

1. Describe the courtship behaviours of these sexually dimorphic fish
2. Establish whether one sex is more active in courtship than the other
3. Determine factors the influence sex-specific behaviours

## Data

The code refers to data that is found in two directories in the top of the repo: Chase_datasheets/ and BORIS_data/. Both contain data from analysis of videos in BORIS. The BORIS_data/ contains the majority of the courtship behaviours, but the videos were re-analysed to investigate chase behaviours after the courtship behaviours were scored. The chase behaviour data is in Chase_datasheets/.  Note that 3 courtship bouts were deleted from the chase data (but not the courtship data) because there was no active behaviour just chasing and surrounding (bouts 14, 16 and 18).

The raw data sheets are merged and tidied in the Rmarkdown file `docs/Data_wrangling.Rmd`. This doc creates three files, `processed_data/courtship_data.csv`, `processed_data/chase_data.csv`, and `processed_data/combined_behavioural_data.csv`. These files are used in the other documents and scripts to run the analyses.


### Data availability

Raw video footage is available upon request. The BORIS output files are archived for review purposes on zenodo: https://doi.org/10.5281/zenodo.7471179.

## Analysis

The analysis for the manuscript is documented in a combination of Rmarkdown documents and R scripts. 

### Data processing

The document `Data_wrangling.Rmd` contains the steps used to convert the raw BORIS outputs into data frames and combine the courtship and chasing data (which are contained in separate spreadsheets). All data is archived on zenodo (doi: 10.5281/zenodo.7735430).

### Analyses and figure creation

* Figure 1: Use `Active_courtship.Rmd`: runs the proportion tests to compare which sex initiates more, and to investigate whether the ornament is used more in courtship or competition. Also includes the code to create Fig 1 in the manuscript.
* Figure 2: Use `Active_courtship.Rmd`, which processes some data, performs some exploratory plotting, and performs model selection on the variables that predict the duration of courtship behaviours. It also includes the code to create Fig. 2 in the manuscript.
* Figure 3: Use `Chasing_Behaviours.Rmd`, which processes some data, performs some exploratory plotting, and performs the generalised linear regression to analyse the probability that chasing will occur. It also includes the code to create Fig. 3 in the manuscript. 



## Navigating this repository


### Rmarkdown documents

The rmarkdown documents are in the folder called docs/. They do the following things:

* `Data_wrangling.Rmd`: This document processes the raw BORIS outputs and saves files to a directory titled processed_data/ for use in other docs (including the `Initiaion_Display_test.R` file).
* `Active_courtship.Rmd`: Performs some exploratory plotting and generates some summary statistics, and performs model selection on the variables that predict the duration of courtship behaviours. It also includes the code to create Fig. 2 in the manuscript.
* `Chasing_Behaviours.Rmd`: Performs some exploratory plotting and performs the generalised linear regression to analyse the probability that chasing will occur. It also includes the code to create Fig. 3 in the manuscript. 

## Author information

Much of this code was written by Fleur van Eyndhoven as part of her MSc thesis at the University of Canterbury. Sarah Flanagan also contributed code and created the final plots for the manuscript.

