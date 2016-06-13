library(stringr)

# rm(merged)
# rm(orig.test)
# rm(orig.train)
# gc()

train <- readRDS('./data/full_train_37M.Rds')

train.size = 3000000
set.seed(10)
indexes <- sample(seq_len(nrow(train)), floor(train.size))
indexes <- indexes[order(indexes)]
# write.csv(indexes, './expedia python solution/csv/random_indexes_3M.csv', row.names = F, col.names = F)
train <- train[indexes, ]
saveRDS(train, './data/3M_random_train.Rds')
gc()

train.size = -1
train_dist_clusters_prob <- read.csv("./calculated clusters probabilities/train_dist_clusters_prob_random_3M.csv",
                                     stringsAsFactors=FALSE, nrows = train.size)
train_dist_clusters_prob <- rbind(train_dist_clusters_prob, rep.int(-1, 100))

train_dest_clusters_prob <- read.csv("./calculated clusters probabilities/train_dest_clusters_prob_random_3M.csv",
                                     stringsAsFactors=FALSE, nrows = train.size)
train_dest_clusters_prob <- rbind(train_dest_clusters_prob, rep.int(-1, 100))

train_dir_clusters_prob <- read.csv("./calculated clusters probabilities/train_dir_clusters_prob_random_3M.csv",
                                    stringsAsFactors=FALSE, nrows = train.size)
train_dir_clusters_prob <- rbind(train_dir_clusters_prob, rep.int(-1, 100))

train_nigh_clusters_prob <- read.csv("./calculated clusters probabilities/train_nigh_clusters_prob_random_3M.csv",
                                    stringsAsFactors=FALSE, nrows = train.size)
train_nigh_clusters_prob <- rbind(train_nigh_clusters_prob, rep.int(-1, 100))

train_mon_clusters_prob <- read.csv("./calculated clusters probabilities/train_mon_clusters_prob_random_3M.csv",
                                    stringsAsFactors=FALSE, nrows = train.size)
train_mon_clusters_prob <- rbind(train_mon_clusters_prob, rep.int(-1, 100))

train_comp_clusters_prob <- read.csv("./calculated clusters probabilities/train_comp_clusters_prob_random_3M.csv",
                                    stringsAsFactors=FALSE, nrows = train.size)
train_comp_clusters_prob <- rbind(train_comp_clusters_prob, rep.int(-1, 100))

# saveRDS(train_dest_clusters_prob, 'data/2M_train_dest_clusters_prob.Rds')
# saveRDS(train_dir_clusters_prob, 'data/2M_train_dir_clusters_prob.Rds')


train.w.clusters.freq <- cbind(train,
                               train_dest_clusters_prob,
                               train_dir_clusters_prob,
                               train_dist_clusters_prob,
                               train_nigh_clusters_prob,
                               train_mon_clusters_prob,
                               train_comp_clusters_prob)
saveRDS(train.w.clusters.freq, './data/3M_random_train.w.clusters.freq.Rds')
rm(train, train_dist_clusters_prob, train_dest_clusters_prob, train_dir_clusters_prob,
   train_nigh_clusters_prob, train_mon_clusters_prob, train_comp_clusters_prob)
gc()

# ----------------------------------------------------------------------------------------------
# test
clusters.probs <- apply(train.w.clusters.freq[1:1000, ], 1, function(row) {
    cl <- as.integer(row['hotel_cluster'])
    calculated_clusters <- c(paste0('dir_', cl),
                             paste0('dest_', cl),
                             paste0('dist_', cl),
                             paste0('nigh_', cl),
                             paste0('mon_', cl),
                             paste0('comp_', cl))
    prob <- as.double(row[calculated_clusters])
    prob.mean <- mean(prob[prob >= 0])
    return(prob.mean)
})
head(clusters.probs, 20)
clusters.probs.neg <- clusters.probs[clusters.probs < 0.001]
if (length(clusters.probs.neg) > 0) {
    print('Авария!')
}
clusters.probs.rownames <- as.integer(names(clusters.probs))
if (clusters.probs.rownames[1] > clusters.probs.rownames[2]) {
    print('Авария!')
}

# ----------------------------------------------------------------------------------------------
# Adding noise
slice.last.index <- nrow(train.w.clusters.freq)
prefixes <- c('dir_', 'dest_', 'dist_', 'nigh_', 'mon_', 'comp_')
for (i in 1:length(prefixes)) {
    set.seed(i*10)
    indexes <- sample(seq_len(slice.last.index), floor(slice.last.index*0.01))
    train.w.clusters.freq[indexes, paste0(prefixes[i], 0:99)] <- -1
}

# ----------------------------------------------------------------------------------------------
# test
clusters.test <- train.w.clusters.freq[train.w.clusters.freq$dest_5 == -1, 'hotel_cluster']
if (length(clusters.test) != 30001) {
    print("Авария!!!")
}


# ----------------------------------------------------------------------------------------------
for (cl in 0:99) {
    calculated_clusters <- c(paste0('dist_', cl),
                             # paste0('dir_', cl),
                             paste0('dest_', cl),
                             paste0('nigh_', cl),
                             paste0('mon_', cl),
                             paste0('coun_', cl),
                             paste0('comp_', cl))
    train.w.clusters.freq[[paste0('sum_', cl)]] <- apply(train.w.clusters.freq[, calculated_clusters], 1, function(row) {
        return(sum(row[row > 0]))
    })
    train.w.clusters.freq[[paste0('avg_', cl)]] <- apply(train.w.clusters.freq[, calculated_clusters], 1, function(row) {
        row[1] <- row[1] * 5 # dist
        return(round(mean(row[row >= 0]), 5))
    })

    cat(cl, '\n')
}

saveRDS(train.w.clusters.freq, './data/3M_random_train.w.clusters.freq_zeroed_pred_sum_mean.Rds')


# ----------------------------------------------------------------------------------------------
# test
clusters.test <- train.w.clusters.freq[train.w.clusters.freq$hotel_cluster == 5,
                                       c('dir_5', 'dest_5', 'dist_5', 'nigh_5', 'mon_5', 'comp_5', 'pred_sum_5')]
clusters.test.near_zero <- ifelse(clusters.test$pred_sum_5 < 0.001, 1, 0)
table(clusters.test.near_zero)

clusters.test <- train.w.clusters.freq[train.w.clusters.freq$hotel_cluster == 31,
                                       c('dir_31', 'dest_31', 'dist_31', 'nigh_31', 'mon_31', 'comp_31', 'pred_sum_31')]

# ----------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------
test <- readRDS('./data/full_test.Rds')

test_dist_clusters_prob <- read.csv("./calculated clusters probabilities/test_dist_clusters_prob_random_3M.csv", stringsAsFactors=FALSE)
test_dest_clusters_prob <- read.csv("./calculated clusters probabilities/test_dest_clusters_prob_random_3M.csv", stringsAsFactors=FALSE)
test_dir_clusters_prob <- read.csv("./calculated clusters probabilities/test_dir_clusters_prob_random_3M.csv", stringsAsFactors=FALSE)
test_nigh_clusters_prob <- read.csv("./calculated clusters probabilities/test_nigh_clusters_prob_random_3M.csv", stringsAsFactors=FALSE)
test_mon_clusters_prob <- read.csv("./calculated clusters probabilities/test_mon_clusters_prob_random_3M.csv", stringsAsFactors=FALSE)
test_comp_clusters_prob <- read.csv("./calculated clusters probabilities/test_comp_clusters_prob_random_3M.csv", stringsAsFactors=FALSE)

test.w.clusters.freq <- cbind(test,
                              test_dest_clusters_prob,
                              test_dir_clusters_prob,
                              test_dist_clusters_prob,
                              test_nigh_clusters_prob,
                              test_mon_clusters_prob,
                              test_comp_clusters_prob)
saveRDS(test.w.clusters.freq, './data/test.w.clusters.freq.Rds')
rm(test, test_dist_clusters_prob, test_dest_clusters_prob, test_dir_clusters_prob,
   test_nigh_clusters_prob, test_mon_clusters_prob, test_comp_clusters_prob)
gc()


# ----------------------------------------------------------------------------------------------
for (cl in 0:99) {
    calculated_clusters <- c(paste0('dist_', cl),
                             # paste0('dir_', cl),
                             paste0('dest_', cl),
                             paste0('nigh_', cl),
                             paste0('mon_', cl),
                             paste0('coun_', cl),
                             paste0('comp_', cl))

    test.w.clusters.freq[[paste0('sum_', cl)]] <- apply(test.w.clusters.freq[, calculated_clusters], 1, function(row) {
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

saveRDS(test.w.clusters.freq, './data/test.w.clusters.freq_pred_sum_mean.Rds')


# ----------------------------------------------------------------------------------------------
# test
clusters.test <- test.w.clusters.freq[1:1000, c('dir_5', 'dest_5', 'dist_5', 'nigh_5', 'mon_5', 'comp_5', 'pred_sum_5')]
clusters.test.near_zero <- ifelse(clusters.test$pred_sum_5 < 0.001, 1, 0)
table(clusters.test.near_zero)
