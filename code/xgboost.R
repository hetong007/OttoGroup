require(xgboost)
require(methods)
load('../data/dat.rda')
y = y-1 # xgboost take features in [0,numOfClass)

thread = 16
param <- list("objective" = "multi:softprob",
              "bst:eta" = 0.03,
              "bst:max_depth" = 20,
              "gamma" = 1,
              "eval_metric" = "mlogloss",
              "silent" = 1,
              "min_child_weight" = 50,
              "subsample" = 0.8,
              "num_class" = 9,
              "colsample_bytree" = 1,
              "nthread" = thread)
cv.nround = 1500

# Cross Validation
bst.cv = xgb.cv(param=param, data = x[trind,], label = y, 
                nfold = 3, nrounds=cv.nround)
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
