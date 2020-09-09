###
### Configurations for calculating ELA LAGGED PROJECTIONS in 2019
###


ELA_2019.config <- list(
     ELA.2019 = list(
                 sgp.content.areas=c("ELA", "ELA"),
                 sgp.baseline.content.areas=c("ELA", "ELA"),
                 sgp.panel.years=c("2017", "2019"),
                 sgp.baseline.panel.years=c("2017", "2019"),
                 sgp.grade.sequences=list(c("3", "5")),
                 sgp.baseline.grade.sequences=list(c("3", "5")),
                 sgp.panel.years.within=c("LAST_OBSERVATION", "FIRST_OBSERVATION"),
                 sgp.projection.sequence="ELA_GRADE_5"),
     ELA.2019 = list(
                 sgp.content.areas=c("ELA", "ELA", "ELA"),
                 sgp.baseline.content.areas=c("ELA", "ELA", "ELA"),
                 sgp.panel.years=c("2016", "2017", "2019"),
                 sgp.baseline.panel.years=c("2016", "2017", "2019"),
                 sgp.grade.sequences=list(c("3", "4", "6")),
                 sgp.baseline.grade.sequences=list(c("3", "4", "6")),
                 sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                 sgp.projection.sequence="ELA_GRADE_6"),
     ELA.2019 = list(
                 sgp.content.areas=c("ELA", "ELA", "ELA"),
                 sgp.baseline.content.areas=c("ELA", "ELA", "ELA"),
                 sgp.panel.years=c("2016", "2017", "2019"),
                 sgp.baseline.panel.years=c("2016", "2017", "2019"),
                 sgp.grade.sequences=list(c("4", "5", "7")),
                 sgp.baseline.grade.sequences=list(c("4", "5", "7")),
                 sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                 sgp.projection.sequence="ELA_GRADE_7"),
     ELA.2019 = list(
                 sgp.content.areas=c("ELA", "ELA", "ELA"),
                 sgp.baseline.content.areas=c("ELA", "ELA", "ELA"),
                 sgp.panel.years=c("2016", "2017", "2019"),
                 sgp.baseline.panel.years=c("2016", "2017", "2019"),
                 sgp.grade.sequences=list(c("5", "6", "8")),
                 sgp.baseline.grade.sequences=list(c("5", "6", "8")),
                 sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                 sgp.projection.sequence="ELA_GRADE_8"))


GRADE_9_LIT_2019.config <- list(
    GRADE_9_LIT.2019 = list(
                sgp.content.areas=c("ELA", "ELA", "GRADE_9_LIT"),
                sgp.baseline.content.areas=c("ELA", "ELA", "GRADE_9_LIT"),
                sgp.panel.years=c("2016", "2017", "2019"),
                sgp.baseline.panel.years=c("2016", "2017", "2019"),
                sgp.grade.sequences=list(c(6, 7, "EOCT")),
                sgp.baseline.grade.sequences=list(c(6, 7, "EOCT")),
                sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                sgp.projection.sequence="GRADE_9_LIT_GRADE_EOCT")
)

AMERICAN_LIT_2019.config <- list(
    AMERICAN_LIT.2019 = list(
                sgp.content.areas=c("ELA", "ELA", "AMERICAN_LIT"),
                sgp.baseline.content.areas=c("ELA", "ELA", "AMERICAN_LIT"),
                sgp.panel.years=c("2015", "2016", "2019"),
                sgp.baseline.panel.years=c("2015", "2016", "2019"),
                sgp.grade.sequences=list(c(7, 8, "EOCT")),
                sgp.baseline.grade.sequences=list(c(7, 8, "EOCT")),
                sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                sgp.projection.sequence="AMERICAN_LIT_GRADE_EOCT")
)
