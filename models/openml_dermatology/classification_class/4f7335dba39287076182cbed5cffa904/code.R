#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:#
set.seed(1)

#:# data
dermatology_dat <- getOMLDataSet(data.id = 35L)
dermatology <- dermatology_dat$data
head(dermatology)

#:# preprocessing
#Usuwam obserwacje z obecnym NA
dermatology <- dermatology[!is.na(dermatology$Age),]
head(dermatology)

#:# model
classif_task <- makeClassifTask(id = "task", data = dermatology, target="class")
classif_lrn <- makeLearner("classif.glmnet", predict.type = "prob")

#:# hash
#:# 4f7335dba39287076182cbed5cffa904
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc)) #brak AUC
#Error: Multiclass problems cannot be used for measure auc!
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
