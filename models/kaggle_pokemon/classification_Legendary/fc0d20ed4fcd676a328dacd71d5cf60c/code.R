#:# libraries
library(digest)
library(mlr)
library(readr)
library(dplyr)

#:# config
set.seed(1)

#:# data
enc <- guess_encoding("pokemon.csv", n_max = 10000)[[1]]
df <- as.data.frame(read_csv("pokemon.csv", locale = locale(encoding = enc[1])))
head(df)

#:# preprocessing
df <- select(df, -"#", -Name)
df <- na.omit(df)
colnames(df) <- c("type1","type2","hp","att","defense","ass","def","speed","gen","Legendary")
df$type1 <- as.factor(df$type1)
df$type2 <- as.factor(df$type2)
head(df)

#:# model
classif_task <- makeClassifTask(id = "task", data = df, target = "Legendary")
classif_lrn <- makeLearner("classif.mda", predict.type = "prob")

#:# hash 
#:# fc0d20ed4fcd676a328dacd71d5cf60c
hash <- digest(list(classif_task, classif_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc, auc, tnr, tpr, ppv, f1))
measure <- r$aggr
measure

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()