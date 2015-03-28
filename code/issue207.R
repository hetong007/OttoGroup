library('foreach')
library('doParallel')
library('xgboost')

x = matrix(rnorm(1:1000),200,5)
target = sample(0:2,200,replace = TRUE)

param <- list("objective" = "multi:softprob",
              "eval_metric" = "mlogloss",
              "num_class" = 3,
              "nthread" = 2)

BootStrappedModels <- function(seed){
    tempModel <- xgboost(params=param, data=x, label=(target), nrounds=5)
    return (tempModel)
}

cl <- makeCluster(1)
registerDoParallel(cl)

models <- foreach (i=(1), .packages=c('xgboost')) %dopar% {
  BootStrappedModels(i)
}

stopCluster(cl)
preds <- predict(models[[1]],x) ####This is where failure occurs
