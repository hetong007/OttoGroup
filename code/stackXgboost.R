require(xgboost)
load('../data/dat.rda')

thread = 8

# Parameter Setting
etas = c(0.001,0.01)
nrounds = c(500,1000)
max_depths = c(10,14)
gammas = c(0.1,1,10)
subsamples = c(0.8)
min_child_weights = c(50)

# Storing matrix
numcol = length(etas)*length(nrounds)*length(max_depths)*length(gammas)*
    length(subsamples)*length(min_child_weights)
stackx = matrix(0,nrow(x),numcol)
L = 1
timeused = list()

for (eta in etas)
    for (nround in nrounds)
        for (max_depth in max_depths)
            for (gamma in gammas)
                for (subsample in subsamples)
                    for (min_child_weight in min_child_weights)
                    {
                        timestp = proc.time()
                        param <- list("objective" = "binary:logitraw",
                                      "bst:eta" = eta,
                                      "bst:max_depth" = max_depth,
                                      "eval_metric" = "auc",
                                      "silent" = 1,
                                      "gamma" = gamma,
                                      "subsample" = subsample,
                                      "min_child_weight" = min_child_weight,
                                      "nthread" = thread)
                        bst.cv = xgb.cv(param=param, data = x[trind,], label = y, 
                                        nfold = 5, nrounds=nround, missing=-100,
                                        prediction = TRUE)
                        stackx[trind,L] = bst.cv[[2]]
                        bst = xgboost(param=param, data = x[trind,], label = y, 
                                     nrounds=nround, missing=-100)
                        pred = predict(bst,x[teind,])
                        stackx[teind,L] = pred
                        timeused[[L]] = proc.time()-timestp
                        cat(timeused[[L]][1:3],'\n')
                        save(stackx,L,file='../data/stackx.tmp.rda')
                        L = L+1
                        cat(eta,nround,max_depth,gamma,subsample,min_child_weight,'\n')
                    }

thread = 8
hyperparam <- list("objective" = "binary:logitraw",
              "bst:eta" = 0.001,
              "bst:max_depth" = 12,
              "gamma" = 0.1,
              "eval_metric" = "auc",
              "silent" = 1,
              "min_child_weight" = 40,
              "subsample" = 0.75,
              "nthread" = thread)
nround = 8000
bst.cv = xgb.cv(param=hyperparam, data = stackx[trind,], label = y, 
                nfold = 5, nrounds=nround)
bst.cv = apply(as.data.frame(bst.cv),2,as.numeric)
plot(bst.cv[,1],type='l',ylim = range(bst.cv[,1],bst.cv[,3]))
lines(bst.cv[,3],col=2)


nround = 8
bst = xgboost(param=hyperparam, data = stackx[trind,], label = y, nrounds=nround)
pred = predict(bst,stackx[teind,])
pred = 1/(1+exp(-pred))

desc = generateDesc(param,nround)
makeSubmission(pred,desc)




