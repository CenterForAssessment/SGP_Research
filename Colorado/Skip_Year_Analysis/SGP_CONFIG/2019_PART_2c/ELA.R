###
### Configurations for calculating LAGGED PROJECTIONS in 2019
###


ELA_2019.config <- list(
     ELA.2019 = list(
                 sgp.content.areas=c('ELA', 'ELA'),
                 sgp.baseline.content.areas=c('ELA', 'ELA'),
                 sgp.panel.years=c('2017', '2019'),
                 sgp.baseline.panel.years=c('2017', '2019'),
                 sgp.grade.sequences=list(c('3', '5')),
                 sgp.baseline.grade.sequences=list(c('3', '5')),
                 sgp.projection.sequence="ELA_GRADE_5"),
     ELA.2019 = list(
                 sgp.content.areas=c('ELA', 'ELA', 'ELA'),
                 sgp.baseline.content.areas=c('ELA', 'ELA', 'ELA'),
                 sgp.baseline.panel.years=c('2016', '2017', '2019'),
                 sgp.panel.years=c('2016', '2017', '2019'),
                 sgp.grade.sequences=list(c('3', '4', '6')),
                 sgp.baseline.grade.sequences=list(c('3', '4', '6')),
                 sgp.projection.sequence="ELA_GRADE_6"),
     ELA.2019 = list(
                 sgp.content.areas=c('ELA', 'ELA', 'ELA'),
                 sgp.baseline.content.areas=c('ELA', 'ELA', 'ELA'),
                 sgp.baseline.panel.years=c('2016', '2017', '2019'),
                 sgp.panel.years=c('2016', '2017', '2019'),
                 sgp.grade.sequences=list(c('4', '5', '7')),
                 sgp.baseline.grade.sequences=list(c('4', '5', '7')),
                 sgp.projection.sequence="ELA_GRADE_7"),
     ELA.2019 = list(
                 sgp.content.areas=c('ELA', 'ELA', 'ELA'),
                 sgp.baseline.content.areas=c('ELA', 'ELA', 'ELA'),
                 sgp.baseline.panel.years=c('2016', '2017', '2019'),
                 sgp.panel.years=c('2016', '2017', '2019'),
                 sgp.grade.sequences=list(c('5', '6', '8')),
                 sgp.baseline.grade.sequences=list(c('5', '6', '8')),
                 sgp.projection.sequence="ELA_GRADE_8"))
