# Read data in
train = read.csv('../data/train.csv',header=TRUE,stringsAsFactors = F)
test = read.csv('../data/test.csv',header=TRUE,stringsAsFactors = F)
train = train[,-1]
test = test[,-1]

y = train[,ncol(train)]
y = gsub('Class_','',y)
y = as.integer(y)
x = rbind(train[,-ncol(train)],test)
x = as.matrix(x)

trind = 1:length(y)
teind = (nrow(train)+1):nrow(x)
 
save(x,y,trind,teind,file='../data/oridat.rda')

# Save to plda format
words = paste0('f',1:93)
pldaout = rep('',nrow(x))
for (i in 1:nrow(x))
{
  ind = which(x[i,]>0)
  pldaout[i] = paste(words[ind],x[i,ind],collapse=' ',sep=' ')
  cat(i,'\r')
}
writeLines(pldaout,'../data/plda.data')

