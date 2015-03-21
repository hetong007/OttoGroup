require(xgboost)
require(methods)
load('../data/dat.rda')
y = y-1 # xgboost take features in [0,numOfClass)

mlogloss <- function(preds, dtrain) {
    labels <- getinfo(dtrain, "label")
    labels <- labels+1
    n = length(labels)
    m = length(unique(labels))
    cat(str(preds))
    preds = matrix(preds,m,n)
    preds = t(preds)
    probs <- preds[cbind(1:n,labels)]
    err <- -mean(log(probs+1e-8))
    return(list(metric = "mlogloss", value = err))
}

thread = 8
param <- list("objective" = "multi:softprob",
              "bst:eta" = 0.05,
              "bst:max_depth" = 5,
              "gamma" = 1,
              "eval_metric" = "merror",
              "silent" = 1,
              "min_child_weight" = 50,
              "subsample" = 0.8,
              "num_class" = 9,
              "colsample_bytree" = 0.5,
              "nthread" = thread)
cv.nround = 5000

# Cross Validation
ind = sample(1:length(y),2000)
bst.cv = xgb.cv(param=param, data = x[ind,1:20], label = y[ind], 
                nfold = 3, nrounds=cv.nround,feval=mlogloss)
bst.cv = apply(as.data.frame(bst.cv),2,as.numeric)
plot(bst.cv[,1],type='l',ylim = range(bst.cv[,1],bst.cv[,3]))
lines(bst.cv[,3],col=2)

# Prediction
valid_uplim = bst.cv[,3]+bst.cv[,4]
nround = which.min(valid_uplim)
bst = xgboost(param=param, data = x[trind,], label = y, nrounds=nround)
pred = predict(bst,x[teind,])
pred = matrix(pred,9,length(pred)/9)
pred = t(pred)

# Output
source('output.R')
desc = generateDesc(param,nround,bst.cv)
makeSubmission(pred,desc)

