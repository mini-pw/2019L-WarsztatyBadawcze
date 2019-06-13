library(mlr)

data_train <- read.csv2("train.csv")
data_test <- read.csv2("WarsztatyBadawcze_test.csv")



classif_task <- makeClassifTask(id="classif", data_train, target = 'Y')

learner <- makeLearner("classif.h2o.gbm", predict.type='prob', par.vals = list('learn_rate' = 0.005, 'ntrees' = 500, 'max_depth' = 13, 'nbins' = 64, 'min_rows' = 6))

m <- train(learner, classif_task)
p <- predict(m, newdata= data_test)

write.csv(p$data$prob.TRUE, "output_Granat.csv", row.names = FALSE)