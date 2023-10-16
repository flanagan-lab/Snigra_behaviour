[![DOI](https://zenodo.org/badge/515324589.svg)](https://zenodo.org/doi/10.5281/zenodo.7735473)

# *Stigmatopora nigra* courtship behaviour analysis

This repository documents the analysis of behavioural data collected from video recordings of 10 mesocosms containing *S. nigra* males and females (which were run in 2020-2021). The goals of the study were to:

1. Describe the courtship behaviours of these sexually dimorphic fish
2. Establish whether one sex is more active in courtship than the other
3. Determine factors the influence sex-specific behaviours

The paper summarising these analyses and the results is published in The Royal Society Open Science, [https://dx.doi.org/10.1098/rsos.231428](https://dx.doi.org/10.1098/rsos.231428)

## Data availability

Raw video footage is available upon request. The BORIS output files are archived for review purposes on zenodo: [https://doi.org/10.5281/zenodo.7471179](https://doi.org/10.5281/zenodo.7735430). These data are organised in two directories, which are referenced in the script `docs/Data_wrangling.Rmd`: Chase_datasheets/ and BORIS_data/. Both contain data from analysis of videos in BORIS. The BORIS_data/ contains the majority of the courtship behaviours, but the videos were re-analysed to investigate chase behaviours after the courtship behaviours were scored. The chase behaviour data is in Chase_datasheets/.  Note that 3 courtship bouts were deleted from the chase data (but not the courtship data) because there was no active behaviour just chasing and surrounding (bouts 14, 16 and 18).

The raw data sheets are merged and tidied in the Rmarkdown file `docs/Data_wrangling.Rmd`. This doc creates three files, `processed_data/courtship_data.csv`, `processed_data/chase_data.csv`, and `processed_data/combined_behavioural_data.csv`. These files are included in this github repository and are used in the other documents and scripts to run the analyses and are included in the repository. Also in `processed_data/` is a file called `phenotype_data.csv`, which contains the body size measurements for all of the individuals in the experimental breeding populations. 


### Data availability


## Analysis

The analysis for the manuscript is documented in a combination of Rmarkdown documents and R scripts. 

### Data processing

The document `Data_wrangling.Rmd` contains the steps used to convert the raw BORIS outputs into data frames and combine the courtship and chasing data (which are contained in separate spreadsheets). All data is archived on zenodo (doi: 10.5281/zenodo.7735430).

### Analyses and figure creation

* Figure 1: Use `Active_courtship.Rmd`, which processes some data, performs some exploratory plotting, and performs hypothesis tests of initiation and conducts model selection on the variables that predict the duration of courtship behaviours. It also includes the code to create Fig. 1 and Table 2 in the manuscript.
* Figure 2: Use `Chasing_Behaviours.Rmd`, which processes some data, performs some exploratory plotting, and performs the generalised linear regression to analyse the probability that chasing will occur. It also includes the code to create Fig. 2 in the manuscript. 

The analysis comparing male and female body sizes is contained in `Data_wrangling.Rmd` as one of the exploratory analyses conducted. 

## Navigating this repository


### Rmarkdown documents

The rmarkdown documents are in the folder called docs/. They do the following things:

* `Data_wrangling.Rmd`: This document processes the raw BORIS outputs and saves files to a directory titled processed_data/ for use in other docs (including the `Initiaion_Display_test.R` file). It also performs some exploratory data analysis, including comparing body sizes across trials.
* `Active_courtship.Rmd`: Performs some exploratory plotting and generates some summary statistics, and performs model selection on the variables that predict the duration of courtship behaviours. It also includes the code to create Fig. 1 in the manuscript.
* `Chasing_Behaviours.Rmd`: Performs some exploratory plotting and performs the generalised linear regression to analyse the probability that chasing will occur. It also includes the code to create Fig. 2 in the manuscript. 

## Author information

Much of this code was written by Fleur van Eyndhoven as part of her MSc thesis at the University of Canterbury. Sarah Flanagan also contributed code, cleaned the repository, and created the final plots for the manuscript.

