################################################################################
###                                                                          ###
###  STEP 2B: Demonstration COVID Skip-year Baseline SGP analyses for 2019   ###
###                                                                          ###
################################################################################

###   Set working directory to Learning_Loss_Analysis repo
setwd("..")


### Get output_directory set up for analyses
if (!exists("output.directory")) output.directory <- "Data/BASIC_ANALYSIS"


###   Load packages
require(SGP)

###   Load data
load(file.path(output.directory, "Demonstration_COVID_SGP_STEP_1.Rdata"))


###   Add Baseline matrices calculated in STEP 2, PART A  to SGPstateData
load(file.path(output.directory, "DEMO_COVID_Baseline_Matrices-SingleCohort.Rdata")) # Alternatively add 'SuperCohort' version if preferred
SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices

###   Read in STEP 3, PART B SGP Configuration Scripts and Combine
source("SGP_CONFIG/STEP_2/PART_B/ELA.R")
source("SGP_CONFIG/STEP_2/PART_B/MATHEMATICS.R")

DEMO_COVID_CONFIG_STEP_2B <- c(ELA_2019.config, MATHEMATICS_2019.config)


#####
###   Run analysis - run abcSGP on object from Step 1 (with BASELINE matrices and configurations - no additional data)
#####

###   Temporarily set names of prior scores from sequential/cohort analyses
data.table::setnames(Demonstration_COVID_SGP@Data,
  c("SCALE_SCORE_PRIOR", "SCALE_SCORE_PRIOR_STANDARDIZED"),
  c("SS_PRIOR_COHORT", "SS_PRIOR_STD_COHORT"))

###   abcSGP
Demonstration_COVID_SGP <- abcSGP(
        sgp_object = Demonstration_COVID_SGP,
        steps = c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
        sgp.config = DEMO_COVID_CONFIG_STEP_2B,
        sgp.percentiles = FALSE,
        sgp.projections = FALSE,
        sgp.projections.lagged = FALSE,
        sgp.percentiles.baseline = TRUE,  #  Skip year SGPs for 2021 comparisons
        sgp.projections.baseline = FALSE, #  Calculated in next step
        sgp.projections.lagged.baseline = FALSE,
        save.intermediate.results = FALSE,
        outputSGP.directory=output.directory
        # parallel.config = ...  #  Optional parallel processing - see SGP
				# 	 									 	 #  package documentation for details.
)

###   Re-set and rename prior scores
data.table::setnames(Demonstration_COVID_SGP@Data,
  c("SCALE_SCORE_PRIOR", "SCALE_SCORE_PRIOR_STANDARDIZED", "SS_PRIOR_COHORT", "SS_PRIOR_STD_COHORT"),
  c("SCALE_SCORE_PRIOR_BASELINE", "SCALE_SCORE_PRIOR_STANDARDIZED_BASELINE", "SCALE_SCORE_PRIOR", "SCALE_SCORE_PRIOR_STANDARDIZED"))

###   Save results
save(Demonstration_COVID_SGP, file=file.path(output.directory, "Demonstration_COVID_SGP_2019_STEP_2b.Rdata"))
