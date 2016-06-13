library(xgboost)
library(Matrix)
library(Metrics)
library(caret)
options(scipen=999)

# factor2int <- function(value) {
#     return (as.integer(as.character(value)))
# }
#
# train.w.clusters.freq <- readRDS('./data/3M_train.w.clusters.freq.Rds')
# test.w.clusters.freq <- readRDS('./data/test.w.clusters.freq.Rds')
#
#
# train.w.clusters.freq <- readRDS('./data/3M_train.w.clusters.freq_zeroed_pred_sum.Rds')
# test.w.clusters.freq <- readRDS('./data/test.w.clusters.freq_pred_sum.Rds')
#
#
# train.w.clusters.freq <- readRDS('./data/3M_random_train.w.clusters.freq_zeroed_pred_sum.Rds')
# test.w.clusters.freq <- readRDS('./data/test.w.clusters.freq_pred_sum.Rds')

# train.w.clusters.freq <- readRDS('./data/3M_train.w.clusters.freq_900var.Rds')
# test.w.clusters.freq <- readRDS('./data/test.w.clusters.freq_900var.Rds')

# train.w.clusters.freq <- readRDS('./data/3M_train.w.clusters.freq_900var_wo_trends_booking.Rds')
# test.w.clusters.freq <- readRDS('./data/test.w.clusters.freq_900var_wo_trends_booking.Rds')

train.w.clusters.freq <- readRDS('./data/3M_train.w.clusters.freq_900var_booking_trends.Rds')
test.w.clusters.freq <- readRDS('./data/test.w.clusters.freq_900var_booking_trends.Rds')



train.w.clusters.freq <- train.w.clusters.freq[train.w.clusters.freq$is_booking == 1, ]

train.w.clusters.freq <- train.w.clusters.freq[1:1000000, ]


# ----------------------------------------------------------------------------------------------
slice.last.index <- nrow(train.w.clusters.freq)
results.valid <- c()
results.test <- c()
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
    # View(train.w.clusters.freq[1:1000, c('hotel_cluster', feature.names)])

    # ----------------------------------------------------------------------------------------------
    for (i in 1:2) {
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
                           eval_metric = 'logloss', maximize = F,
                           watchlist = watchlist, print.every.n = 20)

        xgb.save(model, paste0('./saved models/20-is_booking_trends/', cl, '_', i, '.xgb'))
        # xgb.dump(model, 'model.txt')
        #     sparsed.feature.names <- colnames(sparse.model.matrix(feature.formula, data = train.sliced[1:10, feature.names]))
        #     imp <- xgb.importance(model = model, feature_names = sparsed.feature.names)
        cat(" Best score:", model$bestScore, '\n')
    }
}
