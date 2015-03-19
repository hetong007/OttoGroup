require(xgboost)
require(methods)
load('../data/dat.rda')
y = y-1 # xgboost take features in [0,numOfClass)

thread = 8
param <- list("objective" = "multi:softprob",
              "bst:eta" = 0.005,
              "bst:max_depth" = 20,
              "gamma" = 1,
              "eval_metric" = "mlogloss",
              "silent" = 1,
              "min_child_weight" = 50,
              "subsample" = 0.9,
              "num_class" = 9,
              "nthread" = thread)
cv.nround = 10

# Cross Validation
bst.cv = xgb.cv(param=param, data = x[trind,], label = y, 
                nfold = 2, nrounds=cv.nround)
bst.cv = apply(as.data.frame(bst.cv),2,as.numeric)
plot(bst.cv[,1],type='l',ylim = range(bst.cv[,1],bst.cv[,3]))
lines(bst.cv[,3],col=2)

# Prediction
nround = 6000
bst = xgboost(param=param, data = x[trind,], label = y, nrounds=nround)
pred = predict(bst,x[teind,])
pred = matrix(pred,9,length(pred)/9)
pred = t(pred)

# Output
source('output.R')
desc = generateDesc(param,nround,bst.cv)
makeSubmission(pred,desc)
