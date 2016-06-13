library(xgboost)
library(Matrix)
library(Metrics)
library(caret)
options(scipen=999)

xgb_grid = expand.grid(
    max_depth = c(10, 15),
    eta = c(0.1, 0.05),
    colsample_bytree = c(0.5, 0.7),
    subsample = c(0.8, 0.9)
)

for (i in 1:nrow(xgb_grid)) {
    for (cl in c(0, 1, 91)) {
        calculated_clusters <- c(paste0('dir_', cl),
                                 paste0('dest_', cl),
                                 paste0('dist_', cl),
                                 paste0('hot_', cl),
                                 paste0('mon_', cl))
        feature.names <- c(calculated_clusters,
                           "is_mobile", "channel", "srch_adults_cnt", "srch_children_cnt", "srch_rm_cnt",
                           "user_location_country", "user_location_region", "is_package", "hotel_country",
                           # "user_location_city_top", "srch_destination_id_top",
                           "srch_destination_type_id", "hotel_market",
                           "search_nights", "search_month", "search_weeks_diff",
                           "srch_adults_children_cnt", "srch_adults_children_flag")

        train.sliced <- train.w.clusters.freq[, c('hotel_cluster', feature.names)]
        train.sliced$TARGET <- ifelse(train.sliced$hotel_cluster == cl, 1, 0)
        train.sliced$pred_sum <- rowSums(train.sliced[, calculated_clusters])
        feature.names <- c(feature.names, 'pred_sum')

        feature.formula <- formula(paste('TARGET ~ ', paste(feature.names, collapse = ' + '), sep = ''))
        dfull <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train.sliced),
                              label = train.sliced$TARGET)


        grid.params <- xgb_grid[i, ]
        print(grid.params)

        xgb_params <- list(booster = "gbtree", objective = "binary:logistic",
                           eval_metric = "rmse", maximize = F,
                           max_depth = grid.params$max_depth,
                           eta = grid.params$eta,
                           colsample_bytree = grid.params$colsample_bytree,
                           subsample = grid.params$subsample)
        seed.number <- 1000000 + i*1000 + cl
        set.seed(seed.number)
        xgb_cv = xgb.cv(params = xgb_params,
                        data = dfull,
                        nrounds = 2001,
                        nfold = 5,
                        prediction = F,
                        showsd = F,
                        stratified = F,
                        verbose = T,
                        print.every.n = 50,
                        early.stop.round = 10
        )

        max.rmse <- max(xgb_cv$test.rmse.mean)
        max.rmse.index <- which.max(xgb_cv$test.rmse.mean)

        xgb_grid[i, paste0('rmse_', cl)] <- max.rmse
        xgb_grid[i, paste0('rmse_index_', cl)] <- max.rmse.index
    }
}

