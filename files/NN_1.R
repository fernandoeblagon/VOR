#Import data
dataVORjib <- VOR1_jib
apply(dataVORjib,2,function(x) sum(is.na(x)))
#summary(IMOCA_VORjib)

#Prepare train and test sets
indexVORjib <- sample(1:nrow(dataVORjib),round(0.75*nrow(dataVORjib)))
trainVORjib <- dataVORjib[indexVORjib,]
testVORjib <- dataVORjib[-indexVORjib,]


#Do linear fit
lm.fitVORjib <- glm(V~., data=trainVORjib)
summary(lm.fitVORjib)
pr.lmVORjib <- predict(lm.fitVORjib,testVORjib)
MSE.lmVORjib <- sum((pr.lmVORjib - testVORjib$V)^2)/nrow(testVORjib)

#Scale data
maxsVORjib <- apply(dataVORjib, 2, max) 
minsVORjib <- apply(dataVORjib, 2, min)

scaledVORjib <- as.data.frame(scale(dataVORjib, center = minsVORjib, scale = maxsVORjib - minsVORjib))

#Prepare train and test sets scaled
trainVORjib_ <- scaledVORjib[indexVORjib,]
testVORjib_ <- scaledVORjib[-indexVORjib,]

#Prepare NN based on data
library(neuralnet)
nVORjib <- names(trainVORjib_)
fVORjib <- as.formula(paste("V ~", paste(nVORjib[!nVORjib %in% "V"], collapse = " + ")))
nnVORjib <- neuralnet(fVORjib,data=trainVORjib_,hidden=c(9,2),linear.output=T)

#Show NN
plot(nnVORjib)

#Test NN
pr.nnVORjib <- compute(nnVORjib,testVORjib_[,1:2])
pr.nnVORjib_ <- pr.nnVORjib$net.result*(max(dataVORjib$V)-min(dataVORjib$V))+min(dataVORjib$V)
test.rVORjib <- (testVORjib_$V)*(max(dataVORjib$V)-min(dataVORjib$V))+min(dataVORjib$V)

#Compare to LM
MSE.nnVORjib <- sum((test.rVORjib - pr.nnVORjib_)^2)/nrow(testVORjib_)

print(paste(MSE.lmVORjib,MSE.nnVORjib))


#Plot
# par(mfrow=c(1,2))
# 
# plot(testVORjib$V,pr.nnVORjib_,col='red',main='Real vs predicted NN',pch=18,cex=0.7)
# abline(0,1,lwd=2)
# legend('bottomright',legend='9/2',pch=18,col='green', bty='n')
# 
# plot(testVORjib$V,pr.lmVORjib,col='blue',main='Real vs predicted lm',pch=18, cex=0.7)
# abline(0,1,lwd=2)
# legend('bottomright',legend='LM',pch=18,col='blue', bty='n', cex=.95)

#Predict

#TWAvVORjib = scale(120, center = minsVORjib[1], scale = maxsVORjib[1] - minsVORjib[1])
#TWSvVORjib = scale(20, center = minsVORjib[2], scale = maxsVORjib[2] - minsVORjib[2])

#prediction.nnVORjib <- compute(nnVORjib,data.frame(TWA=TWAvVORjib,TWS=TWSvVORjib))
#prediction.nnVORjib_ <- prediction.nnVORjib$net.result*(max(dataVORjib$V)-min(dataVORjib$V))+min(dataVORjib$V)
#prediction.nnVORjib_

#Iterate best fit
#for (i in 1:7){
#  for (j in 1:3){
#      nnVORjib <- neuralnet(f,data=trainVORjib_,hidden=c(i,j),linear.output=T)
#      pr.nnVORjib <- compute(nnVORjib,testVORjib_[,1:2])
#      pr.nnVORjib_ <- pr.nnVORjib$net.result*(max(dataVORjib$V)-min(dataVORjib$V))+min(dataVORjib$V)
#      test.rVORjib <- (testVORjib_$V)*(max(dataVORjib$V)-min(dataVORjib$V))+min(dataVORjib$V)
#      
 #     #Compare to LM
#      MSE.doVORjib[i,j] <- sum((test.rVORjib - pr.nnVORjib_)^2)/nrow(testVORjib_)
#      MSE.doVORjib[i,j]
#  }
#}
  
