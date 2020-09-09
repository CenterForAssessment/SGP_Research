################################################################################
###                                                                          ###
###  Merge in Student info from Illinois 2018 & 2019 Skip Year SGP Analyses  ###
###                                                                          ###
################################################################################

### Load required packages

require(SGP)
require(data.table)

###  Set working directory to top level directory (./Illinois/Skip_Year)
my.dir <- getwd()

####   Read in ZIP files
setwd(tempdir())
system(paste0("unzip '", file.path(my.dir, './Data/Pearson_School_Numbers/PC_pcspr18_IL_PARCC_State_Summative_Record_File_Spring_D201808281428.csv.zip'), "'"))
system(paste0("unzip '", file.path(my.dir, './Data/Pearson_School_Numbers/pcspr19_IL_State_Summative_Record_File_Spring_D201908141813.csv.zip'), "'"))
IL_2018 <- fread("PC_pcspr18_IL_PARCC_State_Summative_Record_File_Spring_D201808281428.csv", sep=",", colClasses=rep("character", 196))
IL_2019 <- fread("pcspr19_IL_State_Summative_Record_File_Spring_D201908141813.csv", sep=",")#, colClasses=rep("character", 197))
unlink(grep("State_Summative_Record", list.files(), value=TRUE))
setwd(my.dir);setwd("../../")

setnames(IL_2018, c("PARCCStudentIdentifier"), c("ID"))
setnames(IL_2019, c("UniquePearsonStudentID"), c("ID"))

###   Clean up unneeded variables to reduce visual clutter
IL_2018[, grep("CSEM|Filler|PaperSection|ScaleScore|StateField|StudentGrowth|SGP|Subclaim|Unit", names(IL_2018), value=TRUE) := NULL]
IL_2019[, grep("CSEM|Filler|PaperSection|ScaleScore|StateField|StudentGrowth|SGP|Subclaim|Unit", names(IL_2019), value=TRUE) := NULL]

names(IL_2019)[!names(IL_2019) %in% (names(IL_2018))]
names(IL_2018)[!names(IL_2018) %in% (names(IL_2019))]

paste0(names(IL_2018)[2:28], collapse = "', '")

variable.order <- c(
  "YEAR", "ID", "StudentTestUUID", "IRTTheta", "StateStudentIdentifier", "LocalStudentIdentifier",
  "TestingDistrictCode", "TestingSchoolCode", "ResponsibleAccountableDistrictCode", "ResponsibleDistrictName",
  "ResponsibleAccountableSchoolCode", "ResponsibleSchoolName",
  "Sex", "EconomicDisadvantageStatus", "StudentWithDisabilities",
  "FederalRaceEthnicity", "HispanicOrLatinoEthnicity", "AmericanIndianOrAlaskaNative", "Asian",
  "BlackOrAfricanAmerican", "NativeHawaiianOrOtherPacificIslander", "White", "TwoOrMoreRaces",
  "EnglishLearnerEL", "MigrantStatus", "GiftedandTalented")

IL_2018[, FederalRaceEthnicity := as.character(as.numeric(FederalRaceEthnicity))]
IL_2018[, YEAR := "2017_2018"]
IL_2019[, YEAR := "2018_2019"]

IL_Student_Info <- rbindlist(list(IL_2018[, variable.order, with=FALSE], IL_2019[, variable.order, with=FALSE]))
# setcolorder(IL_Student_Info, variable.order)

load("Data/Illinois_SGP_LONG_Data.Rdata")

setkeyv(IL_Student_Info, c("YEAR", "ID", "StudentTestUUID"))
setkeyv(Illinois_SGP_LONG_Data, c("YEAR", "ID", "StudentTestUUID"))

Illinois_Skip_Year_Analysis_Data <- IL_Student_Info[Illinois_SGP_LONG_Data]
table(Illinois_Skip_Year_Analysis_Data[YEAR > '2016_2017', is.na(NO_SKIP_SGP), is.na(ResponsibleAccountableSchoolCode)])
table(Illinois_Skip_Year_Analysis_Data[YEAR > '2016_2017' & ResponsibleAccountableSchoolCode == "", YEAR])
table(Illinois_Skip_Year_Analysis_Data[YEAR > '2016_2017', is.na(NO_SKIP_SGP), EconomicDisadvantageStatus])
Illinois_Skip_Year_Analysis_Data[CONTENT_AREA %in% c("ELA", "MATHEMATICS", "ALGEBRA_I"), as.list(summary(as.numeric(IRTTheta)-SCALE_SCORE)), keyby="TestCode"]
dim(Illinois_Skip_Year_Analysis_Data[as.numeric(IRTTheta) != SCALE_SCORE, ]) # 1 student with mismatched score (ALGEBRA_I in 2018)

###   Subset 2019 first and save data

Illinois_Skip_Year_Analysis_Data <- Illinois_Skip_Year_Analysis_Data[YEAR %in% c("2017_2018", "2018_2019")]


write.csv(Illinois_Skip_Year_Analysis_Data, file="Data/Illinois_Skip_Year_Analysis_Data-2019.csv", row.names = FALSE, na="")
zip(zipfile="Data/Illinois_Skip_Year_Analysis_Data-2019.csv.zip", files="Data/Illinois_Skip_Year_Analysis_Data-2019.csv", flags="-mqj")

save(Illinois_Skip_Year_Analysis_Data, file="Data/Illinois_Skip_Year_Analysis_Data.Rdata")
