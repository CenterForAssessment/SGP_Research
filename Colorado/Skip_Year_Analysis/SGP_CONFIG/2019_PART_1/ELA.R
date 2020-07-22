################################################################################
###                                                                          ###
###          ELA 2019 SGP Configurations for 2021 Contingency Plan           ###
###                                                                          ###
################################################################################

ELA.2019.config <- list(
	ELA.2019 = list(
		sgp.content.areas=rep("ELA", 3),
		sgp.panel.years=c("2016", "2017", "2019"),
		sgp.grade.sequences=list(c("3", "5"), c("3", "4", "6"), c("4", "5", "7"), c("5", "6", "8")))
)


###
###		PSAT/SAT ELA
###

ELA_PSAT_9.2019.config <- list(
	ELA_PSAT_9.2019 = list(
		sgp.content.areas=c("ELA", "ELA", "ELA_PSAT_9"),
		sgp.panel.years=c("2016", "2017", "2019"),
		sgp.grade.sequences=list(c("5", "6", "7", "9")))
)

ELA_PSAT_10.2019.config <- list(
	ELA_PSAT_10.2019 = list(
		sgp.content.areas=c("ELA", "ELA", "ELA_PSAT_10"),
		sgp.panel.years=c("2016", "2017", "2019"),
		sgp.grade.sequences=list(c("7", "8", "10")),
		sgp.projection.grade.sequences=list("NO_PROJECTIONS"))
)

ELA_SAT.2019.config <- list(
	ELA_SAT.2019 = list(
		sgp.content.areas=c("ELA", "ELA", "ELA_SAT"),
		sgp.panel.years=c("2016", "2017", "2019"),
		sgp.grade.sequences=list(c("8", "9", "11")))
)
