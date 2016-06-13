clusters <- 0:99
feature.names <- c(
    paste0('sum_', clusters),
    paste0('avg_', clusters),
    # paste0('dir_', clusters),
    paste0('dest_', clusters),
    paste0('nigh_', clusters),
    paste0('mon_', clusters),
    paste0('dist_', clusters),
    paste0('coun_', clusters),
    paste0('comp_', clusters))
feature.names <- c(
    paste0('sum_', clusters),
    paste0('avg_', clusters))

feature.formula <- formula(paste('~ ', paste(feature.names, collapse = ' + '), sep = ''))

slice.last.index <- 50000
slice <- train.w.clusters.freq[1:slice.last.index, c('hotel_cluster', feature.names)]
slice$hotel_cluster <- factor(slice$hotel_cluster)
set.seed(100)
indexes <- sample(seq_len(slice.last.index), floor(slice.last.index*0.7))
hotel_clusters <- slice[1:slice.last.index, 'hotel_cluster']
train.sliced <- slice[1:slice.last.index, feature.names]

# ----------------------------------------------------------------------------------------------
dtrain <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train.sliced[indexes, feature.names]),
                      label = hotel_clusters[indexes])
dvalid <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train.sliced[-indexes, feature.names]),
                      label = hotel_clusters[-indexes])
watchlist <- list(valid = dvalid, train = dtrain)
cat("Data created:", as.character(Sys.time()), '\n')

# ----------------------------------------------------------------------------------------------
params <- list(booster = "gblinear", objective = "multi:softprob")
model <- xgb.train(params = params, data = dtrain, num_class = 101,
                   nrounds = 101, early.stop.round = 5,
                   eval_metric = 'mlogloss', maximize = F,
                   watchlist = watchlist, print.every.n = 1)

dtest <- sparse.model.matrix(feature.formula, data = train.sliced[-indexes, feature.names])
pred <- predict(model, dtest)
predictions <- as.data.frame(t(matrix(pred, nrow=101)))
predictions <- predictions[, -1]
colnames(predictions) <- 0:99
predictions_top5 <- t(apply(predictions, 1, function(x) as.integer(head(names(sort(x, decreasing = T)), 5))))
labels.int <- as.integer(as.character(hotel_clusters[-indexes]))
predictions_top5 <- cbind(predictions_top5, labels.int)
mapk(5, labels.int, predictions_top5)



dtest <- sparse.model.matrix(feature.formula, data = test.w.clusters.freq[1:1000, feature.names])
pred <- predict(model, dtest)
predictions <- as.data.frame(t(matrix(pred, nrow=101)))
predictions <- predictions[, -1]
colnames(predictions) <- 0:99
predictions_top5.test <- t(apply(predictions, 1, function(x) as.integer(head(names(sort(x, decreasing = T)), 5))))


