#Made by Wojciech Bogucki & Karol Pysiak
library(mlr)
library(dplyr)

data_train <- read.csv2("train.csv")
data_test <- read.csv2("WarsztatyBadawcze_test.csv")

params <- list(num.trees=983, replace=FALSE, sample.fraction=0.703, mtry=floor(ncol(data_test)*0.257), 
               respect.unordered.factors='ignore', min.node.size=1)

prepare <- function(train, test){
  columns_to_drop <- caret::findCorrelation(cor(train),cutoff = 0.99)
  
  train_reduced <- train[, -columns_to_drop] %>% distinct()
  test_reduced <- test[,-columns_to_drop]
  
  # zamiana zmiennych na factory
  df_stat_test_reduced <- funModeling::df_status(train_reduced,print_results = FALSE)
  to_categ <- df_stat_test_reduced %>% filter(type!="factor",unique<20) %>% select(variable)
  for(col in unlist(to_categ)){
    test_reduced[,col] <- as.factor(test_reduced[,col])
    train_reduced[, col] <- as.factor(train_reduced[, col])
  }
  list(train_reduced, test_reduced)
}

prepared <- prepare(data_train, data_test)

task <- makeClassifTask(id="task", data = prepared[[1]], target="Y")
learner <- makeLearner("classif.ranger", par.vals = params, predict.type = "prob")

model <- mlr::train(learner = learner, task = task)

prediction <- predict(model, newdata = prepared[[2]])

prob_true <- prediction$data$prob.TRUE

write.csv(prob_true, file="prob_true_Bogucki_Pysiak.csv", row.names = FALSE)