source("SGP_CONFIG/STEP_3/PART_A/ELA.R")
source("SGP_CONFIG/STEP_3/PART_A/MATHEMATICS.R")

###   Combine config elements in the typical way
growth_config_2021 <- c(
  ELA_2021.config,
  MATHEMATICS_2021.config
)

###   Extend config out (one list element per cohort)
growth_config_2021 <- SGP:::getSGPConfig(
  sgp_object=list(),
  state = "DEMO_COVID",
  tmp_sgp_object = list(),
  content_areas=NULL,
  years = NULL,
  grades=NULL,
  sgp.config=growth_config_2021,
  trim.sgp.config=TRUE,
  sgp.percentiles=TRUE,
  sgp.projections=FALSE,
  sgp.projections.lagged=FALSE,
  sgp.percentiles.baseline=FALSE,
  sgp.projections.baseline=FALSE,
  sgp.projections.lagged.baseline=FALSE,
  sgp.config.drop.nonsequential.grade.progression.variables = FALSE,
  sgp.minimum.default.panel.years=3,
  sgp.use.my.coefficient.matrices=NULL)[[1]]
