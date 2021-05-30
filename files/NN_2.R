#Import data
dataVORspi <- VOR2_spi
apply(dataVORspi,2,function(x) sum(is.na(x)))
#summary(IMOCA_VORspi)

#Prepare train and test sets
indexVORspi <- sample(1:nrow(dataVORspi),round(0.75*nrow(dataVORspi)))
trainVORspi <- dataVORspi[indexVORspi,]
testVORspi <- dataVORspi[-indexVORspi,]


#Do linear fit
lm.fitVORspi <- glm(V~., data=trainVORspi)
summary(lm.fitVORspi)
pr.lmVORspi <- predict(lm.fitVORspi,testVORspi)
MSE.lmVORspi <- sum((pr.lmVORspi - testVORspi$V)^2)/nrow(testVORspi)

#Scale data
maxsVORspi <- apply(dataVORspi, 2, max) 
minsVORspi <- apply(dataVORspi, 2, min)

scaledVORspi <- as.data.frame(scale(dataVORspi, center = minsVORspi, scale = maxsVORspi - minsVORspi))

#Prepare train and test sets scaled
trainVORspi_ <- scaledVORspi[indexVORspi,]
testVORspi_ <- scaledVORspi[-indexVORspi,]

#Prepare NN based on data
library(neuralnet)
nVORspi <- names(trainVORspi_)
fVORspi <- as.formula(paste("V ~", paste(nVORspi[!nVORspi %in% "V"], collapse = " + ")))
nnVORspi <- neuralnet(fVORspi,data=trainVORspi_,hidden=c(9,2),linear.output=T)

#Show NN
plot(nnVORspi)

#Test NN
pr.nnVORspi <- compute(nnVORspi,testVORspi_[,1:2])
pr.nnVORspi_ <- pr.nnVORspi$net.result*(max(dataVORspi$V)-min(dataVORspi$V))+min(dataVORspi$V)
test.rVORspi <- (testVORspi_$V)*(max(dataVORspi$V)-min(dataVORspi$V))+min(dataVORspi$V)

#Compare to LM
MSE.nnVORspi <- sum((test.rVORspi - pr.nnVORspi_)^2)/nrow(testVORspi_)

print(paste(MSE.lmVORspi,MSE.nnVORspi))


#Plot
# par(mfrow=c(1,2))
# 
# plot(testVORspi$V,pr.nnVORspi_,col='red',main='Real vs predicted NN',pch=18,cex=0.7)
# abline(0,1,lwd=2)
# legend('bottomright',legend='9/2',pch=18,col='green', bty='n')
# 
# plot(testVORspi$V,pr.lmVORspi,col='blue',main='Real vs predicted lm',pch=18, cex=0.7)
# abline(0,1,lwd=2)
# legend('bottomright',legend='LM',pch=18,col='blue', bty='n', cex=.95)

#Predict

#TWAvVORspi = scale(120, center = minsVORspi[1], scale = maxsVORspi[1] - minsVORspi[1])
#TWSvVORspi = scale(20, center = minsVORspi[2], scale = maxsVORspi[2] - minsVORspi[2])####

#prediction.nnVORspi <- compute(nnVORspi,data.frame(TWA=TWAvVORspi,TWS=TWSvVORspi))
#prediction.nnVORspi_ <- prediction.nnVORspi$net.result*(max(dataVORspi$V)-min(dataVORspi$V))+min(dataVORspi$V)
#prediction.nnVORspi_

#Iterate best fit
#for (i in 1:7){
#  for (j in 1:3){
#      nnVORspi <- neuralnet(f,data=trainVORspi_,hidden=c(i,j),linear.output=T)
#      pr.nnVORspi <- compute(nnVORspi,testVORspi_[,1:2])
#      pr.nnVORspi_ <- pr.nnVORspi$net.result*(max(dataVORspi$V)-min(dataVORspi$V))+min(dataVORspi$V)
#      test.rVORspi <- (testVORspi_$V)*(max(dataVORspi$V)-min(dataVORspi$V))+min(dataVORspi$V)
#      
#      #Compare to LM
#      MSE.doVORspi[i,j] <- sum((test.rVORspi - pr.nnVORspi_)^2)/nrow(testVORspi_)
#      MSE.doVORspi[i,j]
#  }
#}
  
