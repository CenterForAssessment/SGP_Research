################################################################################
###                                                                          ###
###          ELA 2017 SGP Configurations for 2021 Contingency Plan           ###
###                                                                          ###
################################################################################

ELA_2017.config <- list(
  ELA.2017 = list(
    sgp.content.areas=c('ELA', 'ELA', 'ELA'),
    sgp.panel.years.within=c(rep('LAST_OBSERVATION', 2), 'FIRST_OBSERVATION'),
    sgp.panel.years=c('2015', '2016', '2017'),
    sgp.grade.sequences=list(c('3', '4'), c('3', '4', '5'), c( '4', '5', '6'), c('5', '6', '7'), c('6', '7', '8'))))


### GRADE_9_LIT

GRADE_9_LIT_2017.config <- list(
  GRADE_9_LIT.2017 = list( # 2
    sgp.content.areas=c('ELA', 'GRADE_9_LIT'),
    sgp.panel.years=c('2015', '2017'),
    sgp.grade.sequences=list(c(8, 'EOCT')),
    sgp.panel.years.within=c('LAST_OBSERVATION', 'FIRST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.exclude.sequences = data.table(VALID_CASE = 'VALID_CASE', CONTENT_AREA=c('ELA','GRADE_9_LIT'),
                                       YEAR=c('2016','2016'), GRADE=c('8','EOCT')),
    sgp.norm.group.preference=7),
	GRADE_9_LIT.2017 = list( # 4
    sgp.content.areas=c('ELA', 'GRADE_9_LIT'),
    sgp.panel.years=c('2016', '2017'),
    sgp.grade.sequences=list(c(8, 'EOCT')),
    sgp.panel.years.within=c('LAST_OBSERVATION', 'FIRST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.norm.group.preference=5),
  GRADE_9_LIT.2017 = list( # 5
    sgp.content.areas=c('ELA', 'ELA', 'GRADE_9_LIT'),
    sgp.panel.years=c( '2015', '2016', '2017'),
    sgp.grade.sequences=list(c(7, 8, 'EOCT')),
    sgp.panel.years.within=c('LAST_OBSERVATION', 'LAST_OBSERVATION', 'FIRST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    # sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.norm.group.preference=4),
  GRADE_9_LIT.2017 = list( # 6
    sgp.content.areas=c('ELA', 'GRADE_9_LIT'),
    sgp.panel.years=c('2016', '2017'),
    sgp.grade.sequences=list(c( 7, 'EOCT')),
    sgp.panel.years.within=c('LAST_OBSERVATION', 'FIRST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.norm.group.preference=3),
  GRADE_9_LIT.2017 = list( # 7
    sgp.content.areas=c('ELA', 'ELA', 'GRADE_9_LIT'),
    sgp.panel.years=c( '2015', '2016', '2017'),
    sgp.grade.sequences=list(c(6, 7, 'EOCT')),
    sgp.panel.years.within=c('LAST_OBSERVATION', 'LAST_OBSERVATION', 'FIRST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.norm.group.preference=2),
  GRADE_9_LIT.2017 = list( # 8
    sgp.content.areas=c('GRADE_9_LIT', 'GRADE_9_LIT'),
    sgp.panel.years=c('2016', '2017'),
    sgp.grade.sequences=list(c('EOCT', 'EOCT')),
    sgp.panel.years.within=c('LAST_OBSERVATION', 'FIRST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.norm.group.preference=1),
  GRADE_9_LIT.2017 = list( # 9
    sgp.content.areas=c('GRADE_9_LIT', 'GRADE_9_LIT'),
    sgp.panel.years=c('2017', '2017'),
    sgp.grade.sequences=list(c('EOCT', 'EOCT')),
    sgp.panel.years.within=c('FIRST_OBSERVATION', 'LAST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.norm.group.preference=0)

) ### END GRADE_9_LIT_2015.config


### AMERICAN_LIT

AMERICAN_LIT_2017.config <- list(
  AMERICAN_LIT.2017 = list( # 11
    sgp.content.areas=c('GRADE_9_LIT', 'AMERICAN_LIT'),
    sgp.panel.years=c('2015', '2017'),
    sgp.grade.sequences=list(c('EOCT', 'EOCT')),
    sgp.panel.years.within=c('LAST_OBSERVATION', 'FIRST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.exclude.sequences = data.table(VALID_CASE = 'VALID_CASE', CONTENT_AREA=c('GRADE_9_LIT', 'AMERICAN_LIT'),
                                       YEAR=c('2016', '2016'), GRADE=c('EOCT', 'EOCT')),
    # sgp.projection.grade.sequences="NO_PROJECTIONS",  # ELA/Lit Projections with Milestones data only
    sgp.norm.group.preference=7),

  AMERICAN_LIT.2017 = list( # 14
    sgp.content.areas=c('GRADE_9_LIT', 'AMERICAN_LIT'),
    sgp.panel.years=c('2016', '2017'),
    sgp.grade.sequences=list(c('EOCT', 'EOCT')),
    sgp.panel.years.within=c('LAST_OBSERVATION', 'FIRST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.norm.group.preference=4),

  AMERICAN_LIT.2017 = list( # 15
    sgp.content.areas=c('ELA', 'GRADE_9_LIT', 'AMERICAN_LIT'),
    sgp.panel.years=c('2015', '2016', '2017'),
    sgp.grade.sequences=list(c(8, 'EOCT', 'EOCT')),
    sgp.panel.years.within=c('LAST_OBSERVATION', 'LAST_OBSERVATION', 'FIRST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.norm.group.preference=3),

  AMERICAN_LIT.2017 = list( # 15
    sgp.content.areas=c('ELA', 'GRADE_9_LIT', 'AMERICAN_LIT'),
    sgp.panel.years=c('2015', '2016', '2017'),
    sgp.grade.sequences=list(c(7, 'EOCT', 'EOCT')),
    sgp.panel.years.within=c('LAST_OBSERVATION', 'LAST_OBSERVATION', 'FIRST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.norm.group.preference=2),

  AMERICAN_LIT.2017 = list( # 16
    sgp.content.areas=c('AMERICAN_LIT', 'AMERICAN_LIT'),
    sgp.panel.years=c('2016', '2017'),
    sgp.grade.sequences=list(c('EOCT', 'EOCT')),
    sgp.panel.years.within=c('LAST_OBSERVATION', 'FIRST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.norm.group.preference=1),

  AMERICAN_LIT.2017 = list( # 17
    sgp.content.areas=c('AMERICAN_LIT', 'AMERICAN_LIT'),
    sgp.panel.years=c('2017', '2017'),
    sgp.grade.sequences=list(c('EOCT', 'EOCT')),
    sgp.panel.years.within=c('FIRST_OBSERVATION', 'LAST_OBSERVATION'),
    sgp.exact.grade.progression=TRUE,
    sgp.projection.grade.sequences="NO_PROJECTIONS",
    sgp.norm.group.preference=0)
) ### END AMERICAN_LIT.2017.config
