MS <- function(modelName, ...) {
  parlist <- as.list(match.call(expand.dots = FALSE)$`...`)
  if(length(parlist) == 0) {
    parcomb = list(list())
  } else if(length(parlist) == 1){
    parlist <- lapply(parlist, function(e) eval(as.expression(e)))
    nam <- names(parlist)
    parcomb <- lapply(parlist[[1]], function(e) {
      t <- list(e)
      names(t) <- nam
      t
    })
  } else {
    parlist <- lapply(parlist, function(e) eval(as.expression(e)))
    parcomb <- expand.grid(parlist, stringsAsFactors = FALSE)
    nam <- colnames(parcomb)
    parcomb <- lapply(1:nrow(parcomb), function(i) {
      t <- parcomb[i,]
      l <- list()
      for (j in 1:ncol(t)) {
        l <- c(l, t[,j])
      }
      names(l) <- nam
      l
    })
  }
  
  ret <- list(modelsNames = rep(modelName, length(parcomb)), 
              modelsParams = parcomb)
  class(ret) <- "ModelsSettings"
  ret
}

'+.ModelsSettings' <- function(MS1,MS2) {
  stopifnot(class(MS2) == "ModelsSettings")
  MS1$modelsNames = c(MS1$modelsNames, MS2$modelsNames)
  MS1$modelsParams = c(MS1$modelsParams, MS2$modelsParams)
  MS1
}

print.ModelsSettings <- function(MS) {
  cat(paste0(
    "Set of ModelSettings
It can generate: ", length(MS$modelsNames), " models of types: \n\n"
  ))
  cat(paste(MS$modelsNames, MS$modelsParams, sep = " ", collapse = "\n"))
}
