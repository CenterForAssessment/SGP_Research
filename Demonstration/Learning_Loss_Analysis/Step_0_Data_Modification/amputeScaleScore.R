`amputeScaleScore` <- function(
    state = "DEMO_COVID",
    ampute.data = SGPdata::sgpData_LONG_COVID[YEAR <= 2021],
    additional.data = NULL,
    growth.config = NULL,
    status.config = NULL,
    default.vars = c("CONTENT_AREA", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL"),
    demographics = c("FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "ETHNICITY", "GENDER"), #
    institutions = c("SCHOOL_NUMBER", "DISTRICT_NUMBER"),
    ampute.vars  = c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS"),
    ampute.args = list(prop=0.3, type="RIGHT"), # as.list(args(mice::ampute)),
    partial.fill = TRUE,
    reverse.scale.score.tail = TRUE,
    invalidate.repeater.dups = TRUE,
    seed = 4224L,
    M = 10){

  ###   Load required packages
  require(SGP)
  require(mice)
  require(data.table)
  `%w/o%` <- function(x,y) x[!x %in% y]

  ###   set up growth.config
  if (is.null(growth.config)) {
    TMP_OBJECT <- prepareSGP(ampute.data, create.additional.variables=FALSE)
  } else TMP_OBJECT <- list()

  amp.config <- SGP:::getSGPConfig(
    sgp_object=TMP_OBJECT,
  	state = "DEMO_COVID",
  	tmp_sgp_object = list(),
  	content_areas=NULL,
  	years = NULL,
  	grades=NULL,
  	sgp.config=growth.config,
  	trim.sgp.config=TRUE,
    sgp.percentiles=TRUE,
    sgp.projections=FALSE,
    sgp.projections.lagged=FALSE,
    sgp.percentiles.baseline=FALSE,
    sgp.projections.baseline=FALSE,
    sgp.projections.lagged.baseline=FALSE,
  	sgp.config.drop.nonsequential.grade.progression.variables = FALSE,
  	sgp.minimum.default.panel.years=3,
  	sgp.use.my.coefficient.matrices=NULL)[[1]]

  for (f in seq(amp.config)) amp.config[[f]][["analysis.type"]] <- "GROWTH"

  if (!is.null(status.config)) {
    for (f in seq(status.config)) status.config[[f]][["analysis.type"]] <- "STATUS"
    amp.config <- c(amp.config, status.config)
  }

  ###   Cycle through amp.config to amputate by cohort
  amp.list <- vector(mode = "list", length = M)

  for (K in seq(amp.config)) {
    amp.iter <- amp.config[[K]]

    tmp.lookup <- SJ("VALID_CASE", tail(amp.iter[["sgp.content.areas"]], length(amp.iter[["sgp.grade.sequences"]])),
      tail(amp.iter[["sgp.panel.years"]], length(amp.iter[["sgp.grade.sequences"]])), amp.iter[["sgp.grade.sequences"]])
    # ensure lookup table is ordered by years.  NULL out key after sorted so that it doesn't corrupt the join in dcast.
    setkey(tmp.lookup, V3)
    setkey(tmp.lookup, NULL)
    setkeyv(ampute.data, SGP:::getKey(ampute.data))

    tmp.long <- ampute.data[tmp.lookup]

    if (amp.iter$analysis.type == "GROWTH") {
      ###   convert long to wide
      long.to.wide.vars <- c(default.vars, institutions, demographics)
      tmp.wide <- dcast(tmp.long, ID ~ YEAR, sep=".", drop=FALSE, value.var=long.to.wide.vars)

      ###   Exclude kids missing 2 or more most recent years
      prior.year <- tail(amp.iter$sgp.panel.years, 2)[1]
      current.year <- tail(amp.iter$sgp.panel.years, 1)
      prior.score <- paste("SCALE_SCORE", prior.year, sep=".")
      current.score <- paste("SCALE_SCORE", current.year, sep=".")
      tmp.wide <- tmp.wide[!(is.na(get(prior.score)) & is.na(get(current.score))),]

      if (partial.fill) {
        ###  Fill in missing content area and grades first
        for (ca in seq(amp.iter$sgp.panel.years)) {
          tmp.wide[, paste("CONTENT_AREA", amp.iter$sgp.panel.years[ca], sep=".") := amp.iter$sgp.content.areas[ca]]
        }

        for (g in seq(amp.iter$sgp.panel.years)) {
          tmp.wide[, paste("GRADE", amp.iter$sgp.panel.years[g], sep=".") := amp.iter$sgp.grade.sequences[g]]
        }

        meas.list <- vector(mode = "list", length = length(long.to.wide.vars))
        meas.list <- lapply(long.to.wide.vars, function(f) meas.list[[f]] <- grep(f, names(tmp.wide)))
        names(meas.list) <- long.to.wide.vars

        ###   First stretch out to get missings in log data
        tmp.long <- melt(tmp.wide, id = "ID", variable.name = "YEAR", measure=meas.list)

        ###   Fill in demographics
        setkey(tmp.long, ID, YEAR)
        tmp.long <- data.table(dplyr::ungroup(tidyr::fill(dplyr::group_by(tmp.long, ID),
                                tidyselect::all_of(demographics), .direction="downup")))

        ###   Fill in school numbers (CLUDGE) - try to figure out how to do with random forrest or something better...
        if ("SCHOOL_NUMBER" %in% institutions) {
          tmp.long.elem <- tmp.long[GRADE %in% c(3:5)]
          if (length(unique(tmp.long.elem[, GRADE])) == 1L) {
            tmp.long.elem[is.na(SCHOOL_NUMBER), SCHOOL_NUMBER :=
              sample(unique(na.omit(tmp.long.elem$SCHOOL_NUMBER)), size=sum(is.na(tmp.long.elem$SCHOOL_NUMBER)), replace=TRUE)]
          } else {
            tmp.long.elem <- data.table(dplyr::ungroup(tidyr::fill(dplyr::group_by(tmp.long.elem, ID),
                                          SCHOOL_NUMBER, .direction="updown")))
          }

          tmp.long.mid <- tmp.long[GRADE %in% c(6:8)]
          if (length(unique(tmp.long.mid[, GRADE])) == 1L) {
            tmp.long.mid[is.na(SCHOOL_NUMBER), SCHOOL_NUMBER :=
              sample(unique(na.omit(tmp.long.mid$SCHOOL_NUMBER)), size=sum(is.na(tmp.long.mid$SCHOOL_NUMBER)), replace=TRUE)]
          } else {
            tmp.long.mid <- data.table(dplyr::ungroup(tidyr::fill(dplyr::group_by(tmp.long.mid, ID),
                                        SCHOOL_NUMBER, .direction="updown")))
          }

          tmp.long <- rbindlist(list(tmp.long.elem, tmp.long.mid))
        }

        if ("DISTRICT_NUMBER" %in% institutions) {
          tmp.long <- data.table(dplyr::ungroup(tidyr::fill(dplyr::group_by(tmp.long, ID),
                                  DISTRICT_NUMBER, .direction="updown")))
        }

        tmp.long[, YEAR := as.character(factor(YEAR, labels = amp.iter[["sgp.panel.years"]]))]

        ###   re-widen
        tmp.wide <- dcast(tmp.long, ID ~ YEAR, sep=".", drop=FALSE, value.var=long.to.wide.vars)
      }  #  END partial.fill

      long.final <- melt(tmp.wide, id = "ID", variable.name = "YEAR", measure=meas.list)
      long.final[, YEAR := as.character(factor(YEAR, labels = amp.iter[["sgp.panel.years"]]))]
      long.final[, VALID_CASE := "VALID_CASE"]
      # ###   Create long.final with only the "current" year (last elements of the config)
      # ###   More thorough to do it with config than just long.final <- long.final[YEAR %in% current.year]
      # tmp.lookup <- SJ("VALID_CASE", tail(amp.iter[["sgp.content.areas"]], 1),
      #   tail(amp.iter[["sgp.panel.years"]], 1), tail(amp.iter[["sgp.grade.sequences"]], 1))
      # setkeyv(long.final, SGP:::getKey(long.final))
      #
      # long.final <- long.final[tmp.lookup]
    } else {  #  END "GROWTH"  --  Begin "STATUS"
      ###   Create institution level summaries
      prior.years <- head(amp.iter$sgp.panel.years, -1)
      tmp.grades <- unique(head(amp.iter$sgp.grade.sequences, -1))
      current.year <- tail(amp.iter$sgp.panel.years, 1)
      demog.amp.vars <- intersect(ampute.vars, demographics)

      subset.wide <- tmp.long[YEAR %in% current.year, c("ID", ampute.vars %w/o% "SCALE_SCORE"), with=FALSE] # assuming not using any other current year data.
      tmp.long.priors <- tmp.long[YEAR %in% prior.years & GRADE %in% tmp.grades, ampute.vars, with=FALSE] # assuming not MNAR
      if (reverse.scale.score.tail) {
        tmp.long.priors[, "SCALE_SCORE" := -1*SCALE_SCORE]
      }
      for (demog in demog.amp.vars) {
        tmp.long.priors[, eval(demog) := as.integer(factor(get(demog)))-1L]
        subset.wide[, eval(demog) := as.integer(factor(get(demog)))-1L]
      }

      if (length(inst.sum.var <- intersect(institutions, ampute.vars)) > 0) {
        for (inst in inst.sum.var) {
          smry_eval_expression <- paste0("PERCENT_", gsub("_STATUS", "", demog.amp.vars), "_", strsplit(inst, "_")[[1]][1],
              " = ", "(100*(sum(",demog.amp.vars,")/.N))")
          smry_eval_expression <- c(paste0("MEAN_SS", "_", strsplit(inst, "_")[[1]][1], " = ", "mean(SCALE_SCORE, na.rm=TRUE)"), smry_eval_expression)
          smry_eval_expression <- setNames(smry_eval_expression, sub('^(.*) = .*', '\\1', smry_eval_expression))

          tmp_inst_smry <- tmp.long.priors[!is.na(eval(inst)),
	              										lapply(smry_eval_expression, function(f) eval(parse(text=f))), keyby = inst]

          subset.wide <- merge(subset.wide, tmp_inst_smry, by=inst)
          subset.wide[, eval(inst) := NULL]
          subset.wide <- na.omit(subset.wide)
        }
      }
      ###   Create long.final with only the "current" year (last elements of the config)
      ###   More thorough to do it with config than just long.final <- tmp.long[YEAR %in% current.year]
      tmp.lookup <- SJ("VALID_CASE", tail(amp.iter[["sgp.content.areas"]], 1),
        tail(amp.iter[["sgp.panel.years"]], 1), tail(amp.iter[["sgp.grade.sequences"]], 1))
      setkeyv(ampute.data, SGP:::getKey(ampute.data))

      long.final <- ampute.data[tmp.lookup]
    } ###  END "STATUS"

    ###   AMPUTE
    ###   Use "mask" approach to single variable proportion control
    ###   https://rianneschouten.github.io/mice_ampute/vignette/ampute.html#missingness_proportion_per_variable

    ##    Subset out scale scores and demographics
    if (amp.iter$analysis.type == "GROWTH")  { # done above for "STATUS"
      ##    Convert character/factor to numeric (0/1) data
      demog.amp.vars <- grep(paste(demographics, collapse="|"), names(tmp.wide), value=TRUE)
      for (demog in demog.amp.vars) {
        tmp.wide[, eval(demog) := as.integer(factor(get(demog)))-1L]
      }

      if (reverse.scale.score.tail) {
        tmp.wide[, eval(prior.score) := -1*get(prior.score)]
      }

      ##    Create institutional level averages of achievement and demographics
      if (length(inst.sum.var <- intersect(institutions, ampute.vars)) > 0) {
        for (inst in inst.sum.var) {
          tmp.inst.var <- paste0(inst, ".", prior.year)
          tmp.wide[, paste0("MEAN_SS", "_", strsplit(inst, "_")[[1]][1]) := mean(get(prior.score), na.rm=TRUE), by=list(get(tmp.inst.var))]
          for (demog in demog.amp.vars) {
            tmp.wide[, paste0("PCT_", demog, "_", strsplit(inst, "_")[[1]][1]) := (sum(get(demog))/.N), by=list(get(tmp.inst.var))]
          }
          # subset.wide[, eval(tmp.inst.var) := NULL]
        }
      }

      subset.wide <- tmp.wide[!is.na(get(current.score)),
        grep(paste0("ID|MEAN_SS|", paste(ampute.vars %w/o% institutions, collapse=paste0(".", prior.year, "|")), ".", prior.year), names(tmp.wide)), with=FALSE]
      subset.wide <- na.omit(subset.wide)

      ##    Find the proportion relative to the complete data that needs to be amputated to give a total ~ ampute.args$prop
      # target.prop <- round((ampute.args$prop - sum(is.na(tmp.wide[[current.score]]))/nrow(tmp.wide)), 3)
      target.prop <- round((round(nrow(tmp.wide)*ampute.args$prop, 0)-sum(is.na(tmp.wide[[current.score]])))/nrow(subset.wide), 3)
      if (target.prop < 0) {
        target.prop <- 0.001;too.low.tf <- TRUE
        pick.miss <- round(nrow(tmp.wide)*target.prop, 0)
        message("More than ", ampute.args$prop*100, "% missing cases already exist in Grade ", tail(amp.iter[["sgp.grade.sequences"]], 1), " ", tail(amp.iter[["sgp.content.areas"]], 1),
        " 'prop' will be temporarily set to 0.001 (0.1% - ", pick.miss, " records removed)")
      } else {
        ltol <- target.prop-c(0.06, rev(seq(0.001, 0.06, 0.0025)))
        utol <- target.prop+c(0.06, rev(seq(0.001, 0.06, 0.0025)))
        too.low.tf <- FALSE
      }
    } else {
      # target.prop <- round((ampute.args$prop - sum(is.na(long.final[, SCALE_SCORE]))/nrow(long.final)), 3)
      target.prop <- round((round(nrow(long.final)*ampute.args$prop, 0)-sum(is.na(long.final[, SCALE_SCORE])))/nrow(subset.wide), 3)
      ltol <- target.prop-c(0.03, rev(seq(0.001, 0.03, 0.00125)))
      utol <- target.prop+c(0.03, rev(seq(0.001, 0.03, 0.00125)))
      too.low.tf <- FALSE
    }
    # ltol <- target.prop-0.049; utol <- target.prop+0.049 # just under 10% tollerance level
    # ltol <- target.prop-c(0.09, rev(seq(0.001, 0.09, 0.004)), 0.001)
    # utol <- target.prop+c(0.09, rev(seq(0.001, 0.09, 0.004)), 0.001)

    ##    Reduce amputation analysis data to non-NA data and standardize
    subset.wide.std <- scale(subset.wide[,-1,])

    tmp.weights <- matrix(rep(1, ncol(subset.wide)-1), nrow = 1)
    tmp.scores <- apply(subset.wide.std, 1, function (x) tmp.weights %*% x)
    if (is.null(ampute.args$type)) ampute.args$type <- "RIGHT"

    ##    mice::ampute.continuous doesn't do a good job at getting the right `prop`
    ##    value down  :(  Do a "burn in" to get it closer
    # adj.prop <- 0
    # for (i in 1:3) { # get an quick average for the initial burn in prop
    #   burn_mask <- mice::ampute.continuous(
    #                         P = rep(2, nrow(subset.wide)), prop = target.prop,
    #                         scores = list(tmp.scores), type = ampute.args$type)
    #   adj.prop <- adj.prop + (target.prop * target.prop/(sum(burn_mask[[1]]==0)/nrow(subset.wide)))/3
    # }
    if (!too.low.tf) {
      adj.prop <- target.prop
      fin.props <- c()
      res.props <- c()
      shrink.tol <- 1L
      for (j in 1:25) {
        adj_mask <- mice::ampute.continuous(
                              P = rep(2, nrow(subset.wide)), prop = adj.prop,
                              scores = list(tmp.scores), type = ampute.args$type)
        res.prop <- (sum(adj_mask[[1]]==0)/nrow(subset.wide))
        if (!inrange(res.prop, ltol[shrink.tol], utol[shrink.tol])) {
          # constrain adjustment to keep from getting too big/small too fast
          tmp.ratio <- target.prop/res.prop
          if (tmp.ratio > 1.15) tmp.ratio <- 1.15
          if (tmp.ratio < 0.85) tmp.ratio <- 0.85
          adj.prop <- adj.prop * tmp.ratio
          if (adj.prop > 0.999) adj.prop <- 0.999
          if (adj.prop < 0.001) adj.prop <- 0.001
        } else {
          fin.props <- c(fin.props, adj.prop)
          res.props <- c(res.props, res.prop)
          shrink.tol <- shrink.tol + 1
        }
      }
      if (!is.null(fin.props)) {
        fin.prop <- weighted.mean(x=fin.props, w=(1/abs(1-target.prop/res.props)))
      } else fin.prop <- target.prop
      ##    Get M sets of amputation candidates
      for (amp.m in seq(M)) {
        set.seed(seed*amp.m)
        mask_var <- mice::ampute.continuous(
                                P = rep(2, nrow(subset.wide)), prop = fin.prop,
                                scores = list(tmp.scores), type = ampute.args$type)

        # summary(mask_var[[1]])
        amp.ids <- subset.wide[which(mask_var[[1]]==0L), ID]

        ###   Amputate...  Finally!!!
        amp.list[[amp.m]][[K]] <- copy(long.final)
        amp.list[[amp.m]][[K]][YEAR == current.year & ID %in% amp.ids, SCALE_SCORE := NA]
        if ("ACHIEVEMENT_LEVEL" %in% names(amp.list[[amp.m]][[K]])) {
          amp.list[[amp.m]][[K]][YEAR == current.year & ID %in% amp.ids, ACHIEVEMENT_LEVEL := NA]
        }
      }
      # for (amp.m in seq(M)) {print(sum(is.na(amp.list[[amp.m]][[K]][, SCALE_SCORE]))/nrow(long.final))}
      # for (amp.m in seq(M)) {print(amp.list[[amp.m]][[K]][, list(NAs = sum(is.na(SCALE_SCORE))/.N), keyby=list(YEAR, CONTENT_AREA, GRADE)])}
    } else {
      max.scores <- head(rev(sort(tmp.scores)), pick.miss*M)
      id.list <- subset.wide[which(tmp.scores %in% max.scores), ID]
      score.prob <- tmp.scores[which(tmp.scores %in% max.scores)]
      for (amp.m in seq(M)) {
        set.seed(seed*amp.m)
        amp.ids <- sample(x=id.list, size=pick.miss, prob=score.prob)
        amp.list[[amp.m]][[K]] <- copy(long.final)
        amp.list[[amp.m]][[K]][YEAR == current.year & ID %in% amp.ids, SCALE_SCORE := NA]
        if ("ACHIEVEMENT_LEVEL" %in% names(amp.list[[amp.m]][[K]])) {
          amp.list[[amp.m]][[K]][YEAR == current.year & ID %in% amp.ids, ACHIEVEMENT_LEVEL := NA]
        }
      }
    }
  }

  final.amp.list <- vector(mode = "list", length = M)

  for (L in seq(M)) {
    final.amp.list[[L]] <- rbindlist(amp.list[[L]], fill=TRUE)

    if (!is.null(additional.data)) {
      final.amp.list[[L]] <- rbindlist(
        list(final.amp.list[[L]], additional.data[, names(final.amp.list[[L]]), with=FALSE]), fill=TRUE)
    }
    if (invalidate.repeater.dups) {
      setkeyv(final.amp.list[[L]], SGP:::getKey(final.amp.list[[L]]))
      setkeyv(final.amp.list[[L]], key(final.amp.list[[L]]) %w/o% "GRADE")
      dup.ids <- final.amp.list[[L]][which(duplicated(final.amp.list[[L]], by=key(final.amp.list[[L]]))), ID]
      final.amp.list[[L]][ID %in% dup.ids & is.na(SCALE_SCORE), VALID_CASE := "INVALID_CASE"]
    }
  }
  return(final.amp.list)
}
