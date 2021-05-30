#Import data
dataVORcode0 <- VOR5_code_0
apply(dataVORcode0,2,function(x) sum(is.na(x)))
#summary(IMOCA_VORcode0)

#Prepare train and test sets
indexVORcode0 <- sample(1:nrow(dataVORcode0),round(0.75*nrow(dataVORcode0)))
trainVORcode0 <- dataVORcode0[indexVORcode0,]
testVORcode0 <- dataVORcode0[-indexVORcode0,]


#Do linear fit
lm.fitVORcode0 <- glm(V~., data=trainVORcode0)
summary(lm.fitVORcode0)
pr.lmVORcode0 <- predict(lm.fitVORcode0,testVORcode0)
MSE.lmVORcode0 <- sum((pr.lmVORcode0 - testVORcode0$V)^2)/nrow(testVORcode0)

#Scale data
maxsVORcode0 <- apply(dataVORcode0, 2, max) 
minsVORcode0 <- apply(dataVORcode0, 2, min)

scaledVORcode0 <- as.data.frame(scale(dataVORcode0, center = minsVORcode0, scale = maxsVORcode0 - minsVORcode0))

#Prepare train and test sets scaled
trainVORcode0_ <- scaledVORcode0[indexVORcode0,]
testVORcode0_ <- scaledVORcode0[-indexVORcode0,]

#Prepare NN based on data
library(neuralnet)
nVORcode0 <- names(trainVORcode0_)
fVORcode0 <- as.formula(paste("V ~", paste(nVORcode0[!nVORcode0 %in% "V"], collapse = " + ")))
nnVORcode0 <- neuralnet(fVORcode0,data=trainVORcode0_,hidden=c(9,2),linear.output=T)

#Show NN
plot(nnVORcode0)

#Test NN
pr.nnVORcode0 <- compute(nnVORcode0,testVORcode0_[,1:2])
pr.nnVORcode0_ <- pr.nnVORcode0$net.result*(max(dataVORcode0$V)-min(dataVORcode0$V))+min(dataVORcode0$V)
test.rVORcode0 <- (testVORcode0_$V)*(max(dataVORcode0$V)-min(dataVORcode0$V))+min(dataVORcode0$V)

#Compare to LM
MSE.nnVORcode0 <- sum((test.rVORcode0 - pr.nnVORcode0_)^2)/nrow(testVORcode0_)

print(paste(MSE.lmVORcode0,MSE.nnVORcode0))


#Plot
# par(mfrow=c(1,2))
# 
# plot(testVORcode0$V,pr.nnVORcode0_,col='red',main='Real vs predicted NN',pch=18,cex=0.7)
# abline(0,1,lwd=2)
# legend('bottomright',legend='9/2',pch=18,col='green', bty='n')
# 
# plot(testVORcode0$V,pr.lmVORcode0,col='blue',main='Real vs predicted lm',pch=18, cex=0.7)
# abline(0,1,lwd=2)
# legend('bottomright',legend='LM',pch=18,col='blue', bty='n', cex=.95)
# 
#Predict

#TWAvVORcode0 = scale(120, center = minsVORcode0[1], scale = maxsVORcode0[1] - minsVORcode0[1])
#TWSvVORcode0 = scale(0, center = minsVORcode0[2], scale = maxsVORcode0[2] - minsVORcode0[2])

#prediction.nnVORcode0 <- compute(nnVORcode0,data.frame(TWA=TWAvVORcode0,TWS=TWSvVORcode0))
#prediction.nnVORcode0_ <- prediction.nnVORcode0$net.result*(max(dataVORcode0$V)-min(dataVORcode0$V))+min(dataVORcode0$V)
#prediction.nnVORcode0_

#Iterate best fit
#MSE.doVORcode0 <- matrix(, nrow=5, ncol=3)
#for (i in 1:5){
#  for (j in 1:3){
#      nnVORcode0 <- neuralnet(fVORcode0,data=trainVORcode0_,hidden=c(i,j),linear.output=T)
#      pr.nnVORcode0 <- compute(nnVORcode0,testVORcode0_[,1:2])
#      pr.nnVORcode0_ <- pr.nnVORcode0$net.result*(max(dataVORcode0$V)-min(dataVORcode0$V))+min(dataVORcode0$V)
#      test.rVORcode0 <- (testVORcode0_$V)*(max(dataVORcode0$V)-min(dataVORcode0$V))+min(dataVORcode0$V)
#      
#      #Compare to LM
#      MSE.doVORcode0[i,j] <- sum((test.rVORcode0 - pr.nnVORcode0_)^2)/nrow(testVORcode0_)
#      MSE.doVORcode0[i,j]
#      print(c(i, j, MSE.doVORcode0[i,j]))
#      # update GUI console
#      flush.console()
#      
#  }
#}
  
