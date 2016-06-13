
train.w.clusters.freq <- train.w.clusters.freq[train.w.clusters.freq$is_booking == 1, ]


slice.last.index <- nrow(train.w.clusters.freq)
hotel_clusters <- train.w.clusters.freq[1:slice.last.index, 'hotel_cluster']
gc()

row <- 11
clusters <- c(33, 4, 21, 18, 19, 70) # 11
row <- 13
clusters <- c(0, 31, 96, 91, 77, 50, 59, 48) # 13
row <- 1
clusters <- c(5, 41, 37, 55, 11, 22, 60, 9, 8) # 1

results <- c()
for (cl in clusters) {
    seed <- 10

    cat('\n=================================================================================\n')
    cat('Cluster: ', cl, '\n')

    # ----------------------------------------------------------------------------------------------
    feature.names <- c(
        # paste0('sum_', cl),
        # paste0('avg_', cl),
        # paste0('dir_', cl),
        paste0('dest_', cl),
        paste0('nigh_', cl),
        paste0('mon_', cl),
        paste0('comp_', cl),
        paste0('coun_', cl),
        paste0('simp_', cl),
        paste0('dist_', cl))
#     feature.names <- c(feature.names,
#                        "srch_adults_cnt",
#                        "srch_children_cnt",
#                        "is_package",
#                        "search_nights",
#                        "search_weeks_diff")
    feature.formula <- formula(paste('~ ', paste(feature.names, collapse = ' + '), sep = ''))
#     View(train.w.clusters.freq[train.w.clusters.freq$hotel_cluster == cl, c('hotel_cluster', feature.names)])
#     View(train.w.clusters.freq[train.w.clusters.freq$hotel_cluster == cl, 1:70])

    # ----------------------------------------------------------------------------------------------
    train.sliced <- train.w.clusters.freq[1:slice.last.index, feature.names]
    target.labels <- ifelse(hotel_clusters == cl, 1, 0)

    # ----------------------------------------------------------------------------------------------
    set.seed(seed)
    indexes <- sample(seq_len(slice.last.index), floor(slice.last.index*0.7))
    dtrain <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train.sliced[indexes, feature.names]),
                          label = target.labels[indexes])
    dvalid <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train.sliced[-indexes, feature.names]),
                          label = target.labels[-indexes])
    watchlist <- list(valid = dvalid, train = dtrain)

    # ----------------------------------------------------------------------------------------------
#     params <- list(booster = "gbtree", objective = "binary:logistic",
#                    max_depth = 10, eta = 0.05,
#                    colsample_bytree = 0.8, subsample = 0.5)
    params <- list(booster = "gbtree", objective = "binary:logistic",
                   max_depth = 6, eta = 0.1,
                   colsample_bytree = 0.9, subsample = 0.7)
    set.seed(seed)
    model <- xgb.train(params = params, data = dtrain,
                       nrounds = 101, early.stop.round = 10,
                       eval_metric = 'rmse', maximize = F,
                       watchlist = watchlist,
                       verbose = 0, print.every.n = 10)
    sparsed.feature.names <- colnames(sparse.model.matrix(feature.formula, data = train.sliced[1, ]))
    imp <- xgb.importance(model = model, feature_names = sparsed.feature.names)

    # ----------------------------------------------------------------------------------------------
    test.sliced <- test.w.clusters.freq[row, feature.names]
    rownames(test.sliced) <- NULL
    print(test.sliced[, 1:min(ncol(test.sliced), 10)])
    dtest <- sparse.model.matrix(feature.formula, data = test.sliced)
    pred <- predict(model, dtest)
    results <- c(results, pred)
    print(pred)
}

print(results)


clusters <- c(5, 41)
feature.names <- c(
    paste0('sum_', clusters),
    paste0('avg_', clusters),
    paste0('dir_', clusters),
    paste0('dest_', clusters),
    paste0('nigh_', clusters),
    paste0('mon_', clusters),
    paste0('dist_', clusters),
    paste0('coun_', clusters),
    paste0('comp_', clusters))
View(test.w.clusters.freq[1:100, feature.names])
View(train.w.clusters.freq[1:100, feature.names])
View(test.w.clusters.freq[1:100, 1:30])


clusters <- unique(train.w.clusters.freq[1:5, 'hotel_cluster'])
clusters <- sort(clusters)
feature.names <- c(
    paste0('sum_', clusters),
    paste0('avg_', clusters),
    paste0('dir_', clusters),
    paste0('dest_', clusters),
    paste0('nigh_', clusters),
    paste0('mon_', clusters),
    paste0('dist_', clusters),
    paste0('coun_', clusters),
    paste0('comp_', clusters))
View(train.w.clusters.freq[1:5, c('hotel_cluster', feature.names)])


clusters <- unique(unlist(strsplit(trimws(winner.submission_2016.06.03.08.08[1:3, 'hotel_cluster']), ' ')))
clusters <- sort(clusters)
feature.names <- c(
    paste0('sum_', clusters),
    paste0('avg_', clusters),
    paste0('dir_', clusters),
    paste0('dest_', clusters),
    paste0('nigh_', clusters),
    paste0('mon_', clusters),
    paste0('dist_', clusters),
    paste0('coun_', clusters),
    paste0('comp_', clusters))
View(test.w.clusters.freq[1:3, feature.names])


clusters <- c(0, 1, 10, 11)
feature.names <- c(
    paste0('sum_', clusters),
    paste0('avg_', clusters),
    paste0('dir_', clusters),
    paste0('dest_', clusters),
    paste0('nigh_', clusters),
    paste0('mon_', clusters),
    paste0('dist_', clusters),
    paste0('coun_', clusters),
    paste0('comp_', clusters))
View(train.w.clusters.freq[1:20, c('hotel_cluster', feature.names)])



clusters <- c(91, 96)
feature.names <- c(
    paste0('sum_', clusters),
    paste0('avg_', clusters),
    paste0('dir_', clusters),
    paste0('dest_', clusters),
    paste0('nigh_', clusters),
    paste0('mon_', clusters),
    paste0('dist_', clusters),
    paste0('coun_', clusters),
    paste0('comp_', clusters))
View(test.w.clusters.freq[1:100, feature.names])
