
results.train <- apply(train.w.clusters.freq[1:1000000, paste0('pred_sum_', 0:99)], 1, function(row) {
    paste(head(order(row, decreasing = T), 5) - 1, collapse = ' ')
})


mapk(5, as.integer(train.w.clusters.freq[1:length(results.train), 'hotel_cluster']), results.train)

train.w.clusters.freq[1:10, 'hotel_cluster']


results.test <- apply(test.w.clusters.freq[, paste0('pred_sum_', 0:99)], 1, function(row) {
    paste(head(order(row, decreasing = T), 5) - 1, collapse = ' ')
})

submission <- data.frame(id = test.w.clusters.freq$id)
submission$hotel_cluster <- results.test
submissionName <- paste0("./results/xgboost_", format(Sys.time(), "%H_%M_%S"))
submissionFile <- paste0(submissionName, ".csv")
write.csv(submission, submissionFile, row.names=FALSE, quote = FALSE)

