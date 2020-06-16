COVID-19 Skip-Year Analysis Source Code and Documentation
======

This repository contains source code demonstrating how to calculate student growth percentiles (SGPs) and student growth projections (AGPs) when
a testing year is skipped like just happened in 2020 due to the COVID-19 pandemic. The repository utilizes the demontration LONG data set contained
in the [SGPdata package](https://github.com/CenterForAssessment/SGPdata) that provides 5 years (2015-2016 to 2019-2020) of longitudinal data for
grades 3 to 10 in two content areas (Mathematics and Reading). For purposes of this analysis, we assume that testing was skipped in 2017-2018.
The analyses are illustrated across several steps that are descibed in greater detail below.

### Step 1: SGP Analysis in 2016-2017

The R script [Demonstration_SGP_2016_2017.R](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Skip_Year_Projection/Demonstration_SGP_2016_2017.R) provides the source code associated with SGP/AGP calculation in 2016-2017, the second year of the testing data and the
year before the skipped year (2017-2018). The analysis configurations for [READING](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Skip_Year_Projection/SGP_CONFIG/2016_2017/READING.R) and [MATHEMATICS](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Skip_Year_Projection/SGP_CONFIG/2016_2017/MATHEMATICS.R) are explicitly defined and read into the call to `abcSGP`.




### Prepared with :heart: by:

* [Damian Betebenner](https://github.com/dbetebenner)
* [Adam VanIwaarden](https://github.com/adamvi)
