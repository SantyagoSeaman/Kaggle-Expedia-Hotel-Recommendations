# OLD version of intersection
# Saved only for history

factor2int <- function(value) {
    return (as.integer(as.character(value)))
}


# -----------------------------------------
train.w.clusters.freq <- train
cnames <- c(paste('clust_freq_', 0:99, sep = ''))

for(i in 0:99) {
    train.w.clusters.freq[paste0('clust_freq_', i)] <- as.numeric(0)
}


slice.size <- 1000
freq_df <- data.frame(cluster = 0)
for(i in 0:99) {
    freq_df[1:slice.size, paste0('clust_freq_', i)] <- rep(as.numeric(0), slice.size)
}
freq_df$cluster <- NULL

for (j in 100:1000) {
    freq_df[,] <- as.numeric(0)

    for(i in 1:slice.size) {
        row <- train.w.clusters.freq[j*slice.size + i, ]
        stat <- train_data_searches_stat[train_data_searches_stat$user_location_country == factor2int(row$user_location_country) &
                                             train_data_searches_stat$hotel_country == factor2int(row$hotel_country) &
                                             train_data_searches_stat$is_package == row$is_package &
                                             train_data_searches_stat$srch_adults_children_flag == as.integer(row$srch_adults_children_flag), ]
        upd <- apply(stat[, c('hotel_cluster', 'search_freq')], 1, function(s) {
            return(c(paste0('clust_freq_', s['hotel_cluster']), s['search_freq']))
        })
        freq_df[i, upd[1, ]] <- as.numeric(upd[2, ])
    }

    train.w.clusters.freq[(j*slice.size + 1):((j+1)*slice.size), cnames] <- freq_df[1:i, cnames]

    cat(as.character(Sys.time()), '-', (j+1)*slice.size, '\n')
}

slice.last.index <- (j*slice.size + 1)

# -----------------------------------------
View(train.w.clusters.freq[1:20, c('user_id', 'hotel_cluster', paste('clust_freq_', 0:99, sep = ''))])


zzz <- unlist(train.w.clusters.freq[13, c(paste('clust_freq_', 0:99, sep = ''))])
names(zzz) <- 0:99
barplot(zzz, cex.axis=0.75, cex.names=0.5, las = 2)


zzz <- table(train[train$user_location_country == 66 & train$hotel_country == 50 & train$user_location_region == 318 &
                       train$search_month == 4 &
                       train$srch_adults_children_flag == 'adults only', 'hotel_cluster'])
View(zzz)


# -----------------------------------------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------------------------------
feature.names <- c(cnames, dnames)
feature.names <- c(feature.names, "is_mobile", "channel", "srch_adults_cnt", "srch_children_cnt", "srch_rm_cnt",
                   "srch_destination_type_id", "hotel_market", "search_nights", "search_month", "search_weeks_diff",
                   "srch_adults_children_cnt", "srch_adults_children_flag")
feature.formula <- formula(paste('hotel_cluster ~ ', paste(feature.names, collapse = ' + '), sep = ''))

nclass = length(levels(train$hotel_cluster))
train.sliced <- train.w.clusters.freq[1:slice.last.index, ]

set.seed(10)
indexes <- sample(seq_len(nrow(train.sliced)), floor(nrow(train.sliced)*0.7))
dtrain <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train.sliced[indexes, ]),
                      label = train.sliced[indexes, 'hotel_cluster'])
dvalid <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train.sliced[-indexes, ]),
                      label = train.sliced[-indexes, 'hotel_cluster'])
watchlist <- list(valid = dvalid, train = dtrain)
print(paste0("Data created: ", Sys.time()))

params <- list(booster = "gbtree", objective = "multi:softprob",
             max_depth = 10, eta = 0.1,
             colsample_bytree = 0.8, subsample = 0.9)
set.seed(10)
model <- xgb.train(params = params, data = dtrain,
                   nrounds = 500, early.stop.round = 10,
                   eval_metric = 'merror', maximize = F,
                   # eval_metric = 'mlogloss', maximize = F,
                   # eval_metric = 'map@5', maximize = T,
                   watchlist = watchlist, print.every.n = 1,
                   num_class = nclass+1)

pred <- predict(model, dvalid)
predictions <- as.data.frame(t(matrix(pred, nrow = nclass+1)))
predictions <- predictions[, -1]
colnames(predictions) <- levels(train.sliced$hotel_cluster)
predictions_top5 <- t(apply(predictions, 1, function(x) names(sort(x, decreasing = T)[1:5])))
predictions_top5 <- cbind(predictions_top5, as.character(train.sliced[-indexes, 'hotel_cluster']))
mapk(5, as.integer(as.character(train.sliced[-indexes, 'hotel_cluster'])), predictions_top5)

