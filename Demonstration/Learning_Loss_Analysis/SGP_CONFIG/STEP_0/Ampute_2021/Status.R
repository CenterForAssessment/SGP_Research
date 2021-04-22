#####
###   ELA and MATHEMATICS 2021 status configurations for amputeScaleScore
#####

ELA_STATUS_2021.config <- list(
  ELA.2021 = list(
    sgp.content.areas = rep("ELA", 2),
    sgp.panel.years = c("2019", "2021"),
    sgp.grade.sequences = c("3", "3")),
  ELA.2021 = list(
    sgp.content.areas = rep("ELA", 2),
    sgp.panel.years = c("2019", "2021"),
    sgp.grade.sequences = c("4", "4"))
)

MATHEMATICS_STATUS_2021.config <- list(
  MATHEMATICS.2021 = list(
    sgp.content.areas = rep("MATHEMATICS", 2),
    sgp.panel.years = c("2019", "2021"),
    sgp.grade.sequences = c("3", "3")),
  MATHEMATICS.2021 = list(
    sgp.content.areas = rep("MATHEMATICS", 2),
    sgp.panel.years = c("2019", "2021"),
    sgp.grade.sequences = c("4", "4"))
)

status_config_2021 <- c(
  ELA_STATUS_2021.config,
  MATHEMATICS_STATUS_2021.config
)
