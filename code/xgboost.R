require(xgboost)
require(methods)
load('../data/dat.rda')
y = y-1 # xgboost take features in [0,numOfClass)

mlogloss <- function(preds, dtrain) {
    labels <- getinfo(dtrain, "label")
    labels <- labels+1
    n = length(labels)
    m = length(unique(labels))
    preds = matrix(preds,m,n)
    preds = t(preds)
    probs <- preds[cbind(1:n,labels)]
    err <- -mean(log(probs+1e-8))
    return(list(metric = "mlogloss", value = err))
}

thread = 8
param <- list("objective" = "multi:softprob",
              "bst:eta" = 0.005,
              "bst:max_depth" = 10,
              "gamma" = 1,
              "eval_metric" = "merror",
              "silent" = 1,
              "min_child_weight" = 100,
              "subsample" = 0.75,
              "num_class" = 9,
              "colsample_bytree" = 0.5,
              "nthread" = thread)
cv.nround = 5000

# Cross Validation
bst.cv = xgb.cv(param=param, data = x[trind,], label = y, 
                nfold = 5, nrounds=cv.nround)
bst.cv = apply(as.data.frame(bst.cv),2,as.numeric)
# plot(bst.cv[,1],type='l',ylim = range(bst.cv[,1],bst.cv[,3]))
# lines(bst.cv[,3],col=2)

# Prediction
nround = 1000
bst = xgboost(param=param, data = x[trind,], label = y, nrounds=nround)
pred = predict(bst,x[teind,])
pred = matrix(pred,9,length(pred)/9)
pred = t(pred)

# Output
source('output.R')
desc = generateDesc(param,nround,bst.cv)
makeSubmission(pred,desc)
