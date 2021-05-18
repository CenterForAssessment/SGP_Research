################################################################################
###                                                                          ###
###     Quick demonstration of how to use the amputeScaleScore function      ###
###                                                                          ###
################################################################################

#####
###      Here's a quick introduction to the arguments and defaults of the function:
#####

###   Read in the amputeScaleScore function
source("Step_0_Data_Modification/amputeScaleScore.R")
args(amputeScaleScore)

##    ampute.data = SGPdata::sgpData_LONG_COVID[YEAR <= 2021]
##        - the dataset we want to begin with and add missing values
##        - the default is the COVID dataset from SGPdata for 2021 and prior

##    additional.data = NULL
##        - the function will return only data that is required for
##          a SGP analysis (based on growth.config).  This allows for
##          the addition of more data (e.g. 2019 grades not used as priors)

##    compact.results = FALSE
##        - By default (FALSE), the function will return a list of longitudinal
##          datassets with the current (amputed) and prior (unchanged) student
##          records.  This is helpful for diagnostics and ease of use, but also
##          produces more redundant prior data than needed. Setting this argument
##          to TRUE returns a single data.table object with a TRUE/FALSE indicator
##          column added for each requested amputation. This flag can be used to
##          make the SCALE_SCORE (and/or other variables) NA in subsequent use cases.

##    growth.config = NULL
##        - an elongated SGP config script. This needs to have an entry
##          for each grade/content_area/year cohort that will be analyzed
##          in subsequent simulations. See SGP_CONFIG/STEP_0/Ampute_2021/Growth.R

##    status.config = NULL
##        - an elongated SGP config script. This needs to have an entry
##          for each grade/content_area/year cohort that will be analyzed
##          in subsequent simulations. See SGP_CONFIG/STEP_0/Ampute_2021/Status.R
##        - Unlike a growth.config entry, status.config entries use data from
##          the same grade, but from a prior year (i.e. not individual variables).
##          For example you might predict 2021 3rd grade ELA missingness from 2019
##          3rd grade school mean scale score, FRL status, etc.

##    default.vars = c("CONTENT_AREA", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL")
##        - variables that will be used in extracting cohort records (subject and grade)
##          and other variables from the data that the user may want returned in
##          the amputed data.

##    demographics = c("FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "ETHNICITY", "GENDER")
##        - demographic variable flag for factor/character variables to use
##          and/or return in the final dataset.

##    institutions = c("SCHOOL_NUMBER", "DISTRICT_NUMBER")
##        - Institution IDs that will be used/or returned in the amputed data

##    ampute.vars = NULL
##        - Intersection of default.vars, demographics and institutions that will
##          be used in the construction of the weighted scores that define the
##          probability of being missing. Any institution included will be used
##          to construct institution level means of other student level ampute.vars.
##          For example, with c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS"),
##          student level scores and demographics will be used along with their
##          associated school level mean scores and proportion FRL (4 total factors).
##        - The default (NULL) means that no factors are considered, creating a
##          "missing completely at random" (MCAR) missingness pattern.

##    ampute.var.weights = NULL
##        - Relative weights assigned to the ampute vars.  Default is NULL meaning
##          the weighted sum scores will be calculated with equal weight (=1).
##          A named list can be provided with the desired relative weights. For
##          example, 'list(SCALE_SCORE=3, FREE_REDUCED_LUNCH_STATUS=2, SCHOOL_NUMBER=1)'
##          will weight a student's scale scores by a factor of 3 and FRL by 2,
##          with all (any other ampute.vars) remaining at the default of 1. In
##          this example, this includes any school level aggregates.  Note that
##          differential weights for institutions should be placed at the end of
##          the list.  If institution IDs (e.g., SCHOOL_NUMBER) are omitted from
##          the list, the aggregates will be given the same weight as the
##          associated student level variable.  In the given example, SCALE_SCORE
##          and school mean scale score would be given a relative weight of 3.
##        - This argument is ignored when `ampute.vars = NULL`.

##    reverse.weight = "SCALE_SCORE"
##        - The current default for ampute.args$type is "RIGHT", which means that
##          students with high weighted scores have the highest probability for
##          amputation.  This makes sense for high % FRL schools, but not for high
##          achieving students and/or students in high achieving schools. This
##          function inverses the variable(s) individual (and institutional mean)
##          value(s) so that higher weight is given to lower scores/means.
##        - This argument is ignored when `ampute.vars = NULL`.

##    ampute.args = list(prop=0.3, type="RIGHT")
##        - variables to be used in the mice:ampute.continuous function.  Currenly
##          only `prop` and `type` can be modified.  See ? mice::ampute.continuous
##          and?mice::ampute for more information.
##        - The `prop` piece is inexact and has required some modification on my
##          part.  I've made it better, but its still imprecise, particularly for
##          values away from 0.5 (50% missing).  Also, the max missingness is 85%,
##          and for that you need to set prop=0.95 or greater.
##        - Note that the prop gives a total proportion missing, which accounts
##          for missingness already included in the data due to students with
##          incomplete longitudinal data histories.  For example, if a cohort
##          starts with 5% students missing due to incomplete histories, an additional
##          25% will be made missing to get to the 30% (default) missingness.
##        - This last point has been dealt with in some regards with the next
##          (recently added) argument, which removes these cases first.

##    complete.cases.only = TRUE
##        - Should cases with the most recent prior and current score be removed?
##        - This removes students with partial longitudinal histories from the
##          most recent prior (e.g., 2019) to the current year (e.g., 2021), producing
##          a "complete" dataset that is easier to interpret.

##    partial.fill = TRUE
##        - Should an attempt be made to fill in some of the demographic and
##          institution ID information based on students previous values?
##        - Part of the process of the amputeScaleScore function is to take the
##          long data (ampute.data) and then first widen and then re-lengthen the
##          data, which creates wholes for students with incomplete longitudinal
##          records.  This part of the function fills in these wholes for students
##          with existing missing data.

##    invalidate.repeater.dups = TRUE
##        - Students who repeat a grade will get missing data rows inserted for
##          the grade that they "should" be in in 2021.  This leads to duplicated
##          cases that can lead to problems in the SGP analyses.  This argument
##          returns those cases with the VALID_CASE variable set to "INVALID_CASE".

##    seed = 4224L
##        - A random seed set for the amputation process to allow for replication
##          of results, or for alternative results using the same code.

##    M = 10
##        - The number of amputed datasets to return.  The default is 10

##    The function returns a list of M amputed datasets from the specified amputation
##    process.  The datasets will exclude data for students not used in any of the
##    specified growth.config or status.config cohorts, unless the additional.data
##    argument has been included.


#####
###   Example workflow of creating missing data
#####

###   Load packages
require(SGP)
require(data.table)

###   Set working directory to base Learning_Loss_Analysis directory


###   We'll use a copy of the SGPdata::sgpData_LONG_COVID.  We'll also add
###   duplicate SCALE_SCORE and ACHIEVEMENT_LEVEL variables to compare with what
###   has been amputated.

new_covid_data <- data.table::copy(SGPdata::sgpData_LONG_COVID)[,
                                     SCALE_SCORE_COMPLETE := SCALE_SCORE][,
                                     ACH_LEV_COMPLETE := ACHIEVEMENT_LEVEL]

###   Read in STEP 0 SGP configuration scripts
source("SGP_CONFIG/STEP_0/Ampute_2021/Growth.R") # Based on STEP 3, PART A
source("SGP_CONFIG/STEP_0/Ampute_2021/Status.R")

###   To begin with we'll run a quick test using the package defaults along with
###   the augmented data and config scripts we just read in.

###   NOTE: the amputeScaleScore function requires the `mice` package!

Test_Data_LONG <- amputeScaleScore(
                        ampute.data=new_covid_data,
                        growth.config = growth_config_2021,
                        status.config = status_config_2021,
                        M=1) # 1 amputation takes about as long as 10!

length(Test_Data_LONG) # we've created 1 amputed dataset

###   Make sure the proportion missing matches the ampute.args$prop value (default = 0.3)
Test_Data_LONG[[1]][YEAR == "2021" & VALID_CASE == "VALID_CASE",
                      list(NAs = sum(is.na(SCALE_SCORE))/.N),
                      keyby=list(CONTENT_AREA, GRADE)]

###   Note that the observed missingness is a bit above the intended (30%).
###   The mice::ampute.continuous function does a decent job around 30% - 50%
###   and worse the further away you get from there! I've tried to correct for
###   this, but it's still a bit off. Depending on how exact you want, you'll need
###   to play around with the default ampute.args$prop argument. 85% is about the
###   most missing I can get it to amputate. Hopefully that extreme enough...

##    amputeScaleScore does not return 2019 scores not used as priors
table(Test_Data_LONG[[1]][, GRADE, YEAR])

##    We may want to add in 2019 priors (could also add in 2018 grades 6:8) for
##    some status and growth comparisons from 2019, so we'll manually add those
##    in to the amputed data via the `additional.data` argument.
priors_to_add <- new_covid_data[YEAR == "2019" & GRADE %in% c("7", "8")]

##    We also want to produce an interesting missingness pattern.  For example,
##    here we will simulate missingness that is correlated with (low) achievement
##    and economic disadvantage (as indicated by Free/Reduced lunch status).  We
##    will also assume that these factors are compounded by the school level
##    concentration of low achievement and economic disadvantage.

my.amp.vars <- c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS")

###   Specify the number of amputed data sets to create - 10 is the default.
MM = 10

##    Also need to add in the additiona variable names that we want returned in
##    the data (SCALE_SCORE_COMPLETE and ACH_LEV_COMPLETE).  We'll add those to the `default.vars`

table(Test_Data_LONG[[1]][!is.na(SCALE_SCORE) & is.na(SCALE_SCORE_COMPLETE), GRADE, YEAR])  # nothing here - didn't return "SCALE_SCORE_COMPLETE"


###   Run 10 amputations with added priors
Test_Data_LONG <- amputeScaleScore(
                      ampute.data=new_covid_data,
                      additional.data = priors_to_add,
                      growth.config = growth_config_2021,
                      status.config = status_config_2021,
                      M=MM,
                      default.vars = c("CONTENT_AREA", "GRADE",
                                       "SCALE_SCORE", "SCALE_SCORE_COMPLETE",
                                       "ACHIEVEMENT_LEVEL", "ACH_LEV_COMPLETE"),
                      ampute.vars = my.amp.vars)

##    All 2019 prior scores are now added
table(Test_Data_LONG[[1]][, GRADE, YEAR])
table(Test_Data_LONG[[10]][, GRADE, YEAR])

##    Total missing scores in 2021 (note that we still have their "actual" score)
table(Test_Data_LONG[[3]][is.na(SCALE_SCORE) & !is.na(SCALE_SCORE_COMPLETE), GRADE, YEAR])
table(Test_Data_LONG[[3]][is.na(SCALE_SCORE) & !is.na(SCALE_SCORE_COMPLETE), GRADE, CONTENT_AREA])

##    Inspect score missingness for all amputations
for (m in seq(MM)) {print(Test_Data_LONG[[m]][YEAR == "2021" & VALID_CASE == "VALID_CASE",
                      list(NAs = sum(is.na(SCALE_SCORE))/.N), keyby=list(CONTENT_AREA, GRADE)])}

##    Inspect score summaries for all amputations
for (m in seq(MM)) {print(Test_Data_LONG[[m]][YEAR == "2021" & VALID_CASE == "VALID_CASE",
                      as.list(summary(SCALE_SCORE)), keyby=list(CONTENT_AREA, GRADE)])}


#####
###      Missing data exploration/visualization
#####

###   Now that we have some amputated data, we should evaluate it to make sure
###   it looks like what we wanted.  In our assumptions, we expect to see more
###   missing data for students with lower 2019 scale scores, who are FRL, etc.
###   The following visualization from the `VIM` package are helpful in exploring.
###   I'd recommend looking into the VIM package for more context on these plots.
###   In general, blue means observed data, red means missing.
###   A decent intro is given at https://www.datacamp.com/community/tutorials/visualize-data-vim-package

require(VIM)

###   Visualizations are easier with WIDE data, so we'll widen our datasets first.

long.to.wide.vars <- c("GRADE", "SCALE_SCORE", "SCALE_SCORE_COMPLETE",
                       "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "ETHNICITY")

###  Create a wide data set from each M amputated data sets
Test_Data_WIDE <- vector(mode = "list", length = MM)

for (m in seq(MM)) {
  Test_Data_WIDE[[m]] <- dcast(Test_Data_LONG[[m]][VALID_CASE == "VALID_CASE" & YEAR %in% c("2019", "2021")],
                    ID + CONTENT_AREA ~ YEAR, sep=".", drop=FALSE, value.var=long.to.wide.vars) # can also do ID ~ YEAR + CONTENT_AREA - extra wide

  ##  Trim data of (107) cases with no data in 2019 or 2021
  Test_Data_WIDE[[m]] <- Test_Data_WIDE[[m]][!(is.na(GRADE.2019) & is.na(GRADE.2021))]

  ##  Fill in GRADE according to our expectations of normal progression
  Test_Data_WIDE[[m]][is.na(GRADE.2019), GRADE.2019 := as.numeric(GRADE.2021)-2L]
  Test_Data_WIDE[[m]][is.na(GRADE.2021), GRADE.2021 := as.numeric(GRADE.2019)+2L]

  ##  Exclude irrelevant GRADE levels
  Test_Data_WIDE[[m]] <- Test_Data_WIDE[[m]][GRADE.2021 %in% 3:8] # Current relevant GRADEs
  Test_Data_WIDE[[m]][!GRADE.2019 %in% 3:6, GRADE.2019 := NA] # Clean up prior GRADEs

  ##  Fill some more (but not all) - Demographics used in missing data plots ONLY
  Test_Data_WIDE[[m]][is.na(FREE_REDUCED_LUNCH_STATUS.2019), FREE_REDUCED_LUNCH_STATUS.2019 := FREE_REDUCED_LUNCH_STATUS.2021]
  Test_Data_WIDE[[m]][is.na(ELL_STATUS.2019), ELL_STATUS.2019 := ELL_STATUS.2021]
  Test_Data_WIDE[[m]][is.na(ETHNICITY.2019), ETHNICITY.2019 := ETHNICITY.2019]
}


###   Start with looking at demographic variables.  Here's missing in 2021 given 2019 ETHNICITY:
spineMiss(as.data.frame(Test_Data_WIDE[[m]][, c("ETHNICITY.2019", "SCALE_SCORE.2021")]), interactive=FALSE)
###   Not much differential impact, which makes sense give ETHNICITY was not used in the amputation calculation
###   (but there may certainly be interactions playing out from other factors)

###   Next we'll look at the interplay between FRL, ELL and missingness
mosaicMiss(Test_Data_WIDE[[m]][, c("FREE_REDUCED_LUNCH_STATUS.2019", "ELL_STATUS.2019", "SCALE_SCORE.2021")],
           highlight = 3, plotvars = 1:2, miss.labels = FALSE)
###   Here we see that FRL and ELL students are more likely to be missing in 2021.
###   This is very much the case for students who are both FRL and ELL.  Too much so?


###   Now we'll look at missingness related to prior scale scores.
###   First lets look at what we started with in the SGPdata::sgpData_LONG_COVID
sgpData_WIDE_COVID <- dcast(new_covid_data[YEAR %in% c("2019", "2021") & VALID_CASE == "VALID_CASE"],
                  ID + CONTENT_AREA ~ YEAR, sep=".", drop=FALSE, value.var=c("GRADE", "SCALE_SCORE"))

##    Trim things down with all NAs (79 cases) and fill in some missing info (partial.fill)
sgpData_WIDE_COVID <- sgpData_WIDE_COVID[!(is.na(GRADE.2019) & is.na(GRADE.2021))]

table(sgpData_WIDE_COVID[, GRADE.2019], exclude=NULL)
sgpData_WIDE_COVID[is.na(GRADE.2019), GRADE.2019 := as.numeric(GRADE.2021)-2L]
table(sgpData_WIDE_COVID[, GRADE.2019], exclude=NULL) # some non-sensical GRADE values we'll get rid of later

table(sgpData_WIDE_COVID[, GRADE.2021], exclude=NULL)
sgpData_WIDE_COVID[is.na(GRADE.2021), GRADE.2021 := as.numeric(GRADE.2019)+2L]
table(sgpData_WIDE_COVID[, GRADE.2021], exclude=NULL) # some non-sensical GRADE values we'll get rid of later

sgpData_WIDE_COVID <- sgpData_WIDE_COVID[GRADE.2021 %in% 5:8]
sgpData_WIDE_COVID <- sgpData_WIDE_COVID[GRADE.2019 %in% 3:6]

###  Some plots from the unaltered data (note this is scores for all grades, and scale is not standardized)
histMiss(as.data.frame(sgpData_WIDE_COVID[, c("SCALE_SCORE.2019", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE)
marginplot(as.data.frame(sgpData_WIDE_COVID[, c("SCALE_SCORE.2019", "SCALE_SCORE.2021")]))
scattmatrixMiss(as.data.frame(sgpData_WIDE_COVID[, c("SCALE_SCORE.2019", "SCALE_SCORE.2021")]), interactive=FALSE)

###   Compare those with what we have in one of our amputated datasets:
###   Change m to see results from other amputations, and run the same plot types
###   for unaltered/amputed data back to back...
histMiss(as.data.frame(Test_Data_WIDE[[m]][, c("SCALE_SCORE.2019", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE, only.miss=FALSE)
marginplot(as.data.frame(Test_Data_WIDE[[m]][, c("SCALE_SCORE.2019", "SCALE_SCORE.2021")]))
scattmatrixMiss(as.data.frame(Test_Data_WIDE[[m]][, c("SCALE_SCORE.2019", "SCALE_SCORE.2021")]), interactive=FALSE)

###   Basically what we see is that in the unaltered data the 2021 missing cases
###   are more-or-less randomly distributed given 2019 observed scores. After
###   amputation, however, the distribution of missings are heavily concentrated
###   in lower prior score observations.

###   Check out similar plots for GRADE specific subsets:
histMiss(as.data.frame(Test_Data_WIDE[[m]][GRADE.2021 == "8" & CONTENT_AREA=="ELA", c("SCALE_SCORE.2019", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE)
marginplot(as.data.frame(Test_Data_WIDE[[m]][GRADE.2021 == "8" & CONTENT_AREA=="ELA", c("SCALE_SCORE.2019", "SCALE_SCORE.2021")]))

scattmatrixMiss(as.data.frame(Test_Data_WIDE[[m]][GRADE.2021 == "8" & CONTENT_AREA=="ELA",
    c("SCALE_SCORE.2019", "SCALE_SCORE.2021")]), interactive=FALSE)

###   Check status only grades for desired missing patterns
histMiss(as.data.frame(Test_Data_WIDE[[m]][GRADE.2021 == "3" & CONTENT_AREA=="ELA", c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE)

mosaicMiss(Test_Data_WIDE[[m]][GRADE.2021 == "3" & CONTENT_AREA=="ELA", c("FREE_REDUCED_LUNCH_STATUS.2019", "ELL_STATUS.2019", "SCALE_SCORE.2021")],
           highlight = 3, plotvars = 1:2, miss.labels = FALSE)


###   Lastly, we can look at the amputed data relative to what we know to be "true"
###   Even though we didn't specify a MNAR missing pattern, we see that missingness
###   is highly correlated with unobserved (current) score because we've used prior
###   scores to determine the probability of missingness.  Given their high correlation
###   we see that play out in the amputed data as well.

histMiss(as.data.frame(Test_Data_WIDE[[m]][, c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE)
histMiss(as.data.frame(Test_Data_WIDE[[m]][GRADE.2021 == "3" & CONTENT_AREA=="ELA", c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE)
histMiss(as.data.frame(Test_Data_WIDE[[m]][GRADE.2021 == "8" & CONTENT_AREA=="ELA", c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE)

##    The "marginplot" shows that the "observed" 2021 scores are identical to the
##    "actual" scores (blue dots along a perfect diagonal) - those are unaltered.
##    The distribution of the missing scores is skewed towards the lower end of
##    achievement according to the (red) boxplot.

histMiss(as.data.frame(Test_Data_WIDE[[m]][, c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE)
marginplot(as.data.frame(Test_Data_WIDE[[m]][, c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]))

##    GROWTH grades only
histMiss(as.data.frame(Test_Data_WIDE[[m]][!GRADE.2021 %in% c("3", "4") & CONTENT_AREA=="ELA", c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE)
histMiss(as.data.frame(Test_Data_WIDE[[m]][!GRADE.2021 %in% c("3", "4") & CONTENT_AREA=="MATHEMATICS", c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE)
marginplot(as.data.frame(Test_Data_WIDE[[m]][!GRADE.2021 %in% c("3", "4") & CONTENT_AREA=="ELA", c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]))
marginplot(as.data.frame(Test_Data_WIDE[[m]][!GRADE.2021 %in% c("3", "4") & CONTENT_AREA=="MATHEMATICS", c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]))

##    STATUS grades only
histMiss(as.data.frame(Test_Data_WIDE[[m]][GRADE.2021 %in% c("3", "4") & CONTENT_AREA=="ELA", c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE)
histMiss(as.data.frame(Test_Data_WIDE[[m]][GRADE.2021 %in% c("3", "4") & CONTENT_AREA=="MATHEMATICS", c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]), breaks=25, interactive=FALSE)
marginplot(as.data.frame(Test_Data_WIDE[[m]][GRADE.2021 %in% c("3", "4") & CONTENT_AREA=="ELA", c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]))
marginplot(as.data.frame(Test_Data_WIDE[[m]][GRADE.2021 %in% c("3", "4") & CONTENT_AREA=="MATHEMATICS", c("SCALE_SCORE_COMPLETE.2021", "SCALE_SCORE.2021")]))


#####
###      Missing data analysis
#####

###   In the following I run through how I would go about pooling the results
###   from the 10 amputed data sets to see how the results differ from the
###   "known truth".  I still need to dig into this part of it more.  But this
###   should be extendable to growth aggregates as well, and to include our
###   attempts at creating "plausible" aggregates.

school_means <- vector(mode = "list", length = length(Test_Data_LONG))
for (m in seq(MM)) {
  sch_mean <- Test_Data_LONG[[m]][YEAR %in% c("2019", "2021"), list(
    Mean_SS_SCHOOL = mean(SCALE_SCORE, na.rm=TRUE),
    SD_SS_SCHOOL = sd(SCALE_SCORE, na.rm=TRUE),
    Mean_SS_SCHOOL_COMPLETE = mean(SCALE_SCORE_COMPLETE, na.rm=TRUE),
    SD_SS_SCHOOL_COMPLETE = sd(SCALE_SCORE_COMPLETE, na.rm=TRUE),
    N = .N, PRESENT = sum(!is.na(SCALE_SCORE)),
    MISSING = sum(is.na(SCALE_SCORE))), keyby = c("YEAR", "CONTENT_AREA", "GRADE", "SCHOOL_NUMBER")]

  school_means[[m]] <- dcast(sch_mean, CONTENT_AREA + GRADE + SCHOOL_NUMBER ~ YEAR,
    value.var= c("Mean_SS_SCHOOL", "SD_SS_SCHOOL", "Mean_SS_SCHOOL_COMPLETE", "SD_SS_SCHOOL_COMPLETE", "N", "PRESENT", "MISSING"), sep=".", drop=FALSE)
}

school_means <- rbindlist(school_means)
school_means[, c("Mean_SS_SCHOOL_COMPLETE.2019", "SD_SS_SCHOOL_COMPLETE.2019") := NULL]
setkeyv(school_means, c("CONTENT_AREA", "GRADE", "SCHOOL_NUMBER"))

pooled_school_means <- school_means[, list(
  Mean_SS_SCHOOL__2019 = mean(Mean_SS_SCHOOL.2019, na.rm=TRUE), # Should all be the same
  Mean_SD_SCHOOL__2019 = mean(SD_SS_SCHOOL.2019, na.rm=TRUE),
  Mean_SS_SCHOOL__2021 = mean(Mean_SS_SCHOOL.2021, na.rm=TRUE),
  SD_Mean_SS_SCHOOL__2021 = sd(Mean_SS_SCHOOL.2021, na.rm=TRUE),
  Mean_SD_SCHOOL__2021 = mean(SD_SS_SCHOOL.2021, na.rm=TRUE),
  Mean_SS_SCHOOL_COMPLETE__2021 = mean(Mean_SS_SCHOOL_COMPLETE.2021, na.rm=TRUE),
  Mean_SD_SCHOOL_COMPLETE__2021 = mean(SD_SS_SCHOOL_COMPLETE.2021, na.rm=TRUE),
  Mean_Present = mean(PRESENT.2021, na.rm=TRUE),
  Mean_Missing = mean(MISSING.2021, na.rm=TRUE)), keyby=c("CONTENT_AREA", "GRADE", "SCHOOL_NUMBER")]

# Note this object has rows for each grade/content in all schools (grades 6-8 for elementary schools & 3-5 for middle schools)
pooled_school_means[(!is.na(Mean_SS_SCHOOL__2019) & !is.na(Mean_SS_SCHOOL__2021)), # remove noted schools
  as.list(summary(Mean_SS_SCHOOL__2021-Mean_SS_SCHOOL__2019, na.rm=TRUE)), keyby=c("CONTENT_AREA", "GRADE")]

###   Actual mean is smaller than in amputed
pooled_school_means[(!is.na(Mean_SS_SCHOOL_COMPLETE__2021) & !is.na(Mean_SS_SCHOOL__2021)), # remove noted schools
  as.list(summary(Mean_SS_SCHOOL_COMPLETE__2021-Mean_SS_SCHOOL__2021, na.rm=TRUE)), keyby=c("CONTENT_AREA", "GRADE")]

###   Actual standard deviation is larger than in amputed
pooled_school_means[(!is.na(Mean_SD_SCHOOL_COMPLETE__2021) & !is.na(Mean_SD_SCHOOL__2021)), # remove noted schools
  as.list(summary(Mean_SD_SCHOOL_COMPLETE__2021-Mean_SD_SCHOOL__2021, na.rm=TRUE)), keyby=c("CONTENT_AREA", "GRADE")]
