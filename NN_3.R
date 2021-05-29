#Import data
dataVORstay <- VOR3_stay
apply(dataVORstay,2,function(x) sum(is.na(x)))
#summary(IMOCA_VORstay)

#Prepare train and test sets
indexVORstay <- sample(1:nrow(dataVORstay),round(0.75*nrow(dataVORstay)))
trainVORstay <- dataVORstay[indexVORstay,]
testVORstay <- dataVORstay[-indexVORstay,]


#Do linear fit
lm.fitVORstay <- glm(V~., data=trainVORstay)
summary(lm.fitVORstay)
pr.lmVORstay <- predict(lm.fitVORstay,testVORstay)
MSE.lmVORstay <- sum((pr.lmVORstay - testVORstay$V)^2)/nrow(testVORstay)

#Scale data
maxsVORstay <- apply(dataVORstay, 2, max) 
minsVORstay <- apply(dataVORstay, 2, min)

scaledVORstay <- as.data.frame(scale(dataVORstay, center = minsVORstay, scale = maxsVORstay - minsVORstay))

#Prepare train and test sets scaled
trainVORstay_ <- scaledVORstay[indexVORstay,]
testVORstay_ <- scaledVORstay[-indexVORstay,]

#Prepare NN based on data
library(neuralnet)
nVORstay <- names(trainVORstay_)
fVORstay <- as.formula(paste("V ~", paste(nVORstay[!nVORstay %in% "V"], collapse = " + ")))
nnVORstay <- neuralnet(fVORstay,data=trainVORstay_,hidden=c(9,2),linear.output=T)

#Show NN
plot(nnVORstay)

#Test NN
pr.nnVORstay <- compute(nnVORstay,testVORstay_[,1:2])
pr.nnVORstay_ <- pr.nnVORstay$net.result*(max(dataVORstay$V)-min(dataVORstay$V))+min(dataVORstay$V)
test.rVORstay <- (testVORstay_$V)*(max(dataVORstay$V)-min(dataVORstay$V))+min(dataVORstay$V)

#Compare to LM
MSE.nnVORstay <- sum((test.rVORstay - pr.nnVORstay_)^2)/nrow(testVORstay_)

print(paste(MSE.lmVORstay,MSE.nnVORstay))


#Plot
# par(mfrow=c(1,2))
# 
# plot(testVORstay$V,pr.nnVORstay_,col='red',main='Real vs predicted NN',pch=18,cex=0.7)
# abline(0,1,lwd=2)
# legend('bottomright',legend='9/2',pch=18,col='green', bty='n')
# 
# plot(testVORstay$V,pr.lmVORstay,col='blue',main='Real vs predicted lm',pch=18, cex=0.7)
# abline(0,1,lwd=2)
# legend('bottomright',legend='LM',pch=18,col='blue', bty='n', cex=.95)
# 
#Predict

#TWAvVORstay = scale(120, center = minsVORstay[1], scale = maxsVORstay[1] - minsVORstay[1])
#TWSvVORstay = scale(0, center = minsVORstay[2], scale = maxsVORstay[2] - minsVORstay[2])

#prediction.nnVORstay <- compute(nnVORstay,data.frame(TWA=TWAvVORstay,TWS=TWSvVORstay))
#prediction.nnVORstay_ <- prediction.nnVORstay$net.result*(max(dataVORstay$V)-min(dataVORstay$V))+min(dataVORstay$V)
#prediction.nnVORstay_

#Iterate best fit
#MSE.doVORstay <- matrix(, nrow=5, ncol=3)
#for (i in 1:5){
#  for (j in 1:3){
#      nnVORstay <- neuralnet(fVORstay,data=trainVORstay_,hidden=c(i,j),linear.output=T)
#      pr.nnVORstay <- compute(nnVORstay,testVORstay_[,1:2])
#      pr.nnVORstay_ <- pr.nnVORstay$net.result*(max(dataVORstay$V)-min(dataVORstay$V))+min(dataVORstay$V)
#      test.rVORstay <- (testVORstay_$V)*(max(dataVORstay$V)-min(dataVORstay$V))+min(dataVORstay$V)
#      
#      #Compare to LM
#      MSE.doVORstay[i,j] <- sum((test.rVORstay - pr.nnVORstay_)^2)/nrow(testVORstay_)
#      MSE.doVORstay[i,j]
#      print(c(i, j, MSE.doVORstay[i,j]))
#      # update GUI console
#      flush.console()
#      
#  }
#}
  