#####
###   Produce Colorado Skip Year Analysis Report
#####

require(SGP)
require(data.table)
require(Literasee)

###   Load SGP object and subset data
load("/Users/avi/Dropbox (SGP)/SGP/State_Alt_Analyses/Colorado/Skip_Year_Analysis/Data/Colorado_SGP_2019_PART_2c.Rdata")
Colorado_Data <- copy(Colorado_SGP@Data)[VALID_CASE == "VALID_CASE" & YEAR == '2019' & CONTENT_AREA %in% c("ELA", "MATHEMATICS") & SCHOOL_ENROLLMENT_STATUS == "Enrolled School: Yes"]

###  Set working directory to Report directory
setwd("~/Dropbox (SGP)/Github_Repos/Projects/SGP_Research/Colorado/Skip_Year_Analysis/SGP_Report")
dir.create("Plots")

renderMultiDocument(rmd_input = "Colorado_Skip_Year_SGP_Report.Rmd",
										report_format = c("HTML", "PDF"))#,
										# cleanup_aux_files=FALSE)

