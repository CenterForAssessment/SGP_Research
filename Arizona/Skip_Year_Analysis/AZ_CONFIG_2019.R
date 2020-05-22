##################################################################################
###
### Configurations to perform skip year analyses
###
##################################################################################

### ELA_2019 percentile, straight projection, lagged projection

ELA_2019.config <- list(
         ELA.2019 = list(
                 sgp.content.areas=c('ELA', 'ELA', 'ELA'),
                 sgp.projection.content.areas=c('ELA', 'ELA'),
                 sgp.panel.years=c('2016', '2017', '2019'),
                 sgp.projection.panel.years=c('2017', '2019'),
                 sgp.grade.sequences=list(c('3', '5'), c('3', '4', '6'), c('4', '5', '7'),
                                             c('5', '6', '8'), c('6', '7', '9'), c('7', '8', '10'),
                                             c('8', '9', '11')),
                 sgp.projection.grade.sequences=list(c("NO_PROJECTIONS"))
#                 sgp.projection.grade.sequences=list('3', c('3', '5'), c('4', '6'), c('5', '7'), c('6', '8'), c('7', '9'), c('8', '10')),
#                 sgp.projection.sequence="ELA")
)


### MATHEMATICS 2019 percentile, straight projection, lagged projection, but straight projection and lagged projections have one more just for '8'

MATHEMATICS_2019.config <- list(
      MATHEMATICS.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'MATHEMATICS', 'MATHEMATICS'),
                  sgp.panel.years=c('2016', '2017', '2019'),
                  sgp.grade.sequences=list(c('3', '5'), c('3', '4', '6'), c('4', '5', '7')),
                  sgp.projection.sequence=c("MATHEMATICS", "ALGEBRA_I_FROM_7")),
      MATHEMATICS.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'MATHEMATICS', 'MATHEMATICS'),
                  sgp.panel.years=c('2016', '2017', '2019'),
                  sgp.grade.sequences=list(c('5', '6', '8')),
                  sgp.projection.sequence=c("MATHEMATICS"))
)


### ALGEBRA I percentile, but straight projections only have ('8', 'EOCT') and ('EOCT'), lagged projections only have ('7','8') and ('8')

ALGEBRA_I_2019.config <- list(
      ALGEBRA_I.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'MATHEMATICS', 'ALGEBRA_I'), #46351 #SGPSPLP
                  sgp.panel.years=c('2016', '2017', '2019'),
                  sgp.grade.sequences=list(c('6', '7', 'EOCT')),
                  sgp.exact.grade.progression=TRUE,
                  sgp.projection.sequence="MATHEMATICS",
                  sgp.norm.group.preference=1),
      ALGEBRA_I.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'ALGEBRA_I'), #50172 #SGPSPLP
                  sgp.panel.years=c('2017', '2019'),
                  sgp.grade.sequences=list(c('7', 'EOCT')),
                  sgp.projection.grade.sequences=list(c("NO_PROJECTIONS")),
                  sgp.exact.grade.progression=TRUE,
                  sgp.projection.sequence="MATHEMATICS",
                  sgp.norm.group.preference=2)
       ALGEBRA_I.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'MATHEMATICS', 'ALGEBRA_I'), #11989 #SGPSP/No LP
                  sgp.panel.years=c('2016', '2017', '2019'),
                  sgp.grade.sequences=list(c('5', '6', 'EOCT')),
                  sgp.exact.grade.progression=TRUE,
                  sgp.projection.sequence="ALGEBRA_I_FROM_7",
                  sgp.norm.group.preference=1),
      ALGEBRA_I.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'ALGEBRA_I'), #12891 #SGPSP/No LP
                  sgp.panel.years=c('2017', '2019'),
                  sgp.grade.sequences=list(c('6', 'EOCT')),
                  sgp.projection.grade.sequences=list(c("NO_PROJECTIONS")),
                  sgp.exact.grade.progression=TRUE,
                  sgp.projection.sequence="ALGEBRA_I_FROM_7",
                  sgp.norm.group.preference=2)
)

### GEOMETRY Percentiles, but straight projections only have ('EOCT','EOCT') and ('EOCT'), lagged projections only have ('8','EOCT') and ('8')

GEOMETRY_2019.config <- list(
      GEOMETRY.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'MATHEMATICS', 'GEOMETRY'), #39373 #SGPSPLP
                  sgp.panel.years=c('2016', '2017', '2019'),
                  sgp.grade.sequences=list(c('7', '8', 'EOCT')),
                  sgp.exact.grade.progression=TRUE,
                  sgp.projection.sequence="MATHEMATICS",
                  sgp.norm.group.preference=1),
      GEOMETRY.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'MATHEMATICS', 'GEOMETRY'), #8727
                  sgp.panel.years=c('2016', '2017', '2019'),
                  sgp.grade.sequences=list(c('6', '7', 'EOCT')),
                  sgp.exact.grade.progression=TRUE,
                  sgp.projection.sequence="ALGEBRA_I_FROM_7",
                  sgp.norm.group.preference=1),
      GEOMETRY.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'GEOMETRY'), #56293 #SGPSPLP
                  sgp.panel.years=c('2017', '2019'),
                  sgp.grade.sequences=list(c('8', 'EOCT')),
                  sgp.projection.grade.sequences=list(c("NO_PROJECTIONS")),
                  sgp.exact.grade.progression=TRUE,
                  sgp.projection.sequence="MATHEMATICS",
                  sgp.norm.group.preference=2),
     GEOMETRY.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'GEOMETRY'),
                  sgp.panel.years=c('2017', '2019'),
                  sgp.grade.sequences=list(c('7', 'EOCT')),
                  sgp.exact.grade.progression=TRUE,
                  sgp.projection.sequence="ALGEBRA_I_FROM_7",
                  sgp.norm.group.preference=2),
     GEOMETRY.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'ALGEBRA_I', 'GEOMETRY'), #758
                  sgp.panel.years=c('2016','2017', '2019'),
                  sgp.grade.sequences=list(c('8', 'EOCT', 'EOCT')),
                  sgp.projection.grade.sequences=list(c("NO_PROJECTIONS")),
                  sgp.exact.grade.progression=TRUE,
        		  sgp.norm.group.preference=3),
     GEOMETRY.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'ALGEBRA_I', 'GEOMETRY'), #650
                  sgp.panel.years=c('2016','2017', '2019'),
                  sgp.grade.sequences=list(c('7', 'EOCT', 'EOCT')),
                  sgp.exact.grade.progression=TRUE,
                  sgp.projection.sequence="ALGEBRA_I_FROM_7",
  		          sgp.norm.group.preference=3),
     GEOMETRY.2019 = list(
                  sgp.content.areas=c('ALGEBRA_I', 'GEOMETRY'), #650
                  sgp.panel.years=c('2017','2019'),
                  sgp.grade.sequences=list(c('EOCT', 'EOCT')),
                  sgp.projection.grade.sequences=list(c("NO_PROJECTIONS")),
                  sgp.exact.grade.progression=TRUE,
  		  sgp.norm.group.preference=4),
)


### ALGEBRA II Percentiles, no straight projections, but lagged projections only have ('EOCT', 'EOCT', 'LAGGED') and ('EOCT','LAGGED')

ALGEBRA_II_2019.config <- list(
      ALGEBRA_II.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'ALGEBRA_I', 'ALGEBRA_II'),
                  sgp.panel.years=c('2016', '2017', '2019'),
                  sgp.grade.sequences=list(c('8', 'EOCT', 'EOCT')),
                  sgp.exact.grade.progression=TRUE,
                  sgp.projection.sequence="MATHEMATICS",
  		          sgp.norm.group.preference=1),
      ALGEBRA_II.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'MATHEMATICS', 'ALGEBRA_II'),
                  sgp.panel.years=c('2016', '2017', '2019'),
                  sgp.grade.sequences=list(c('7', '8', 'EOCT')),
                  sgp.projection.grade.sequences=list(c('NO_PROJECTIONS')),
                  sgp.exact.grade.progression=TRUE,
                  sgp.norm.group.preference=3),
      ALGEBRA_II.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'MATHEMATICS', 'ALGEBRA_II'),
                  sgp.panel.years=c('2016','2017', '2019'),
                  sgp.grade.sequences=list(c('6', '7', 'EOCT')),
                  sgp.projection.grade.sequences=list(c('NO_PROJECTIONS')),
                  sgp.exact.grade.progression=TRUE,
                  sgp.norm.group.preference=4),
      ALGEBRA_II.2019 = list(
                  sgp.content.areas=c('ALGEBRA_I', 'ALGEBRA_II'),
                  sgp.panel.years=c('2017', '2019'),
                  sgp.grade.sequences=list(c('EOCT', 'EOCT')),
                  sgp.projection.grade.sequences=list(c('NO_PROJECTIONS')),
                  sgp.exact.grade.progression=TRUE,
                  sgp.projection.sequence="MATHEMATICS",
                  sgp.norm.group.preference=2),
     ALGEBRA_II.2019 = list(
                  sgp.content.areas=c('MATHEMATICS', 'ALGEBRA_I', 'ALGEBRA_II'),
                  sgp.panel.years=c('2016', '2017', '2019'),
                  sgp.grade.sequences=list(c('7', 'EOCT', 'EOCT')),
                  sgp.projection.grade.sequences=list(c('NO_PROJECTIONS')),
                  sgp.exact.grade.progression=TRUE,
                  sgp.norm.group.preference=4),
)


### Combine all the configurations together

AZ_CONFIG <- c(ELA_2019.config, MATHEMATICS_2019.config, ALGEBRA_I_2019.config, GEOMETRY_2019.config, ALGEBRA_II_2019.config)
