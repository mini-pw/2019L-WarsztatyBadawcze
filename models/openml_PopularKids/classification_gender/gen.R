#:# libraries
library(digest)
library(OpenML)
library(mlr)
library(jsonlite)

#:# config
set.seed(1233)


#:# data
popularKids <- getOMLDataSet(data.id = 1100L)
kids <- popularKids$data

#:# preprocessing
head(kids)
summary(kids)

#:# model
target <- "gender"
type <- "classification"
classif_task <- makeClassifTask(id="kids", data = kids, target = target )
classif_lrn <- makeLearner("classif.randomForest", predict.type = 'prob')


#:# hash 
hash <- digest(classif_lrn)
hash


#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn,classif_task,cv, measures = list(acc, auc))
perf <- r$aggr
names(perf) <- c("ACC", "AUC")
perf

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()

#:# audit JSON
audit <- list(id=paste0("audit_",hash),
              date=format(Sys.time(), "%d-%m-%Y"),
              added_by="WojtekBogucki",
              model_id=hash,
              task_id = paste(type,target,sep = "_"),
              dataset_id = popularKids$desc$name,
              performance = as.list(perf))

file1 <- toJSON(list(audit), pretty = TRUE,auto_unbox = TRUE)
file1
write(file1, "audit.json")

#:# task JSON
task <- list(id=paste(type,target,sep = "_"),
             added_by="WojtekBogucki",
             date=format(Sys.time(), "%d-%m-%Y"),
             dataset_id = popularKids$desc$name,
             type = type,
             target = target)

file2 <- toJSON(list(task), pretty = TRUE,auto_unbox = TRUE)
file2
write(file2, "task.json")
