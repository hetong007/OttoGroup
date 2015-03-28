
require(xgboost)
require(methods)
library(caret)
library(Metrics)

library(debug)

train = read.csv('../data/train.csv',header=TRUE,stringsAsFactors = F)
test = read.csv('../data/test.csv',header=TRUE,stringsAsFactors = F)
train = train[,-1]
test = test[,-1]


y = train[,ncol(train)]
y = gsub('Class_','',y)
y = as.integer(y)-1 #xgboost take features in [0,numOfClass)

x = rbind(train[,-ncol(train)],test)
x = as.matrix(x)
x = matrix(as.numeric(x),nrow(x),ncol(x))
trind = 1:length(y)
teind = (nrow(train)+1):nrow(x)



# Set necessary parameter 
param <- list("objective" = "multi:softprob",
              "eval_metric" = "mlogloss",
              "num_class" = 9
)



lpXGB <- list(type = "Classification",
              library = "xgboost",
              loop = NULL)


prm <- data.frame(parameter = c("gamma", "max.depth", "min.child.weight", "eta", "subsample", "colsample_bytree", "NR"),
                  class = rep("numeric", 7),
                  label = c("Gamma", "MaxDepth", "MinChildWeight", "Eta", "SubSample", "ColsampleBytree", "NRounds"))
lpXGB$parameters <- prm

xgbGrid<-function(x, y, len = NULL){
    data.frame(gamma = c(1),
               max.depth = c(5),
               min.child.weight=c(3),
               eta=c(1),
               subsample=c(0.95),
               colsample_bytree=c(0.7),
               NR=c(100))
}

lpXGB$grid <- xgbGrid


xgbFit <- function(x, y, wts, param, lev, last, weights, classProbs, ...) {
    param2<-c(param,  list("objective" = "multi:softprob",
                           "eval_metric" = "mlogloss",
                           "num_class" = 9,
                           "nthread" = 8) )
    
    xgboost(param=param2, data = as.matrix(x), label = y, nrounds=param2$NR)
    
}

lpXGB$fit <- xgbFit


xgbPred <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
    predict(modelFit, newdata)
lpXGB$predict <- xgbPred



xgbProb <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
    predict(modelFit, newdata, type="probabilities")
lpXGB$prob <- xgbProb

xgbSort <- function(x) x[order(x$NR),]
lpXGB$sort <- xgbSort

set.seed(1234)
fitControl <- trainControl(method = "cv",
                           ## 10-fold CV...
                           number = 2,
                           ## repeated ten times
                           repeats = 1, verboseIter = T)


# mtrace(nominalTrainWorkflow)
#, selectionFunction=function(x, metric, maximize){best(metric="RMSE", x=x, maximize=maximize)}
myxgb<-train.default(x=x[trind,], y=as.factor(y),  method=lpXGB, trControl=fitControl)
