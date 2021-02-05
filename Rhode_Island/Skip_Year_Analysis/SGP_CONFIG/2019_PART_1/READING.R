################################################################################
###                                                                          ###
###        Reading 2019 SGP Configurations for 2021 Contingency Plan         ###
###                                                                          ###
################################################################################

READING_2019.config <- list(
	READING.2019 = list(
		sgp.content.areas=rep("READING", 5),
		sgp.panel.years=c("2014", "2015", "2016", "2017", "2019"),
		sgp.grade.sequences=list(c("3", "5"), c("3", "4", "6"), c("3", "4", "5", "7"), c("3", "4", "5", "6", "8"))),

	READING.2019 = list( # No change from 'official' 2019 analysis
    sgp.content.areas=rep("READING", 4),
    sgp.panel.years=c("2014", "2015", "2016", "2019"),
    sgp.grade.sequences=list(c("6", "7", "8", "11")))
)
