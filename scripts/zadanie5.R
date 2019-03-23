library(dplyr)
library(jsonlite)
library(mlr)
library(stringi)
options(stringsAsFactors = FALSE)

#moje<-sapply(audity, function(x){
  #xd<-read_json(x,simplifyVector = TRUE)
  #if(xd$added_by=="wernerolaf"){return(x)}
})
#moje = moje[-which(sapply(moje, is.null))]
#moje=unlist(moje)
#tnr=specificity ppv=precision tpr=recall
#for (x in moje) {
  #test<-jsonlite::read_json(x,simplifyVector = TRUE )
  #test$performance<-dplyr::rename(test$performance,specificity=tnr,precision=ppv,recall=tpr)
  #test<-toJSON(test,pretty = TRUE,auto_unbox = TRUE)
  #write(test,x)
}
#for(x in moje){
  #test<-jsonlite::read_json(x,simplifyVector = TRUE )
  #print(length(names(test$performance)))
  #if(length(names(test$performance))==1){test$performance<-mutate(test$performance,specificity=NA,precision=NA,recall=NA,f1=NA,auc=NA)}
  #test<-toJSON(test,pretty = TRUE,auto_unbox = TRUE,na="null")
  #write(test,x)
}

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


regresja<-data_frame(added_by=character(),date=character(),library=character(),model_name=character(),task_id=character(),
                     dataset_id=character(),r2=numeric(),mae=numeric(),rmse=numeric(), mse=numeric())

for(x in 1:j){regresja<-rbind(regresja,c(regresja_model[[x]][2:7],regresja_audit[[x]]$performance))}

setdiff(names(regresja),names(c(regresja_model[[x]][2:7],regresja_audit[[x]]$performance)))

regresja_model[[x]][2:7]


