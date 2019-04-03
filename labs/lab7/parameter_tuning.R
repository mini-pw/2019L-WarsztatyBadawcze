library(OpenML)
library(mlr)

set.seed(1)

# Discrete set of parameters
discrete_ps = makeParamSet(
  makeDiscreteParam("C", values = c(0.5, 1.0, 1.5, 2.0)),
  makeDiscreteParam("sigma", values = c(0.5, 1.0, 1.5, 2.0))
)
print(discrete_ps)

# 3-fold CV
rdesc = makeResampleDesc("CV", iters = 3L)
# Create Tune Grid, use all combinations of parameters
ctrl = makeTuneControlGrid()
res = tuneParams("classif.ksvm", task = iris.task, resampling = rdesc,
                 par.set = discrete_ps, control = ctrl)



# Create a search space for the C hyperparameter from 0.01 to 0.1 and sigma hyperparameter from 0.5 to 2.0
ps = makeParamSet(
  makeNumericParam("C", lower = 0.01, upper = 0.1),
  makeNumericParam("sigma", lower = 0.5, upper = 2.0)
)
# ex: grid search search with resolution 15
ctrl = makeTuneControlGrid(resolution = 15L)
res = tuneParams("classif.ksvm", task = iris.task, resampling = rdesc,
                 par.set = ps, control = ctrl)


# ex: random search with 100 iterations
ctrl = makeTuneControlRandom(maxit = 100L)
res = tuneParams("classif.ksvm", task = iris.task, resampling = rdesc,
                 par.set = ps, control = ctrl)

