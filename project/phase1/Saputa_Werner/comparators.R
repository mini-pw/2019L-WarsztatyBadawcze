require(mlr)

porownywacz<-function(modele,dane,target){

task <- makeClassifTask(id = "task", data = dane, target =target)
cv <- makeResampleDesc("CV", iters = 5)

podsumowanie<-sapply(modele, function(model){
  learner<-makeLearner(model[[1]],predict.type = "prob",par.vals=model[-1])
  r <- resample(learner,task,cv, measures = auc)
  r<-r$aggr
  r
})
modele[[which.max(podsumowanie)]]
}

our_best_shot <- function(model_names, dataset){
  
  task <- makeClassifTask(id = "task", data = dataset, target = "Y")
  cv <- makeResampleDesc("CV", iters = 5)
  
  score_summary <- sapply(model_names, function(model){
    print(paste0("Testing now (cross-validation): ", model, "--------------------------"))
    if(is.null(def_params[[model]]))
      learner<-makeLearner(model, predict.type = "prob")
    else
      learner<-makeLearner(model, predict.type = "prob", par.vals = def_params[[model]])
    r <- resample(learner,task,cv, measures = list(mlr::auc))
    r<-r$aggr
    r
  })
  model_names[[which.max(score_summary)]]
}
