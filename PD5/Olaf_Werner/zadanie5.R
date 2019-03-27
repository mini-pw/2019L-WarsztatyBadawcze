library(dplyr)
library(jsonlite)
library(mlr)
library(stringi)
library(DataExplorer)
library(ggplot2)
options(stringsAsFactors = FALSE)


# poprawa moich plikow i granata

# audity<-list.files(pattern = "audit.json$",recursive = TRUE)
# 
# moje<-sapply(audity, function(x){
# xd<-read_json(x,simplifyVector = TRUE)
# if(xd$added_by=="wernerolaf" || xd$added_by=="granatb"){return(x)}
# })
# moje = moje[-which(sapply(moje, is.null))]
# moje=unlist(moje)
# #tnr=specificity ppv=precision tpr=recall
# for (x in moje) {
# test<-jsonlite::read_json(x,simplifyVector = TRUE )
# if("tnr" %in% names(test$performance)){
# test$performance<-dplyr::rename(test$performance,specificity=tnr,precision=ppv,recall=tpr)
# test<-toJSON(test,pretty = TRUE,auto_unbox = TRUE)
# write(test,x)
# }
# }
 # 
#nazwy brakujace classification

# foldery<-list.dirs(recursive = TRUE)
# foldery<-foldery[stri_detect_regex(foldery,pattern  = "[0-9a-z]{32}$")]
# for(x in foldery){
#   audit<-read_json(path = file.path(x,"audit.json"),simplifyVector = TRUE)
#   if(length(names(audit$performance))!=6 && stri_detect_regex(audit$task_id,pattern = "^classification")){
#     audit$performance<-mutate_at(audit$performance,setdiff(c("specificity","precision","recall","acc","auc","f1"),names(audit$performance)),function(x){NA})
#   audit<-toJSON(audit,pretty = TRUE,auto_unbox = TRUE,na="null")
#   write(audit,file.path(x,"audit.json"))}
# }

#nazwy brakujace regresion

# foldery<-list.dirs(recursive = TRUE)
# foldery<-foldery[stri_detect_regex(foldery,pattern  = "[0-9a-z]{32}$")]
# for(x in foldery){
#   audit<-read_json(path = file.path(x,"audit.json"),simplifyVector = TRUE)
#   if(length(names(audit$performance))!=4 && stri_detect_regex(audit$task_id,pattern = "^regression")){
#     audit$performance<-mutate_at(audit$performance,setdiff(c("mae","r2","mse","rmse"),names(audit$performance)),function(x){NA})
#   audit<-toJSON(audit,pretty = TRUE,auto_unbox = TRUE,na="null")
#   write(audit,file.path(x,"audit.json"))}
# }



#rsq zamiast r2

# for (x in foldery) {
# audit<-read_json(path = file.path(x,"audit.json"),simplifyVector = TRUE)
# if("rsq" %in% names(audit$performance)){names(audit$performance)[names(audit$performance)=="rsq"]<-"r2"
# audit<-toJSON(audit,pretty = TRUE,auto_unbox = TRUE)
# write(audit,file.path(x,"audit.json"))}
# }

#Duze litery

#for (x in foldery) {
 # audit<-read_json(path = file.path(x,"audit.json"),simplifyVector = TRUE)
#  names(audit$performance)<-tolower(names(audit$performance))
 # audit<-toJSON(audit,pretty = TRUE,auto_unbox = TRUE)
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

#wczytywanie danych

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

#filtrowanie
klasyfikacja<-klasyfikacja[!is.na(klasyfikacja$acc),]

unique(klasyfikacja$model_name)
table(klasyfikacja$model_name)

klasyfikacja %>% group_by(model_name) %>% filter(n()>3)->klasyfikacja_filter

klasyfikacja_filter %>% group_by(task_id,dataset_id) %>% filter(n()>8)->klasyfikacja_filter

klasyfikacja_filter %>% group_by(model_name) %>% filter(n()>3)->klasyfikacja_filter

klasyfikacja_filter$task_id<-substring(klasyfikacja_filter$task_id,first = 16)

klasyfikacja_filter$model_name<-substring(klasyfikacja_filter$model_name,first = 9)

unique(klasyfikacja_filter$model_name)
table(klasyfikacja_filter$model_name)

ggplot(klasyfikacja_filter,aes(y=acc,x=model_name,group=dataset_id,fill=model_name))+geom_bar(stat = "identity",position = "dodge")+facet_grid(.~dataset_id,scales="free")+theme(axis.text.x = element_text(angle = 45))

ggplot(data = klasyfikacja_filter,aes(x=task_id,y=acc,group=dataset_id))+geom_boxplot()+facet_grid(.~dataset_id)

#filtrowanie regresji

unique(regresja$model_name)
table(regresja$model_name)

regresja %>% group_by(model_name) %>% filter(n()>3)->regresja_filter

regresja_filter %>% group_by(task_id,dataset_id) %>% filter(n()>8)->regresja_filter

regresja_filter %>% group_by(model_name) %>% filter(n()>3)->regresja_filter

#regresja_filter$task_id<-substring(regresja_filter$task_id,first = 16)

#regresja_filter$model_name<-substring(regresja_filter$model_name,first = 9)

unique(regresja_filter$model_name)
table(regresja_filter$model_name)

ggplot(regresja_filter,aes(y=r2,x=model_name,group=dataset_id,fill=model_name))+geom_bar(stat = "identity",position = "dodge")+facet_grid(.~dataset_id,scales="free")+theme(axis.text.x = element_text(angle = 45))

ggplot(data = regresja_filter,aes(x=task_id,y=r2,group=dataset_id))+geom_boxplot()+facet_grid(.~dataset_id)

ggplot(regresja,aes(x=r2))+geom_histogram()+scale_x_log10()


#DataExplorer::create_report(klasyfikacja[-1])

#DataExplorer::create_report(klasyfikacja_filter)

xd<-listLearners(check.packages = TRUE)
xd[xd$missings==TRUE & xd$type=="regr",]

model1<-"regr.rpart"
model2<-"regr.gbm"
model3<-"regr.featureless"

train_filter<-klasyfikacja_filter[-c(1,2,4,6)]
train<-klasyfikacja[-1]


#train<-regresja[-1]

#robimy taska i learnera

train[sapply(train, is.character)] <- lapply(train[sapply(train, is.character)], 
                                       as.factor)

train_filter[sapply(train_filter, is.character)] <- lapply(train_filter[sapply(train_filter, is.character)], 
                                             as.factor)

set.seed(1)
train<-sample_frac(train)
train_filter<-sample_frac(train_filter)
task = makeRegrTask(id = "task", data = train_filter, "acc")
learner<-makeLearner(model2)
measures<-intersect(listMeasures(task),c("mse","rsq","mae","rmse"))
Rcuda<-list(mse=mse,rmse=rmse, mae=mae,rsq=rsq)
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(learner, task, cv,measures = Rcuda[measures])


#top 10 najpopularniejszy
klasyfikacja %>% group_by(model_name) %>% summarise(ile=n()) %>% top_n(10) %>% arrange(-ile)

# fani niszowych bibliotek
klasyfikacja %>% filter(library!="mlr") %>% group_by(library,added_by) %>% summarise(ile=n())
