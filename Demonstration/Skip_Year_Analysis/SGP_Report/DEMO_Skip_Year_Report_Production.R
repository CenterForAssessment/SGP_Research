#####
###   Produce Demonstration Skip Year Analysis Report
#####

require(SGP)
require(data.table)
require(Literasee)

###  Set working directory to Report directory
setwd("~/Dropbox (SGP)/SGP/State_Alt_Analyses/Demonstration/Skip_Year_Analysis/SGP_Report")

###   Load SGP object and subset data
load("../Data/Demonstration_SGP_2018_2019_PART_2c.Rdata")
Report_Data <- copy(Demonstration_SGP_2018_2019_PART_2c@Data)[VALID_CASE == "VALID_CASE" & YEAR == '2018_2019' & CONTENT_AREA %in% c("READING", "MATHEMATICS") & SCHOOL_ENROLLMENT_STATUS == "Enrolled School: Yes"]


###   Set up report parameters as a list to feed into renderMultiDocument
params <- list(
  reportDate= format(Sys.time(), format = "%B, %d %Y"),
  state.name = "Demonstration",
  state.abv =  "DEMO",
	Year_Long_Form = TRUE,
  child.file.path = "../../../../../Github_Repos/Projects/SGP_Research/Master_Documents/Skip_Year_Analysis/SGP_Report", # "../../../master/Skip_Year_Analysis/SGP_Report",  # "github" or NULL/missing to download from github.
  draft.text = "DRAFT REPORT - DO NOT CITE!",
  seq.code.url =  "https://github.com/CenterForAssessment/Demonstration",
  skip.code.url = "https://github.com/CenterForAssessment/SGP_Research/tree/master/Demonstration/Skip_Year_Analysis",
  gof.path.seq =  "../Sequential_GOF/Goodness_of_Fit",
  gof.path.skip = "../Goodness_of_Fit")

###   Render 'parent' document with children into PDF/HTML documents
#  params sent in through argument report_params as list (above)
renderMultiDocument(rmd_input = "Demonstration_Skip_Year_SGP_Report.Rmd", report_format = c("RMD", "PDF"), report_params = params) # , cleanup_aux_files=FALSE)

#  params sent in through YAML in document
# renderMultiDocument(rmd_input = "Demonstration_Skip_Year_SGP_Report.Rmd", report_format = c("HTML", "PDF"))


###
##    OPTIONAL WORKFLOW: draft document creation and use in rendering PDF/HTML reports
###

###   Render 'parent' document with children into .Rmd Draft for review/revisions
renderMultiDocument(rmd_input = "Demonstration_Skip_Year_SGP_Report.Rmd", report_format = "RMD", report_params = params, cleanup_aux_files=FALSE)

#  Render compiled 'draft' document into polished PDF/HTML documents
setwd("Draft")
renderMultiDocument(rmd_input = "Demonstration_Skip_Year_SGP_Report-Compiled_Draft_v2.Rmd", report_format = c("HTML", "PDF"), cleanup_aux_files=FALSE)

#  Compare two drafts using diffFile
diffFile("Demonstration_Skip_Year_SGP_Report-Compiled_Draft_v2.Rmd", "Demonstration_Skip_Year_SGP_Report-Compiled_Draft_v1.Rmd", clean_empyt_lines=TRUE, keep_diff=TRUE)

#  Make 'Draft' document 'Final_Draft' and render PDF/HTML documents
setwd("..") # SGP_Report
renderMultiDocument(rmd_input = "Draft/Demonstration_Skip_Year_SGP_Report-Compiled_Draft_v2.Rmd", report_format = c("HTML", "PDF"), make_draft_final = TRUE) #, cleanup_aux_files=FALSE)
