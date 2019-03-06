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
regr_task <- makeRegrTask(id = "barcelona", data = df, target = "PartOfTheDay")
regr_lrn <- makeLearner("regr.svm")

#:# hash 
#:# 678075b0369fbd9353d30a59d2a7a011
hash <- digest(regr_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 4)
r <- resample(regr_lrn, regr_task, cv, measures = list(mse))
r$aggr

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
