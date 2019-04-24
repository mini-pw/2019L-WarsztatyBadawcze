source("ourBestiests/gettingData.R")


mtries <- c(1,2,4,8)

aucs <- matrix(nrow = 5, ncol = 4, dimnames = list(c("boston", "stock", "house_8L", "ilpd", "pokemon"), mtries))


for(i in 1:5) {
  tsk <- makeClassifTask("task", data = dsets[[i]]$data, target = dsets[[i]]$target)
  for(j in 1:4) {
    lrn <- makeLearner("classif.ranger", predict.type = "prob", par.vals = list(min.node.size=6, mtry = mtries[j]))
    res <- mlr::resample(lrn, tsk, cv5, measures = list(mlr::auc))
    aucs[i,j] <- res$aggr["auc.test.mean"]
  }
}

saveRDS(aucs, "compare_mtries.RData")

rules <- c("gini", "extratrees")

aucs2 <- matrix(nrow = 5, ncol = 2, dimnames = list(c("boston", "stock", "house_8L", "ilpd", "pokemon"), rules))

for(i in 1:5) {
  tsk <- makeClassifTask("task", data = dsets[[i]]$data, target = dsets[[i]]$target)
  for(j in 1:2) {
    lrn <- makeLearner("classif.ranger", predict.type = "prob", par.vals = list(mtry = 1, splitrule=rules[j]))
    res <- mlr::resample(lrn, tsk, cv5, measures = list(mlr::auc))
    aucs2[i,j] <- res$aggr["auc.test.mean"]
  }
}

saveRDS(aucs2, "compare_splitrules.RData")
