###
### Configurations for calculating MATHEMATICS LAGGED PROJECTIONS in 2019
###


MATHEMATICS_2019.config <- list(
     MATHEMATICS.2019 = list(
                 sgp.content.areas=c("MATHEMATICS", "MATHEMATICS"),
                 sgp.baseline.content.areas=c("MATHEMATICS", "MATHEMATICS"),
                 sgp.panel.years=c("2017", "2019"),
                 sgp.baseline.panel.years=c("2017", "2019"),
                 sgp.grade.sequences=list(c("3", "5")),
                 sgp.baseline.grade.sequences=list(c("3", "5")),
                 sgp.panel.years.within=c("LAST_OBSERVATION", "FIRST_OBSERVATION"),
                 sgp.projection.sequence="MATHEMATICS_GRADE_5"),
     MATHEMATICS.2019 = list(
                 sgp.content.areas=c("MATHEMATICS", "MATHEMATICS", "MATHEMATICS"),
                 sgp.baseline.content.areas=c("MATHEMATICS", "MATHEMATICS", "MATHEMATICS"),
                 sgp.panel.years=c("2016", "2017", "2019"),
                 sgp.baseline.panel.years=c("2016", "2017", "2019"),
                 sgp.grade.sequences=list(c("3", "4", "6")),
                 sgp.baseline.grade.sequences=list(c("3", "4", "6")),
                 sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                 sgp.projection.sequence="MATHEMATICS_GRADE_6"),
     MATHEMATICS.2019 = list(
                 sgp.content.areas=c("MATHEMATICS", "MATHEMATICS", "MATHEMATICS"),
                 sgp.baseline.content.areas=c("MATHEMATICS", "MATHEMATICS", "MATHEMATICS"),
                 sgp.panel.years=c("2016", "2017", "2019"),
                 sgp.baseline.panel.years=c("2016", "2017", "2019"),
                 sgp.grade.sequences=list(c("4", "5", "7")),
                 sgp.baseline.grade.sequences=list(c("4", "5", "7")),
                 sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                 sgp.projection.sequence="MATHEMATICS_GRADE_7"),
     MATHEMATICS.2019 = list(
                 sgp.content.areas=c("MATHEMATICS", "MATHEMATICS", "MATHEMATICS"),
                 sgp.baseline.content.areas=c("MATHEMATICS", "MATHEMATICS", "MATHEMATICS"),
                 sgp.panel.years=c("2016", "2017", "2019"),
                 sgp.baseline.panel.years=c("2016", "2017", "2019"),
                 sgp.grade.sequences=list(c("5", "6", "8")),
                 sgp.baseline.grade.sequences=list(c("5", "6", "8")),
                 sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                 sgp.projection.sequence=c("MATHEMATICS_GRADE_8", "MATH_COORD_ALG_GRADE_8"))
)


ALGEBRA_I_2019.config <- list(
    ALGEBRA_I.2019 = list(
                sgp.content.areas=c("MATHEMATICS", "MATHEMATICS", "ALGEBRA_I"),
                sgp.baseline.content.areas=c("MATHEMATICS", "MATHEMATICS", "ALGEBRA_I"),
                sgp.panel.years=c("2016", "2017", "2019"),
                sgp.baseline.panel.years=c("2016", "2017", "2019"),
                sgp.grade.sequences=list(c(6, 7, "EOCT")),
                sgp.baseline.grade.sequences=list(c(6, 7, "EOCT")),
                sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                sgp.projection.sequence="ALGEBRA_I_GRADE_EOCT")
)

GEOMETRY_2019.config <- list(
    GEOMETRY.2019 = list(
                sgp.content.areas=c("MATHEMATICS", "MATHEMATICS", "GEOMETRY"),
                sgp.baseline.content.areas=c("MATHEMATICS", "MATHEMATICS", "GEOMETRY"),
                sgp.panel.years=c("2016", "2017", "2019"),
                sgp.baseline.panel.years=c("2016", "2017", "2019"),
                sgp.grade.sequences=list(c(7, 8, "EOCT")),   #   ONLY 8, 'EOCT' available for this year
                sgp.baseline.grade.sequences=list(c(7, 8, "EOCT")),
                sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                sgp.projection.sequence="GEOMETRY_GRADE_EOCT")
)


COORDINATE_ALGEBRA_2019.config <- list(
    COORDINATE_ALGEBRA.2019 = list(
                sgp.content.areas=c("MATHEMATICS", "MATHEMATICS", "COORDINATE_ALGEBRA"),
                sgp.baseline.content.areas=c("MATHEMATICS", "MATHEMATICS", "COORDINATE_ALGEBRA"),
                sgp.panel.years=c("2016", "2017", "2019"),
                sgp.baseline.panel.years=c("2016", "2017", "2019"),
                sgp.grade.sequences=list(c(6, 7, "EOCT")),
                sgp.baseline.grade.sequences=list(c(6, 7, "EOCT")),
                sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                sgp.projection.sequence="COORDINATE_ALGEBRA_GRADE_EOCT")
)

ANALYTIC_GEOMETRY_2019.config <- list(
    ANALYTIC_GEOMETRY.2019 = list(
                sgp.content.areas=c("MATHEMATICS", "MATHEMATICS", "ANALYTIC_GEOMETRY"),
                sgp.baseline.content.areas=c("MATHEMATICS", "MATHEMATICS", "ANALYTIC_GEOMETRY"),
                sgp.panel.years=c("2016", "2017", "2019"),
                sgp.baseline.panel.years=c("2016", "2017", "2019"),
                sgp.grade.sequences=list(c(7, 8, "EOCT")),
                sgp.baseline.grade.sequences=list(c(7, 8, "EOCT")),
                sgp.panel.years.within=c("LAST_OBSERVATION", "LAST_OBSERVATION", "FIRST_OBSERVATION"),
                sgp.projection.sequence="ANALYTIC_GEOMETRY_GRADE_EOCT")
)
