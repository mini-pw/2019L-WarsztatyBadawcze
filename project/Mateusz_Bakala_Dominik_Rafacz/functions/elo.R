datasetSimilarity <- function(datasetPath) {
  # TO-DO: porównać docelowy oraz bieżący dataset
  dataset <- read_json(datasetPath)[[1]]
  exp(-compare_datasets(dataset, reference))
}

elo <- function(modelAUC, modelScore, datasetWeight, tune) {
  difference <- matrix(ncol = length(modelAUC), nrow = length(modelAUC))
  # liczenie update klasyfikacji
  for (i in 1:length(modelAUC)) {
    model <- names(modelAUC)[i]
    # każdy z każdym
    for (j in 1:length(modelAUC)) {
      otherModel <- names(modelAUC)[j]
      # dzielimy przez zwycięzcę minus przegranego
      scoreDiff <- modelAUC[model] - modelAUC[otherModel]
      difference[j, i] <- (scoreDiff + 1)/2 - 1/(10^((modelScore[otherModel] - modelScore[model])/tune) + 1)
      # if (modelAUC[model] >= modelAUC[otherModel]) {
      #   difference[j, i] <- (exp(modelAUC[model]) - exp(modelAUC[otherModel]))/exp(modelScore[model] - modelScore[otherModel])
      # } else {
      #   difference[j, i] <- (exp(modelAUC[model]) - exp(modelAUC[otherModel]))/exp(modelScore[otherModel] - modelScore[model])
      # }
    }
  }
  difference <- datasetWeight * colSums(difference)
  names(difference) <- names(modelAUC)
  difference
}

computeELOScores <- function(niter = 6, tune = 5) {
  # inicjalizacja zmiennych
  sep <- .Platform$file.sep
  modelScore <- numeric(0)
  scoreHistory <- numeric(0)
  appeared <- numeric(0)
  testedDirs <- character(0)
  modelsInDirs <- numeric(0)
  weights <- numeric(0)
  aucStats <- list()
  
  datasetDirs <- list.dirs(recursive = FALSE)
  # dataset poniżej wyrzuca error :/
  datasetDirs <- datasetDirs[datasetDirs != paste0(".", sep, "openml_kc2")]
  for (ddir in datasetDirs) {
    datasetWeight <- datasetSimilarity(paste0(ddir, sep, "dataset.json"))
    taskDirs <- list.dirs(path = ddir, recursive = FALSE)
    for (tdir in taskDirs) {
      # filtrowanie wyłącznie tasków klasyfikacji
      if (grepl("classification", tdir)) {
        message(paste0("Present task: ", tdir))
        modelDirs <- list.dirs(tdir, recursive = FALSE)
        modelAUC <- numeric(0)
        # policzenie podobieństwa datasetów
        # zebranie najlepszych wyników dla każdego typu modelu
        for (mdir in modelDirs) {
          model <- fromJSON(paste0(mdir, sep, "model.json"))
          audit <- fromJSON(paste0(mdir, sep, "audit.json"))
          if (!is.na(audit$performance$auc)) {
            modelAUC[model$model_name] <- max(modelAUC[model$model_name], audit$performance$auc, na.rm = TRUE)
          }
        }
        for (model in names(modelAUC)) {
          # classif.neuralnet często zwraca AUC = 0.5, to oznacza jakiś problem
          if (is.na(modelAUC[model]) || model %in% c("classif.neuralnet", "classif.featureless")) {
            # if (is.na(modelAUC[model])) {
            modelAUC <- modelAUC[names(modelAUC) != model]
          } else {
            if (is.na(modelScore[model])) {
              modelScore[model] <- 0
              appeared[model] <- 0
            }
            appeared[model] <- appeared[model] + 1
          }
        }
        # teoretycznie niepotrzebne, ale bezpieczniej będzie nie wykonywać tego, gdy modelAUC jest puste lub zawiera jeden model
        if (length(modelAUC) > 1) {
          # przeskalowanie do [0, 1] przy 0 <- 0.5 oraz 1 <- {0, 1}
          modelAUC <- 2*abs(modelAUC - 0.5)
          aucStats[[tdir]]$data <- modelAUC
          aucStats[[tdir]]$weight <- datasetWeight
          # dodanie ddir do testedDirs, jeśli nie pojawił się wcześniej
          testedDirs <- c(testedDirs, ddir)
          modelsInDirs <- c(modelsInDirs, length(modelAUC))
          weights <- c(weights, weightToSimilarity(datasetWeight))
        }
      }
    }
  }
  
  # oldMax <- -Inf
  for (i in 1:niter) {
    message(rep("-", 40))
    message(paste0("Iter number ", i))
    message(rep("-", 40))
    lapply(aucStats, function(x) {
      # swoista miara błędu
      difference <- elo(x$data, modelScore, x$weight, tune)
      # update klasyfikacji pseudo-ELO dla modeli
      for (model in names(x$data)) {
        modelScore[model] <<- modelScore[model] + difference[model]
      }
      # if (max(modelScore) != oldMax) {
      #   message(paste0("New best score so far: ", max(modelScore)))
      # }
      # oldMax <<- max(modelScore)
    })
    if (i != niter) {
      scoreHistory <- rbind(scoreHistory, modelScore)
    }
    # print(modelScore)
  }
  
  result <- cbind(data.frame(modelScore = modelScore, appeared = appeared), t(scoreHistory))
  if (niter == 1) {
    colnames(result) <- c("modelScore", "appeared")
  } else {
    colnames(result) <- c("modelScore", "appeared", paste0("scoreHistory", 1:(niter-1)))
  }
  result <- result[order(result$modelScore, decreasing = TRUE), ]
  
  dirStats <- data.frame(numberOfModels = modelsInDirs, datasetSimilarity = weights)
  row.names(dirStats) <- testedDirs
  dirStats <- dirStats[order(dirStats$datasetSimilarity, decreasing = TRUE), ]
  # names(modelsInDirs) <- testedDirs
  # modelsInDirs <- sort(modelsInDirs, decreasing = TRUE)
  
  list(data = result, numberOfModels = dirStats)
}

weightToSimilarity <- function(weight) {
  exp(weight/100)
}

computeAllSimiliarities <- function() {
  sep <- .Platform$file.sep
  datasetDirs <- list.dirs(recursive = FALSE)
  # dataset poniżej wyrzuca error :/
  datasetDirs <- datasetDirs[datasetDirs != paste0(".", sep, "openml_kc2")]
  
  rs_vec <- c(count_factors_range(reference), count_nums_skewness(reference))
  for (ddir in datasetDirs) {
    print(paste0("Dataset: ", ddir))
    #datasetWeight <- datasetSimilarity(paste0(ddir, sep, "dataset.json"))
    dataset <- read_json(paste0(ddir, sep, "dataset.json"))[[1]]
    ds_vec <- c(count_factors_range(dataset), count_nums_skewness(dataset))
    #print(ds_vec)
    dw <- sqrt(sum((ds_vec-rs_vec)^2))
    #print(dw)
    datasetWeight <- exp(-dw/100)
    print(datasetWeight)
  }
}
