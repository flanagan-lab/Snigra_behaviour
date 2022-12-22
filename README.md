# *Stigmatopora nigra* courtship behaviour analysis

This repository documents the analysis of behavioural data collected from video recordings of 10 mesocosms containing *S. nigra* males and females (which were run in 2020-2021). The goals of the study are to:

1. Describe the courtship behaviours of these sexually dimorphic fish
2. Establish whether one sex is more active in courtship than the other
3. Determine factors the influence sex-specific behaviours

## Data

The data can be found in two directories: Chase_datasheets/ and BORIS_data/. Both contain data from analysis of videos in BORIS. The BORIS_data/ contains the majority of the courtship behaviours, but the videos were re-analysed to investigate chase behaviours after the courtship behaviours were scored. 
The chase behaviour data is in Chase_datasheets/.

The files in Chase_datasheets/ can be read in and used for chasing behaviour analysis using code in the R script named `chasing_data`.

The raw exports from BORIS in BORIS_data/ need to be read into R using the code in the R script called `Readin_data.R`.

### Data notes

3 courtship bouts were deleted from the chase data (but not the courtship data) because there was no active behaviour just chasing and surrounding (bouts 14, 16 and 18).

## Analysis

The analysis is documented in a combination of Rmarkdown documents and R scripts. 

### Data processing

* `Chasing_data.R`: Parses the datasheets focused on chasing behaviours, which are in Chase_datasheets/.
* `Combining_data.R`: Combines data from the original scoring of courtship behaviours (in BORIS_data/) with the chasing behaviour data (in Chase_datasheets/).
* `Readin_data.R`: parses the datasheets focusing on courtship behaviours, which are in BORIS_data/. 

### Exploratory analyses

Exploratory plots and analyses can be found in the following files:

* `Activity_linear_model.R`: Processes the courtship data to be able to run a linear model on courtship display times. Performs model selection and identifies the best fitting model. Some exploratory plots are also included (not included in manuscript).
* `Group_size_lm.R`: Reads in courtship behaviour and performs some exploratory plotting and analysis of courtship behaviour and its relationship to group size. This was not included in the main manuscript. 
* `Active_courtship.Rmd`: Processes some data, performs some exploratory plotting, and performs model selection on the variables that predict the duration of courtship behaviours. It also includes the code to create Fig. 2 in the manuscript.
* `Chasing_Behaviours.Rmd`: Processes some data, performs some exploratory plotting, and performs the generalised linear regression to analyse the probability that chasing will occur. It also includes the code to create Fig. 3 in the manuscript. 


### Main analyses and figure creation

* Figure 1: Use `Initiation_Display_test.R`: runs the proportion tests to compare which sex initiates more, and to investigate whether the ornament is used more in courtship or competition. Also includes the code to create Fig 1 in the manuscript.
* Figure 2: Use `Active_courtship.Rmd`, which processes some data, performs some exploratory plotting, and performs model selection on the variables that predict the duration of courtship behaviours. It also includes the code to create Fig. 2 in the manuscript.
* Figure 3: Use `Chasing_Behaviours.Rmd`, which processes some data, performs some exploratory plotting, and performs the generalised linear regression to analyse the probability that chasing will occur. It also includes the code to create Fig. 3 in the manuscript. 



## Navigating this repository

### R scripts

The directory called R_scripts/ contains Fleur's R scripts used in the analysis for her thesis, and some used for the analyses in the manuscript. The functions of each of the scripts are as follows (in order in which they are most useful):

* `Chasing_data.R`: Parses the datasheets focused on chasing behaviours, which are in Chase_datasheets/.
* `Combining_data.R`: Combines data from the original scoring of courtship behaviours (in BORIS_data/) with the chasing behaviour data (in Chase_datasheets/).
* `Readin_data.R`: parses the datasheets focusing on courtship behaviours, which are in BORIS_data/. 
* `Initiation_Display_test.R`: runs the proportion tests to compare which sex initiates more, and to investigate whether the ornament is used more in courtship or competition. Also includes the code to create Fig 1 in the manuscript.
* `Activity_linear_model.R`: Processes the courtship data to be able to run a linear model on courtship display times. Performs model selection and identifies the best fitting model. Some exploratory plots are also included (not included in manuscript).
* `Group_size_lm.R`: Reads in courtship behaviour and performs some exploratory plotting and analysis of courtship behaviour and its relationship to group size. This was not included in the main manuscript. 

### Rmarkdown documents

The rmarkdown documents are in the folder called docs/. They do the following things:

* `Active_courtship.Rmd`: Processes some data, performs some exploratory plotting, and performs model selection on the variables that predict the duration of courtship behaviours. It also includes the code to create Fig. 2 in the manuscript.
* `Chasing_Behaviours.Rmd`: Processes some data, performs some exploratory plotting, and performs the generalised linear regression to analyse the probability that chasing will occur. It also includes the code to create Fig. 3 in the manuscript. 

## Author information

Much of this code was written by Fleur van Eyndhoven as part of her MSc thesis at the University of Canterbury. Sarah Flanagan also contributed code and created the final plots for the manuscript.
