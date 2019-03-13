#:# libraries
library(digest)
library(mlr)
library(readr)
library(naniar)
library(dplyr)

#:# config
set.seed(11235)

#:# data
enc <- guess_encoding("accidents_2017.csv", n_max = 10000)[[1]]
df <- as.data.frame(read_csv("accidents_2017.csv", locale = locale(encoding = enc[1])))
head(df)

#:# preprocessing
df <- na.omit(as.data.frame(replace_with_na_all(df, condition = ~.x == "Unknown")))
df <- df[,c(8,9,10,11,12,13)]
colnames(df) <- c("Hour","PartOfTheDay","MildInjuries","SeriousInjuries","Victims","VehiclesInvolved")
df <- filter(df, df$PartOfTheDay!="Night")
df$PartOfTheDay <- ifelse(df$PartOfTheDay == "Morning",1,0)
head(df)

#:# model
regr_task <- makeRegrTask(id = "task", data = df, target = "PartOfTheDay")
regr_lrn <- makeLearner("regr.svm")

#:# hash 
#:# 25d9d874a28a8989e295fe65b193f1c7
hash <- digest(list(regr_task, regr_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 4)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse, rmse, mae, rsq))
r$aggr

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
