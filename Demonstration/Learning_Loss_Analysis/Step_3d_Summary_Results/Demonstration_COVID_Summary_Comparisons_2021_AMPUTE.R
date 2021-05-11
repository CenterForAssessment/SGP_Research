################################################################################
###
### Script to investigate summary (e.g., mean SGP) comparisons with BASIC_ANALYSIS
### inferred values from functions such as bootstrapSRS
###
################################################################################

setwd("..")


### Load packages

require(SGP)
require(cfaTools)
require(data.table)


### Define parameters

if (!exists("input.directory")) input.directory <- "Data/BASIC_ANALYSIS"
if (!exists("output.directory")) output.directory <- "Data/LOW_PARTICIPATION_AMPUTE/MISSING_30"
if (!exists("output.file")) output.file <- "Demonstration_COVID_SGP_LONG_Data.Rdata"
if (!exists("output.file.directories")) output.file.directories <- "STATUS_w_DEMOG" ##c("MCAR", "STATUS_w_DEMOG")
aggregation_group <- c("CONTENT_AREA", "GRADE")
list_of_data_files_for_summary <- list()
list_of_summary_files <- list()


### Load Data

load(file.path(input.directory, "Demonstration_COVID_SGP_Summaries_STEP_3d.Rdata"))
setnames(Demonstration_COVID_SGP_Summaries_STEP_3d, c("MEAN_SCALE_SCORE", "MEAN_SGP", "MEAN_SGP_BASELINE"), c("MEAN_SCALE_SCORE_COMPLETE", "MEAN_SGP_COMPLETE", "MEAN_SGP_BASELINE_COMPLETE"))


### Create list of data files

for (directory.iter in file.path(output.directory, output.file.directories)) {
    for (subdirectory.iter in list.dirs(directory.iter, recursive=FALSE, full.names=FALSE)) {
        print(subdirectory.iter)
        tmp.name <- load(file.path(directory.iter, subdirectory.iter, output.file))
        if ("SGP" %in% class(eval(parse(text=tmp.name)))) {
            list_of_data_files_for_summary[[subdirectory.iter]] <- Demonstration_COVID_SGP@Data
        }
        if ("data.table" %in% class(eval(parse(text=tmp.name)))) {
            list_of_data_files_for_summary[[subdirectory.iter]] <- Demonstration_COVID_SGP_LONG_Data
        }
    }
}

### bootstrapSRS_SGP


for (data.iter in names(list_of_data_files_for_summary)) {
    list_of_summary_files[[data.iter]] <- bootstrapSRS_SGP(
                                sgp_object=list_of_data_files_for_summary[[data.iter]],
                                strata_summaries=c("STATUS", "GROWTH"),
                                strata_variables=c("ETHNICITY", "FREE_REDUCED_LUNCH_STATUS", "SCALE_SCORE_DECILE"),
                                strata_proportions_years_status="2019",
                                strata_proportions_years_growth="2021",
                                summary_years="2021",
                                sample_size=10000,
                                aggregation_group=aggregation_group)

    list_of_summary_files[[data.iter]] <- list_of_summary_files[[data.iter]][list_of_data_files_for_summary[[data.iter]][,list("MEAN_SCALE_SCORE_COMPLETE"=mean(SCALE_SCORE_COMPLETE, na.rm=TRUE), "MEAN_SGP_COMPLETE"=mean(SGP_COMPLETE, na.rm=TRUE), "MEAN_SGP_BASELINE_COMPLETE"=mean(SGP_BASELINE_COMPLETE, na.rm=TRUE)), keyby=aggregation_group]]
    setcolorder(list_of_summary_files[[data.iter]], c("MEAN_SCALE_SCORE_COMPLETE", "MEAN_SCALE_SCORE", "MEAN_SCALE_SCORE_INFERRED", "MEAN_SGP_COMPLETE", "MEAN_SGP", "MEAN_SGP_INFERRED", "MEAN_SGP_BASELINE_COMPLETE", "MEAN_SGP_BASELINE", "MEAN_SGP_BASELINE_INFERRED", "MEAN_SCALE_SCORE_INFERRED_SE", "MEAN_SGP_INFERRED_SE", "MEAN_SGP_BASELINE_INFERRED_SE"))
    Demonstration_COVID_SGP_Summaries_STEP_3d <- list_of_summary_files[[data.iter]]
    save(Demonstration_COVID_SGP_Summaries_STEP_3d, file=file.path(directory.iter, data.iter, "Demonstration_COVID_SGP_Summaries_STEP_3d.Rdata"))
}

### rbindlist to create overall data set

Demonstration_COVID_SGP_Summaries_STEP_3d <- rbindlist(list_of_summary_files)


### Save results

save(Demonstration_COVID_SGP_Summaries_STEP_3d, file=file.path(output.directory, output.file.directories, "Demonstration_COVID_SGP_Summaries_STEP_3d.Rdata"))
