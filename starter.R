library(xgboost)
library(Matrix)
library(Metrics)
library(caret)
library(MASS)
options(scipen=999)

input.path <- './input/'
# ---------------------------------------------------
# Load
con <- gzfile(paste0(input.path, 'test.csv.gz'), 'r')
orig.test <- read.csv(con, stringsAsFactors = F)

con <- gzfile(paste0(input.path, 'train.csv.gz'), 'r')
# orig.train <- read.csv(con, stringsAsFactors = F, nrows = 20)
orig.train <- read.csv(con, stringsAsFactors = F)

# orig.train.1 <- read.csv(con, stringsAsFactors = F, nrows = 10)
# feature.names <- c(names(orig.train.1), 'id')
# names(orig.train) <- feature.names

con <- gzfile(paste0(input.path, 'destinations.csv.gz'), 'r')
orig.destinations <- read.csv(con, stringsAsFactors = F)


# orig.test_user_id <- orig.test$user_id
# orig.train_user_id <- orig.train$user_id
# common.users <- intersect(orig.test_user_id, orig.train_user_id)
#
# View(orig.test[orig.test$user_id %in% common.users, ])
# View(orig.train[orig.train$user_id %in% common.users, ])


# ---------------------------------------------------
# Merge
orig.test$hotel_cluster <- -1
orig.test$is_booking <- 1
orig.test$posa_continent <- NULL
orig.train$id <- -1
orig.train$cnt <- NULL
orig.train$posa_continent <- NULL

feature.names <- names(orig.train)
merged <- rbind(orig.train[, feature.names], orig.test[, feature.names])
merged[is.na(merged)] <- 0

# ---------------------------------------------------
# Convert
feature.names <- names(merged)

merged$date_time <- as.Date(merged$date_time)
merged$srch_ci <- as.Date(merged$srch_ci)
merged$srch_co <- as.Date(merged$srch_co)
merged$search_nights <- as.integer(merged$srch_co - merged$srch_ci)
merged[is.na(merged$search_nights), 'search_nights'] <- 0
merged$search_month <- as.integer(format(merged$srch_ci, '%m'))
merged[is.na(merged$search_month), 'search_month'] <- 0
merged$search_month <- factor(merged$search_month)
merged$search_weeks_diff <- floor(as.numeric(merged$srch_ci - merged$date_time, units="weeks"))
merged[is.na(merged$search_weeks_diff), 'search_weeks_diff'] <- 0

merged$site_name <- factor(merged$site_name)
merged$user_location_country <- factor(merged$user_location_country)
merged$user_location_region <- factor(merged$user_location_region)
merged$channel <- factor(merged$channel)
merged$srch_destination_type_id <- factor(merged$srch_destination_type_id)
merged$hotel_continent <- factor(merged$hotel_continent)
merged$hotel_country <- factor(merged$hotel_country)
merged$hotel_market <- factor(merged$hotel_market)
# merged$hotel_cluster <- factor(merged$hotel_cluster)


# disp <- table(merged$user_location_city)
# disp <- disp[order(disp, decreasing = T)]
# disp_top <- as.integer(names(head(disp, 1000)))
# merged$user_location_city_top <- ifelse(merged$user_location_city %in% disp_top,
#                                         merged$user_location_city, -1)
# merged$user_location_city_top <- factor(merged$user_location_city_top)
# disp <- table(merged$srch_destination_id)
# disp <- disp[order(disp, decreasing = T)]
# disp_top <- as.integer(names(head(disp, 1000)))
# merged$srch_destination_id_top <- ifelse(merged$srch_destination_id %in% disp_top,
#                                         merged$srch_destination_id, -1)
# merged$srch_destination_id_top <- factor(merged$srch_destination_id_top)

# zzz <- intersect(train$user_id, test$user_id)
# train[train$user_id == 12, ]
# test[test$user_id == 12, ]

merged$srch_adults_children_cnt <- paste(merged$srch_adults_cnt, merged$srch_children_cnt, sep = '+')
merged$srch_adults_children_cnt <- factor(merged$srch_adults_children_cnt)

merged$srch_adults_children_flag <- factor(apply(merged[, c('srch_adults_cnt', 'srch_children_cnt')], 1, function(row) {
    if (row['srch_adults_cnt'] == 1 & row['srch_children_cnt'] == 0) {
        return ('single adult')
    }
#     if (row['srch_children_cnt'] == 1 & row['srch_adults_cnt'] == 0) {
#         return ('single child')
#     }
    if (row['srch_adults_cnt'] > 0) {
        if (row['srch_children_cnt'] > 0) {
            return('adults and children')
        } else {
            return('adults')
        }
#     } else {
#         if (row['srch_children_cnt'] > 0) {
#             return('children')
#         }
    }
    return('unknown')
}))

# merged$user_hotel_country_pair <- paste(merged$user_location_country, merged$hotel_country, sep = '-')
# merged$user_hotel_country_pair <- factor(merged$user_hotel_country_pair)

# ---------------------------------------------------
# Split
train <- merged[merged$hotel_cluster != -1, ]
test <- merged[merged$hotel_cluster == -1, ]


saveRDS(train, './data/full_train_37M.Rds')
saveRDS(test, './data/full_test_2M.Rds')

# ---------------------------------------------------
# Cleanup
rm(orig.train)
rm(orig.test)
rm(merged)
gc()


# ---------------------------------------------------
# Features
feature.names <- names(train)
feature.names <- feature.names[-match(c('id', 'date_time', 'hotel_cluster', 'srch_ci', 'srch_co', 'is_booking', 'cnt', 'user_id'), feature.names)]
feature.names <- feature.names[-match(c('user_location_city', 'srch_destination_id'), feature.names)]
feature.names <- feature.names[-match(c('orig_destination_distance', 'hotel_continent'), feature.names)]
feature.names <- feature.names[-match(c('site_name', 'posa_continent'), feature.names)]
feature.names <- feature.names[-match(c('user_location_country', 'hotel_country', 'search_weeks_diff'), feature.names)]
feature.names <- feature.names[-match(c('srch_adults_cnt', 'srch_children_cnt'), feature.names)]
feature.formula <- formula(paste('hotel_cluster ~ ', paste(feature.names, collapse = ' + '), sep = ''))


# ---------------------------------------------------
# XGBOOST
dfull <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train[, c(feature.names, 'hotel_cluster')]), label = train$hotel_cluster)
dtest <- sparse.model.matrix(feature.formula, data = test[, c(feature.names, 'hotel_cluster')])
sparsed.feature.names <- colnames(dtest)


i = 1
results <- list()
nclass = length(levels(train$hotel_cluster))
for (i in 1:1000) {
    print(i)
    print(paste0("Started: ", Sys.time()))

    set.seed(10 + i)
    indexes <- sample(seq_len(nrow(train)), floor(nrow(train)*0.8))
    dtrain <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train[indexes, ]),
                          label = train[indexes, 'hotel_cluster'])
    dvalid <- xgb.DMatrix(sparse.model.matrix(feature.formula, data = train[-indexes, ]),
                          label = train[-indexes, 'hotel_cluster'])
    watchlist <- list(valid = dvalid, train = dtrain)
    print(paste0("Data created: ", Sys.time()))

    rand.max.depth <- round(runif(1, 4, 8), 0)
    rand.eta <- round(runif(1, 0.01, 0.1), 3)
    print(paste0("Max depth: ", rand.max.depth, ', eta: ', rand.eta))

    params <- list(booster = "gbtree", objective = "multi:softprob",
                   max_depth = rand.max.depth, eta = rand.eta,
                   colsample_bytree = 0.3, subsample = 0.7)
    #   params <- list(booster = "gbtree", objective = "multi:softprob",
    #                  max_depth = 8, eta = 0.05,
    #                  colsample_bytree = 0.3, subsample = 0.7)
    set.seed(10 + i)
    model <- xgb.train(params = params, data = dtrain,
                       nrounds = 20, early.stop.round = 20,
                       eval_metric = 'merror', maximize = F,
                       # eval_metric = 'mlogloss', maximize = F,
                       # eval_metric = 'map@5', maximize = T,
                       watchlist = watchlist, print.every.n = 1,
                       num_class = nclass+1)
    print(paste0("Model created: ", Sys.time()))
    # imp <- xgb.importance(sparsed.feature.names, model = model)
    xgb.dump(model, 'model.txt')


    pred <- predict(model, dvalid)
    predictions <- as.data.frame(t(matrix(pred, nrow = nclass+1)))
    predictions <- predictions[, -1]
    colnames(predictions) <- levels(train$hotel_cluster)
    predictions_top5 <- t(apply(predictions, 1, function(x) names(sort(x, decreasing = T)[1:5])))
    predictions_top5 <- cbind(predictions_top5, as.character(train[-indexes, 'hotel_cluster']))
    mapk(5, as.integer(as.character(train[-indexes, 'hotel_cluster'])), predictions_top5)


    pred <- predict(model, dtest)
    predictions <- as.data.frame(t(matrix(pred, nrow=nclass+1)))
    predictions <- predictions[, -1]
    colnames(predictions) <- levels(train$hotel_cluster)
    predictions_top5 <- t(apply(predictions, 1, function(x) names(sort(x, decreasing = T)[1:5])))


    submission <- data.frame(id = test$id)
    submission$hotel_cluster <- apply(predictions_top5, 1, function(row){return(paste(row, collapse = ' '))})
    submissionName <- paste0("./results/xgboost_", format(Sys.time(), "%H_%M_%S", model$bestScore, model$bestInd))
    submissionFile <- paste0(submissionName, ".csv")
    write.csv(submission, submissionFile, row.names=FALSE, quote = FALSE)

    print(paste0("Saved: ", Sys.time()))

    rm(predictions)
    rm(predictions_top5)
    rm(submission)
    rm(model)
    gc()
}


rm(predictions)
rm(predictions_top5)
rm(submission)
gc()

# ---------------------------------------------------
# SAVE
submission <- data.frame(id = test$id)
submission$hotel_cluster <- apply(predictions_top5, 1, function(row){return(paste(row, collapse = ' '))})
submissionName <- paste0("./results/xgboost_", format(Sys.time(), "%H_%M_%S"))
submissionFile <- paste0(submissionName, ".csv")
write.csv(submission, submissionFile, row.names=FALSE, quote = FALSE)

