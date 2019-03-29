#:# libraries
library(digest)
library(OpenML)
library(caret)

#:# config
set.seed(1)

#:# data
dermatology_dat <- getOMLDataSet(data.id = 35L)
dermatology <- dermatology_dat$data
head(dermatology)

#:# preprocessing
#Usuwam obserwacje z obecnym NA
dermatology <- dermatology[!is.na(dermatology$Age),]
dermatology$erythema
head(dermatology)

#:# model
train_control <- trainControl(method="cv", number = 5)
classif_lrn <- train(erythema~., data = dermatology, method = "treebag",
                     trControl = train_control,
                     metric = "Accuracy")
Acc <- classif_lrn$results$Accuracy

#:# hash
#:# 71d19aab84a554ef20475ad007c66c85
hash <- digest(list(erythema~., dermatology, "treebag", NULL))
hash

#:# audit
Acc

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()