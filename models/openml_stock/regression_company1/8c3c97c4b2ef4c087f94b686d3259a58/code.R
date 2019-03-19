#paczki i seed
set.seed(1)
library(jsonlite)
library(OpenML)
library(farff)
library(digest) 

#wczytujemy dataset
dataset<-read_json("dataset.json",simplifyVector = TRUE)
preprocessing<-dataset$variables
dataset$source=="openml"
pattern<-regexec("\\d+$",dataset$url)
ID<-regmatches(dataset$url,pattern)
ID<-as.numeric(ID)
dane<-getOMLDataSet(ID)
train<-dane$data

#sprawdzamy paczki
listLearners("regr",check.packages = TRUE)

#zmiana celu
dane$target.features<-"company1"

#robimy taska i learnera
regr_task = makeRegrTask(id = paste("regr_",dane$target.features,sep = ""), data = train, target =dane$target.features)
regr_learner<-makeLearner("regr.gbm")

#testy
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_learner, regr_task, cv)
MSE <- r$aggr

#bierzemy parametry
parametry<-getParamSet(regr_learner)
parametry<-parametry$pars
parametry<-lapply(parametry, FUN=function(x){x$default})
getHyperPars(regr_learner)

#haszujemy
hash <- digest(regr_learner)
hash    

#robimy jsony
modeldozapisu<-list(
  id= hash,
  added_by= "wernerolaf",
  date= format.Date(Sys.Date(),"%d-%m-%Y") ,
  task_id=paste("regression_",dane$target.features,sep = ""),
  dataset_id= dataset$id,
  parameters=parametry,
  preprocessing=dataset$variables
)

modeldozapisu<-toJSON(list(modeldozapisu),pretty = TRUE,auto_unbox = TRUE)

taskdozapisu<-list(id=paste("regression_",dane$target.features,sep = ""),added_by= "wernerolaf",
                   date= format.Date(Sys.Date(),"%d-%m-%Y") ,dataset_id= dataset$id,type="regression",target=dane$target.features)

auditdozapisu<-list(id=paste("audit_",hash,sep = ""),
                    date= format.Date(Sys.Date(),"%d-%m-%Y"),added_by= "wernerolaf",model_id=hash,task_id=paste("regression_",dane$target.features,sep = ""),dataset_id=dataset$id,performance=list(MSE=MSE))

taskdozapisu<-toJSON(list(taskdozapisu),pretty = TRUE,auto_unbox = TRUE)

auditdozapisu<-toJSON(list(auditdozapisu),pretty = TRUE,auto_unbox = TRUE)

#zapisujemy
write(taskdozapisu,"task.json")
write(modeldozapisu,"model.json")
write(auditdozapisu,"audit.json")

# info o sesji
sink(paste0("sessionInfo_", hash,".txt"))
sessionInfo()
sink()


