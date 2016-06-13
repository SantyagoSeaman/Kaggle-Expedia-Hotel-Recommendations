library(xgboost)
library(Matrix)
library(Metrics)
library(caret)
options(scipen=999)

clusters <- unique(train.w.clusters.freq[1:10, 'hotel_cluster'])
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
View(train.w.clusters.freq[1:10, c('hotel_cluster', feature.names)])

# ----------------------------------------------------------------------------------------------
slice.last.index <- 3000000
results.test <- c()
set.seed(10)
indexes <- sample(seq_len(slice.last.index), floor(slice.last.index*0.7))
hotel_clusters <- train.w.clusters.freq[1:slice.last.index, 'hotel_cluster']
for (cl in clusters) {
    cat('\n=================================================================================\n')
    cat('Cluster: ', cl, '\n')

    # ----------------------------------------------------------------------------------------------
    feature.names <- c(
        paste0('sum_', cl),
        # paste0('avg_', cl),
        # paste0('dir_', cl),
        paste0('dest_', cl),
        paste0('nigh_', cl),
        paste0('mon_', cl),
        paste0('comp_', cl),
        paste0('coun_', cl),
        paste0('dist_', cl))
    feature.names <- c(feature.names,
                       "srch_adults_cnt",
                       "srch_children_cnt",
                       "is_package",
                       "search_nights",
                       "search_weeks_diff")
    feature.formula <- formula(paste('~ ', paste(feature.names, collapse = ' + '), sep = ''))

    # ----------------------------------------------------------------------------------------------
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
                   max_depth = 6, eta = 0.05,
                   colsample_bytree = 0.9, subsample = 0.7)
    set.seed(100)
    model <- xgb.train(params = params, data = dtrain,
                       nrounds = 151, early.stop.round = 10,
                       eval_metric = 'rmse', maximize = F,
                       watchlist = watchlist, print.every.n = 10)

    # ----------------------------------------------------------------------------------------------
#     sparsed.feature.names <- colnames(sparse.model.matrix(feature.formula, data = train.sliced[1:10, feature.names]))
#     imp <- xgb.importance(model = model, feature_names = sparsed.feature.names)

    # ----------------------------------------------------------------------------------------------
    dtest <- sparse.model.matrix(feature.formula, data = train.w.clusters.freq[1:10, feature.names])
    pred <- predict(model, dtest)
    results.test <- c(results.test, list(pred))
}


cluster_names <- c(paste('cluster_', clusters, sep = ''))
results_df.test <- data.frame(results.test)
colnames(results_df.test) <- cluster_names

predictions_top5.test <- t(apply(results_df.test, 1, function(row) {
    ind <- clusters[order(unlist(row), decreasing = T)]
    return(head(ind, 5))
}))

