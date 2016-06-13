library(ggplot2)


train <- readRDS('./data/full_train_37M.Rds')

train$srch_ci_y_m <- factor(format(train[, 'srch_ci'], '%Y-%m'))

for (cl in 0:99) {
    g <- ggplot(data = train[train$hotel_cluster == cl, c('srch_ci_y_m', 'is_booking')], aes(srch_ci_y_m)) +
        ggtitle(paste("Cluster ", cl)) +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
        geom_histogram(alpha = .2, col = 'black') +
        facet_grid(is_booking ~ ., scales = 'free_y')
    ggsave(paste0('plots/bookings/', cl, '.png'), g, width = 15, height = 7, scale = 1, dpi = 72, limitsize = F)
}

train.w.clusters.freq <- readRDS('./data/3M_random_train.Rds')
# train.w.clusters.freq <- readRDS('./data/3M_random_train.w.clusters.freq_zeroed_pred_sum.Rds')
train.w.clusters.freq$srch_ci_y_m <- factor(format(train.w.clusters.freq[, 'srch_ci'], '%Y-%m'))

d <- train.w.clusters.freq[train.w.clusters.freq$hotel_country == 70, c('hotel_cluster', 'srch_ci_y_m')]
d.f <- as.data.frame(table(d$hotel_cluster, d$srch_ci_y_m))
for (i in 0:9) {
    from <- (i*10)
    to <- ((i+1)*10)
    g <- ggplot(d.f[d.f$Var1 %in% from:to, ], aes(x=Var2, y=Freq, group=Var1, color = Var1)) +
        ggtitle(paste("Clusters ", from, ':', to)) +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
        geom_line()
    ggsave(paste0('plots/clusters/', from, '-', to, '.png'), g, width = 15, height = 10, scale = 1, dpi = 72, limitsize = F)
}


for (l in levels(d.f$Var2)) {
    d.f[d.f$Var2 == l, 'Sum'] <- sum(d.f[d.f$Var2 == l, 'Freq'])
}
d.f$RealFreq <- round(d.f$Freq / d.f$Sum * 100, 4)
d.f[is.na(d.f$RealFreq), 'RealFreq'] <- 0
d.f <- d.f[d.f$RealFreq > 0 & d.f$RealFreq < 10, ]
for (i in 0:19) {
    from <- (i*5)
    to <- ((i+1)*5 - 1)
    g <- ggplot(d.f[d.f$Var1 %in% from:to, ], aes(x=Var2, y=RealFreq, group=Var1, color = Var1)) +
        ggtitle(paste("Clusters ", from, ':', to)) +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
        geom_line() +
        geom_smooth(method = "gam", span = 0.1, alpha = 0.1, aes(alpha = 0.1))
    ggsave(paste0('plots/clusters_freq/', from, '-', to, '.png'), g, width = 15, height = 10, scale = 1, dpi = 72, limitsize = F)
}


test.w.clusters.freq$srch_ci_y_m <- factor(format(test.w.clusters.freq[, 'srch_ci'], '%Y-%m'))
table(test.w.clusters.freq$srch_ci_y_m)
test.w.clusters.freq$date_time_y <- as.integer(format(test.w.clusters.freq$date, '%Y'))
table(test.w.clusters.freq$date_time_y)



train.w.clusters.freq$date_time_y_m <- factor(format(train.w.clusters.freq[, 'date_time'], '%Y-%m'))
d <- train.w.clusters.freq[train.w.clusters.freq$hotel_country == 70, c('hotel_cluster', 'date_time_y_m')]
d.f.m <- as.data.frame.matrix(table(d$hotel_cluster, d$date_time_y_m))
d.f <- as.data.frame(table(d$hotel_cluster, d$date_time_y_m))


for (l in levels(d.f$Var2)) {
    d.f[d.f$Var2 == l, 'Sum'] <- sum(d.f[d.f$Var2 == l, 'Freq'])
}
d.f$RealFreq <- round(d.f$Freq / d.f$Sum * 100, 4)
d.f[is.na(d.f$RealFreq), 'RealFreq'] <- 0
d.f <- d.f[d.f$RealFreq > 0 & d.f$RealFreq < 10, ]
for (i in 0:19) {
    from <- (i*5)
    to <- ((i+1)*5 - 1)
    g <- ggplot(d.f[d.f$Var1 %in% from:to, ], aes(x=Var2, y=RealFreq, group=Var1, color = Var1)) +
        ggtitle(paste("Clusters ", from, ':', to)) +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
        geom_line() +
        geom_smooth(method = "gam", span = 0.1, alpha = 0.1, aes(alpha = 0.1))
    ggsave(paste0('plots/clusters_freq_date_time/', from, '-', to, '.png'), g, width = 15, height = 10, scale = 1, dpi = 72, limitsize = F)
}


