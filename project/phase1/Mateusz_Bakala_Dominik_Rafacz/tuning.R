source("ourBestiests/gettingData.R")
library(mlr)
library(mlrMBO)
options(java.parameters = "-Xmx8g")
Sys.setenv('JAVA_HOME' = 'C:\\Program Files\\Java\\jre1.8.0_201')

control <- makeMBOControl()
control <- setMBOControlTermination(control, iters = 100, max.evals = 100)
control <- setMBOControlInfill(control, crit = crit.ei)
control <- setMBOControlMultiPoint(control, method = "cl", cl.lie = min)
tunecontrol <- makeTuneControlMBO(mbo.control = control)

# lista linków do datasetów
# zmienna "dsets"

# lista modeli z ich parametrami
models_and_params <- list(
  # lda = list(
  #   model = "classif.lda",
  #   parset = makeParamSet(
  #     makeNumericParam("nu", 2, 15),
  #     makeNumericParam("tol", -20, 0, trafo = function(x) 2^x)
  #   )
  # ),
  # gamboost = list(
  #   model = "classif.gamboost",
  #   parset = makeParamSet(
  #     makeDiscreteParam("baselearner", values = c("bbs", "bols")),
  #     makeIntegerParam("mstop", 50, 250),
  #     makeNumericParam("nu", -10, -2, trafo = function(x) 2^x)
  #   )
  # ),
  # h2o_randomForest = list(
  #   model = "classif.h2o.randomForest",
  #   parset = makeParamSet(
  #     makeIntegerParam("ntrees", 50, 500),
  #     makeIntegerParam("mtries", 1, 9),
  #     makeIntegerParam("nbins", 10, 40)
  #   )
  # ),
  # ranger = list(
  #   model = "classif.ranger",
  #   parset = makeParamSet(
  #     makeIntegerParam("num.trees", 50, 500),
  #     makeIntegerParam("mtry", 1, 9),
  #     makeIntegerParam("min.node.size", 1, 20),
  #     makeDiscreteParam("splitrule", values = c("gini", "extratrees"))
  #   )
  # ),
  # svm = list(
  #   model = "classif.svm",
  #   parset = makeParamSet(
  #     makeDiscreteParam("kernel", values = c("radial", "sigmoid", "polynomial")),
  #     makeNumericParam("cost", -15, 15, trafo = function(x) 2^x),
  #     makeNumericParam("gamma", -15, 15, trafo = function(x) 2^x, requires = quote(kernel == "radial")),
  #     makeIntegerParam("degree", lower = 2, upper = 4, requires = quote(kernel == "polynomial"))
  #   )
  # ),
  randomForest = list(
    model = "classif.randomForest",
    parset = makeParamSet(
      makeIntegerParam("ntree", 50, 500),
      makeIntegerParam("mtry", 1, 9),
      makeIntegerParam("nodesize", 1, 20)
    )
  )
)

# library(parallelMap)
# parallelStartSocket(4, level = "mlr.tuneParams")
best_pars <- lapply(models_and_params, function(x) {
  best_pars_ <- lapply(dsets, function(y) {
    message(paste0(x$model, " on ", y$target))
    pars <- tuneParams(
      makeLearner(x$model, predict.type = "prob"),
      makeClassifTask(id = "task", data = y$data, target = y$target),
      resampling = cv3,
      measures = mlr::auc,
      par.set = x$parset,
      control = tunecontrol,
      show.info = TRUE
    )
    pars$x
  })
  best_pars_
})
# parallelStop()

# do usunięcia później
best_pars <- lapply(models_and_params, function(x) {
  pars <- tuneParams(
    makeLearner(x$model, predict.type = "prob"),
    makeClassifTask(id = "task", data = dsets[[3]]$data, target = dsets[[3]]$target),
    resampling = cv3,
    measures = mlr::auc,
    par.set = x$parset,
    control = tunecontrol,
    show.info = TRUE
  )
  pars$x
})

print(best_pars)
