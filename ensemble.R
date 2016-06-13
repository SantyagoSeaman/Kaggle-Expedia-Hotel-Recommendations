create.weight.df <- function(vec) {
    data.frame(num = vec, weight = seq(length(vec), 1))
}

create.weight.list <- function(vec) {
    result <- rep(0, 100)
    l <- length(vec)
    for (i in 1:l) {
        c <- vec[i] + 1
        result[c] <- result[c] + (l + 1 - i)
    }

    return(result)
}

# submission$hotel_cluster <- apply(submission[, 2:6], 1, paste, collapse=' ')
submission <- aws_xgboost_06_45_37
submission <- aws_xgboost_13_44_55


final <- winner.submission_2016.06.10.21
# for (i in 1:nrow(test.w.clusters.freq)) {
for (i in 1:nrow(submission)) {
    clusters.last <- as.integer(unlist(strsplit(submission[i, 'hotel_cluster'], ' ')))
    clusters.winnerTop <- as.integer(unlist(strsplit(trimws(final[i, 'hotel_cluster']), ' ')))

    weights <- create.weight.list(clusters.last)
    weights <- weights + (create.weight.list(clusters.winnerTop) * 3)
    names(weights) <- 0:99
    weights <- weights[order(weights, decreasing = T)]

    final[i, 'hotel_cluster'] <- paste(names(head(weights, 5)), collapse = ' ')

    if (i %% 1000 == 0) {
        cat(i, '\n')
    }
}


# submissionName <- paste0("./results/gradient_ensemble_", format(Sys.time(), "%H_%M_%S"), "_10000")
# # submissionName <- paste0("./results/ens_", format(Sys.time(), "%H%M%S"))
# submissionFile <- paste0(submissionName, ".csv")
# write.csv(final, submissionFile, row.names=FALSE, quote = FALSE)





submissionName <- paste0("./results/stupid_ensemble_", format(Sys.time(), "%H_%M_%S"), "_", i)
# submissionName <- paste0("./results/ens_", format(Sys.time(), "%H%M%S"), paste(coeffs, collapse = ''))
# submissionName <- paste0("./results/ens_", format(Sys.time(), "%H%M%S"))
submissionFile <- paste0(submissionName, ".csv")
write.csv(final, submissionFile, row.names=FALSE, quote = FALSE)
