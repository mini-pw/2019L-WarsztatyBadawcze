library(mlr)
train <- read.csv2("train.csv")
test <- read.csv2("WarsztatyBadawcze_test.csv")

task <- makeClassifTask(id="wb", train, target = 'Y')

learner <- makeLearner("classif.ada", predict.type='prob', par.vals = list("loss" = "exponential",
                                                                           "type" = "discrete",
                                                                           "iter" = 2000,
                                                                           "nu" = 0.1,
                                                                           "bag.frac" = 0.5,
                                                                           "model.coef" = TRUE,
                                                                           "bag.shift" =  FALSE,
                                                                           "max.iter" = 20,
                                                                           "delta" = 1e-010,
                                                                           "verbose" = FALSE,
                                                                           "minsplit" =  20,
                                                                           "cp" = 0.01,
                                                                           "maxcompete" = 4,
                                                                           "maxsurrogate" = 5,
                                                                           "usesurrogate" = 2,
                                                                           "surrogatestyle" = 0,
                                                                           "maxdepth" = 30,
                                                                           "xval" = 0))

trained <- train(learner, task)

prediction <- predict(trained, newdata=test)

write.csv(prediction$data$prob.TRUE, "out.csv", row.names = FALSE)
