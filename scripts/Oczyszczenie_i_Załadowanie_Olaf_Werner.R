library(dplyr)
library(jsonlite)
library(mlr)
library(stringi)
options(stringsAsFactors = FALSE)


# poprawa moich plikow

#moje<-sapply(audity, function(x){
  #xd<-read_json(x,simplifyVector = TRUE)
  #if(xd$added_by=="wernerolaf"){return(x)}
#})
#moje = moje[-which(sapply(moje, is.null))]
#moje=unlist(moje)
#tnr=specificity ppv=precision tpr=recall
#for (x in moje) {
  #test<-jsonlite::read_json(x,simplifyVector = TRUE )
  #test$performance<-dplyr::rename(test$performance,specificity=tnr,precision=ppv,recall=tpr)
  #test<-toJSON(test,pretty = TRUE,auto_unbox = TRUE)
  #write(test,x)
#}

#samo acc

#foldery<-list.dirs(recursive = TRUE)
#foldery<-foldery[stri_detect_regex(foldery,pattern  = "[0-9a-z]{32}$")]
#for(x in foldery){
 # audit<-read_json(path = file.path(x,"audit.json"),simplifyVector = TRUE)
  #if(length(names(audit$performance))==1 && stri_detect_regex(audit$task_id,pattern = "^classification")){audit$performance<-mutate(audit$performance,specificity=NA,precision=NA,recall=NA,f1=NA,auc=NA)
  #audit<-toJSON(audit,pretty = TRUE,auto_unbox = TRUE,na="null")
  #write(audit,file.path(x,"audit.json"))}
#}


#rsq zamiast r2

#for (x in foldery) {
 # audit<-read_json(path = file.path(x,"audit.json"),simplifyVector = TRUE)
  #if("rsq" %in% names(audit$performance)){names(audit$performance)[names(audit$performance)=="rsq"]<-"r2"
  #audit<-toJSON(audit,pretty = TRUE,auto_unbox = TRUE)
  #write(audit,file.path(x,"audit.json"))}
#}

#Duze litery

#for (x in foldery) {
 # audit<-read_json(path = file.path(x,"audit.json"),simplifyVector = TRUE)
  #names(audit$performance)<-tolower(names(audit$performance))
  #audit<-toJSON(audit,pretty = TRUE,auto_unbox = TRUE)
  #write(audit,file.path(x,"audit.json"))
#}



foldery<-list.dirs(recursive = TRUE)
foldery<-foldery[stri_detect_regex(foldery,pattern  = "[0-9a-z]{32}$")]
i<-0
j<-0
klasyfikacja_model<-list()
klasyfikacja_audit<-list()
regresja_audit<-list()
regresja_model<-list()
for (x in foldery) {
  print(i+j+1)
  audit<-read_json(path = file.path(x,"audit.json"),simplifyVector = TRUE)
  model<-read_json(path = file.path(x,"model.json"),simplifyVector = TRUE)
  if(stri_detect_regex(model$task_id,pattern = "^classification")){
    i<-i+1
    klasyfikacja_model[i]<-list(model)
    klasyfikacja_audit[i]<-list(audit)
  }else{
    j<-j+1
    regresja_model[j]<-list(model)
    regresja_audit[j]<-list(audit)
  }
  
}

klasyfikacja<-data_frame(id=character(),added_by=character(),date=character(),library=character(),model_name=character(),task_id=character(),
                     dataset_id=character(),acc=numeric(),auc=numeric(),specificity=numeric(),recall=numeric(),precision=numeric(),f1=numeric())

for(x in 1:i){klasyfikacja<-rbind(klasyfikacja,c(klasyfikacja_model[[x]][1:7],klasyfikacja_audit[[x]]$performance))}

setdiff(names(klasyfikacja),names(c(klasyfikacja_model[[x]][1:7],klasyfikacja_audit[[x]]$performance)))

klasyfikacja_model[[x]][1:7]




regresja<-data_frame(id=character(),added_by=character(),date=character(),library=character(),model_name=character(),task_id=character(),
                     dataset_id=character(),r2=numeric(),mae=numeric(),rmse=numeric(), mse=numeric())

for(x in 1:j){regresja<-rbind(regresja,c(regresja_model[[x]][1:7],regresja_audit[[x]]$performance))}

setdiff(names(regresja),names(c(regresja_model[[x]][1:7],regresja_audit[[x]]$performance)))

regresja_model[[x]][1:7]


