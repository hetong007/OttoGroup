devtools::install_local('~/github/xgboost/xgboost_0.3-4.tar.gz')
require(xgboost)

train_mat = matrix(rnorm(2000*5),2000,5)
train_class = sample(0:2,2000,replace=TRUE)

tuning=list()
for(depth in seq(6, 16, by=2)){
    for(eta in seq(0.01, 0.1, length.out = 4)){
        print(paste(depth, eta, sep="-"))
        tuning_param = list("objective" = "multi:softprob",
                            "eval_metric" = "mlogloss",
                            "eta"=eta,
                            "max_depth"=depth,
                            "num_class" = 9,
                            "nthread" = 8)
        tuning.cv = xgb.cv(param=tuning_param, 
                            data = train_mat, 
                            label = train_class,  
                            nfold = 3, nrounds=1500)  
        tuning.cv=tuning.cv[, lapply(.SD, as.numeric)]
        tuning.cv[, ':='(index=1:nrow(tuning.cv), eta=eta, depth=depth)]
        tuning.cv[which.min(test.mlogloss.mean + test.mlogloss.std)]
        tuning=c(tuning, list(tuning.cv[which.min(test.mlogloss.mean + test.mlogloss.std)]))
    }
}