#paczki i seed
set.seed(123, "L'Ecuyer")
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
  listLearners(check.packages = TRUE)
  
  #robimy taska i learnera
  classif_task = makeClassifTask(id = "task", data = train, target =dane$target.features)
  classif_learner<-makeLearner("classif.logreg",predict.type = "prob")
  
  #testy Acc, AUC, Specificity, Recall, Precision, F1 regresja:MSE, RMSE, MAE, R2 | "f1", "acc" "auc" "tnr" "tpr" "ppv"| "mse" "mae" "rmse" "rsq" 
  Rcuda<-list(f1=f1, acc=acc, auc=auc, tnr=tnr, tpr=tpr ,ppv=ppv)
  measures<-intersect(listMeasures(classif_task),c("f1", "acc", "auc", "tnr", "tpr" ,"ppv"))
  cv <- makeResampleDesc("CV", iters = 5)
  r <- resample(classif_learner, classif_task, cv,measures = Rcuda[measures])
  r<-r$aggr
  pattern<-regexec("\\.test\\.mean$",names(r))
  regmatches(names(r),pattern)<-""
  r<-as.list(r)
  Rcuda<-lapply(Rcuda,function(x){NA})
  Rcuda[names(r)]<-r
  
  #bierzemy parametry
  parametry<-getParamSet(classif_learner)
  parametry<-parametry$pars
  parametry<-lapply(parametry, FUN=function(x){ ifelse(is.null(x$default), NA, x$default)})
  hiper<-getHyperPars(classif_learner)
  parametry[names(hiper)]<-hiper
  
  #haszujemy
  hash <- digest(list(classif_task,classif_learner))
  hash    
  
  #robimy jsony
  modeldozapisu<-list(
  id= hash,
  added_by= "wernerolaf",
  date= format.Date(Sys.Date(),"%d-%m-%Y") ,
  library= "mlr",
  model_name= "classif.logreg",
  task_id=paste("classification_",dane$target.features,sep = ""),
  dataset_id= dataset$id,
  parameters=parametry,
  preprocessing=dataset$variables
  )
  
  modeldozapisu<-toJSON(list(modeldozapisu),pretty = TRUE,auto_unbox = TRUE)
 
  taskdozapisu<-list(id=paste("classification_",dane$target.features,sep = ""),added_by= "wernerolaf",
                        date= format.Date(Sys.Date(),"%d-%m-%Y") ,
                     dataset_id= dataset$id,type="classification",target=dane$target.features)
  
  auditdozapisu<-list(id=paste("audit_",hash,sep = ""),
                      date= format.Date(Sys.Date(),"%d-%m-%Y"),added_by= "wernerolaf",
                      model_id=hash,task_id=paste("classification_",
                      dane$target.features,sep = ""),
                      dataset_id=dataset$id,performance=Rcuda)
  
  taskdozapisu<-toJSON(list(taskdozapisu),pretty = TRUE,auto_unbox = TRUE)
  
  auditdozapisu<-toJSON(list(auditdozapisu),pretty = TRUE,auto_unbox = TRUE)
  
  #zapisujemy
  
  task_id=paste("classification_",dane$target.features,sep = "")
  dir.exists(task_id)
  dir.create(task_id)
  setwd(file.path(getwd(),task_id))
  write(taskdozapisu,"task.json")
  dir.create(hash)
  setwd(file.path(getwd(),hash))
  write(modeldozapisu,"model.json")
  write(auditdozapisu,"audit.json")
  
  # info o sesji
  sink("sessionInfo.txt")
  sessionInfo()
  sink()
  
  
  