library(stringr)

# TRAIN
# ----------------------------------------------------------------------------------------------------------
train_full_clusters_prob_random <- read.csv("./calculated clusters probabilities/train_full_clusters_prob_random_trends.csv", stringsAsFactors=FALSE)
# saveRDS(train_full_clusters_prob_random, './data/train_full_clusters_prob_random_3M_booking_trends.Rds')


# ----------------------------------------------------------------------------------------------------------
# train_full_clusters_prob_random <- readRDS('./data/train_full_clusters_prob_random_3M.Rds')
train <- readRDS('./data/3M_random_train.Rds')
train.w.clusters.freq <- cbind(train, train_full_clusters_prob_random)


for (cl in 0:99) {
    calculated_clusters <- c(paste0('dist_', cl),
                             # paste0('dir_', cl),
                             paste0('dest_', cl),
                             paste0('simp_', cl),
                             paste0('nigh_', cl),
                             paste0('mon_', cl),
                             paste0('coun_', cl),
                             paste0('comp_', cl))
    train.w.clusters.freq[[paste0('sum_', cl)]] <- apply(train.w.clusters.freq[, calculated_clusters], 1, function(row) {
        row[1] <- row[1] * 2 # dist
        return(sum(row[row > 0]))
    })
    train.w.clusters.freq[[paste0('avg_', cl)]] <- apply(train.w.clusters.freq[, calculated_clusters], 1, function(row) {
        row[1] <- row[1] * 5 # dist
        return(round(mean(row[row >= 0]), 5))
    })

    cat(cl, '\n')
}

saveRDS(train.w.clusters.freq, './data/3M_train.w.clusters.freq_900var_maximize_booking_trends.Rds')
rm(train, train_full_clusters_prob_random)
gc()


table(train.w.clusters.freq$is_booking)


# TEST
# ----------------------------------------------------------------------------------------------------------
test_full_clusters_prob_random <- read.csv("./calculated clusters probabilities/test_full_clusters_prob_random_trends.csv", stringsAsFactors=FALSE)
# saveRDS(test_full_clusters_prob_random, './data/test_full_clusters_prob_random_booking_trends.Rds')


test <- readRDS('./data/full_test.Rds')
# test_full_clusters_prob_random <- readRDS('./data/test_full_clusters_prob_random.Rds')

test.w.clusters.freq <- cbind(test, test_full_clusters_prob_random)


for (cl in 0:99) {
    calculated_clusters <- c(paste0('dist_', cl),
                             # paste0('dir_', cl),
                             paste0('dest_', cl),
                             paste0('simp_', cl),
                             paste0('nigh_', cl),
                             paste0('mon_', cl),
                             paste0('coun_', cl),
                             paste0('comp_', cl))

    test.w.clusters.freq[[paste0('sum_', cl)]] <- apply(test.w.clusters.freq[, calculated_clusters], 1, function(row) {
        row[1] <- row[1] * 2 # dist
        return(sum(row[row > 0]))
    })

    test.w.clusters.freq[[paste0('avg_', cl)]] <- apply(test.w.clusters.freq[, calculated_clusters], 1, function(row) {
        row[1] <- row[1] * 5 # dist
        return(round(mean(row[row >= 0]), 5))
    })

    avg <- paste0('avg_', cl)
    test.w.clusters.freq[is.na(test.w.clusters.freq[[avg]]), avg] <- 0

    cat(cl, '\n')
}


saveRDS(test.w.clusters.freq, './data/test.w.clusters.freq_900var_maximize_booking_trends.Rds')
rm(test, test_full_clusters_prob_random)
gc()


