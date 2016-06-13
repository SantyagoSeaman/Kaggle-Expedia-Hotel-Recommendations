indexes <- sample(seq_len(nrow(train)), floor(5000000))
train <- train[indexes, ]
saveRDS(train, './data/5M_train_clean_sample_data.Rds')
saveRDS(indexes, './data/5M_train_clean_sample_indexes.Rds')

