#Import data
dataVORhgnk <- VOR6_hgnk
apply(dataVORhgnk,2,function(x) sum(is.na(x)))
#summary(IMOCA_VORhgnk)

#Prepare train and test sets
indexVORhgnk <- sample(1:nrow(dataVORhgnk),round(0.75*nrow(dataVORhgnk)))
trainVORhgnk <- dataVORhgnk[indexVORhgnk,]
testVORhgnk <- dataVORhgnk[-indexVORhgnk,]


#Do linear fit
lm.fitVORhgnk <- glm(V~., data=trainVORhgnk)
summary(lm.fitVORhgnk)
pr.lmVORhgnk <- predict(lm.fitVORhgnk,testVORhgnk)
MSE.lmVORhgnk <- sum((pr.lmVORhgnk - testVORhgnk$V)^2)/nrow(testVORhgnk)

#Scale data
maxsVORhgnk <- apply(dataVORhgnk, 2, max) 
minsVORhgnk <- apply(dataVORhgnk, 2, min)

scaledVORhgnk <- as.data.frame(scale(dataVORhgnk, center = minsVORhgnk, scale = maxsVORhgnk - minsVORhgnk))

#Prepare train and test sets scaled
trainVORhgnk_ <- scaledVORhgnk[indexVORhgnk,]
testVORhgnk_ <- scaledVORhgnk[-indexVORhgnk,]

#Prepare NN based on data
library(neuralnet)
nVORhgnk <- names(trainVORhgnk_)
fVORhgnk <- as.formula(paste("V ~", paste(nVORhgnk[!nVORhgnk %in% "V"], collapse = " + ")))
nnVORhgnk <- neuralnet(fVORhgnk,data=trainVORhgnk_,hidden=c(9,2),linear.output=T)

#Show NN
plot(nnVORhgnk)

#Test NN
pr.nnVORhgnk <- compute(nnVORhgnk,testVORhgnk_[,1:2])
pr.nnVORhgnk_ <- pr.nnVORhgnk$net.result*(max(dataVORhgnk$V)-min(dataVORhgnk$V))+min(dataVORhgnk$V)
test.rVORhgnk <- (testVORhgnk_$V)*(max(dataVORhgnk$V)-min(dataVORhgnk$V))+min(dataVORhgnk$V)

#Compare to LM
MSE.nnVORhgnk <- sum((test.rVORhgnk - pr.nnVORhgnk_)^2)/nrow(testVORhgnk_)

print(paste(MSE.lmVORhgnk,MSE.nnVORhgnk))


#Plot
# par(mfrow=c(1,2))
# 
# plot(testVORhgnk$V,pr.nnVORhgnk_,col='red',main='Real vs predicted NN',pch=18,cex=0.7)
# abline(0,1,lwd=2)
# legend('bottomright',legend='9/2',pch=18,col='green', bty='n')
# 
# plot(testVORhgnk$V,pr.lmVORhgnk,col='blue',main='Real vs predicted lm',pch=18, cex=0.7)
# abline(0,1,lwd=2)
# legend('bottomright',legend='LM',pch=18,col='blue', bty='n', cex=.95)
# 
#Predict

#TWAvVORhgnk = scale(120, center = minsVORhgnk[1], scale = maxsVORhgnk[1] - minsVORhgnk[1])
#TWSvVORhgnk = scale(0, center = minsVORhgnk[2], scale = maxsVORhgnk[2] - minsVORhgnk[2])

#prediction.nnVORhgnk <- compute(nnVORhgnk,data.frame(TWA=TWAvVORhgnk,TWS=TWSvVORhgnk))
#prediction.nnVORhgnk_ <- prediction.nnVORhgnk$net.result*(max(dataVORhgnk$V)-min(dataVORhgnk$V))+min(dataVORhgnk$V)
#prediction.nnVORhgnk_

#Iterate best fit
#MSE.doVORhgnk <- matrix(, nrow=5, ncol=3)
#for (i in 1:5){
#  for (j in 1:3){
#      nnVORhgnk <- neuralnet(fVORhgnk,data=trainVORhgnk_,hidden=c(i,j),linear.output=T)
#      pr.nnVORhgnk <- compute(nnVORhgnk,testVORhgnk_[,1:2])
#      pr.nnVORhgnk_ <- pr.nnVORhgnk$net.result*(max(dataVORhgnk$V)-min(dataVORhgnk$V))+min(dataVORhgnk$V)
#      test.rVORhgnk <- (testVORhgnk_$V)*(max(dataVORhgnk$V)-min(dataVORhgnk$V))+min(dataVORhgnk$V)
#      
#      #Compare to LM
#      MSE.doVORhgnk[i,j] <- sum((test.rVORhgnk - pr.nnVORhgnk_)^2)/nrow(testVORhgnk_)
#      MSE.doVORhgnk[i,j]
#      print(c(i, j, MSE.doVORhgnk[i,j]))
#      # update GUI console
#      flush.console()
#      
#  }
#}
  
