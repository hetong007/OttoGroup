require(e1071)
require(methods)
load('../data/dat.rda')

svm.model = svm(x = x[trind,], y = as.factor(y))

cv.nround = 2000

# Cross Validation
bst.cv = xgb.cv(param=param, data = x[trind,], label = y, 
                nfold = 3, nrounds=cv.nround)
bst.cv = apply(as.data.frame(bst.cv),2,as.numeric)
plot(bst.cv[,1],type='l',ylim = range(bst.cv[,1],bst.cv[,3]))
lines(bst.cv[,3],col=2)

# Prediction
nround = 2000
bst = xgboost(param=param, data = x[trind,], label = y, nrounds=nround)
pred = predict(bst,x[teind,])
pred = matrix(pred,9,length(pred)/9)
pred = t(pred)

# Output
source('output.R')
desc = generateDesc(param,nround,bst.cv)
makeSubmission(pred,desc)
