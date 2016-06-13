library(stringr)
options(scipen=999)

# rm(train.w.clusters.freq)

sum_arr <- paste0('sum_', 0:99)
avg_arr <- paste0('avg_', 0:99)
dist_arr <- paste0('dist_', 0:99)
dest_arr <- paste0('dest_', 0:99)
# dir_arr <- paste0('dir_', 0:99)
nigh_arr <- paste0('nigh_', 0:99)
mon_arr <- paste0('mon_', 0:99)
comp_arr <- paste0('comp_', 0:99)
coun_arr <- paste0('coun_', 0:99)
simp_arr <- paste0('simp_', 0:99)


# dist ssum avg dest dir  nigh  mon  comp coun
# 12.5 1    1   1    1    0.125 0.1  1    0.1
# 10   0.2  1   5    1    1     5    1    0.1

# dist ssum avg dest nigh  mon    comp coun simp
# 125  0.1  0.2 10   5     0.625  5    0.08 1

calculated_clusters <- c(sum_arr, avg_arr, dist_arr, dest_arr, nigh_arr, mon_arr, comp_arr, coun_arr, simp_arr)

# calc.clusters <- function(slice, features, koeff) {
#     clusters <- t(data.frame(apply(slice, 1, function(row) {
#         values <- row[features]
#         values <- values[values > 0.001] * koeff
#         if (length(values) > 0) {
#             values <- values[order(values, decreasing = T)]
#             top <- head(values, 5)
#
#             df <- data.frame(index = as.integer(str_extract(names(top), "[0-9]{1,2}")), prob = top)
#             # print(df)
#             agg <- aggregate(prob ~ index, df, sum)
#             # print(agg)
#             top <- agg[order(agg$prob, decreasing = T), 'index']
#             # print(top)
#
#             return(list(head(top, 5)))
#         }
#
#         return(list())
#     })))
#     rownames(clusters) <- NULL
#     clusters
# }
#
# zzz <- calc.clusters(test.w.clusters.freq[1, avg_arr], avg_arr, 10)


calc.clusters <- function(slice, koeff_vector) {
    apply(slice, 1, function(row) {
        # print(row)
        top <- c()

        dist <- row[dist_arr]
        dist <- dist[dist > 0.001] * koeff_vector[1]
        if (length(dist) > 0) {
            dist <- dist[order(dist, decreasing = T)]
            top <- c(top, head(dist, 5))
        }

#         ssum <- row[sum_arr]
#         ssum <- ssum[ssum > 0.001] * koeff_vector[2]
#         if (length(ssum) > 0) {
#             ssum <- ssum[order(ssum, decreasing = T)]
#             top <- c(top, head(ssum, 5))
#         }

        avg <- row[avg_arr]
        avg <- avg[avg > 0.001] * koeff_vector[3]
        if (length(avg) > 0) {
            avg <- avg[order(avg, decreasing = T)]
            top <- c(top, head(avg, 5))
        }

        dest <- row[dest_arr]
        dest <- dest[dest > 0.001] * koeff_vector[4]
        if (length(dest) > 0) {
            dest <- dest[order(dest, decreasing = T)]
            top <- c(top, head(dest, 5))
        }

        nigh <- row[nigh_arr]
        nigh <- nigh[nigh > 0.001]* koeff_vector[5]
        if (length(nigh) > 0) {
            nigh <- nigh[order(nigh, decreasing = T)]
            top <- c(top, head(nigh, 5))
        }

        mon <- row[mon_arr]
        mon <- mon[mon > 0.001] * koeff_vector[6]
        if (length(mon) > 0) {
            mon <- mon[order(mon, decreasing = T)]
            top <- c(top, head(mon, 5))
        }

        comp <- row[comp_arr]
        comp <- comp[comp > 0.001] * koeff_vector[7]
        if (length(comp) > 0) {
            comp <- comp[order(comp, decreasing = T)]
            top <- c(top, head(comp, 5))
        }

        coun <- row[coun_arr]
        coun <- coun[coun > 0.001] * koeff_vector[8]
        if (length(coun) > 0) {
            coun <- coun[order(coun, decreasing = T)]
            top <- c(top, head(coun, 5))
        }

        simp <- row[simp_arr]
        simp <- simp[simp > 0.001] * koeff_vector[9]
        if (length(simp) > 0) {
            simp <- simp[order(simp, decreasing = T)]
            top <- c(top, head(simp, 5))
        }

        # print(top)
        if (length(top) > 0) {
            # str_extract('dest_25', "[0-9]{1,2}")

            df <- data.frame(index = as.integer(str_extract(names(top), "[0-9]{1,2}")), prob = top)
            # print(df)
            agg <- aggregate(prob ~ index, df, sum)
            # print(agg)
            top <- agg[order(agg$prob, decreasing = T), 'index']
            # print(top)
        }

        l <- as.integer(head(top, 5))
        l.len <- length(l)
        if (l.len < 5) {
            l <- c(l, rep(NA, 5-l.len))
        }

        return(list(l))
    })
}


# test.slice <- test.w.clusters.freq[13, calculated_clusters]
# clusters <- t(data.frame(calc.clusters(test.slice, koeff.vector)))
# clusters <- apply(clusters, 1, paste, collapse = ' ')
#
#
# test.slice <- test.w.clusters.freq[1:1000, calculated_clusters]

train.slice <- train.w.clusters.freq[1:5000, calculated_clusters]
train.slice.clusters <- train.w.clusters.freq[1:5000, 'hotel_cluster']

mapk.current.value <- 0
koeff.vector.len <- 9
koeff.vector <- rep(1, koeff.vector.len)
step <- 10
for (i in 1:10) {
    cat('Step:', step, '\n')
    cat(koeff.vector, '\n')

    for (koeff.index in 1:koeff.vector.len) {
        new.koeff.vector <- koeff.vector
        new.koeff.vector[koeff.index] <- koeff.vector[koeff.index] * step
        clusters <- t(data.frame(calc.clusters(train.slice, new.koeff.vector)))
        mapk.value <- mapk(5, train.slice.clusters, clusters)
        if (mapk.value > mapk.current.value) {
            cat(koeff.index, 'mult', mapk.value, '\n')
            mapk.current.value <- mapk.value
            koeff.vector[koeff.index] <- new.koeff.vector[koeff.index]
        } else {
            new.koeff.vector[koeff.index] <- koeff.vector[koeff.index] / step
            clusters <- t(data.frame(calc.clusters(train.slice, new.koeff.vector)))
            mapk.value <- mapk(5, train.slice.clusters, clusters)
            if (mapk.value > mapk.current.value) {
                cat(koeff.index, 'div', mapk.value, '\n')
                mapk.current.value <- mapk.value
                koeff.vector[koeff.index] <- new.koeff.vector[koeff.index]
            }
        }
    }

    step <- step / 2
}


names(clusters) <- NULL

submission <- data.frame(id = test.w.clusters.freq$id)
submission <- data.frame(id = test.w.clusters.freq[1:length(clusters), 'id'])
submission$hotel_cluster <- clusters

submissionName <- paste0("./results/xgboost_", format(Sys.time(), "%H_%M_%S"))
submissionFile <- paste0(submissionName, ".csv")
write.csv(submission, submissionFile, row.names=FALSE, quote = FALSE)



final <- winner.submission_2016.05.30.15.44
final[1:10000, 'hotel_cluster'] <- submission$hotel_cluster
submissionName <- paste0("./results/xgboost_", format(Sys.time(), "%H_%M_%S"), '_top_10000')
submissionFile <- paste0(submissionName, ".csv")
write.csv(final, submissionFile, row.names=FALSE, quote = FALSE)

