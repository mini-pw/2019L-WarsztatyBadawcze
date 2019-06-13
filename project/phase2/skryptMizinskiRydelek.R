library(mlr)

daneTrain <- read.csv("./train.csv",na.strings=c(""," ","NA"),sep=";")
daneTest <- read.csv("./WarsztatyBadawcze_test.csv",na.strings=c(""," ","NA"),sep=";")

daneTrain$Y <-as.numeric(daneTrain$Y)
daneTest$Y <-as.numeric(daneTest$Y)

daneTrain$Y <-as.factor(daneTrain$Y)
daneTest$Y <-as.factor(daneTest$Y)

classif_task <- makeClassifTask(id = "classif", data = daneTrain, target = "Y")
classif_lrn <- makeLearner("classif.h2o.randomForest", predict.type = "prob", par.vals = list(ntrees = 48, sample_rate = 0.7439919,
                                                                                     max_depth = 27, min_rows = 2, nbins = 17))
mod <- train(classif_lrn,classif_task)
pred <- predict(mod, newdata = daneTest)

odpowiedz <- as.data.frame(pred)$prob.1

write.csv(odpowiedz, file = "./odpowiedz.csv", row.names = FALSE)
