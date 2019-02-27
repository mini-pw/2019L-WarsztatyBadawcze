#install.packages("OpenML")
#install.packages("parsnip")
#install.packages("tidymodels")

library(OpenML)
library(parsnip)
library(tidymodels)

set.seed(1)

liver_disorders <- getOMLDataSet(data.id = 8L)
liver <- liver_disorders$data
head(liver)

# model
tree_mod <- 
  decision_tree(
    mode = "regression",
    tree_depth = 5
  ) %>% 
  set_engine("rpart")
tree_mod$engine
tree_mod$args
?rpart::rpart
?rpart::rpart.control

#https://tidymodels.github.io/parsnip/articles/articles/Models.html

tree_fit <- fit(
  object = tree_mod,
  formula = drinks~.,
  data = liver
)


# cv
cv <- vfold_cv(liver, v = 5)


#:# audyt
cv <- makeResampleDesc("CV", iters = 5)
r <- resample(regr_lrn, regr_task, cv)
MSE <- r$aggr
MSE
