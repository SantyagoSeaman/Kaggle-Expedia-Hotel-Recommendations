
# ----------------------------------------------------------------------------------------------------------
# ONLY BOOKINGS
# ----------------------------------------------------------------------------------------------------------
load("~/Dropbox/Work/Kaggle/Expedia Hotel Recommendations/data/40M_full_data.RData")

rm(merged, orig.test, orig.train)
gc()


train$date_time_year <- as.integer(format(train$date_time, '%Y'))

train_only_bookings <- train[train$is_booking == 1, ]
saveRDS(train_only_bookings, './data/train_only_bookings.Rds')
train_only_bookings <- readRDS('./data/train_only_bookings.Rds')

write.csv(train_only_bookings[, c("hotel_cluster", 'date_time_year',
                                  'search_nights', 'search_month', "search_weeks_diff")],
          './data/train_only_bookings.csv', row.names=FALSE, quote = FALSE)


train_only_bookings <- train[train$is_booking == 1 & train$date_time_year == 2014, ]
saveRDS(train_only_bookings, './data/train_only_bookings_2014.Rds')


# ----------------------------------------------------------------------------------------------------------
# TRAIN
# ----------------------------------------------------------------------------------------------------------
train_full_clusters_prob_random <- read.csv("./calculated clusters probabilities/train_full_clusters_prob_bookings_only_with_trends.csv", stringsAsFactors=FALSE)
train <- readRDS('./data/train_only_bookings.Rds')
train.w.clusters.freq <- cbind(train, train_full_clusters_prob_random)

saveRDS(train.w.clusters.freq, './data/3M_train.w.clusters.freq_900var_maximize_booking_trends.Rds')
rm(train, train_full_clusters_prob_random)
gc()


table(train.w.clusters.freq$is_booking)


# ----------------------------------------------------------------------------------------------------------
# TEST
# ----------------------------------------------------------------------------------------------------------
test_full_clusters_prob_random <- read.csv("./calculated clusters probabilities/test_full_clusters_prob_bookings_only_with_trends.csv", stringsAsFactors=FALSE)
test <- readRDS('./data/full_test.Rds')
test <- test[, c('id', 'search_nights', 'search_month', "search_weeks_diff")]

test.w.clusters.freq <- cbind(test, test_full_clusters_prob_random)


saveRDS(test.w.clusters.freq, './data/test.w.clusters.freq_900var_maximize_booking_trends.Rds')
rm(test, test_full_clusters_prob_random)
gc()


