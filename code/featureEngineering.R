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
# col bind together
x = cBind(x,tfidfx)

# LDA-20 feature
# system('bash plda.sh')
pldamat = read.table('../data/plda.model')
nms = plda[,1]
plda = plda[,-1]

# End of feature engineering
save(x,y,trind,teind,file='../data/dat.rda')
