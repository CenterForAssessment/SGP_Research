COVID-19 Learning Loss Analysis Source Code and Documentation
======

This repository contains source code demonstrating how to calculate student growth
percentiles (SGPs) and adequate growth projections (AGPs) when a testing year is
skipped like just happened in 2020 due to the COVID-19 pandemic. The repository
utilizes the demonstration COVID LONG data set contained in the
[SGPdata package](https://github.com/CenterForAssessment/SGPdata) that provides
7 longitudinal data panels (2016 to 2019 and 2021 to 2023) for grades 3 to 8 in
two content areas (Mathematics and ELA). Test data for 2020 is missing entirely.
The analyses are illustrated across several steps that are described in greater
detail below.


### Step 1: SGP analysis in pre-COVID pandemic years (2017-2019)

The R script [Demonstration_COVID_SGP_2017_to_2019_PreCOVID.R](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/Step_1_Pre_COVID/Demonstration_COVID_SGP_2017_to_2019_PreCOVID.R)
provides the source code associated with SGP/AGP calculation in 'normal', pre-COVID
years, which begins with the second year of the testing data (2017) and ends with
the year before the pandemic-shortened academic year (2019). The analysis configurations
for [ELA](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_1/ELA.R)
and [MATHEMATICS](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_1/MATHEMATICS.R)
are explicitly defined and read into the call to `abcSGP`.  Note that these analyses
are restricted to use (at most) two years of prior test data.


### Step 2: Baseline SGP matrix calculations using pre-COVID test data

Step 2 represents work that can be done before any test data for 2021 arrives,
particularly the calculation of baseline referenced coefficient matrices using
pre-COVID years' data.  In these demonstration analyses it also involves data
simulation in which the post-COVID skip year (2021-2023) data is perturbed in
various ways to simulate multiple possible impacts on students (e.g., 'learning
loss' due to modes of instruction) and test administration (e.g., participation
rates and in-person/remote testing mode). DATA SIMULATION/PERTURBATION CODE IS TBA!

The investigation of 'learning loss' from these analyses requires an estimate of
what typical, or expected, learning would have been if the pandemic and it's impact
on student education had ***not*** occurred. To this end we can calculate 'baseline'
SGP coefficient matrices from pre-COVID years to establish growth norms for what
would have been expected in typical times.

Baseline growth norms can be established using any number of reference cohorts for
coefficient matrix calculation. One way is to use a single-cohort, such as the
students from 2019 (the last pre-COVID cohort). Another approach is to 'stack'
multiple cohorts into a 'super-cohort'. For example, in the demonstration COVID
data it is possible to combine two or more cohorts with at least two prior years
of data into one given the number of years available (e.g., 2016 to 2018 and 2017
to 2019). Single-year cohort baseline referenced SGPs may be desired given the
ease of interpretation and explanation of what 'typical' growth is in reference
to. That is, we can ask 'What does growth in 2021 look like relative to what was
observed in 2019?'. A super-cohort baseline referenced SGP may be desired, on the
other hand, if there are known issues with the scale in a particular year
(e.g., scale drift), in which case combining several years of data can smooth out
irregularities or inconsistencies in the assessment data.

Either single- or super-cohort baseline SGP coefficient matrices can be constructed
by selecting the configuration code from the appropriate 'SGP_CONFIG' subdirectory
([SingleCohort](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_2_BASELINE/SingleCohort/)
or [SuperCohort](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_2_BASELINE/SuperCohort/)).
The resulting matrices can be used interchangeably in the `SGP` package when
inserted in the `SGPstateData` where required. However, the code has been written
to use the single-cohort matrices in the code for subsequent steps.

DATA SIMULATION/PERTURBATION IS TBA


### Step 3: SGP Analysis in 2021 (following the pandemic skipped year in 2020)

Step 3 represents the analyses that can be done in the very challenging and weird
academic year that we have seen from fall 2020 to this point in 2021. Many schools
have been forced to do remote teaching or a hybrid or remote and in-person.
Other issues such as low participation rates and low student-motivation may also
be relevant factors impacting test scores in this scatter-shot year of continued
pandemic impact on all facets of education.

The analyses conducted in 2021 are performed in multiple parts, where part A
involves the calculation of SGPs and parts B and C involves the calculation of
student growth projections that are used for the calculation of AGPs. If your
interest is only in the calculation of SGPs, then you can forego parts 3b and 3c.


#### Part A: Calculation of SGPs

The R script [Demonstration_COVID_SGP_2021_PART_A](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/Step_3_Skip_Year_Analyses/Demonstration_COVID_SGP_2021_PART_A.R)
uses `updateSGP` applied to the SGP object from Step 1 together with the 2021 data.
Part A calculates **ONLY** SGPs, although both baseline and cohort referenced SGP
versions are calculated. The content area and grade sequences for these analyses
are specified in the configuration code located [here.](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_3/)

#### Parts B and C: Calculate student growth projections (AGPs)

The calculation of student growth projections requires a little more work than
the SGPs. Those familiar with student growth projections know that there are two
types of projections: _lagged_ projections and _straight_ projections. Lagged
projections are projections made from the penultimate score (in this case from
2019) and straight projections are made from the current score (in this case from
2021). Straight projections assume (going forward) annual assessments. However,
in the current year (2021), coefficient matrices calculated involve a skip year
and thus are not appropriate for projecting annual growth going forward. In order
to project annual growth going forward we use baseline coefficient matrices that
do not include a skip year (sequential). These matrices were constructed along
with the skip year matrices in Step 2.


##### Part B: Calculate Baseline Referenced Straight Projections.

The R script [Demonstration_COVID_SGP_2021_PART_B](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/Step_3_Skip_Year_Analyses/Demonstration_COVID_SGP_2021_PART_B.R)
is used to calculate **JUST** the baseline referenced _straight_ projections.
Like with the other scripts examined thus far, configurations for
[ELA](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_3b/ELA.R)
and [MATHEMATICS](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_3b/MATHEMATICS.R)
are provided that explicitly state what the baseline projection sequences are.
In addition, the configurations reference grade projection sequences that are
embedded within the `SGPstateData` beginning [on line 33](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/Step_3_Skip_Year_Analyses/Demonstration_COVID_SGP_2021_PART_B.R#L32)
of the analysis script. Straight projections have to be done separately from
lagged projections due to the fact that lagged projections must skip a grade/year
whereas straight projections do not skip. Note that the script (on
[line 86](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/Step_3_Skip_Year_Analyses/Demonstration_COVID_SGP_2021_PART_B.R#L86))
also calculates the associated scale score targets for the straight projection AGPs.

##### Part C: Calculate Baseline Referenced Lagged Projections.

The R script [Demonstration_COVID_SGP_2021_PART_C](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/Step_3_Skip_Year_Analyses/Demonstration_COVID_SGP_2021_PART_C.R)
is used to calculate **JUST** the baseline referenced _lagged_ projections. Lagged
projections are used to determine AGPs and evaluate the adequacy of growth toward
a pre-defined standard in the current year. Part C is the last part of the 2021
analyses. Note that the script (on [line 85](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/Step_3_Skip_Year_Analyses/Demonstration_COVID_SGP_2021_PART_C.R#L85))
also calculates the associated scale score targets for the lagged projection AGPs.
Like with the other scripts examined thus far, configurations for
[ELA](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_3c/ELA.R)
and [MATHEMATICS](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_3c/MATHEMATICS.R)
are provided that explicitly state what the baseline projection sequences are.
In addition, the configurations reference grade projection sequences that are
embedded within the `SGPstateData` beginning [on line 32](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/Step_3_Skip_Year_Analyses/Demonstration_COVID_SGP_2021_PART_C.R#L31)
of the analysis script. These projections sequences differ from those in Part B
(for straight projections) in that they specify that a grade needs to be skipped
because of the missed year of testing.


### Step 4: SGP Analysis in 2022

In 2022, two years after the pandemic skipped year, things have returned to 'normal'
in terms of the testing schedule and the penultimate test is from the
year before and (hopefully!) teaching, learning and test taking is also back to
all in-person. The R script for this first year of 'recovery' is
[Demonstration_COVID_SGP_2022](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/Step_4_Recovery_Year_1/Demonstration_COVID_SGP_2022.R),
which is used to calculate SGPs, straight projections and lagged projections in
a single call to `updateSGP`. All analyses are cohort and baseline referenced,
which allows us to compare students and schools from both current (post-COVID/2022)
and baseline (pre-COVID/2019) norms. Note that in the [2022 configuration code](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/SGP_CONFIG/STEP_4/)
we specify the max order for the SGPs and projections to be 1 (use a single prior
from 2021). It's possible to calculate SGPs using additional priors (from 2019)
but those will only be available for students in grade 6 and higher. However,
projections will only use 1 prior matrices as they are the most recent matrices
capable of annual projections.

### Step 5: SGP Analysis in 2023

In 2023, three years after the pandemic skipped year and the second year of recovery,
things are truly back to 'normal' in test taking with two consecutive years of
prior test data. The R script for this recovery year is
[Demonstration_COVID_SGP_2023](https://github.com/CenterForAssessment/SGP_Research/blob/master/Demonstration/Learning_Loss_Analysis/Step_5_Recovery_Year_2/Demonstration_COVID_SGP_2023.R).
Again we calculate SGPs, straight projections and lagged projections in the same
step with a single call to the `updateSGP` function. We also continue to calculate
cohort and baseline referenced SGPs, which allows us to compare norms from the
current (2023) and baseline (pre-COVID/2019) cohorts.


### Comments

* It's likely possible to combine some of the Part 3, 3b, and 3c scripts. They
were separated into 3 pieces (SGPs, straight projections, lagged projections) to
simplify the illustration of the results.
* Going beyond grade-level testing and including end-of-course testing should be
straight forward and will just require more complicated analysis configurations
and grade projection configurations.
* We're pretty happy we were able to accomplish this without adding any additional
features to the SGP package and using already existing features.


### Prepared with :heart: by:

* [Damian Betebenner](https://github.com/dbetebenner)
* [Adam VanIwaarden](https://github.com/adamvi)
