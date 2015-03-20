require(autoencoder)
require(methods)
load('../data/dat.rda')

x = as.matrix(x)

system.time({ae = autoencode(X.train = x,N.hidden=1000,unit.type='tanh',
                 lambda=1,beta=1,rho=0.05,epsilon=0.1,
                 max.iterations = 10,rescale.flag = TRUE)})