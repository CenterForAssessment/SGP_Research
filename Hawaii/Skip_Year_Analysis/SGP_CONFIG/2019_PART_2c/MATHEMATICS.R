################################################################################
###                                                                          ###
###        Configurations for calculating LAGGED PROJECTIONS in 2019         ###
###                                                                          ###
################################################################################

MATHEMATICS_2019.config <- list(
     MATHEMATICS.2019 = list(
                 sgp.content.areas=rep("MATHEMATICS", 2),
                 sgp.baseline.content.areas=rep("MATHEMATICS", 2),
                 sgp.panel.years=c("2017", "2019"),
                 sgp.baseline.panel.years=c("2017", "2019"),
                 sgp.grade.sequences=list(c("3", "5")),
                 sgp.baseline.grade.sequences=list(c("3", "5")),
                 sgp.projection.sequence="MATHEMATICS_GRADE_5"),
     MATHEMATICS.2019 = list(
                 sgp.content.areas=rep("MATHEMATICS", 3),
                 sgp.baseline.content.areas=rep("MATHEMATICS", 3),
                 sgp.baseline.panel.years=c("2016", "2017", "2019"),
                 sgp.panel.years=c("2016", "2017", "2019"),
                 sgp.grade.sequences=list(c("3", "4", "6")),
                 sgp.baseline.grade.sequences=list(c("3", "4", "6")),
                 sgp.projection.sequence="MATHEMATICS_GRADE_6"),
     MATHEMATICS.2019 = list(
                 sgp.content.areas=rep("MATHEMATICS", 4),
                 sgp.baseline.content.areas=rep("MATHEMATICS", 4),
                 sgp.baseline.panel.years=c("2015", "2016", "2017", "2019"),
                 sgp.panel.years=c("2015", "2016", "2017", "2019"),
                 sgp.grade.sequences=list(c("3", "4", "5", "7")),
                 sgp.baseline.grade.sequences=list(c("3", "4", "5", "7")),
                 sgp.projection.sequence="MATHEMATICS_GRADE_7"),
     MATHEMATICS.2019 = list(
                 sgp.content.areas=rep("MATHEMATICS", 4),
                 sgp.baseline.content.areas=rep("MATHEMATICS", 4),
                 sgp.baseline.panel.years=c("2015", "2016", "2017", "2019"), # Only include SBAC tests for "BASELINE" projections
                 sgp.panel.years=c("2015", "2016", "2017", "2019"),
                 sgp.grade.sequences=list(c("4", "5", "6", "8")),
                 sgp.baseline.grade.sequences=list(c("4", "5", "6", "8")),
                 sgp.projection.sequence="MATHEMATICS_GRADE_8"))
