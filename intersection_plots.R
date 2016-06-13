library(ggplot2)


train.w.clusters.freq <- readRDS('./data/3M_random_train.Rds')
train.w.clusters.freq$hotel_cluster <- factor(train.w.clusters.freq$hotel_cluster)
train.w.clusters.freq$date_time_year <- as.integer(format(train.w.clusters.freq$date_time, '%Y'))


ggplot(data = train[-indexes, ], aes(factor(hotel_cluster))) +
    geom_histogram(alpha = .2, col = 'red')


user_location_country.disp.train <- table(train$user_location_country)
user_location_country.disp.train <- user_location_country.disp.train[order(user_location_country.disp.train, decreasing = T)]
user_location_country.disp.test <- table(test$user_location_country)
user_location_country.disp.test <- user_location_country.disp.test[order(user_location_country.disp.test, decreasing = T)]

#user_location_country
zzz <- table(train[train$user_location_country == 205, 'hotel_cluster'])
zzz <- zzz[order(zzz, decreasing = T)]
ggplot(data = train[train$user_location_country %in% c(66, 205, 69, 3, 77, 46, 1, 133), ], aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(user_location_country ~ ., scales = 'free_y')
ggplot(data = train[train$user_location_country %in% c(66, 205, 69, 3, 77, 46, 1, 133), ], aes(user_location_country)) +
    geom_histogram(alpha = .2, col = 'black') +
    geom_histogram(data = test[test$user_location_country %in% c(66, 205, 69, 3, 77, 46, 1, 133), ], alpha = .2, col = 'blue')

# intersection between user_location_country and hotel_country
zzz <- table(train[train$user_location_country == 205, 'hotel_country'])
zzz <- zzz[order(zzz, decreasing = T)]
ggplot(data = train[train$user_location_country == 205 & train$hotel_country %in% c(50, 198, 8, 105, 70), ],
       aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(hotel_country ~ ., scales = 'free_y')

# search_nights
zzz <- table(train[train$user_location_country == 205 & train$hotel_country == 50, 'search_nights'])
zzz <- zzz[order(zzz, decreasing = T)]
ggplot(data = train[train$user_location_country == 205 & train$hotel_country == 50 & train$nights %in% 1:10, ],
       aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(nights ~ ., scales = 'free_y')

# search_month
zzz <- table(train[train$user_location_country == 205 & train$hotel_country == 50, 'month'])
zzz <- zzz[order(zzz, decreasing = T)]
ggplot(data = train[train$user_location_country == 205 & train$hotel_country == 50, ],
       aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(month ~ ., scales = 'free_y')

# srch_adults_cnt
ggplot(data = train[train$user_location_country == 205 & train$hotel_country == 50, ],
       aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(srch_adults_cnt ~ ., scales = 'free_y')

# srch_children_cnt
ggplot(data = train[train$user_location_country == 205 & train$hotel_country == 50, ],
       aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(srch_children_cnt ~ ., scales = 'free_y')

# srch_adults_children_cnt
zzz <- table(train[train$user_location_country == 205 & train$hotel_country == 50, 'srch_adults_children_cnt'])
zzz <- zzz[order(zzz, decreasing = T)]
ggplot(data = train[train$user_location_country == 205 & train$hotel_country == 50 &
                        train$srch_adults_children_cnt %in% names(zzz)[1:10], ],
       aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(srch_adults_children_cnt ~ ., scales = 'free_y')

# srch_destination_type_id
ggplot(data = train[train$user_location_country == 205 & train$hotel_country == 50, ],
       aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(srch_destination_type_id ~ ., scales = 'free_y')
dest_50 <- unique(train[train$hotel_country == 50, 'srch_destination_id'])
dest_105 <- unique(train[train$hotel_country == 105, 'srch_destination_id'])
intersect(dest_105, dest_50)

dest.train <- unique(train$srch_destination_id)
dest.test <- unique(test$srch_destination_id)
zzz <- intersect(dest.train, dest.test)


# user_hotel_country_pair
zzz <- table(train[, 'user_hotel_country_pair'])
zzz <- zzz[order(zzz, decreasing = T)]
head(zzz, 20)
ggplot(data = train[train$user_hotel_country_pair %in% names(zzz)[1:10], ],
       aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(user_hotel_country_pair ~ ., scales = 'free_y')

# is_package
ggplot(data = train[train$user_location_country == 205 & train$hotel_country == 50, ],
       aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(is_package ~ ., scales = 'free_y')

# srch_adults_children_flag
ggplot(data = train[train$user_location_country == 205 & train$hotel_country == 50, ],
       aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(srch_adults_children_flag ~ ., scales = 'free_y')

# channel
ggplot(data = train[train$user_location_country == 205 & train$hotel_country == 50, ],
       aes(hotel_cluster)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(channel ~ ., scales = 'free_y')
ggplot(data = test[test$user_location_country == 205 & test$hotel_country == 50, ], aes(channel)) +
    geom_histogram(alpha = .2, col = 'black') +
    geom_histogram(data = train[train$user_location_country == 205 & train$hotel_country == 50, ], alpha = .2, col = 'blue')


# Важно!!!
# Распределение кластеров по просмотрам и реальным бронирования
ggplot(data = train.w.clusters.freq[, c('hotel_cluster', 'is_booking')], aes(hotel_cluster)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(is_booking ~ ., scales = 'free_y')

ggplot(data = train.w.clusters.freq[train.w.clusters.freq$date_time_year == 2013, c('hotel_cluster', 'is_booking')], aes(hotel_cluster)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(is_booking ~ ., scales = 'free_y')

ggplot(data = train.w.clusters.freq[train.w.clusters.freq$date_time_year == 2014, c('hotel_cluster', 'is_booking')], aes(hotel_cluster)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(is_booking ~ ., scales = 'free_y')

ggplot(data = train.w.clusters.freq[train.w.clusters.freq$hotel_country == 50, c('hotel_cluster', 'is_booking')], aes(hotel_cluster)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(is_booking ~ ., scales = 'free_y')

# распределение кластеров по годам
ggplot(data = train.w.clusters.freq[, c('hotel_cluster', 'date_time_year')], aes(hotel_cluster)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(date_time_year ~ ., scales = 'free_y')

ggplot(data = train.w.clusters.freq[train.w.clusters.freq$hotel_country == 50, c('hotel_cluster', 'date_time_year')], aes(hotel_cluster)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    geom_histogram(alpha = .2, col = 'black') +
    facet_grid(date_time_year ~ ., scales = 'free_y')
