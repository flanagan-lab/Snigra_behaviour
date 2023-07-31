# *Stigmatopora nigra* courtship behaviour analysis

### R scripts

The directory called R_scripts/archive/ contains archived R scripts used in initial analyses (but which are superseded by the docs). The functions of each of the scripts are as follows:

* `archive/Readin_data.R`: parses the datasheets focusing on courtship behaviours, which are in BORIS_data/. 
* `archive/Chasing_data.R`: Parses the datasheets focused on chasing behaviours, which are in Chase_datasheets/.
* `archive/Combining_data.R`: Combines data from the original scoring of courtship behaviours (in BORIS_data/) with the chasing behaviour data (in Chase_datasheets/).
* `archive/Initiation_Display_test.R`: runs the proportion tests to compare which sex initiates more, and to investigate whether the ornament is used more in courtship or competition. 
* `archive/Activity_linear_model.R`: Processes the courtship data to be able to run a linear model on courtship display times. Performs model selection and identifies the best fitting model. Some exploratory plots are also included (not included in manuscript).
* `archive/Group_size_lm.R`: Reads in courtship behaviour and performs some exploratory plotting and analysis of courtship behaviour and its relationship to group size. This was not included in the main manuscript. 
