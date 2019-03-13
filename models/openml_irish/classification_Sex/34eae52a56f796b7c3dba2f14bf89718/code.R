#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(11235)

#:# data
temp <- getOMLDataSet(data.id = 451L)
df <- temp$data
head(df)

#:# preprocessing
df$Sex <- as.factor(ifelse(df$Sex=="male",1,0))
df$Leaving_Certificate <- as.integer(ifelse(df$Leaving_Certificate=="taken",2,1))
df$Type_school <- as.integer(ifelse(df$Type_school=="secondary", 1, ifelse(df$Type_school=="vocational", 2, 9)))
df$Educational_level <- factor(df$Educational_level, 
                                  levels = unique(
                                    levels(df$Educational_level)[c(7,4,3,6,5,9,8,10,2,1)]
                                  )
)
df$Educational_level <- as.integer(df$Educational_level)
df <- na.omit(df)
head(df)


#:# model
classif_task <- makeClassifTask(id = "task", data = df, target = "Sex")
classif_lrn <- makeLearner("classif.gbm", predict.type = "prob", par.vals = list(distribution = "bernoulli"))

#:# hash 
#:# 34eae52a56f796b7c3dba2f14bf89718
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
r$aggr

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
