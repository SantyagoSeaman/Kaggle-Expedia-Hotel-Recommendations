library(xgboost)
library(Matrix)
library(Metrics)
library(caret)
options(scipen=999)

train.w.clusters.freq <- readRDS('./data/3M_train.w.clusters.freq_900var_booking_trends.Rds')
test.w.clusters.freq <- readRDS('./data/test.w.clusters.freq_900var_booking_trends.Rds')


slice.last.index <- 3000000
results.valid <- c()
results.test <- c()
set.seed(10)
indexes <- sample(seq_len(slice.last.index), floor(slice.last.index*0.7))
for (cl in 0:99) {
    cat('\n=================================================================================\n')
    cat('Cluster: ', cl, ', started: ', as.character(Sys.time()), '\n')

    model <- xgb.load(paste0('./saved models/20-is_booking_trends/', cl, '.xgb'))

    feature.names <- c(
        # paste0('sum_', cl),
        paste0('avg_', cl),
        # paste0('dir_', cl),
        paste0('dest_', cl),
        paste0('nigh_', cl),
        paste0('mon_', cl),
        paste0('comp_', cl),
        paste0('coun_', cl),
        paste0('simp_', cl),
        paste0('dist_', cl))
#     feature.names <- c(feature.names,
#                        # "is_mobile",
#                        # "channel",
#                        "srch_adults_cnt", "srch_children_cnt",
#                        # "srch_rm_cnt",
#                        "user_location_country",
#                        # "user_location_region",
#                        "is_package",
#                        # "hotel_country",
#                        # "hotel_market",
#                        # "user_location_city_top", "srch_destination_id_top",
#                        "srch_destination_type_id",
#                        "search_nights", "search_month", "search_weeks_diff",
#                        "srch_adults_children_cnt",
#                        "srch_adults_children_flag")
    feature.names <- c(feature.names,
                       "srch_adults_cnt",
                       "srch_children_cnt",
                       "is_package",
                       "search_nights",
                       "search_weeks_diff")
    feature.formula <- formula(paste('~ ', paste(feature.names, collapse = ' + '), sep = ''))

    dvalid <- sparse.model.matrix(feature.formula, data = train.w.clusters.freq[-indexes, feature.names])
    pred <- predict(model, dvalid)
    results.valid <- c(results.valid, list(pred))

    dtest <- sparse.model.matrix(feature.formula, data = test.w.clusters.freq[, feature.names])
    pred <- predict(model, dtest)
    results.test <- c(results.test, list(pred))
}


# ----------------------------------------------------------------------------------------------
cluster_names <- c(paste('cluster_', 0:99, sep = ''))
results_df.valid <- data.frame(results.valid)
colnames(results_df.valid) <- cluster_names

valid.hotel_cluster <- train.w.clusters.freq[1:slice.last.index, 'hotel_cluster']
valid.hotel_cluster <- valid.hotel_cluster[-indexes]
results_df.valid$hotel_cluster <- valid.hotel_cluster
results_df.valid <- results_df.valid[, c('hotel_cluster', cluster_names)]

predictions_top5.valid <- t(apply(results_df.valid, 1, function(row) {
    ind <- order(unlist(row[-1]), decreasing = T) - 1
    return(head(ind, 5))
}))
# zzz$hotel_cluster <- train.sliced[-indexes, 'hotel_cluster']
mapk(5, as.integer(valid.hotel_cluster), predictions_top5.valid)



# ----------------------------------------------------------------------------------------------
cluster_names <- c(paste('cluster_', 0:99, sep = ''))
results_df.test <- data.frame(results.test)
colnames(results_df.test) <- cluster_names

predictions_top5.test.small <- t(apply(results_df.test[1:100, ], 1, function(row) {
    # print(row[order(unlist(row), decreasing = T)])
    ind <- order(unlist(row), decreasing = T) - 1
    return(head(ind, 5))
}))

predictions_top5.test <- t(apply(results_df.test, 1, function(row) {
    ind <- order(unlist(row), decreasing = T) - 1
    return(head(ind, 5))
}))

submission <- data.frame(id = test.w.clusters.freq$id)
submission$hotel_cluster <- apply(predictions_top5.test, 1, function(row){return(paste(row, collapse = ' '))})
submissionName <- paste0("./results/xgboost_", format(Sys.time(), "%H_%M_%S"))
submissionFile <- paste0(submissionName, ".csv")
write.csv(submission, submissionFile, row.names=FALSE, quote = FALSE)


# zzz <- test.w.clusters.freq[1:100, ]
# zzz$predicted_clusters <- predictions_top5.test.small
# zzz$predicted_winners <- winner_submission_2016.05.17.09.18[1:100, 'hotel_cluster']
#
# write.csv(zzz, 'zzz.csv')
