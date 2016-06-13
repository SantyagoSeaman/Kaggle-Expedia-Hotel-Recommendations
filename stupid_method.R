library(stringr)
options(scipen=999)

# rm(train.w.clusters.freq)

test.w.clusters.freq <- readRDS('./data/test.w.clusters.freq_1000var_maximize_booking_trends.Rds')
test.w.clusters.freq$search_month <- NULL

sum_arr <- paste0('sum_', 0:99)
avg_arr <- paste0('avg_', 0:99)
dist_arr <- paste0('dist_', 0:99)
dest_arr <- paste0('dest_', 0:99)
dir_arr <- paste0('dir_', 0:99)
nigh_arr <- paste0('nigh_', 0:99)
mon_arr <- paste0('mon_', 0:99)
comp_arr <- paste0('comp_', 0:99)
coun_arr <- paste0('coun_', 0:99)
simp_arr <- paste0('simp_', 0:99)

# calculated_clusters <- c(sum_arr, avg_arr, dist_arr, dest_arr, nigh_arr, mon_arr, comp_arr, coun_arr, simp_arr)
calculated_clusters <- c(sum_arr, avg_arr, dist_arr, dest_arr, nigh_arr, mon_arr, comp_arr, coun_arr, simp_arr, dir_arr)


coeffs <- c(100, # dist
            0, # ssum
            1, # avg
            5, # dest
            1, # dir
            0.5, # nigh
            0.5, # mon
            0.5, # comp
            0.1, # coun
            1) # simp

# clusters <- apply(train.w.clusters.freq[1:10000, calculated_clusters], 1, function(row) {
# clusters <- apply(test.w.clusters.freq[, calculated_clusters], 1, function(row) {
clusters <- c()
for (n in 1:nrow(test.w.clusters.freq)) {
    row <- unlist(test.w.clusters.freq[n, ])
    # print(row)
    top <- c()

    dist <- row[dist_arr]
    dist <- dist[dist > 0.001]
    if (length(dist) > 0) {
        dist <- dist * coeffs[1]
        dist <- dist[order(dist, decreasing = T)]
        top <- c(top, head(dist, 5))
    }

#     ssum <- row[sum_arr]
#     ssum <- ssum[ssum > 0.001]
#     if (length(ssum) > 0) {
#         # print(ssum)
#         ssum <- ssum * coeffs[2]
#         ssum <- ssum[order(ssum, decreasing = T)]
#         top <- c(top, head(ssum, 5))
#     }

    avg <- row[avg_arr]
    avg <- avg[avg > 0.001]
    if (length(avg) > 0) {
        avg <- avg * coeffs[3]
        avg <- avg[order(avg, decreasing = T)]
        top <- c(top, head(avg, 5))
    }

    dest <- row[dest_arr]
    dest <- dest[dest > 0.001]
    if (length(dest) > 0) {
        dest <- dest * coeffs[4]
        dest <- dest[order(dest, decreasing = T)]
        top <- c(top, head(dest, 5))
    }

#     dir <- row[dir_arr]
#     dir <- dir[dir > 0.001]
#     if (length(dir) > 0) {
#         dir <- dir * coeffs[5]
#         dir <- dir[order(dir, decreasing = T)]
#         top <- c(top, head(dir, 5))
#     }

    nigh <- row[nigh_arr]
    nigh <- nigh[nigh > 0.001]
    if (length(nigh) > 0) {
        nigh <- nigh * coeffs[6]
        nigh <- nigh[order(nigh, decreasing = T)]
        top <- c(top, head(nigh, 5))
    }

#     mon <- row[mon_arr]
#     mon <- mon[mon > 0.001]
#     if (length(mon) > 0) {
#         mon <- mon * coeffs[7]
#         mon <- mon[order(mon, decreasing = T)]
#         top <- c(top, head(mon, 5))
#     }

    comp <- row[comp_arr]
    comp <- comp[comp > 0.001]
    if (length(comp) > 0) {
        comp <- comp * coeffs[8]
        comp <- comp[order(comp, decreasing = T)]
        top <- c(top, head(comp, 5))
    }
#
#     coun <- row[coun_arr]
#     coun <- coun[coun > 0.001]
#     if (length(coun) > 0) {
#         coun <- coun * coeffs[9]
#         coun <- coun[order(coun, decreasing = T)]
#         top <- c(top, head(coun, 5))
#     }

    simp <- row[simp_arr]
    simp <- simp[simp > 0.001]
    if (length(simp) > 0) {
        simp <- simp * coeffs[10]
        simp <- simp[order(simp, decreasing = T)]
        top <- c(top, head(simp, 5))
    }

    # print(top)
    res <- rep(0, 100)
    names(res) <- 0:99
    if (length(top) > 0) {
        # str_extract('dest_25', "[0-9]{1,2}")

        indexes = as.integer(str_extract(names(top), "[0-9]{1,2}")) + 1
        probs = top
        for (i in 1:length(indexes)) {
            res[indexes[i]] <- res[indexes[i]] + probs[i]
        }
        res <- res[order(res, decreasing = T)]

        top <- as.integer(names(head(res, 5)))
        top.len <- length(top)
        if (top.len < 5) {
            top <- c(top, rep(NA, 5 - top.len))
        }
    }

    # return(list(l))
    clusters <- c(clusters, paste(top, collapse = ' '))

    if (n %% 1000 == 0) {
        print(n)
    }
}


# names(clusters) <- NULL
# clusters <- t(data.frame(clusters))
# mapk(5, train.w.clusters.freq[1:nrow(clusters), 'hotel_cluster'], clusters)


# submission <- data.frame(id = test.w.clusters.freq$id)
submission <- data.frame(id = test.w.clusters.freq[1:length(clusters), 'id'])
submission$hotel_cluster <- clusters



submissionName <- paste0("./results/xgboost_", format(Sys.time(), "%H_%M_%S"))
submissionFile <- paste0(submissionName, ".csv")
write.csv(submission, submissionFile, row.names=FALSE, quote = FALSE)


final <- submission_2016.06.04.14.36
final[1:nrow(submission), 'hotel_cluster'] <- submission$hotel_cluster
submissionName <- paste0("./results/stupid_", format(Sys.time(), "%H_%M_%S"), '_top_', n)
submissionFile <- paste0(submissionName, ".csv")
write.csv(final, submissionFile, row.names=FALSE, quote = FALSE)


