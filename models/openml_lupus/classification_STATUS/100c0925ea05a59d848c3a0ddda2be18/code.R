

#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(123, "L'Ecuyer")

#:# data
df <- read.csv("lupus.csv")

#:# model
classif_task = makeClassifTask(id = "lupus", data = df, target = "STATUS")
classif_lrn =  makeLearner("classif.rpart", predict.type = "prob", fix.factors.prediction = TRUE)
#:# hash 

#:# 
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()

source("generator.R")
make3JSON(df, "maksymiuks", "openml_lupus", "classification", classif_task, classif_lrn, c("acc", "auc", "specificity", "recall", "precision,", "f1"))
