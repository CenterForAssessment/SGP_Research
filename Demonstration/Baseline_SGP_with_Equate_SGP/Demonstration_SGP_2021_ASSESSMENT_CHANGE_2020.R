######################################################################################
###
### SGP analyses for 2021 data
###
######################################################################################

### Load packages
require(SGP)
require(data.table)

### Load data
load("Data/ASSESSMENT_CHANGE_2020/Demonstration_SGP_LONG_Data_ASSESSMENT_CHANGE_2020.Rdata")

### Only use 2 priors
SGPstateData[["DEMO"]][["SGP_Configuration"]][["max.order.for.percentile"]] <- 2

### Put score prior to 2020_2021 on the 2020_2021 scale using equateSGP.
SGPstateData[["DEMO"]][["Assessment_Program_Information"]][["Assessment_Transition"]][["Year"]] <- "2019_2020"

Demonstration_SGP_LONG_Data_ASSESSMENT_CHANGE_2020[,SCALE_SCORE_ORIGINAL:=SCALE_SCORE]

data.for.equate <- Demonstration_SGP_LONG_Data_ASSESSMENT_CHANGE_2020[YEAR <= "2019_2020"]
tmp.equate.linkages <- SGP:::equateSGP(
                                tmp.data=data.for.equate,
                                state="DEMO",
                                current.year="2019_2020",
                                equating.method=c("identity", "mean", "linear", "equipercentile"))

setkey(data.for.equate, VALID_CASE, CONTENT_AREA, YEAR, GRADE, SCALE_SCORE)

data.for.equate <- SGP:::convertScaleScore(data.for.equate, "2019_2020", tmp.equate.linkages, "OLD_TO_NEW", "equipercentile", "DEMO")
data.for.equate[YEAR < "2020_2021", SCALE_SCORE:=SCALE_SCORE_EQUATED_EQUIPERCENTILE_OLD_TO_NEW]
data.for.equate[,SCALE_SCORE_EQUATED_EQUIPERCENTILE_OLD_TO_NEW:=NULL]

Demonstration_SGP_LONG_Data_ASSESSMENT_CHANGE_2020 <- rbindlist(list(data.for.equate, Demonstration_SGP_LONG_Data_ASSESSMENT_CHANGE_2020[YEAR=="2020_2021"]))
setkey(Demonstration_SGP_LONG_Data_ASSESSMENT_CHANGE_2020, VALID_CASE, CONTENT_AREA, YEAR, ID)


### abcSGP
Demonstration_SGP_2021_ASSESSMENT_CHANGE_2020 <- abcSGP(
                                    Demonstration_SGP_LONG_Data_ASSESSMENT_CHANGE_2020,
                                    steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
                                    years=c("2020_2021"),
                                    sgp.percentiles=TRUE,
                                    sgp.projections=FALSE,
                                    sgp.projections.lagged=FALSE,
                                    sgp.percentiles.baseline=FALSE,
                                    sgp.projections.baseline=FALSE,
                                    sgp.projections.lagged.baseline=FALSE,
                                    outputSGP.directory="Data/ASSESSMENT_CHANGE_2020"

)

### Save results
save(Demonstration_SGP_2021_ASSESSMENT_CHANGE_2020, file="Data/ASSESSMENT_CHANGE_2020/Demonstration_SGP_2021_ASSESSMENT_CHANGE_2020.Rdata")
