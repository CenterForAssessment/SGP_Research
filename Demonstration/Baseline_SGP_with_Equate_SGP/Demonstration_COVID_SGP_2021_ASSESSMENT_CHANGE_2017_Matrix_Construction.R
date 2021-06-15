######################################################################################
###
### Baseline matrix calculation using ASSESSMENT_CHANGE_2017 (non-perturbed) data (2016, 2017, 2019)
###
######################################################################################

### Load packages
require(SGP)
require(data.table)

### Set up parameters
parallel.config <- list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=4, BASELINE_PERCENTILES=4, PROJECTIONS=4, LAGGED_PROJECTIONS=4, SGP_SCALE_SCORE_TARGETS=4, BASELINE_MATRICES=4))

### Load data
load("Data/ASSESSMENT_CHANGE_2017/Demonstration_COVID_SGP_LONG_Data_ASSESSMENT_CHANGE_2017.Rdata")

### Put 2016 scores on current scale using equateSGP
SGPstateData[["DEMO_COVID"]][["Assessment_Program_Information"]][["Assessment_Transition"]][["Year"]] <- "2017"

Demonstration_COVID_SGP_LONG_Data_ASSESSMENT_CHANGE_2017[,SCALE_SCORE_ORIGINAL:=SCALE_SCORE]

data.for.equate <- Demonstration_COVID_SGP_LONG_Data_ASSESSMENT_CHANGE_2017[YEAR <= "2018"]
tmp.equate.linkages <- SGP:::equateSGP(
                                tmp.data=data.for.equate,
                                state="DEMO",
                                current.year="2018",
                                equating.method=c("identity", "mean", "linear", "equipercentile"))

setkey(data.for.equate, VALID_CASE, CONTENT_AREA, YEAR, GRADE, SCALE_SCORE)

data.for.equate <- SGP:::convertScaleScore(data.for.equate, "2018", tmp.equate.linkages, "OLD_TO_NEW", "equipercentile", "DEMO")
data.for.equate[YEAR < "2018", SCALE_SCORE:=SCALE_SCORE_EQUATED_EQUIPERCENTILE_OLD_TO_NEW]
data.for.equate[,SCALE_SCORE_EQUATED_EQUIPERCENTILE_OLD_TO_NEW:=NULL]

Demonstration_COVID_SGP_LONG_Data_ASSESSMENT_CHANGE_2017 <- rbindlist(list(data.for.equate, Demonstration_COVID_SGP_LONG_Data_ASSESSMENT_CHANGE_2017[YEAR >"2018"]))

### Pull in to loss/hoss any abberant values
for (content_area.iter in c("ELA", "MATHEMATICS")) {
    for (grade.iter in as.character(3:8)) {
        tmp.loss.hoss <- SGPstateData[['DEMO_COVID']][['Achievement']][['Knots_Boundaries']][[content_area.iter]][[paste('loss.hoss', grade.iter, sep="_")]]
        Demonstration_COVID_SGP_LONG_Data_ASSESSMENT_CHANGE_2017[SCALE_SCORE < tmp.loss.hoss[1], SCALE_SCORE:=tmp.loss.hoss[1]]
        Demonstration_COVID_SGP_LONG_Data_ASSESSMENT_CHANGE_2017[SCALE_SCORE > tmp.loss.hoss[2], SCALE_SCORE:=tmp.loss.hoss[2]]
    }
}
setkey(Demonstration_COVID_SGP_LONG_Data_ASSESSMENT_CHANGE_2017, VALID_CASE, CONTENT_AREA, YEAR, ID)


########################################################################
### Create baseline matrices
########################################################################

###  Create a smaller subset of the LONG data to work with.
Demonstration_COVID_Data_LONG <- data.table(Demonstration_COVID_SGP_LONG_Data_ASSESSMENT_CHANGE_2017[,
		c("ID", "CONTENT_AREA", "YEAR", "GRADE", "SCALE_SCORE", "VALID_CASE"),])

###   Read in Baseline SGP Configuration Scripts and Combine
source("SGP_CONFIG/Baseline_Matrix/ELA.R")
source("SGP_CONFIG/Baseline_Matrix/MATHEMATICS.R")

BASELINE_MATRIX_CONFIG <- c(
	ELA_BASELINE.config,
	MATHEMATICS_BASELINE.config
)

Demonstration_COVID_SGP <- prepareSGP(Demonstration_COVID_Data_LONG, create.additional.variables=FALSE)

DEMO_COVID_Baseline_Matrices_ASSESSMENT_CHANGE_2017 <- baselineSGP(
				Demonstration_COVID_SGP,
				sgp.baseline.config=BASELINE_MATRIX_CONFIG,
				return.matrices.only=TRUE,
				calculate.baseline.sgps=FALSE,
				goodness.of.fit.print=FALSE,
				parallel.config=parallel.config  #  Optional parallel processing - see SGP package documentation for details.
)

###   Save results
save(DEMO_COVID_Baseline_Matrices_ASSESSMENT_CHANGE_2017, file="Data/ASSESSMENT_CHANGE_2017/DEMO_COVID_Baseline_Matrices-SingleCohort_ASSESSMENT_CHANGE_2017.Rdata")
