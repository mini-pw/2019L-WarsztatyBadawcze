gamboost_pars <- readRDS("gamboost_pars.RData")
h2o.randomForest_pars <- readRDS("h2o.randomForest_pars.RData")
ranger_pars <- readRDS("ranger_pars.rdata")
rf_pars <- readRDS("rf_pars.RData")
svm_pars <- readRDS("svm_pars.RData")

source("ourBestiests/gettingData.R")
source("functions/elo.R")
source("functions/model_metrics.R")

inds <- c(1,2,NA,3,4)

datnames <- c("boston", "stock", "house_8L", "ilpd", "pokemon")
modnames <- c("gamboost", "h2o.randomForest", "ranger", "rf", "svm")
datsetsres <- list()


for(i in c(1,2,4,5)) {
  cat(datnames[i], "\n")
  tsk <- makeClassifTask("task", data = dsets[[i]]$data, target = dsets[[i]]$target)
  lrn <- list()
  lrn[[1]] <- makeLearner("classif.gamboost", predict.type = "prob", par.vals = gamboost_pars[[inds[i]]])
  lrn[[2]] <- makeLearner("classif.h2o.randomForest", predict.type = "prob", par.vals = h2o.randomForest_pars[[i]])
  lrn[[3]] <- makeLearner("classif.ranger", predict.type = "prob", par.vals = ranger_pars[[i]])
  lrn[[4]] <- makeLearner("classif.randomForest", predict.type = "prob", par.vals = rf_pars[[i]])
  lrn[[5]] <- makeLearner("classif.svm", predict.type = "prob", par.vals = svm_pars[[inds[i]]])
  
  datsetsres[[i]] <- list(similarity = NA, models = list())
  for(j in 1:5) {
    cat(modnames[j], "\n")
    res <- mlr::resample(lrn[[j]],tsk, mlr::cv5, measures = mlr::auc)
    datsetsres[[i]]$models[[j]] <- list(AUC = res$aggr["auc.test.mean"], par.vals = lrn[[j]]$par.vals)
  }
  names(datsetsres[[i]]$models) <- modnames
}

tsk <- makeClassifTask("task", data = dsets[[3]]$data, target = dsets[[3]]$target)
lrn <- list()
lrn[[2]] <- makeLearner("classif.h2o.randomForest", predict.type = "prob", par.vals = h2o.randomForest_pars[[3]])
lrn[[3]] <- makeLearner("classif.ranger", predict.type = "prob", par.vals = ranger_pars[[3]])
lrn[[4]] <- makeLearner("classif.randomForest", predict.type = "prob", par.vals = rf_pars[[3]])

datsetsres[[3]] <- list(similarity = NA, models = list())

for(j in 2:4) {
  res <- mlr::resample(lrn[[j]],tsk, mlr::cv5, measures = mlr::auc)
  datsetsres[[3]]$models[[j]] <- list(AUC = res$aggr["auc.test.mean"], par.vals = lrn[[j]]$par.vals)
}
names(datsetsres[[3]]$models) <- modnames[1:4]

names(datsetsres) <- datnames

library(jsonlite)
reference <- read_json("dataset.json")[[1]]

for(i in 1:5) {
  datsetsres[[i]]$similarity <- weightToSimilarity(datasetSimilarity_v3(paste0("./ourBestiests/", datnames[i], ".json")), 50)
}

saveRDS(datsetsres, file="best_datasets_and_models.RData")
