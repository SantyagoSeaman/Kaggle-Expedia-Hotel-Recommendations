
model <- xgb.load('model_full_6_01_07_08_21.xgb')
model <- xgb.load('model_full_6_01_07_08_51.xgb')


cl <- 0:99
feature.names <- c(
    paste0('sum_', cl),
    paste0('avg_', cl),
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
dtest <- sparse.model.matrix(feature.formula, data = test.w.clusters.freq[1:1000, feature.names])
pred <- predict(model, dtest)

predictions <- as.data.frame(t(matrix(pred, nrow=100)))
colnames(predictions) <- 0:99
predictions_top5.test <- t(apply(predictions, 1, function(x) as.integer(head(names(sort(x, decreasing = T)), 5))))

submission <- data.frame(id = test.w.clusters.freq[1:nrow(predictions_top5.test), 'id'])
submission$hotel_cluster <- apply(predictions_top5.test, 1, function(row){return(paste(row, collapse = ' '))})

