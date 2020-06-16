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

### Step 2: SGP Analysis in 2018-2019 (follow the skipped year)

The analyses conducted in 2018-2019 are performed in two-parts where Part 1 involves the calculate of SGPs and Part 2 involves the calculation of
student growth projections that are used for the calculation of AGPs. If your interest is only in the calcultion of SGPs, then you can forego Part 2.


#### Part 1: Calculation of SGPs

SGP calculation across a skip-year or grade is fairly common in states. For example, several states have testing in grades 3 to 8 and grade 10. Those
states often calculate SGPs for grade 10 using the grade 8 prior. States with end-of-course testing also calculate SGPs across two and sometimes three
year spans of time. The R script [Demonstration_SGP_2018_2019_PART_1](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Skip_Year_Projection/Demonstration_SGP_2018_2019_PART_1.R) uses `updateSGP` applied to the SGP object from Step 1 together with the 2018_2019 data.
Part 1 calculates **ONLY** SGPs. An [additional portion of the R script](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Skip_Year_Projection/Demonstration_SGP_2018_2019_PART_1.R#L51), which can be omitted if your goal is to just calculate SGPs, takes the coefficient
matrices calculated in Step 1 and the skip-year matrices calculated here and creates _baseline_ matrices from them. These baseline matrices will be
used in Part 2 to calculate student growth projections.

#### Part 2: Calculate student growth projections (AGPs)

The calculation of student growth projections requires a little more work than the SGPs. Those familiar with student growth projections know that there
are two types of projections: _lagged_ projections and _straight_ projections. Lagged projections are projections made from the penultimate score (in this
case from 2016-2017) and straight projections are made from the current score (in this case from 2018-2019). Straight projections assume (going forward)
annual assessments. However, in the current year (2018-2019), coefficient matrices calculated involve a skip year and thus are not appropriate for
projecting annual growth going forward. In order to project annual growth going forward we go back and use the most recent annual growth matrices
(2016-2017). These matrices (and the skip year matrices) were converted to baseline matrices to use for this purpose.

##### Part 2a: Calculate Baseline SGPs

The R script [Demonstration_SGP_2018_2019_PART_2a](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Skip_Year_Projection/Demonstration_SGP_2018_2019_PART_2a.R) is used to calculate **JUST** the baseline SGPs using the baseline matrices. Note that these SGPs will be
equivalent to the cohort referenced SGPs calculated in Part 1 of Step 2. They are calculated here because the program uses `SGP_BASELINE` to determine
Catch-Up/Keep-Up and Move-Up/Stay-Up status. 



### Prepared with :heart: by:

* [Damian Betebenner](https://github.com/dbetebenner)
* [Adam VanIwaarden](https://github.com/adamvi)
