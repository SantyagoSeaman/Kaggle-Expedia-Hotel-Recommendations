zzz <- which(test.w.clusters.freq$dist_0 != -1)

View(test.w.clusters.freq[zzz, 1:50])

zzz <- zzz[1:100]

View(data.frame(w = winner.submission_2016.05.30.15.44[zzz, 'hotel_cluster'], p = submission[zzz, 'hotel_cluster']))

View(data.frame(test.w.clusters.freq[zzz, paste('dist_', 0:99, sep = '')]))
View(data.frame(test.w.clusters.freq[zzz, 1:100]))


View(data.frame(test.w.clusters.freq[zzz, paste('avg_', 0:99, sep = '')]))



# взять 10000 stupid предсказаний и смёржить их с 1000 записями с известными distance
# это проверка на корректность моих предсказаний distance
create.weight.df <- function(vec) {
    data.frame(num = vec, weight = seq(length(vec), 1))
}

not_empty_dist <- which(test.w.clusters.freq$dist_0 != -1)
final <- winner.submission_2016.06.03.13.21
# for (i in 1:nrow(test.w.clusters.freq)) {
for (i in not_empty_dist[1:1000]) {
    clusters.last <- as.integer(unlist(strsplit(submission[i, 'hotel_cluster'], ' ')))
    clusters.winnerTop <- as.integer(unlist(strsplit(trimws(final[i, 'hotel_cluster']), ' ')))

    weights <- create.weight.df(clusters.winnerTop)
    weights$weight <- weights$weight
    weights <- rbind(weights, create.weight.df(clusters.last))
    weights <- aggregate(weight ~ num, weights, sum)
    weights <- weights[order(weights$weight, decreasing = T), ]

    final[i, 'hotel_cluster'] <- paste(head(weights$num, 5), collapse = ' ')

    if (i %% 1000 == 0) {
        cat(i, '\n')
    }
}

# final[not_empty_dist[1:1000], 'hotel_cluster'] <- submission[not_empty_dist[1:1000], 'hotel_cluster']

submissionName <- paste0("./results/stupid_only_distance_", format(Sys.time(), "%H_%M_%S"), "_w_avg_wo_trends_1000")
# submissionName <- paste0("./results/ens_", format(Sys.time(), "%H%M%S"))
submissionFile <- paste0(submissionName, ".csv")
write.csv(final, submissionFile, row.names=FALSE, quote = FALSE)



View(data.frame(w = winner.submission_2016.06.03.13.21[not_empty_dist, 'hotel_cluster'],
                p = submission[not_empty_dist, 'hotel_cluster'],
                f = final[not_empty_dist, 'hotel_cluster']))








# ----------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------
only_empty_dist <- which(train.w.clusters.freq$dist_0 == -1)
train.w.clusters.freq <- train.w.clusters.freq[only_empty_dist, ]
slice.last.index <- nrow(train.w.clusters.freq)
gc()
for (cl in 0:99) {
    cat('\n=================================================================================\n')
    cat('Cluster: ', cl, ', ', as.character(Sys.time()), '\n')

    # ----------------------------------------------------------------------------------------------
    feature.names <- c(
        # paste0('sum_', cl),
        paste0('avg_', cl),
        # paste0('dir_', cl),
        paste0('dest_', cl),
        paste0('nigh_', cl),
        paste0('mon_', cl),
        paste0('comp_', cl),
        paste0('coun_', cl))
    feature.names <- c(feature.names,
                       "srch_adults_cnt",
                       "srch_children_cnt",
                       "is_package",
                       "search_nights",
                       "search_weeks_diff")
    feature.formula <- formula(paste('~ ', paste(feature.names, collapse = ' + '), sep = ''))

    # ----------------------------------------------------------------------------------------------
    for (i in 1:3) {
        seed <- cl*10000 + i*10

        set.seed(seed)
        indexes <- sample(seq_len(slice.last.index), floor(slice.last.index*0.7))
        hotel_clusters <- train.w.clusters.freq[1:slice.last.index, 'hotel_cluster']
        train.sliced <- train.w.clusters.freq[1:slice.last.index, feature.names]
        target.labels <- ifelse(hotel_clusters == cl, 1, 0)

        # ----------------------------------------------------------------------------------------------
        dtrain <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train.sliced[indexes, feature.names]),
                              label = target.labels[indexes])
        dvalid <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train.sliced[-indexes, feature.names]),
                              label = target.labels[-indexes])
        watchlist <- list(valid = dvalid, train = dtrain)
        cat("Data created:", as.character(Sys.time()), '\n')

        # ----------------------------------------------------------------------------------------------
        params <- list(booster = "gbtree", objective = "binary:logistic",
                       max_depth = 6, eta = 0.1,
                       colsample_bytree = 0.9, subsample = 0.7)
        set.seed(seed)
        model <- xgb.train(params = params, data = dtrain,
                           nrounds = 101, early.stop.round = 10,
                           eval_metric = 'rmse', maximize = F,
                           watchlist = watchlist, print.every.n = 100)
        cat(" Best score:", model$bestScore, '\n')
        xgb.save(model, paste0('./saved models/17-wo_sum_only_wo_distance-3/', cl, '_', i, '.xgb'))
    }
}
