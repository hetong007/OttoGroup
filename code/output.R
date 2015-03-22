generateDesc = function(param,nround,cvres,num_bag)
{
    namelist = c('eta','max_depth','gamma','min_child_weight',
                 'subsample','colsample_bytree','bag')
    res = paste0('cv',cvres[nround,3],'nround',nround,'bag',num_bag)
    pname = names(param)
    for (nm in namelist)
    {
        ind = grep(nm,names(param))
        if (length(ind>0))
            res = paste0(res,nm,param[[ind]])
    }
    return(res)
}

makeSubmission = function(pred,desc)
{
    pred = format(pred, digits=2,scientific=F)
    pred = data.frame(1:nrow(pred),pred)
    names(pred) = c('id',
                    paste0('Class_',1:9))
    csvname = paste0('../submission/',desc,'.csv')
    write.csv(pred,file=csvname,
              quote=FALSE,row.names=FALSE)
    zipname = paste0('../submission/',desc,'.zip')
    zip.command = paste('zip',zipname,csvname)
    system(zip.command)
}
