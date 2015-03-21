load('../data/oridat.rda')
# FeatureEngineering
require(Matrix)

x = as(x,'dgCMatrix')

# TF-IDF
tfidf = function(Mat)
{
    oneMat = Mat==1
    rS = colSums(oneMat)
    idf = log((nrow(Mat)+1)/(rS+1))
    TfIdf = Diagonal(x = 1/rowSums(Mat)) %*% Mat %*% Diagonal(x=idf)
    return(TfIdf)
}

tfidfx = tfidf(x)

# BM25
bm25 = function(Mat,k1=1.5,b=0.75)
{
    oneMat = Mat==1
    rS = colSums(oneMat)
    idf = log((nrow(Mat)-rS+0.5)/(rS+0.5))
    tf = Diagonal(x = 1/rowSums(Mat)) %*% Mat
    avgdl = mean(rowSums(Mat))
    tfreg = tf*(k1+1)/(tf+k1*(1-b+b*nrow(Mat)/avgdl))
    BM25 = tfreg %*% Diagonal(x=idf)
    return(BM25)
}

bm25x = bm25(x)

# LDA-20 feature
# system('bash plda.sh')
plda = read.table('../data/plda.model')
nms = as.character(plda[,1])
nms = as.numeric(gsub('f','',nms))
ind = order(nms)
plda = plda[,-1]
plda = plda[ind,]
plda = as.matrix(plda)
rS = rowSums(plda)
plda = diag(1/rS) %*% plda

pldax = x %*% plda

# Statistics of the data
rSx = rowSums(x!=0)
tmp = by(as.matrix(x[trind,]),as.factor(y),colSums)
tmp = do.call(cbind,tmp)
tmp = tmp %*% diag(1/colSums(tmp))
Bayesx = x %*% tmp

# col bind together
x = cBind(x,tfidfx,bm25x,pldax,rSx,Bayesx)

# End of feature engineering
save(x,y,trind,teind,file='../data/dat.rda')
