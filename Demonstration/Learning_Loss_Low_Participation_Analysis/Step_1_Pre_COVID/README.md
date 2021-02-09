Step 1 of Learning Loss Analysis
======

The R script [Demonstration_COVID_SGP_2017_to_2019_PreCOVID.R](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/Step_1_Pre_COVID/Demonstration_COVID_SGP_2017_to_2019_PreCOVID.R)
provides the source code associated with SGP/AGP calculation in 'normal', pre-COVID
years, which begins with the second year of the testing data (2017) and ends with
the year before the pandemic-shortened academic year (2019). The analysis configurations
for [ELA](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_1/ELA.R)
and [MATHEMATICS](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_1/MATHEMATICS.R)
are explicitly defined and read into the call to `abcSGP`.  Note that these analyses
are restricted to use (at most) two years of prior test data.
