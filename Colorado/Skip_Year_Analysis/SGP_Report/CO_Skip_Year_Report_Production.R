#####
###   Produce Colorado Skip Year Analysis Report
#####

require(SGP)
require(data.table)
require(Literasee)

setwd("~/Dropbox (SGP)/Github_Repos/Projects/SGP_Research/Colorado/Skip_Year_Analysis/SGP_Report")

renderMultiDocument(rmd_input = "Colorado_Skip_Year_SGP_Report.Rmd",
										report_format = c("HTML", "PDF"))#,
										# cleanup_aux_files=FALSE)

