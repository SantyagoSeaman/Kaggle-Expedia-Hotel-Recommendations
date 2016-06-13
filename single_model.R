library(xgboost)
library(Matrix)
library(Metrics)
library(caret)
options(scipen=999)

train.w.clusters.freq <- readRDS('./data/3M_train.w.clusters.freq_1000var_maximize_booking_trends.Rds')
test.w.clusters.freq <- readRDS('./data/test.w.clusters.freq_1000var_maximize_booking_trends.Rds')


clusters <- 0:99
feature.names <- c(
  paste0('sum_', clusters),
  paste0('avg_', clusters),
  paste0('dir_', clusters),
  paste0('dest_', clusters),
  paste0('nigh_', clusters),
  paste0('mon_', clusters),
  paste0('dist_', clusters),
  paste0('comp_', clusters),
  paste0('simp_', clusters),
  paste0('coun_', clusters))
feature.names <- c(
  paste0('sum_', clusters),
  paste0('avg_', clusters))

feature.formula <- formula(paste('~ ', paste(feature.names, collapse = ' + '), sep = ''))


# train.w.clusters.freq <- train.w.clusters.freq[train.w.clusters.freq$is_booking == 1, ]

slice.last.index <- nrow(train.w.clusters.freq)
slice <- train.w.clusters.freq[1:slice.last.index, c('hotel_cluster', feature.names)]
slice$hotel_cluster <- factor(slice$hotel_cluster)
set.seed(100)
indexes <- sample(seq_len(slice.last.index), floor(slice.last.index*0.7))
hotel_clusters <- slice[1:slice.last.index, 'hotel_cluster']
train.sliced <- slice[1:slice.last.index, feature.names]

rm(train.w.clusters.freq, slice)
gc()

# ----------------------------------------------------------------------------------------------
dtrain <- xgb.DMatrix(as.matrix(train.sliced[indexes, feature.names]),
                      label = hotel_clusters[indexes])
dvalid <- xgb.DMatrix(as.matrix(train.sliced[-indexes, feature.names]),
                      label = hotel_clusters[-indexes])
watchlist <- list(valid = dvalid, train = dtrain)
cat("Data created:", as.character(Sys.time()), '\n')

# ----------------------------------------------------------------------------------------------
params <- list(booster = "gbtree", objective = "multi:softprob",
               max_depth = 7, eta = 0.1,
               colsample_bytree = 0.5, subsample = 0.7)
model <- xgb.train(params = params, data = dtrain, num_class = 101,
                   nrounds = 11, early.stop.round = 5,
                   eval_metric = 'merror', maximize = F,
                   watchlist = watchlist, print.every.n = 1)
# xgb.dump(model, 'model_single.txt')
# sparsed.feature.names <- colnames(sparse.model.matrix(feature.formula, data = train.sliced[1:10, feature.names]))
# imp <- xgb.importance(model = model, feature_names = sparsed.feature.names)

dtest <- sparse.model.matrix(feature.formula, data = train.sliced[-indexes, feature.names])
pred <- predict(model, dtest)
predictions <- as.data.frame(t(matrix(pred, nrow=101)))
predictions <- predictions[, -1]
colnames(predictions) <- 0:99
predictions_top5 <- t(apply(predictions, 1, function(x) as.integer(head(names(sort(x, decreasing = T)), 5))))
labels.int <- as.integer(as.character(hotel_clusters[-indexes]))
predictions_top5 <- cbind(predictions_top5, labels.int)
mapk(5, labels.int, predictions_top5)


model <- xgb.load('model_single.xgb')


dtest <- sparse.model.matrix(feature.formula, data = test.w.clusters.freq[1:1000, feature.names])
pred <- predict(model, dtest)
predictions <- as.data.frame(t(matrix(pred, nrow=101)))
predictions <- predictions[, -1]
colnames(predictions) <- 0:99
predictions_top5.test <- t(apply(predictions, 1, function(x) as.integer(head(names(sort(x, decreasing = T)), 5))))


