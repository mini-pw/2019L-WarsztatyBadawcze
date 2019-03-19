# install.packages("DALEX")
# install.packages("auditor")
library(DALEX)
library(auditor)
library(randomForest)

# apartments data
data("apartments")
head(apartments)
data("apartmentsTest")
head(apartmentsTest)

# linear model
apartments_lm_model <- lm(m2.price ~ ., data = apartments)
# MSE
predicted_mi2_lm <- predict(apartments_lm_model, apartmentsTest)
sqrt(mean((predicted_mi2_lm - apartmentsTest$m2.price)^2))

# random forest
set.seed(59)
apartments_rf_model <- randomForest(m2.price ~ ., data = apartments)
# MSE
predicted_mi2_rf <- predict(apartments_rf_model, apartmentsTest)
sqrt(mean((predicted_mi2_rf - apartmentsTest$m2.price)^2))


# create explainers and audit functions
explainer_lm <- explain(apartments_lm_model, 
                        data = apartmentsTest[,2:6], y = apartmentsTest$m2.price)


explainer_rf <- explain(apartments_rf_model, 
                  data = apartmentsTest[,2:6], y = apartmentsTest$m2.price)



# Function model_performance() calculates predictions and residuals for validation dataset apartmentsTest.
mp_lm <- model_performance(explainer_lm)
mp_rf <- model_performance(explainer_rf)

plot(mp_lm, mp_rf)
plot(mp_lm, mp_rf, geom = "boxplot")

# Model agnostic variable importance is calculated by means of permutations. 
# We simply substract the loss function calculated for validation dataset with permuted values 
# for a single variable from the loss function calculated for validation dataset. 
vi_lm <- variable_importance(explainer_lm, loss_function = loss_root_mean_square)
vi_lm

vi_rf <- variable_importance(explainer_rf, loss_function = loss_root_mean_square)
vi_rf

plot(vi_lm, vi_rf)


# Partial Dependence Plots show the expected output condition on a selected variable
sv_rf  <- single_variable(explainer_rf, variable =  "construction.year", type = "pdp")
sv_lm  <- single_variable(explainer_lm, variable =  "construction.year", type = "pdp")
plot(sv_rf, sv_lm)

# A tool that helps to understand what happens with factor variables is Merging Path Plot.
svd_rf  <- single_variable(explainer_rf, variable = "district", type = "factor")
svd_lm  <- single_variable(explainer_lm, variable = "district", type = "factor")

plot(svd_rf, svd_lm)


# Detailed models

audit_lm <- audit(apartments_lm_model, 
                  data = apartmentsTest, y = apartmentsTest$m2.price)
audit_rf <- audit(apartments_rf_model, 
                  data = apartmentsTest, y = apartmentsTest$m2.price, label = "rm")

plot(audit_rf, type = "Prediction", variable = "m2.price")



# Improved model
library("DALEX")

apartments_lm_model_improved <- lm(m2.price ~ I(construction.year < 1935 | construction.year > 1995) + surface + floor + 
                                     no.rooms + district, data = apartments)

explainer_lm_improved <- explain(apartments_lm_model_improved, label = "lm_imp",
                                 data = apartmentsTest[,2:6], y = apartmentsTest$m2.price)

mp_lm_improved <- model_performance(explainer_lm_improved)
plot(mp_lm_improved, mp_lm, mp_rf, geom = "boxplot")

