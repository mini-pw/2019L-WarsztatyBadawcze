trainset <- read.csv("train.csv", sep=";")
testset <- read.csv("WarsztatyBadawcze_test.csv", sep = ";")

columns <- c("Zuzanna", "Lena", "Maja", "Hanna", "Zofia", "Amelia", "Natalia", "Wiktoria",
             "Emilia", "Antonina", "Laura", "Anna", "Nadia", "Liliana", "Y")

trainset <- trainset[,columns]
testset <- testset[,columns]

logicols <-c("Zuzanna", "Natalia", "Nadia", "Liliana")
numecols <- columns[!(columns %in% c(logicols, "Y"))]

getpars <- function(column) {
  list(min = min(column), max = max(column))
}

standardise <- function(x, pars){
  (x-pars$min)/(pars$max - pars$min)
}

parlist <- lapply(trainset[,numecols], getpars)
for(i in 1:length(numecols)) {
  trainset[,numecols[i]] <- standardise(trainset[,numecols[i]], parlist[[i]])
  testset[,numecols[i]] <- standardise(testset[,numecols[i]], parlist[[i]])
}

##############

library(mlr)
tsk <- makeClassifTask("deferred", data = trainset, target = "Y")
lrn <- makeLearner("classif.ranger", predict.type = "prob", par.vals = list(min.node.size=6))

trn <- train(lrn, tsk)

prd <- predict(trn, newdata = testset)
write.csv(prd$data$prob.TRUE, "predictions.csv", row.names = FALSE)
