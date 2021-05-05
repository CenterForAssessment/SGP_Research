`imputeScaleScore` <- function(
    impute.data,
    additional.data = NULL,
    diagnostics.dir = getwd(),
    growth.config = NULL,
    status.config = NULL,
    default.vars = c("CONTENT_AREA", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL"),
    demographics = c("FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "ETHNICITY", "GENDER"),
    institutions = c("SCHOOL_NUMBER", "DISTRICT_NUMBER"),
    impute.factors = "SCALE_SCORE",
    impute.method = NULL,
    cluster.institution = FALSE, # set to TRUE for multilevel (cross-sectional) methods
    partial.fill = TRUE,
    seed = 4224L,
    M = 10,
    maxit = 5,
    verbose=FALSE,
    ...){

  ###   Load required packages
  require(SGP)
  require(mice)
  require(data.table)

  ###   Utility functions from SGP package
  `%w/o%` <- function(x,y) x[!x %in% y]

  `getKey` <- function(data) {
		if ("YEAR_WITHIN" %in% names(data)) return(c("VALID_CASE", "CONTENT_AREA", "YEAR", "GRADE", "ID", "YEAR_WITHIN")) else return(c("VALID_CASE", "CONTENT_AREA", "YEAR", "GRADE", "ID"))
  } ### END getKey

  ###   Initial checks
  if(length(inst.sum.var <- intersect(institutions, impute.factors)) > 1) stop("Only one 'institution' variable can be used as a impute (summary) variable.")

  if (is.null(impute.method)) {
    impute.method <- "pmm"
  }

  if (!cluster.institution & grepl("2l[.]", impute.method)) {
    cluster.institution <- TRUE
    message("\n\tArgument 'cluster.institution' set to TRUE with 2l.* method\n")
  }
  ###   Combine and augment config lists
  imp.config <- growth.config

  if (!is.null(growth.config)) {
    for (f in seq(imp.config)) imp.config[[f]][["analysis.type"]] <- "GROWTH"
  }
  if (!is.null(status.config)) {
    for (f in seq(status.config)) status.config[[f]][["analysis.type"]] <- "STATUS"
    imp.config <- c(imp.config, status.config)
  }

  if (is.null(imp.config)) stop("Either a 'growth.config' or 'status.config' must be supplied")

  long.to.wide.vars <- c(default.vars, institutions, demographics)

  ###   Cycle through imp.config to amputate by cohort
  imp.list <- vector(mode = "list", length = M)

  for (K in seq(imp.config)) {
    imp.iter <- imp.config[[K]]

    tmp.lookup <- SJ("VALID_CASE", tail(imp.iter[["sgp.content.areas"]], length(imp.iter[["sgp.grade.sequences"]])),
      tail(imp.iter[["sgp.panel.years"]], length(imp.iter[["sgp.grade.sequences"]])), imp.iter[["sgp.grade.sequences"]])
    # ensure lookup table is ordered by years.  NULL out key after sorted so that it doesn't corrupt the join in dcast.
    setkey(tmp.lookup, V3)
    setkey(tmp.lookup, NULL)
    setkeyv(impute.data, getKey(impute.data))

    tmp.long <- impute.data[tmp.lookup][, unique(c("VALID_CASE", "ID", "YEAR", long.to.wide.vars)), with=FALSE]

    prior.years <- head(imp.iter$sgp.panel.years, -1)
    current.year <- tail(imp.iter$sgp.panel.years, 1)
    current.grade <- tail(imp.iter$sgp.grade.sequences, 1)
    current.subject <- tail(imp.iter$sgp.content.areas, 1)
    prior.scores <- paste("SCALE_SCORE", prior.years, sep=".")
    current.score <- paste("SCALE_SCORE", current.year, sep=".")

    if (imp.iter$analysis.type == "GROWTH") {
      ###   convert long to wide
      tmp.wide <- dcast(tmp.long, ID ~ YEAR, sep=".", drop=FALSE, value.var=long.to.wide.vars)

      ###   Exclude kids missing current and most recent year's scale score
      tmp.wide <- tmp.wide[!(is.na(get(tail(prior.scores, 1))) & is.na(get(current.score))),]

      if (partial.fill) {
        ###   Fill in missing content area and grades first
        for (ca in seq(imp.iter$sgp.panel.years)) {
          tmp.wide[, paste("CONTENT_AREA", imp.iter$sgp.panel.years[ca], sep=".") := imp.iter$sgp.content.areas[ca]]
        }

        for (g in seq(imp.iter$sgp.panel.years)) {
          tmp.wide[, paste("GRADE", imp.iter$sgp.panel.years[g], sep=".") := imp.iter$sgp.grade.sequences[g]]
        }

        meas.list <- vector(mode = "list", length = length(long.to.wide.vars))
        meas.list <- lapply(long.to.wide.vars, function(f) meas.list[[f]] <- grep(paste0(f, "[.]"), names(tmp.wide)))
        names(meas.list) <- long.to.wide.vars

        ###   First stretch out to get missings in log data
        long.final <- melt(tmp.wide, id = "ID", variable.name = "YEAR", measure=meas.list)

        ###   Fill in demographics
        setkey(long.final, ID, YEAR)
        long.final <- data.table(dplyr::ungroup(tidyr::fill(dplyr::group_by(long.final, ID),
                                tidyselect::all_of(demographics), .direction="downup")))

        ###   Fill in school numbers (CLUDGE) - try to figure out how to do with random forrest or something better...
        if ("SCHOOL_NUMBER" %in% institutions) {
          tmp.long.elem <- long.final[GRADE %in% c(3:5)]
          if (length(unique(tmp.long.elem[, GRADE])) == 1L) {
            tmp.long.elem[is.na(SCHOOL_NUMBER), SCHOOL_NUMBER :=
              sample(unique(na.omit(tmp.long.elem$SCHOOL_NUMBER)), size=sum(is.na(tmp.long.elem$SCHOOL_NUMBER)), replace=TRUE)]
          } else {
            tmp.long.elem <- data.table(dplyr::ungroup(tidyr::fill(dplyr::group_by(tmp.long.elem, ID),
                                          SCHOOL_NUMBER, .direction="updown")))
          }

          tmp.long.mid <- long.final[GRADE %in% c(6:8)]
          if (length(unique(tmp.long.mid[, GRADE])) == 1L) {
            tmp.long.mid[is.na(SCHOOL_NUMBER), SCHOOL_NUMBER :=
              sample(unique(na.omit(tmp.long.mid$SCHOOL_NUMBER)), size=sum(is.na(tmp.long.mid$SCHOOL_NUMBER)), replace=TRUE)]
          } else {
            tmp.long.mid <- data.table(dplyr::ungroup(tidyr::fill(dplyr::group_by(tmp.long.mid, ID),
                                        SCHOOL_NUMBER, .direction="updown")))
          }

          long.final <- rbindlist(list(tmp.long.elem, tmp.long.mid))
        }

        if ("DISTRICT_NUMBER" %in% institutions) {
          long.final <- data.table(dplyr::ungroup(tidyr::fill(dplyr::group_by(long.final, ID),
                                  DISTRICT_NUMBER, .direction="updown")))
        }

        long.final[, YEAR := as.character(factor(YEAR, labels = imp.iter[["sgp.panel.years"]]))]

        ###   re-widen
        ##    This could probably be made more parsimonious!  Really only need
        ##    current & most recent prior year w/ impute.factors
        tmp.wide <- dcast(long.final, ID ~ YEAR, sep=".", drop=FALSE, value.var=long.to.wide.vars)
      }  else { #  END partial.fill
        long.final <- melt(tmp.wide, id = "ID", variable.name = "YEAR", measure=meas.list)
        long.final[, YEAR := as.character(factor(YEAR, labels = imp.iter[["sgp.panel.years"]]))]
      }

      long.final[, VALID_CASE := "VALID_CASE"]

    } else {  #  END "GROWTH"  --  Begin "STATUS"
      ###   Create institution level summaries
      tmp.grades <- unique(head(imp.iter$sgp.grade.sequences, -1))

      subset.wide <- tmp.long[YEAR %in% current.year, c("ID", impute.factors), with=FALSE] # %w/o% "SCALE_SCORE" assuming not using any other current year data.
      #  remove columns that are all NA (e.g., SGP for 3rd grade priors)
      subset.wide <- subset.wide[,
        names(subset.wide)[!unlist(lapply(names(subset.wide), function(f) all(is.na(subset.wide[,get(f)]))))], with=FALSE]

      tmp.long.priors <- tmp.long[YEAR %in% prior.years & GRADE %in% tmp.grades, impute.factors, with=FALSE] # assuming not MNAR - all prior values for imp.vars

      if (length(demog.imp.vars <- intersect(demographics, impute.factors)) > 0) {
        for (demog in demog.imp.vars) {
          tmp.long.priors[, eval(demog) := as.integer(factor(get(demog)))-1L]
          subset.wide[, eval(demog) := as.integer(factor(get(demog)))-1L]
        }
      }

      if (length(inst.sum.var) > 0) {
        tmp.inst.var <- paste0(inst.sum.var, ".", current.year)
        # smry_eval_expression <- paste0("IMV__", impute.factors %w/o% c(institutions, demographics)
        subset.wide[, paste0("IMV___SCALE_SCORE.", current.year, "___", tmp.inst.var) := as.numeric(NA)]
        for (demog in intersect(impute.factors, demographics)) {
          subset.wide[, paste0("IMV___", demog, "___", tmp.inst.var) := mean(get(demog), na.rm=TRUE), by=list(get(inst.sum.var))]
        }

        ##    Prior year(s) summaries to use
        smry_eval_expression <-
          paste0("PRIOR_IMV__", impute.factors %w/o% c(demographics, institutions), "_", tmp.inst.var, " = ", "mean(", impute.factors %w/o% c(demographics, institutions), ", na.rm=TRUE)") # intersect(impute.factors, demographics)
        smry_eval_expression <- setNames(smry_eval_expression, sub('^(.*) = .*', '\\1', smry_eval_expression))

        tmp_inst_smry <- tmp.long.priors[!is.na(eval(inst.sum.var)),
              										lapply(smry_eval_expression, function(f) eval(parse(text=f))), keyby = inst.sum.var]

        subset.wide <- merge(subset.wide, tmp_inst_smry, by=inst.sum.var)
        setnames(subset.wide, inst.sum.var, tmp.inst.var)
      }
      setnames(subset.wide, "SCALE_SCORE", current.score)

      ###   Create long.final with only the "current" year (last elements of the config)
      ###   More thorough to do it with config than just long.final <- tmp.long[YEAR %in% current.year]
      tmp.lookup <- SJ("VALID_CASE", tail(imp.iter[["sgp.content.areas"]], 1),
        tail(imp.iter[["sgp.panel.years"]], 1), tail(imp.iter[["sgp.grade.sequences"]], 1))
      setkeyv(impute.data, getKey(impute.data))

      long.final <- impute.data[tmp.lookup][, unique(c("VALID_CASE", "ID", "YEAR", long.to.wide.vars)), with=FALSE]
    } ###  END "STATUS"

    #####
    ###   IMPUTE
    #####

    ##    Subset out scale scores and demographics
    if (imp.iter$analysis.type == "GROWTH") {  #  done above for "STATUS"
      wide.imp.vars <- grep(paste0(impute.factors %w/o% institutions, "[.]", collapse="|"), names(tmp.wide), value=TRUE)
      wide.imp.vars <- c(wide.imp.vars, paste(intersect(impute.factors, institutions), current.year, sep="."))

      #  create subset of wide data with only variables to be used in imputation
      subset.wide <- tmp.wide[, grep(paste0("ID|", paste(wide.imp.vars, collapse="|")), names(tmp.wide)), with=FALSE]
      #  remove columns that are all NA (e.g., SGP for 3rd grade priors)
      subset.wide <- subset.wide[,
        names(subset.wide)[!unlist(lapply(names(subset.wide), function(f) all(is.na(subset.wide[,get(f)]))))], with=FALSE]

      ##    Convert character/factor to numeric (0/1) data
      demog.imp.vars <- grep(paste(demographics, collapse="|"), wide.imp.vars, value=TRUE)
      if (length(demog.imp.vars) > 0) {
        for (demog in demog.imp.vars) {
          subset.wide[, eval(demog) := as.integer(factor(get(demog)))-1L]
        }
      }

      ##    Create a single demographic average value for demographics in impute.factors
      if (length(demog.imp.vars) > 0) {
        for (demog in intersect(impute.factors, demographics)) {
          tmp.dmg <- grep(demog, demog.imp.vars, value=TRUE)
          subset.wide[, paste0("SUMSCORE__", demog) := rowSums(.SD, na.rm = TRUE)/length(tmp.dmg), .SDcols = tmp.dmg]
          subset.wide[, eval(tmp.dmg) := NULL]
          wide.imp.vars <- c(wide.imp.vars %w/o% tmp.dmg, paste0("SUMSCORE__", demog))
        }
      }
      ##    Create institutional level averages of achievement and demographics
      ##    IMV__  -  institutional mean variable
      if (length(inst.sum.var) > 0) {
        tmp.inst.var <- paste0(inst.sum.var, ".", current.year)
        subset.wide[, paste0("IMV___SCALE_SCORE.", current.year, "___", tmp.inst.var) := as.numeric(NA)]

        tmp.demg.vars <- grep(paste(demographics, collapse="|"), wide.imp.vars, value=TRUE)
        for (wiv in tmp.demg.vars) {
          subset.wide[, paste0("IMV___", wiv, "___", inst.sum.var) := mean(get(wiv), na.rm=TRUE), by=list(get(tmp.inst.var))] # tail(tmp.inst.vars, 1)
        }
      }
    }  ###  END "GROWTH"

    tmp.meth <- mice::make.method(data=subset.wide)
    tmp.pred <- mice::make.predictorMatrix(data=subset.wide)
    tmp.pred[, "ID"] <- 0
    if (length(inst.sum.var) > 0) {
      if (cluster.institution) {
        tmp.pred[, tmp.inst.var] <- -2
      } else tmp.pred[, tmp.inst.var] <- 0
    }

    tmp.grp.means <- names(tmp.meth)[grepl("IMV___", names(tmp.meth)) & tmp.meth != ""]
    if (length(tmp.grp.means) > 0) {
      require(miceadds)
      tmp.meth[tmp.grp.means] <- "2l.groupmean"
      for(f in seq(tmp.grp.means)) {
        tmp.f <- strsplit(tmp.grp.means[f], "___")[[1]]
        tmp.pred[tmp.grp.means[f], tmp.f[2]] <- 2
        tmp.pred[tmp.grp.means[f], tmp.f[3]] <- -2
        subset.wide[, eval(tmp.f[3]) := as.integer(get(tmp.f[3]))]
      }
    }

    tmp.meth[current.score] <- impute.method

    if (imp.iter$analysis.type == "GROWTH") {
      # tmp.meth[prior.scores] <- ""  #  Seems to do a better job when imputing prior years too, but can turn them off here.
      tmp.meth[prior.scores] <- "pmm"
    }

    imp <- suppressWarnings(mice::mice(subset.wide, meth = tmp.meth, pred = tmp.pred, m = M, maxit = maxit, seed = seed, allow.na=TRUE, print=verbose, ...))

    ##    Save some diagnostic plots
    if (!dir.exists(file.path(diagnostics.dir, "diagnostics"))) dir.create(file.path(diagnostics.dir, "diagnostics"))
    pdf(file.path(diagnostics.dir, "diagnostics", paste0("Grade_", current.grade, "_", current.subject, "_", impute.method, "_M_", M, "__maxit_", maxit, "__converge", ".pdf")))
    print(plot(imp, names(tmp.meth[tmp.meth != ""]))) # [1:2]
    invisible(dev.off())
    pdf(file.path(diagnostics.dir, "diagnostics", paste0("Grade_", current.grade, "_", current.subject, "_", impute.method, "_M_", M, "__maxit_", maxit, "__density", ".pdf")))
    print(densityplot(imp))
    invisible(dev.off())

    tmp.wide[, IMPUTED := is.na(get(current.score))]
    long.imputed <- as.data.table(complete(imp, action="long"))[, c(".imp", "ID", current.score), with=FALSE][, YEAR := eval(current.year)]
    setkey(long.imputed, ID, YEAR)
    setkey(long.final, ID, YEAR)

    for (m in seq(M)) {
      imp.list[[m]][[K]] <- long.imputed[.imp==m][long.final]
      imp.list[[m]][[K]][, IMPUTED_SS := FALSE]
      imp.list[[m]][[K]][is.na(SCALE_SCORE) & YEAR == eval(current.year), IMPUTED_SS := TRUE]
      imp.list[[m]][[K]][is.na(SCALE_SCORE) & YEAR == eval(current.year), SCALE_SCORE := get(current.score)]
      imp.list[[m]][[K]][, c(".imp", current.score) := NULL]
      #  Add ACHIEVEMENT_LEVEL for imputed
    }
  }  ###  END K

  final.imp.list <- vector(mode = "list", length = M)

  for (L in seq(M)) {
    final.imp.list[[L]] <- rbindlist(imp.list[[L]], fill=TRUE)
    # final.imp.list[[L]][, .imp := L]

    if (!is.null(additional.data)) {
      final.imp.list[[L]] <- rbindlist(
        list(final.imp.list[[L]], additional.data[, names(final.imp.list[[L]]), with=FALSE]), fill=TRUE)
    }

    ##    remove dups for repeaters created from long to wide to long reshaping
    setkeyv(final.imp.list[[L]], getKey(final.imp.list[[L]]))
    setkeyv(final.imp.list[[L]], key(final.imp.list[[L]]) %w/o% "GRADE")
    dup.ids <- final.imp.list[[L]][which(duplicated(final.imp.list[[L]], by=key(final.imp.list[[L]]))), ID]
    final.imp.list[[L]][ID %in% dup.ids & is.na(SCALE_SCORE), VALID_CASE := "NEW_DUP"] # INVALID_CASE

    final.imp.list[[L]] <- final.imp.list[[L]][VALID_CASE != "NEW_DUP"]
  }
  return(final.imp.list)
}
