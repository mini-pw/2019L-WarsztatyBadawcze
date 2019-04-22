raw_test <- read.csv("../WarsztatyBadawcze_test.csv", sep = ";")
DataExplorer::plot_correlation(raw_test)

test <- raw_test[,c("Zuzanna", "Lena", "Maja", "Hanna", "Zofia", "Amelia", "Natalia", "Wiktoria",
                    "Emilia", "Antonina", "Laura", "Anna", "Nadia", "Liliana", "Y")]

cmp <- DataExplorer::plot_histogram(test_mod)

standardise <- function(x){
  (x-min(x))/(max(x) - min(x))
}

test_mod <- test[,-15]
test_mod$Lena <- standardise(test_mod$Lena)
test_mod$Maja <- standardise(log(test_mod$Maja + 1))
test_mod$Hanna <- standardise(test_mod$Hanna)
test_mod$Zofia <- standardise(test_mod$Zofia)
test_mod$Amelia <- standardise(test_mod$Amelia)
test_mod$Wiktoria <- standardise(test_mod$Wiktoria)
test_mod$Emilia <- standardise(log(test_mod$Emilia + 1))
test_mod$Antonina <- standardise(test_mod$Antonina)
test_mod$Laura <- standardise(test_mod$Laura)
test_mod$Anna <- standardise(test_mod$Anna)
test_mod$Zuzanna <- as.logical(test_mod$Zuzanna)
test_mod$Natalia <- as.logical(test_mod$Natalia)
test_mod$Nadia <- as.logical(test_mod$Nadia)
test_mod$Liliana <- as.logical(test_mod$Liliana)

write.csv(test_mod, "WarsztatyBadawcze_transformed.csv", row.names = FALSE)
create_fake_json(test_mod)
