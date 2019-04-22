source(paste0("ourBestiests/gettingData.R"))
library(mlr)
library(mlrMBO)

control <- makeMBOControl()
control <- setMBOControlTermination(control, iters = 100, max.evals = 100)
control <- setMBOControlInfill(control, crit = crit.ei)
control <- setMBOControlMultiPoint(control, method = "cl", cl.lie = min)
tunecontrol <- makeTuneControlMBO(mbo.control = control)

# lista linków do datasetów
# zmienna "dsets"

# lista modeli z ich parametrami
models_and_params <- list(
  svm = list(
    model = "classif.svm",
    parset = makeParamSet(
      makeDiscreteParam("kernel", values = c("radial", "sigmoid", "polynomial")),
      makeNumericParam("cost", -15, 15, trafo = function(x) 2^x),
      makeNumericParam("gamma", -15, 15, trafo = function(x) 2^x, requires = quote(kernel == "radial")),
      makeIntegerParam("degree", lower = 2, upper = 4, requires = quote(kernel == "polynomial"))
    )
  ),
  randomForest = list(
    model = "classif.randomForest",
    parset = makeParamSet(
      makeIntegerParam("ntree", 50, 500),
      makeIntegerParam("mtry", 3, 15),
      makeIntegerParam("nodesize", 1, 20)
    )
  ),
  ranger = list(
    model = "classif.ranger",
    parset = makeParamSet(
      makeIntegerParam("num.trees", 50, 500),
      makeIntegerParam("mtry", 3, 15),
      makeIntegerParam("min.node.size", 1, 20),
      makeDiscreteParam("splitrule", values = c("gini", "extratrees"))
    )
  ),
  h2o_randomForest = list(
    model = "classif.h2o.randomForest",
    parset = makeParamSet(
      makeIntegerParam("ntrees", 50, 500),
      makeIntegerParam("mtries", 3, 15),
      makeIntegerParam("nbins", 10, 40)
    )
  ),
  lda = list(
    model = "classif.lda",
    parset = makeParamSet(
      makeNumericParam("nu", 2, 15),
      makeNumericParam("tol", -20, 0, trafo = function(x) 2^x)
    )
  ),
  gamboost = list(
    model = "classif.gamboost",
    parset = makeParamSet(
      makeDiscreteParam("baselearner", values = c("bbs", "bols", "btree")),
      makeIntegerParam("mstop", 50, 250),
      makeNumericParam("nu", -10, -2, trafo = function(x) 2^x)
    )
  )
)

best_pars <- lapply(models_and_params, function(x) {
  best_pars_ <- lapply(dsets, function(y) {
    pars <- tuneParams(
      makeLearner(x$model, predict.type = "prob"),
      makeClassifTask(id = "task", data = y$data, target = y$target),
      resampling = makeFixedHoldoutInstance(train.inds = 1:ltsr,
                                            test.inds = (ltsr + 1):(ltsr + lvsr),
                                            size = ltsr + lvsr),
      measures = mlr::auc,
      par.set = x$parset,
      control = tunecontrol,
      show.info = TRUE
    )
    pars$x
  })
  best_pars_
})

print(best_pars)
