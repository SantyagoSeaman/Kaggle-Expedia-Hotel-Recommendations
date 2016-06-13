test.w.clusters.freq <- readRDS('./data/test.w.clusters.freq_900var_wo_trends.Rds')

row <- 11
clusters <- c(33, 4, 21, 18, 19, 70) # 11
row <- 13
clusters <- c(0, 31, 96, 91, 77, 50, 59, 48) # 13
row <- 1
clusters <- c(5, 37, 55, 11, 22, 41, 60) # 1

results.final <- c()
for (cl in clusters) {
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
        paste0('dist_', cl))
    feature.names <- c(feature.names,
                       "srch_adults_cnt",
                       "srch_children_cnt",
                       "is_package",
                       "search_nights",
                       "search_weeks_diff")
    feature.formula <- formula(paste('~ ', paste(feature.names, collapse = ' + '), sep = ''))

    results <- c()
    test.sliced <- test.w.clusters.freq[row, feature.names]
    rownames(test.sliced) <- NULL
    print(test.sliced[, 1:min(ncol(test.sliced), 8)])
    dtest <- sparse.model.matrix(feature.formula, data = test.sliced)

    for (i in 1:5) {
        # model <- xgb.load(paste0('./saved models/15-weighted-probs-full-5/', cl, '_', i, '.xgb'))
        model <- xgb.load(paste0('./saved models/16-weighted-probs-wo_sum_avg-5/', cl, '_', i, '.xgb'))
        pred <- predict(model, dtest)
        results <- c(results, list(pred))
        print(pred)
    }
    results <- data.frame(results)

    results.final <- c(results.final, rowMeans(results[1, ]))
}

names(results.final) <- clusters
results.final <- results.final[order(results.final, decreasing = T)]
print(results.final)


clusters <- c(0)
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
View(test.w.clusters.freq[1:1000, feature.names])
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



clusters <- unique(as.integer(unlist(strsplit(trimws(winner.submission_2016.05.30.15.44[1:3, 'hotel_cluster']), ' '))))
clusters <- sort(clusters)
feature.names <- c(
    paste0('sum_', clusters),
    paste0('avg_', clusters),
    paste0('dir_', clusters),
    paste0('dest_', clusters),
    paste0('nigh_', clusters),
    paste0('mon_', clusters),
    # paste0('dist_', clusters),
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
