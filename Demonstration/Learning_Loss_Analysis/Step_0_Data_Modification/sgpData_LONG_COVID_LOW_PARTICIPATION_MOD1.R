####### Script to simulate low participation in 2021 sgpData_LONG_COVID ######
# Missing data is introduced into the sgpData_LONG_COVID dataset for 2021 at the 
# school-level, based on:
#  (1) the proportion students receiving FRL (a mixture distribution, based on
#      the normal and log-normal distributions, with a mean that is a function 
#      of the proportion of FRL in a school), and 
#  (2) school membership (similar to FRL, each school is randomly assigned an effect based on
#      random deviates from a mixture distribution)   
#I. Setup ----------------------------------------------------------------------
  library(SGPdata)
  library(data.table)
  covid <-  sgpData_LONG_COVID
  set.seed(145)
  setwd("..") ## Set working directory to base directory
  
#II. Introduce Missingess for 2021 Data ----------------------------------------
  #A Set up 2021 Data ----------------------------------------------------------
  #A1. Grab 2021 Data
  c2021 <- covid[covid$YEAR == "2021",]
  c2021 <- data.table(c2021)
  
  #A2. Create Dummy Vars
  c2021$D_ETH_AfAmer   <- ifelse(c2021$ETHNICITY == "African American", 1, 0)
  c2021$D_ETH_Asian    <- ifelse(c2021$ETHNICITY == "Asian", 1, 0)
  c2021$D_ETH_Hispanic <- ifelse(c2021$ETHNICITY == "Hispanic", 1, 0) 
  c2021$D_ETH_Other    <- ifelse(c2021$ETHNICITY == "Other", 1, 0) 
  c2021$D_ETH_White    <- ifelse(c2021$ETHNICITY == "White", 1, 0) 
  
  c2021$D_FRL <- ifelse(c2021$FREE_REDUCED_LUNCH_STATUS == "Free Reduced Lunch: Yes",
                        1, 0)
  
  #A3. Calcuate Aggregated Stats (note, as of now, only FRL is used)
  school.agg <- c2021[,list(n_ETH_AfAmer   = sum(D_ETH_AfAmer),
                            n_ETH_Asian    = sum(D_ETH_Asian),
                            n_ETH_Hispanic = sum(D_ETH_Hispanic),
                            n_ETH_Other    = sum(D_ETH_Other),
                            n_ETH_White    = sum(D_ETH_White),
                            n_FRL          = sum(D_FRL),
                            n              = length(D_FRL),
                            p_ETH_AfAmer   = sum(D_ETH_AfAmer)/length(D_FRL),
                            p_ETH_Asian    = sum(D_ETH_Asian)/length(D_FRL),
                            p_ETH_Hispanic = sum(D_ETH_Hispanic)/length(D_FRL),
                            p_ETH_Other    = sum(D_ETH_Other)/length(D_FRL),
                            p_ETH_White    = sum(D_ETH_White)/length(D_FRL),
                            p_FRL          = sum(D_FRL)/length(D_FRL)), 
                      by=SCHOOL_NUMBER] 
  
  school.agg <- data.frame(school.agg)
   
  #B. Introduce Missingess -----------------------------------------------------
  #Introducing missingness as a (1) proportion of FRL and (2) randomly by school
  #more complicated versions of missing data could include scenarios like:
  #i. a three way interaction between ED, IEP & ED concentration
  #ii. by introducing a relationships between FRL & scale scores or, 
  #iii. an interaction between IEP & FRL concentrations in schools
  
  #B. Define Missingness Related to FRL (adds more missing data for schools
  #that have very high and very low FRL)
  #B1. Introduce Missingness Related to Student who Are FRL
  school.agg$p_frl_missing <- (1.3*school.agg$p_FRL-.5)^3 +.1 +
  rlnorm(nrow(school.agg), meanlog = 0, sdlog = 1)/15 + 
    rnorm(nrow(school.agg), mean=-.01, sd=.025)
  
  #Manual Supressions
  school.agg$p_frl_missing <- school.agg$p_frl_missing - .1 
  
  school.agg$p_frl_missing  <- ifelse(school.agg$p_FRL < .35 & school.agg$p_frl_missing > .4,
                                      sample(x=seq(from=.35, to=.55, by=.001), size=1),
                                      school.agg$p_frl_missing)
    
  #Ensuring Correct Ranges
  school.agg$p_frl_missing <- ifelse(school.agg$p_frl_missing >= 1,  
                                    sample(x=seq(from=.9, to=.99, by=.001), size=1), 
                                    school.agg$p_frl_missing)
  
  school.agg$p_frl_missing <- ifelse(school.agg$p_frl_missing < 0,  
                                        sample(x=seq(from=0, to=.05, by=.001), size=1), 
                                        school.agg$p_frl_missing)

  #B2. For Non-FRL
  school.agg$p_notfrl_missing <- 1.2*(.9*abs(school.agg$p_FRL-1))^6 + 
                                rnorm(nrow(school.agg), mean=-.01, sd=.025) +
                                rlnorm(nrow(school.agg), meanlog = 0, sdlog = 1)/40

  school.agg$p_notfrl_missing <- ifelse(school.agg$p_notfrl_missing>= 1,  
                                     sample(x=seq(from=.9, to=.99, by=.001), size=1), 
                                     school.agg$p_notfrl_missing)
  
  school.agg$p_notfrl_missing <- ifelse(school.agg$p_notfrl_missing < 0,  
                                     sample(x=seq(from=0, to=.05, by=.001), size=1), 
                                     school.agg$p_notfrl_missing) 
  
  #A4.B  Define School-Membership Missingness 
  school.agg$p_missing <- rlnorm(length(school.agg$p_frl_missing), meanlog = -.15, sdlog = 1)/25
  
  school.agg$p_missing <- ifelse(school.agg$p_missing>= 1,  
                                        sample(x=seq(from=.9, to=.99, by=.001), size=1), 
                                        school.agg$p_missing)
  
  school.agg$p_missing <- ifelse(school.agg$p_missing < 0,  
                                        sample(x=seq(from=0, to=.1, by=.001), size=1), 
                                        school.agg$p_missing) 
  
  #B.Introduce Missingness into 2021 Data -------------------------------------
  c2021$SCALE_SCORE_A       <- c2021$SCALE_SCORE
  c2021$ACHIEVEMENT_LEVEL_A <- c2021$ACHIEVEMENT_LEVEL
    
  c2021.missing <- NULL
  
  for(i in 1:nrow(school.agg)){
    dat.agg <- school.agg[i,]
    dat     <- c2021[c2021$SCHOOL_NUMBER == dat.agg$SCHOOL_NUMBER,]
    
    #A. Introduce Overall Missingness for School i
    dat$SCALE_SCORE[sample(1:dat.agg$n, size=round(dat.agg$n*dat.agg$p_missing, digits=0))] <- NA
    dat$ACHIEVEMENT_LEVEL[is.na(dat$SCALE_SCORE)] <- NA
    
    #B. Introduce Missingness based on FRL
    dat_frl  <- dat[dat$D_FRL == 1,]
    dat_nfrl <- dat[dat$D_FRL == 0,]
    
      #B1. FRL
      dat_frl$SCALE_SCORE[sample(1:dat.agg$n_FRL, 
                                 size=round(dat.agg$n_FRL*dat.agg$p_frl_missing, digits=0))] <- NA
      
      #B2. Non-FRL
      dat_nfrl$SCALE_SCORE[sample(1:(dat.agg$n-dat.agg$n_FRL), 
                                 size=round((dat.agg$n-dat.agg$n_FRL)*dat.agg$p_notfrl_missing, digits=0))] <- NA
      
      dat <- rbind(dat_frl, dat_nfrl)
      
    #C. Stack
    c2021.missing <- rbind(c2021.missing, dat)
  }
  
#III. Combine into Total Dataset ------------------------------------------------
  #Reduce just to years that would be observed in Spring 2021 and then 
  covid <- covid[covid$YEAR %in% c(2016, 2017, 2018, 2019),]
  covid$SCALE_SCORE_A <- NA
  covid$ACHIEVEMENT_LEVEL_A <- NA
  
  covid <- data.frame(covid)
  c2021.missing <- data.frame(c2021.missing)
  
  c.mis <- c2021.missing[,names(c2021.missing)[names(c2021.missing) %in% names(covid)]]  
  covid <- rbind(covid,  c.mis)
 
#IV. Remove extraneous variables and save data set. 

  sgpData_LONG_COVID <- as.data.table(covid)
  sgpData_LONG_COVID[,SCALE_SCORE_A:=NULL]
  sgpData_LONG_COVID[,ACHIEVEMENT_LEVEL_A:=NULL]
  setkey(sgpData_LONG_COVID, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)
  save(sgpData_LONG_COVID, file="Data/LOW_PARTICIPATION_MOD1/sgpData_LONG_COVID.Rdata") 
