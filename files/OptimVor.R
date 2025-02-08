# Library declaration
library(neuralnet)
library(rWind)
library(geosphere)
library(lubridate)
library(ggplot2)
library(ggmap)
library(mapproj)
library(rgenoud)
library(gridExtra)
library(readxl)
library(tidyr)

# Import polars and train NN, only when needed i.e. when the polars are updated
# VOR1_jib <- read_excel("C:/Personal/Vendee Globe 2024/VOR1-jib.xlsx")
# VOR1_jib <- VOR1_jib %>% pivot_longer(cols = 3:37, names_to = "TWS", values_to = "V")
# VOR1_jib <- (as.data.frame(subset(VOR1_jib, select = c(1, 3, 4))))
# VOR1_jib <- transform(VOR1_jib, TWS = as.numeric(TWS))
# colnames(VOR1_jib)[1] <- "TWA"
# VOR2_spi <- read_excel("C:/Personal/Vendee Globe 2024/VOR2-spi.xlsx")
# VOR2_spi <- VOR2_spi %>% pivot_longer(cols = 3:37, names_to = "TWS", values_to = "V")
# VOR2_spi <- (as.data.frame(subset(VOR2_spi, select = c(1, 3, 4))))
# VOR2_spi <- transform(VOR2_spi, TWS = as.numeric(TWS))
# colnames(VOR2_spi)[1] <- "TWA"
# 
# 
# source("C:/Personal/VOR/NN_1.R")
# source("C:/Personal/VOR/NN_2.R")

# Define the number of 3-hour steps to be calculated (Time Limit)
TL = 8


# General matrix definition
de <- matrix(, nrow=TL, ncol=8)
pred <- matrix(, nrow=1, ncol=7)
colnames(de) <- c("Lon", "Lat", "Angle", "TWA", "TWS", "Bearing", "Speed", "Sail")
colnames(pred) <- c("VORjib", "VORspi", "stay", "lightj", "VORcode0", "heavyg", "lightg")
try2w <- matrix(, nrow=TL, ncol=10)
colnames(try2w) <- c("trial", "tack", "Lon", "Lat", "Bearing", "TWA", "Sail", "V", "WA", "TWS")
BeOp <- c(rep.int(0, TL))

# Distance in degrees of the size of area to be obtained for wind prediction. The reason for this is that if the starting and end point are in a similar 
# latitude or longitude then the optimizer will sail outside the prediction area!
leeway <- 10

# Define the GMT vessel time and Present Latitude an Longitude as well as Destination Latitude and Longitude. Values must be expressed in degrees hence minutes must be divided by 
# 60 and seconds by 3600
TiSt <- c(2025, 2,8,9)
PLa = 45+2/60+45/60/60
PLo = -11-27/60-37/60/60
DLa = 46+28/60+16/60/60
DLo = -1-49/60-53/60/60

# Define straight line bearing and fill the step array with the straight line bearing which will be used to Begin the Optimization.
BeOp[] = as.integer(bearingRhumb(c(PLo,PLa),c(DLo,DLa)))
if (BeOp[1]<0){
  BeOp = 360+BeOp
}

# Define the step size in hours. Numbers other than 3 hours are discouraged since the NOAA predictions are in 3-hour intervals. We could in principle work with multiples of 3 but the script may missbehave.
Rate = 3

# Offlimits is lat_max, lat_min, lon_max, lon_min
OffLimits = c(40, 37, -23, -32)

# Save startin conditions for reuse
PLaR <- PLa
PLoR <- PLo
TiStR <- TiSt

# Download wind data from NOOA using the rwind package.
# The wind is downloaded in 3-hour intervals. If a number of steps lower than 48 is desired, then we can comment out the part of wind that will not be needed. This is 
# a time-consuming step that takes the longest due to the amount of data being downloaded from NOAA. A single 3-hour interval prediction will be in the range of 
# 200 - 400 kB and would take around 2 seconds to download.
if(TL>2){
  WiSt <- TiSt
u1 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u2 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u3 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u4 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u5 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u6 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u7 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u8 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u9 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u10 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u11 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u12 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)

dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)


if(TL>12){

  u13 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
  u14 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
  u15 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
  u16 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
  u17 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
  u18 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
  u19 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
  u20 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
  u21 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
  u22 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
  u23 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
  u24 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
  
  dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
  WiSt[2]<-month(dsm)
  WiSt[1]<-year(dsm)
  WiSt[3]<-day(dsm)
  WiSt[4]<-hour(dsm)
if(TL>24){
u25 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u26 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u27 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u28 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u29 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u30 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u31 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u32 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u33 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u34 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u35 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u36 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)

dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)

u37 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u38 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u39 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u40 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u41 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u42 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u43 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u44 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u45 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u46 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u47 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
dsm <- strptime(paste(WiSt[3], WiSt[2], WiSt[1], WiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
WiSt[2]<-month(dsm)
WiSt[1]<-year(dsm)
WiSt[3]<-day(dsm)
WiSt[4]<-hour(dsm)
u48 <- wind.dl(WiSt[1],WiSt[2],WiSt[3],WiSt[4],c(PLo, DLo)[which.min(c(PLo, DLo))]-leeway,c(PLo, DLo)[which.max(c(PLo, DLo))]+leeway,c(PLa, DLa)[which.min(c(PLa, DLa))]-leeway,c(PLa, DLa)[which.max(c(PLa, DLa))]+leeway)
}

}
}


# Definition of the target function to be optimized. This function can commented out once it's been run.
# The function will calculate the distance and return the value in 10 x km, i.e. if the distance calculated is 235 km, the output would be 2.35*10^1.
{
target <- function(x) {
  
  
  for (i in 1:TL){
    
    if (i==1){
      uuu = u1
    }
    if (i==2){
      uuu = u2
    }
    if (i==3){
      uuu = u3
    }
    if (i==4){
      uuu = u4
    }
    if (i==5){
      uuu = u5
    }
    if (i==6){
      uuu = u6
    }
    if (i==7){
      uuu = u7
    }
    if (i==8){
      uuu = u8
    }
    if (i==9){
      uuu = u9
    }
    if (i==10){
      uuu = u10
    }
    if (i==11){
      uuu = u11
    }
    if (i==12){
      uuu = u12
    }
    if (i==13){
      uuu = u13
    }
    if (i==14){
      uuu = u14
    }
    if (i==15){
      uuu = u15
    }
    if (i==16){
      uuu = u16
    }
    if (i==17){
      uuu = u17
    }
    if (i==18){
      uuu = u18
    }
    if (i==19){
      uuu = u19
    }
    if (i==20){
      uuu = u20
    }
    if (i==21){
      uuu = u21
    }
    if (i==22){
      uuu = u22
    }
    if (i==23){
      uuu = u23
    }
    if (i==24){
      uuu = u24
    }
    
    if (i==25){
      uuu = u25
    }
    if (i==26){
      uuu = u26
    }
    if (i==27){
      uuu = u27
    }
    if (i==28){
      uuu = u28
    }
    if (i==29){
      uuu = u29
    }
    if (i==30){
      uuu = u30
    }
    if (i==31){
      uuu = u31
    }
    if (i==32){
      uuu = u32
    }
    if (i==33){
      uuu = u33
    }
    if (i==34){
      uuu = u34
    }
    if (i==35){
      uuu = u35
    }
    if (i==36){
      uuu = u36
    }
    if (i==37){
      uuu = u37
    }
    if (i==38){
      uuu = u38
    }
    if (i==39){
      uuu = u39
    }
    if (i==40){
      uuu = u40
    }
    if (i==41){
      uuu = u41
    }
    if (i==42){
      uuu = u42
    }
    if (i==43){
      uuu = u43
    }
    if (i==44){
      uuu = u44
    }
    if (i==45){
      uuu = u45
    }
    if (i==46){
      uuu = u46
    }
    if (i==47){
      uuu = u47
    }
    if (i==48){
      uuu = u48
    }
    
    # twind <- wind.fit_int(uuu[which((uuu$`latitude (degrees_north)` == round(PLa/0.5)*0.5) & (uuu$`longitude (degrees_east)` == round(PLo/0.5)*0.5)),])
    twind <- (uuu[which((uuu$`lat` == round(PLa/0.5)*0.5) & (uuu$`lon` == round(PLo/0.5)*0.5)),])
    if (twind[7] < 4){
      twind[7] = 4
    } else
    {
      twind[7] = twind[7]*1.9438
    }
    if (twind[6] > 180){
      twind[6] = twind[6]-180
    } else
    {twind[6] = twind[6]+180
    }

    angle = abs(as.double(x[i])-twind[6])
    if (angle > 180){
      angle = 360 - angle
    }
    
    TWAvVORjib = scale(angle, center = minsVORjib[1], scale = maxsVORjib[1] - minsVORjib[1])
    TWSvVORjib = scale(twind[7], center = minsVORjib[2], scale = maxsVORjib[2] - minsVORjib[2])
    
    TWAvVORspi = scale(angle, center = minsVORspi[1], scale = maxsVORspi[1] - minsVORspi[1])
    TWSvVORspi = scale(twind[7], center = minsVORspi[2], scale = maxsVORspi[2] - minsVORspi[2])
    
    prediction.nnVORjib <- compute(nnVORjib,data.frame(TWA=TWAvVORjib,TWS=TWSvVORjib))
    prediction.nnVORjib_ <- prediction.nnVORjib$net.result*(max(dataVORjib$V)-min(dataVORjib$V))+min(dataVORjib$V)
    pred[1] <- prediction.nnVORjib_
    prediction.nnVORspi <- compute(nnVORspi,data.frame(TWA=TWAvVORspi,TWS=TWSvVORspi))
    prediction.nnVORspi_ <- prediction.nnVORspi$net.result*(max(dataVORspi$V)-min(dataVORspi$V))+min(dataVORspi$V)
    pred[2] <- prediction.nnVORspi_

    DistanceSailed=as.double(pred[which.max(pred[1:2])])*Rate*1852
    # DistanceSailed
    
    p <- cbind(PLo,PLa)
    d <- destPoint(p,as.double(x[i]),DistanceSailed)
    de[i,1] <- d[1]
    de[i,2] <- d[2]
    de[i,3] <- as.double(angle)
    de[i,4] <- as.double(twind[6])
    de[i,5] <- as.double(twind[7])
    de[i,6] <- as.double(x[i])
    de[i,7] <- as.double(pred[which.max(pred[1:2])])
    de[i,8] <- colnames(pred)[which.max(pred[1:2])]
    
    
    if ((d[2] > OffLimits[1]) & (d[2] < OffLimits[2]) & (d[1] > OffLimits[3]) & (d[1] < OffLimits[4] )){
    }    else    {
      PLa <- d[2]
      PLo <- d[1]
    }
    
    dtm <- strptime(paste(TiSt[3], TiSt[2], TiSt[1], TiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
    TiSt[2]<-month(dtm)
    TiSt[1]<-year(dtm)
    TiSt[3]<-day(dtm)
    TiSt[4]<-hour(dtm)
    
    # print(c(i, PLa, DLa, PLo, DLo, x[i]))
    # update GUI console
    flush.console()
  }
  
  result <- distHaversine(c(PLo,PLa),c(DLo,DLa))/10000
  # print(result)
  # # update GUI console
  flush.console()
  
  return(result)
}
}

# Calculate the distance using a direct line between the Start and Goal points.
a <- target(BeOp)

# Define boundary conditions for optimization. boundy[1,] and [2,] define the maximum deviation from the straight line that the boat can tack. 
boundy <- matrix(, nrow=2, ncol=TL)
boundy[1,] <- BeOp-90
boundy[2,] <- BeOp+90
boundy <- t(boundy)

# Run optimization
fidu <-  genoud(target, max.generations = 50, print.level = 1, hard.generation.limit = TRUE, data.type.int=TRUE, pop.size = 50, Domains = boundy, boundary.enforcement=2, starting.values=BeOp, nvars=TL,max=FALSE)


# Define new function to calculate the distance traveled using the direct line for plotting. This function can commented out once it's been run.
{ course <- function(x) {
  
  for (i in 1:TL){
    
    if (i==1){
      uuu = u1
    }
    if (i==2){
      uuu = u2
    }
    if (i==3){
      uuu = u3
    }
    if (i==4){
      uuu = u4
    }
    if (i==5){
      uuu = u5
    }
    if (i==6){
      uuu = u6
    }
    if (i==7){
      uuu = u7
    }
    if (i==8){
      uuu = u8
    }
    if (i==9){
      uuu = u9
    }
    if (i==10){
      uuu = u10
    }
    if (i==11){
      uuu = u11
    }
    if (i==12){
      uuu = u12
    }
    if (i==13){
      uuu = u13
    }
    if (i==14){
      uuu = u14
    }
    if (i==15){
      uuu = u15
    }
    if (i==16){
      uuu = u16
    }
    if (i==17){
      uuu = u17
    }
    if (i==18){
      uuu = u18
    }
    if (i==19){
      uuu = u19
    }
    if (i==20){
      uuu = u20
    }
    if (i==21){
      uuu = u21
    }
    if (i==22){
      uuu = u22
    }
    if (i==23){
      uuu = u23
    }
    if (i==24){
      uuu = u24
    }
    
    if (i==25){
      uuu = u25
    }
    if (i==26){
      uuu = u26
    }
    if (i==27){
      uuu = u27
    }
    if (i==28){
      uuu = u28
    }
    if (i==29){
      uuu = u29
    }
    if (i==30){
      uuu = u30
    }
    if (i==31){
      uuu = u31
    }
    if (i==32){
      uuu = u32
    }
    if (i==33){
      uuu = u33
    }
    if (i==34){
      uuu = u34
    }
    if (i==35){
      uuu = u35
    }
    if (i==36){
      uuu = u36
    }
    if (i==37){
      uuu = u37
    }
    if (i==38){
      uuu = u38
    }
    if (i==39){
      uuu = u39
    }
    if (i==40){
      uuu = u40
    }
    if (i==41){
      uuu = u41
    }
    if (i==42){
      uuu = u42
    }
    if (i==43){
      uuu = u43
    }
    if (i==44){
      uuu = u44
    }
    if (i==45){
      uuu = u45
    }
    if (i==46){
      uuu = u46
    }
    if (i==47){
      uuu = u47
    }
    if (i==48){
      uuu = u48
    }
    
    
    twind <- (uuu[which((uuu$`lat` == round(PLa/0.5)*0.5) & (uuu$`lon` == round(PLo/0.5)*0.5)),])
    if (twind[7] < 4){
      twind[7] = 4
    } else
    {
      twind[7] = twind[7]*1.9438
    }
    if (twind[6] > 180){
      twind[6] = twind[6]-180
    } else
    {twind[6] = twind[6]+180
    }
    
    angle = abs(x[i]-twind[6])
    if (angle > 180){
      angle = 360 - angle
    }
    
    TWAvVORjib = scale(angle, center = minsVORjib[1], scale = maxsVORjib[1] - minsVORjib[1])
    TWSvVORjib = scale(twind[7], center = minsVORjib[2], scale = maxsVORjib[2] - minsVORjib[2])
    
    TWAvVORspi = scale(angle, center = minsVORspi[1], scale = maxsVORspi[1] - minsVORspi[1])
    TWSvVORspi = scale(twind[7], center = minsVORspi[2], scale = maxsVORspi[2] - minsVORspi[2])
    
    # TWAvVORcode0 = scale(angle, center = minsVORcode0[1], scale = maxsVORcode0[1] - minsVORcode0[1])
    # TWSvVORcode0 = scale(twind[7], center = minsVORcode0[2], scale = maxsVORcode0[2] - minsVORcode0[2])
    
    prediction.nnVORjib <- compute(nnVORjib,data.frame(TWA=TWAvVORjib,TWS=TWSvVORjib))
    prediction.nnVORjib_ <- prediction.nnVORjib$net.result*(max(dataVORjib$V)-min(dataVORjib$V))+min(dataVORjib$V)
    pred[1] <- prediction.nnVORjib_
    prediction.nnVORspi <- compute(nnVORspi,data.frame(TWA=TWAvVORspi,TWS=TWSvVORspi))
    prediction.nnVORspi_ <- prediction.nnVORspi$net.result*(max(dataVORspi$V)-min(dataVORspi$V))+min(dataVORspi$V)
    pred[2] <- prediction.nnVORspi_
    #prediction.nnstay <- compute(nnstay,data.frame(TWA=TWAvstay,TWS=TWSvstay))
    #prediction.nnstay_ <- prediction.nnstay$net.result*(max(datastay$V)-min(datastay$V))+min(datastay$V)
    #pred[3] <- prediction.nnstay_
    # prediction.nnVORcode0 <- compute(nnVORcode0,data.frame(TWA=TWAvVORcode0,TWS=TWSvVORcode0))
    # prediction.nnVORcode0_ <- prediction.nnVORcode0$net.result*(max(dataVORcode0$V)-min(dataVORcode0$V))+min(dataVORcode0$V)
    # pred[5] <- prediction.nnVORcode0_
    #pred[5] <- 0
    
    DistanceSailed=as.double(pred[which.max(pred[1:2])])*Rate*1852
    DistanceSailed

    p <- cbind(PLo,PLa)
    d <- destPoint(p,x[i],DistanceSailed)
    de[i,1] <- as.double(d[1])
    de[i,2] <- as.double(d[2])
    de[i,3] <- as.double(angle)
    de[i,4] <- as.double(twind[6])
    de[i,5] <- as.double(twind[7])
    de[i,6] <- as.double(x[i])
    de[i,7] <- as.double(pred[which.max(pred[1:2])])
    de[i,8] <- colnames(pred)[which.max(pred[1:2])]
    PLa <- d[2]
    PLo <- d[1]

    try2w[i,1] <- paste(TiSt,collapse=" ")
    try2w[i,2] <- as.double(i)
    try2w[i,3] <- as.double(PLo)
    try2w[i,4] <- as.double(PLa)
    try2w[i,5] <- as.double(x[i])
    #try2w[i,6] <- as.double(distHaversine(c(PLo,PLa),c(DLo,DLa)))
    try2w[i,6] <- as.double(angle)
    try2w[i,7] <- colnames(pred)[which.max(pred)]
    try2w[i,8] <- as.double(pred[which.max(pred)])
    try2w[i,9] <- de[i,4]
    try2w[i,10] <- de[i,5]
    
    
    dtm <- strptime(paste(TiSt[3], TiSt[2], TiSt[1], TiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
    TiSt[2]<-month(dtm)
    TiSt[1]<-year(dtm)
    TiSt[3]<-day(dtm)
    TiSt[4]<-hour(dtm)
    
    
  }  
  return(try2w)

}
}
  
# Recover initial conditions
PLa <- PLaR
PLo <- PLoR
TiSt <- TiStR

# Getting the map. A google API key is necessary. This is free as of 2025 for personal use.
lon <- c(DLo,PLo)
lat <- c(PLa, DLa)
df <- as.data.frame((cbind(lon,lat)))
register_google(key = "GoogleAPIkey")
mapgilbert <- get_map(location = c(lon = mean(df$lon), lat = mean(df$lat)), zoom = 4,
                      maptype = "satellite", scale = 2)

# Preparing data to lay over map and accompanying table
pointers <- as.data.frame(course(BeOp)[,c(3,4)])
pointers <- matrix(as.double(matrix(unlist(pointers), nrow = TL, ncol=2)), nrow = TL, ncol=2)
colnames(pointers) <- c("Lon", "Lat")
pointers <- as.data.frame(pointers)
painters <- as.data.frame(course(fidu$par)[,c(3,4)])
painters <- matrix(as.double(matrix(unlist(painters), nrow = TL, ncol=2)), nrow = TL, ncol=2)
colnames(painters) <- c("Lon", "Lat")
painters <- as.data.frame(painters)

# Map and table render
mytheme <- gridExtra::ttheme_default(
  core = list(fg_params=list(cex = 1)),
  colhead = list(fg_params=list(cex = 1)),
  rowhead = list(fg_params=list(cex = 1)))

grid.arrange(tableGrob(course(fidu$par)[1:8, c(1, 5, 6, 7)], theme = mytheme), ggmap(mapgilbert) +
               geom_point(data = as.data.frame(rbind(painters)), aes(x = as.double(Lon), y = as.double(Lat)), color = 4, fill = 4, size = 2, alpha=0.8)+
               geom_point(data = as.data.frame(rbind(pointers)), aes(x = as.double(Lon), y = as.double(Lat)), color = 3, fill = 3, size = 2, alpha=0.8)+
               geom_point(data = as.data.frame(c(DLo, DLa)), aes(x = DLo, y = DLa), color = 2, fill = 2, size = 2, alpha=0.8)  +
               geom_point(data = as.data.frame(c(PLo, PLa)), aes(x = PLo, y = PLa), color = 2, fill = 2, size = 2, alpha=0.8)  
             , ncol=2)
