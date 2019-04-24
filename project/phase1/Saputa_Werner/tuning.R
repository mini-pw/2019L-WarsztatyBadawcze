# 
# tunedParams <- tuneParams(
#   learner = lrn_scT,
#   task = tsk_ap,
#   resampling = makeResampleInstance("CV", iters = 3, task = tsk_ap),
#   par.set = svm_params,
#   control = control
# )
# 
# tuned_lrn <- setHyperPars(
#   learner = lrn_scF,
#   par.vals = tunedParams$x
# )
# 
# tuned_train_ <- train(tuned_lrn, tsk_ap)
# prediction <- predict(tuned_train_, newdata = ap_tt)
# results[3,1] <- performance(prediction, measures = acc)
# performance(prediction, measures = acc)
# length(levels(ap_tt$district))

def_params <- list(
  "classif.cvglmnet " = list(
    "alpha" = 0.403,
    "lambda" = 0.004
  ),
  "classif.xgboost" = list(
    "nrounds" = 4168,
    "eta" = 0.018,
    "subsample" = 0.839,
    "max_depth" = 13,
    "min_child_weight" = 2.06,
    "colsample_bytree" = 0.752,
    "colsample_bylevel" = 0.585,
    "lambda" = 0.982,
    "alpha" = 1.113
  )
)
