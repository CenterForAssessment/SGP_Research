################################################################################
###                                                                          ###
###        STEP 3: Demonstration COVID Skip-year SGP analyses for 2021       ###
###                                                                          ###
################################################################################

###   Set working directory to Learning_Loss_Analysis repo
setwd("..")


### Get input/output.directory set up for analyses
if (!exists("output.directory")) output.directory <- "Data/BASIC_ANALYSIS"
if (!exists("input.directory")) input.directory <- output.directory

### Set up parrallel.config if it doesn't exist
if (!exists("parallel.config")) parallel.config <- NULL

###   Load packages
require(SGP)
require(SGPdata)


###   Load data
load(file.path(input.directory, "Demonstration_COVID_SGP_2019_STEP_2c.Rdata"))


###   Create 2021 subset of COVID data
if (!exists("Demonstration_COVID_Data_LONG_2021"))
  Demonstration_COVID_Data_LONG_2021 <- sgpData_LONG_COVID[YEAR == "2021"]


###   Add Baseline matrices calculated in STEP 2A to SGPstateData
load(file.path(input.directory, "DEMO_COVID_Baseline_Matrices-SingleCohort.Rdata")) # Alternatively add 'SuperCohort' version if preferred
SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices


###   Read in STEP 3 SGP Configuration Scripts and Combine
source("SGP_CONFIG/STEP_3/PART_A/ELA.R")
source("SGP_CONFIG/STEP_3/PART_A/MATHEMATICS.R")

DEMO_COVID_CONFIG_STEP_3 <- c(ELA_2021.config, MATHEMATICS_2021.config)


#####
###   Run analysis
#####

Demonstration_COVID_SGP <- updateSGP(
        what_sgp_object = Demonstration_COVID_SGP,
        with_sgp_data_LONG = Demonstration_COVID_Data_LONG_2021,
        steps = c("prepareSGP", "analyzeSGP", "combineSGP"),
        sgp.config = DEMO_COVID_CONFIG_STEP_3,
        sgp.percentiles = TRUE,
        sgp.projections = FALSE,
        sgp.projections.lagged = FALSE,
        sgp.percentiles.baseline = TRUE,
        sgp.projections.baseline = FALSE,
        sgp.projections.lagged.baseline = FALSE,
        save.intermediate.results = FALSE,
        outputSGP.directory=output.directory,
        parallel.config=parallel.config  #  Optional parallel processing - see SGP package documentation for details.
)

###   Save results
save(Demonstration_COVID_SGP, file=file.path(output.directory, "Demonstration_COVID_SGP_2021_STEP_3a.Rdata"))
