library(stringr)
library(ggplot2)
options(scipen=999)


# submission <- read.csv("./results/winner-submission_2016-06-09-23-24.csv", stringsAsFactors=FALSE)
train_only_bookings <- read.csv("./data/train_only_bookings.csv", stringsAsFactors=FALSE)
train_only_bookings$hotel_cluster <- factor(train_only_bookings$hotel_cluster)

# -----------------------------------------------------
# submission <- xgboost_01_48_45[, c('id', 'hotel_cluster')]
# submission <- aws_xgboost_13_44_55
parsed <- t(apply(submission, 1, function(row) {
    return(as.integer(unlist(str_split(trimws(row['hotel_cluster']), ' '))))
}))
clusters_weights <- rep(0, 100)
names(clusters_weights) <- 0:99
for (row in parsed) {
    for (i in 1:5) {
        cluster <- row[i] + 1
        clusters_weights[cluster] <- clusters_weights[cluster] + (6 - i)
    }
}


parsed.winner <- t(apply(winner.submission_2016.06.10.09.13, 1, function(row) {
    return(as.integer(unlist(str_split(trimws(row['hotel_cluster']), ' '))))
}))
clusters_weights_winner <- rep(0, 100)
names(clusters_weights_winner) <- 0:99
for (row in parsed.winner) {
    for (i in 1:5) {
        cluster <- row[i] + 1
        clusters_weights_winner[cluster] <- clusters_weights_winner[cluster] + (6 - i)
    }
}
# -----------------------------------------------------


g <- ggplot(data = data.frame(cluster = factor(0:99), freq = clusters_weights_winner/5), aes(cluster, freq)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    geom_bar(stat="identity")
ggsave(paste0('plots/winner-submission-clusters.png'), g, width = 15, height = 10, scale = 1, dpi = 72, limitsize = F)



g <- ggplot(data = train_only_bookings, aes(hotel_cluster)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    geom_histogram() +
    facet_grid(date_time_year ~ ., scales = 'free_y')
ggsave(paste0('plots/train-only-bookings-clusters.png'), g, width = 15, height = 10, scale = 1, dpi = 72, limitsize = F)


g <- ggplot() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    geom_histogram(data = train_only_bookings[train_only_bookings$date_time_year == 2014, ],
                   aes(hotel_cluster),
                   alpha = .3, fill = 'red', col = 'red', width = 0.5) +
    geom_histogram(data = train_only_bookings[train_only_bookings$date_time_year == 2013, ],
                   aes(hotel_cluster),
                   alpha = .1, fill = 'blue', col = 'blue', width = 0.2) +
    geom_point(data = data.frame(cluster = factor(0:99), freq = clusters_weights/5*5),
               aes(cluster, freq),
               stat = "identity",
               alpha = .7, col = 'black', size = 5) +
    geom_point(data = data.frame(cluster = factor(0:99), freq = clusters_weights_winner/5/10),
               aes(cluster, freq),
               stat = "identity",
               alpha = .7, col = 'green', size = 5)

ggsave(paste0('plots/winner-submission-clusters-with-train-total-single-model.png'), g, width = 25, height = 10, scale = 1, dpi = 72, limitsize = F)
ggsave(paste0('plots/winner-submission-clusters-with-train-total-stupid-model.png'), g, width = 25, height = 10, scale = 1, dpi = 72, limitsize = F)
