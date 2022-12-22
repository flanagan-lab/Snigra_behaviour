# *Stigmatopora nigra* courtship behaviour analysis

This directory contains the behavioural data from mesocosms containing *S. nigra* males and females (which were run in 2020-2021). It also contains the scripts and Rmd documents used for the analysis of the data.

## Data

The data can be found in two directories: Chase_datasheets/ and BORIS_data/. Both contain data from analysis of videos in BORIS. The BORIS_data/ contains the majority of the courtship behaviours, but the videos were re-analysed to investigate chase behaviours after the courtship behaviours were scored. 
The chase behaviour data is in Chase_datasheets/.

The files in Chase_datasheets/ can be read in and used for chasing behaviour analysis using code in the R script named `chasing_data`.

The raw exports from BORIS in BORIS_data/ need to be read into R using the code in the R script called `Readin_data.R`.

### Data notes

3 courtship bouts were deleted from the chase data (but not the courtship data) because there was no active behaviour just chasing and surrounding (bouts 14, 16 and 18).

## Scripts

The directory called R_scripts/ contains Fleur's R scripts used in the analysis. The functions of each of the scripts are as follows:

* `Chasing_data.R`: Parses the datasheets focused on chasing behaviours, which are in Chase_datasheets/.
* `Combing_data.R`: Combines data from the original scoring of courtship behaviours (in BORIS_data/) with the chasing behaviour data (in Chase_datasheets/).
* `Readin_data.R`: parses the datasheets focusing on courtship behaviours, which are in BORIS_data/. 


