library(RMySQL)

factor2int <- function(value) {
    return (as.integer(as.character(value)))
}

con <- dbConnect(MySQL(),
                 user = 'root',
                 password = '12345',
                 host = 'localhost',
                 dbname='expedia')

# ---------------------------------------------------------------------------------------
# Store to DB
train.to.export <- train[, c('user_location_country', 'user_location_region', 'user_location_city',
                             "user_id", "is_mobile", "is_package", "channel", "srch_ci", "srch_co",
                             "srch_adults_cnt", "srch_children_cnt", "srch_rm_cnt",
                             "srch_destination_id", "srch_destination_type_id",
                             "orig_destination_distance", "is_booking",
                             "hotel_continent", "hotel_country", "hotel_market", "hotel_cluster",
                             "search_nights", "search_month", "search_weeks_diff",
                             "srch_adults_children_cnt", "srch_adults_children_flag")]

train.to.export$srch_adults_children_cnt <- as.integer(train.to.export$srch_adults_children_cnt)
train.to.export$srch_adults_children_flag <- as.integer(train.to.export$srch_adults_children_flag)

train.to.export$srch_destination_type_id <- factor2int(train.to.export$srch_destination_type_id)
train.to.export$hotel_country <- factor2int(train.to.export$hotel_country)
train.to.export$hotel_market <- factor2int(train.to.export$hotel_market)

for(i in 0:floor(nrow(train.to.export)/100000)) {
    dbWriteTable(conn = con, name = 'train_data', value = train.to.export[(i*100000):((i+1)*100000), ], append = T, row.names = F)
}


# ---------------------------------------------------------------------------------------
# train_data_searches_stat <- dbGetQuery(con, "SELECT * FROM train_data_searches_stat")
# train_data_destinations_popularity <- dbGetQuery(con, "SELECT * FROM train_data_destinations_popularity")

# ---------------------------------------------------------------------------------------
train.w.clusters.freq <- train

# ---------------------------------------------------------------------------------------
train_data_destinations_popularity_grouped <- dbGetQuery(con, "
    SELECT srch_destination_id, srch_destination_type_id,
        hotel_country, hotel_market, srch_adults_children_flag,
        is_package,
        group_concat(hotel_cluster, ':', search_freq) as hotel_cluster_freq_array
    FROM expedia.train_data_destinations_popularity
    GROUP BY srch_destination_id, srch_destination_type_id,
        hotel_country, hotel_market, srch_adults_children_flag,
        is_package")

train.to.export$temp_id <- 1:nrow(train.to.export)
train.to.export <- merge(train.to.export,
                         train_data_destinations_popularity_grouped,
                         by = c('srch_destination_id', 'srch_destination_type_id',
                                'hotel_country', 'hotel_market', 'srch_adults_children_flag',
                                'is_package'))
train.to.export <- train.to.export[order(train.to.export$temp_id), ]
train.to.export$temp_id <- NULL

dest.freq.names <- c(paste('dest_freq_', 0:99, sep = ''))
for(i in 0:99) {
    train.w.clusters.freq[paste0('dest_freq_', i)] <- as.numeric(0)
}

slice.size <- 10000
freq_df <- data.frame(cluster = 0)
for(i in 0:99) {
    freq_df[1:slice.size, paste0('dest_freq_', i)] <- rep(as.numeric(0), slice.size)
}
freq_df$cluster <- NULL

for (j in 0:2500) {
    freq_df[,] <- as.numeric(0)

    rows <- train.to.export[(j*slice.size + 1):((j+1)*slice.size), ]
    for(i in 1:nrow(rows)) {
        row <- rows[i, ]
        row.comma.sliced <- unlist(strsplit(row$hotel_cluster_freq_array, ','))
        for(c in row.comma.sliced) {
            c.sliced <- unlist(strsplit(c, ':'))
            freq_df[i, as.integer(c.sliced[1]) + 1] <- as.numeric(c.sliced[2])
        }
    }

    train.w.clusters.freq[(j*slice.size + 1):((j+1)*slice.size), dest.freq.names] <- freq_df[1:i, dest.freq.names]

    cat(as.character(Sys.time()), '-', (j+1)*slice.size, '\n')
}


# ---------------------------------------------------------------------------------------
train_data_directions_popularity_grouped <- dbGetQuery(con,
    "SELECT user_location_country, hotel_country, hotel_market,
        srch_adults_children_flag, is_package,
        group_concat(hotel_cluster, ':', search_freq) as hotel_cluster_freq_array
    FROM expedia.train_data_directions_popularity
    GROUP BY user_location_country, hotel_country, hotel_market,
        srch_adults_children_flag, is_package")
# saveRDS(train_data_directions_popularity_grouped, 'data/train_data_directions_popularity_grouped.RDS')

train.to.export$temp_id <- 1:nrow(train.to.export)
train.to.export <- merge(train.to.export,
                         train_data_directions_popularity_grouped,
                         by = c('user_location_country', 'hotel_country', 'hotel_market',
                                'srch_adults_children_flag', 'is_package'))
train.to.export <- train.to.export[order(train.to.export$temp_id), ]
train.to.export$temp_id <- NULL
saveRDS(train.to.export, 'data/train.to.export_directions_popularity_grouped.RDS')

direct.freq.names <- c(paste('direct_freq_', 0:99, sep = ''))
for(i in 0:99) {
    train.w.clusters.freq[paste0('direct_freq_', i)] <- as.numeric(0)
}

slice.size <- 1000
freq_df <- data.frame(cluster = 0)
for(i in 0:99) {
    freq_df[1:slice.size, paste0('direct_freq_', i)] <- rep(as.numeric(0), slice.size)
}
freq_df$cluster <- NULL

for (j in 0:2500) {
    freq_df[,] <- as.numeric(0)

    rows <- train.to.export[(j*slice.size + 1):((j+1)*slice.size), ]
    for(i in 1:nrow(rows)) {
        row <- rows[i, ]
        row.comma.sliced <- unlist(strsplit(row$hotel_cluster_freq_array, ','))
        for(c in row.comma.sliced) {
            c.sliced <- unlist(strsplit(c, ':'))
            freq_df[i, as.integer(c.sliced[1]) + 1] <- as.numeric(c.sliced[2])
        }
    }

    train.w.clusters.freq[(j*slice.size + 1):((j+1)*slice.size), direct.freq.names] <- freq_df[1:i, direct.freq.names]

    cat(as.character(Sys.time()), '-', (j+1)*slice.size, '\n')
}

