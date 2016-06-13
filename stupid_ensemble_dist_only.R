library(stringr)
options(scipen=999)


test.w.clusters.freq <- readRDS('./data/test.w.clusters.freq_900var_booking_trends.Rds')

create.weight.df <- function(vec) {
    data.frame(num = vec, weight = seq(length(vec), 1))
}

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

calculated_clusters <- c(paste0('dist_', 0:99), paste0('dest_', 0:99), paste0('simp_', 0:99))

test.w.clusters.freq <- test.w.clusters.freq[, c('id', calculated_clusters)]
gc()


only_dist_indexes <- which(test.w.clusters.freq$dist_0 != -1)

clusters <- apply(test.w.clusters.freq[only_dist_indexes[1:10000], ], 1, function(row) {
    # print(row)
    top <- c()

    dist <- row[dist_arr]
    dist <- dist[dist > 0.001] * 3
    if (length(dist) > 0) {
        dist <- dist[order(dist, decreasing = T)]
        top <- c(top, head(dist, 5))
    }

    dist.n <- length(dist)
    if (dist.n > 1 | 1==1) {
        dest <- row[dest_arr]
        dest <- dest[dest > 0.001] * 2
        if (length(dest) > 0) {
            dest <- dest[order(dest, decreasing = T)]
            top <- c(top, head(dest, 5))
        }

        simp <- row[simp_arr]
        simp <- simp[simp > 0.001] * 1
        if (length(simp) > 0) {
            simp <- simp[order(simp, decreasing = T)]
            top <- c(top, head(simp, 5))
        }
        #
        #     avg <- row[avg_arr]
        #     avg <- avg[avg > 0.001] * 1
        #     if (length(avg) > 0) {
        #         avg <- avg[order(avg, decreasing = T)]
        #         top <- c(top, head(avg, 5))
        #     }
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
#     l.len <- length(l)
#     if (l.len < 5) {
#         l <- c(l, rep(NA, 5-l.len))
#     }

    # gc()

    # return(list(l))
    return(paste(l, collapse = ' '))
})

gc()


submission <- data.frame(id = test.w.clusters.freq$id)
submission[only_dist_indexes[1:length(clusters)], 'hotel_cluster'] <- clusters


submission_2016.06.04.14.36 <- read.csv("./results/submission_2016-06-04-14-36.csv", stringsAsFactors=FALSE)

final <- submission_2016.06.04.14.36
j <- 0
# for (i in 1:nrow(test.w.clusters.freq)) {
for (i in only_dist_indexes[1:length(clusters)]) {
# for (i in only_dist_indexes[8582:8584]) {
    clusters.last <- as.integer(unlist(strsplit(submission[i, 'hotel_cluster'], ' ')))
    clusters.last <- clusters.last[!is.na(clusters.last)]
    clusters.winnerTop <- as.integer(unlist(strsplit(trimws(final[i, 'hotel_cluster']), ' ')))
    clusters.winnerTop <- clusters.winnerTop[!is.na(clusters.winnerTop)]

    weights <- create.weight.df(clusters.winnerTop)
    weights$weight <- weights$weight * 2
    # weights <- rbind(weights, create.weight.df(clusters.winner2))
    weights <- rbind(weights, create.weight.df(clusters.last))
    weights <- aggregate(weight ~ num, weights, sum)
    weights <- weights[order(weights$weight, decreasing = T), ]

    final[i, 'hotel_cluster'] <- paste(head(weights$num, 5), collapse = ' ')

    j <- j + 1
    if (j %% 1000 == 0) {
        cat(j, '\n')
    }
}


submissionName <- paste0("./results/gradient_ensemble_", format(Sys.time(), "%H_%M_%S"), "_", j, "_dist_only")
# submissionName <- paste0("./results/ens_", format(Sys.time(), "%H%M%S"))
submissionFile <- paste0(submissionName, ".csv")
write.csv(final, submissionFile, row.names=FALSE, quote = FALSE)

