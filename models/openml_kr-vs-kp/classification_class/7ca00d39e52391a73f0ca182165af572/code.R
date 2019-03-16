#:# libraries
library(digest)
library(mlr)
library(OpenML)

source("generate_audit_model_task_json_hubertbaniecki_v2.R"); 



#:# config
set.seed(123, "L'Ecuyer")



#:# data
df <- getOMLDataSet(3L)

#:# preprocessing
df <- df$data


#:# model

classif_task <- makeClassifTask(data=df, target = 'class')
classif_lrn <- makeLearner('classif.ada', predict.type = 'prob', par.vals = list(iter=2000))

#:# hash 
#:# c147040bb9c51e29cb17df401adcd6f4
hash <- digest(classif_lrn)
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(classif_lrn, classif_task, cv, measures = list(acc,auc,tpr,ppv,f1,tnr))
r$aggr


make3JSON('WojciechKretowicz','openml_kr-vs-kp','classification', classif_task, classif_lrn, c('ACC','AUC','Recall','Precision','f1','Specificity'))
