library(neuralnet)
library(rWind)
library(geosphere)
library(lubridate)
library(ggplot2)
library(ggmap)
library(mapproj)
#library(optimr)
#library(nloptr)
library(rgenoud)
library(gridExtra)
library(mailR)
library(readxl)
library(rJava)

VOR1_jib <- read_excel("C:/Personal/VOR/VOR1-jib.xlsx")
VOR2_spi <- read_excel("C:/Personal/VOR/VOR2-spi.xlsx")
VOR5_code_0 <- read_excel("C:/Personal/VOR/VOR5-code_0.xlsx")


source("C:/Personal/VOR/NN_1.R")
source("C:/Personal/VOR/NN_2.R")
source("C:/Personal/VOR/NN_5.R")

TL = 48


de = matrix(, nrow=TL, ncol=8)
pred = matrix(, nrow=1, ncol=7)
colnames(de) <- c("Lon", "Lat", "Angle", "TWA", "TWS", "Bearing", "Speed", "Sail")
colnames(pred) <- c("VORjib", "VORspi", "stay", "lightj", "VORcode0", "heavyg", "lightg")
#try2w = matrix(, nrow=240, ncol=7)
try2w = matrix(, nrow=TL, ncol=8)
colnames(try2w) <- c("trial", "tack", "Lon", "Lat", "Bearing", "TWA", "Sail", "V")
BeOp = c(rep.int(0, TL))
leeway = 10


PLa = 4+38/60+4/60/60
PLo = 151+56/60+27/60/60
DLo = 174+41.2/60
DLa = -36-48.7/60


BeOp[] = as.integer(bearing(c(PLo,PLa),c(DLo,DLa)))
if (BeOp[1]<0){
  BeOp = 360+BeOp
}
TiSt <- c(2018, 2,15, 15)
Rate = 3

OffLimits = c(-10, -8, 150, 162)

PLaR <- PLa
PLoR <- PLo
TiStR <- TiSt

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
    
    twind <- wind.fit(uuu[which((uuu$`latitude (degrees_north)` == round(PLa/0.5)*0.5) & (uuu$`longitude (degrees_east)` == round(PLo/0.5)*0.5)),])
    twind[3]
    twind[4]
    if (twind[4] < 4){
      twind[4] = 4
    } else
    {
      twind[4] = twind[4]*1.9438
    }
    if (twind[3] > 180){
      twind[3] = twind[3]-180
    } else
    {twind[3] = twind[3]+180
    }
    
    angle = abs(as.double(x[i])-twind[3])
    if (angle > 180){
      angle = 360 - angle
    }
    
    TWAvVORjib = scale(angle, center = minsVORjib[1], scale = maxsVORjib[1] - minsVORjib[1])
    TWSvVORjib = scale(twind[4], center = minsVORjib[2], scale = maxsVORjib[2] - minsVORjib[2])
    
    TWAvVORspi = scale(angle, center = minsVORspi[1], scale = maxsVORspi[1] - minsVORspi[1])
    TWSvVORspi = scale(twind[4], center = minsVORspi[2], scale = maxsVORspi[2] - minsVORspi[2])
    
    TWAvVORcode0 = scale(angle, center = minsVORcode0[1], scale = maxsVORcode0[1] - minsVORcode0[1])
    TWSvVORcode0 = scale(twind[4], center = minsVORcode0[2], scale = maxsVORcode0[2] - minsVORcode0[2])
    
    prediction.nnVORjib <- compute(nnVORjib,data.frame(TWA=TWAvVORjib,TWS=TWSvVORjib))
    prediction.nnVORjib_ <- prediction.nnVORjib$net.result*(max(dataVORjib$V)-min(dataVORjib$V))+min(dataVORjib$V)
    pred[1] <- prediction.nnVORjib_
    prediction.nnVORspi <- compute(nnVORspi,data.frame(TWA=TWAvVORspi,TWS=TWSvVORspi))
    prediction.nnVORspi_ <- prediction.nnVORspi$net.result*(max(dataVORspi$V)-min(dataVORspi$V))+min(dataVORspi$V)
    pred[2] <- prediction.nnVORspi_
    #prediction.nnstay <- compute(nnstay,data.frame(TWA=TWAvstay,TWS=TWSvstay))
    #prediction.nnstay_ <- prediction.nnstay$net.result*(max(datastay$V)-min(datastay$V))+min(datastay$V)
    #pred[3] <- prediction.nnstay_
    prediction.nnVORcode0 <- compute(nnVORcode0,data.frame(TWA=TWAvVORcode0,TWS=TWSvVORcode0))
    prediction.nnVORcode0_ <- prediction.nnVORcode0$net.result*(max(dataVORcode0$V)-min(dataVORcode0$V))+min(dataVORcode0$V)
    pred[5] <- prediction.nnVORcode0_
    #pred[5] <- 0
    
    DistanceSailed=as.double(pred[which.max(pred)])*Rate*1852
    DistanceSailed
    
    p <- cbind(PLo,PLa)
    d <- destPoint(p,as.double(x[i]),DistanceSailed)
    de[i,1] <- d[1]
    de[i,2] <- d[2]
    de[i,3] <- as.double(angle)
    de[i,4] <- as.double(twind[3])
    de[i,5] <- as.double(twind[4])
    de[i,6] <- as.double(x[i])
    de[i,7] <- as.double(pred[which.max(pred)])
    de[i,8] <- colnames(pred)[which.max(pred)]
    
    
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
    
    #try2w[try2windex,1] <- nofun
    #try2w[try2windex,2] <- i
    #try2w[try2windex,3] <- PLo
    #try2w[try2windex,4] <- PLa
    #try2w[try2windex,5] <- Bear
    #try2w[try2windex,6] <- distHaversine(c(PLo,PLa),c(DLo,DLa))
    #try2w[try2windex,7] <- colnames(pred)[which.max(pred)]
    #try2windex = try2windex+1
    # Bear = bearing(c(PLo,PLa),c(DLo,DLa)) + runif(1, -1*noise, noise)
    
    print(c(i, PLa, DLa, PLo, DLo, x[i]))
    # update GUI console
    flush.console()
  }
  
  result <- distHaversine(c(PLo,PLa),c(DLo,DLa))/10000
  print(result)
  # update GUI console
  flush.console()
  
  return(result)
}

#a <- target(c(50,70,50,61,61,61,61,61,61,64,64,64,64,64,64, 132, 132, 132, 132, 132, 132, 132, 132, 132))
a <- target(BeOp)

#a <- target(c(70,70,45,100,100,100,100,113,113,113,113,113,113,113,113, 132, 132, 132, 132, 132, 132, 144, 144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,128,128,128,128,180, 195, 157 ))
#a

#optCou
#a
#difi <- opm(BeOp, target, method = "Nelder-Mead", control = list(maxit = 5, trace = 6, REPORT = 1, fnscale = 100, parscale= c(2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3)))


#didi <- opm(BeOp, target, lower = BeOp-90, upper = BeOp+90, method = "L-BFGS-B", control = list(maxit = 5, trace = 6, REPORT = 1, fnscale = 100, parscale= c(2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3)))


#difu <- nloptr(x0=BeOp, eval_f=target, lb = BeOp-90, ub = BeOp+90, opts = list("algorithm"="NLOPT_GN_ISRES", maxeval = 1000, trace = 6, REPORT = 1, fnscale = 100, parscale= c(2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3)))

boundy <- matrix(, nrow=2, ncol=TL)
boundy[1,] <- BeOp-90
boundy[2,] <- BeOp+90
boundy <- t(boundy)
fidu <-  genoud(target, max.generations = 100, print.level = 3, hard.generation.limit = TRUE, data.type.int=TRUE, pop.size = 100, Domains = boundy, boundary.enforcement=2, starting.values=BeOp, nvars=TL,max=FALSE)


#d <- opm(BeOp, target, method = "Rvmmin", control = list(maxit = 5, trace = 6, REPORT = 1, fnscale = 100, parscale= c(2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3)))
#optCou2 <- difu[1,1:TL]

optCou2 <- fidu$solution

PLa <- PLaR
PLo <- PLoR
TiSt <- TiStR


targetS <- function(x) {
  for (i in 1:TL) {
    if (i == 1) {
      uuu = u1
    }
    if (i == 2) {
      uuu = u2
    }
    if (i == 3) {
      uuu = u3
    }
    if (i == 4) {
      uuu = u4
    }
    if (i == 5) {
      uuu = u5
    }
    if (i == 6) {
      uuu = u6
    }
    if (i == 7) {
      uuu = u7
    }
    if (i == 8) {
      uuu = u8
    }
    if (i == 9) {
      uuu = u9
    }
    if (i == 10) {
      uuu = u10
    }
    if (i == 11) {
      uuu = u11
    }
    if (i == 12) {
      uuu = u12
    }
    if (i == 13) {
      uuu = u13
    }
    if (i == 14) {
      uuu = u14
    }
    if (i == 15) {
      uuu = u15
    }
    if (i == 16) {
      uuu = u16
    }
    if (i == 17) {
      uuu = u17
    }
    if (i == 18) {
      uuu = u18
    }
    if (i == 19) {
      uuu = u19
    }
    if (i == 20) {
      uuu = u20
    }
    if (i == 21) {
      uuu = u21
    }
    if (i == 22) {
      uuu = u22
    }
    if (i == 23) {
      uuu = u23
    }
    if (i == 24) {
      uuu = u24
    }
    
    if (i == 25) {
      uuu = u25
    }
    if (i == 26) {
      uuu = u26
    }
    if (i == 27) {
      uuu = u27
    }
    if (i == 28) {
      uuu = u28
    }
    if (i == 29) {
      uuu = u29
    }
    if (i == 30) {
      uuu = u30
    }
    if (i == 31) {
      uuu = u31
    }
    if (i == 32) {
      uuu = u32
    }
    if (i == 33) {
      uuu = u33
    }
    if (i == 34) {
      uuu = u34
    }
    if (i == 35) {
      uuu = u35
    }
    if (i == 36) {
      uuu = u36
    }
    if (i == 37) {
      uuu = u37
    }
    if (i == 38) {
      uuu = u38
    }
    if (i == 39) {
      uuu = u39
    }
    if (i == 40) {
      uuu = u40
    }
    if (i == 41) {
      uuu = u41
    }
    if (i == 42) {
      uuu = u42
    }
    if (i == 43) {
      uuu = u43
    }
    if (i == 44) {
      uuu = u44
    }
    if (i == 45) {
      uuu = u45
    }
    if (i == 46) {
      uuu = u46
    }
    if (i == 47) {
      uuu = u47
    }
    if (i == 48) {
      uuu = u48
    }
    
    twind <-
      wind.fit(uuu[which((uuu$`latitude (degrees_north)` == round(PLa / 0.5) *
                            0.5) & (uuu$`longitude (degrees_east)` == round(PLo / 0.5) * 0.5)
      ), ])
    twind[3]
    twind[4]
    if (twind[4] < 4) {
      twind[4] = 4
    } else
    {
      twind[4] = twind[4] * 1.9438
    }
    if (twind[3] > 180) {
      twind[3] = twind[3] - 180
    } else
    {
      twind[3] = twind[3] + 180
    }
    
    if (TiSt[4] == 9 | TiSt[4] == 18 | TiSt[4] == 0) {
      angle = abs(as.double(x[i]) - twind[3])
      if (angle > 180) {
        angle = 360 - angle
      }
      
      TWAvVORjib = scale(angle,
                         center = minsVORjib[1],
                         scale = maxsVORjib[1] - minsVORjib[1])
      TWSvVORjib = scale(twind[4],
                         center = minsVORjib[2],
                         scale = maxsVORjib[2] - minsVORjib[2])
      
      TWAvVORspi = scale(angle,
                         center = minsVORspi[1],
                         scale = maxsVORspi[1] - minsVORspi[1])
      TWSvVORspi = scale(twind[4],
                         center = minsVORspi[2],
                         scale = maxsVORspi[2] - minsVORspi[2])
      
      TWAvVORcode0 = scale(angle,
                           center = minsVORcode0[1],
                           scale = maxsVORcode0[1] - minsVORcode0[1])
      TWSvVORcode0 = scale(twind[4],
                           center = minsVORcode0[2],
                           scale = maxsVORcode0[2] - minsVORcode0[2])
      
      prediction.nnVORjib <-
        compute(nnVORjib, data.frame(TWA = TWAvVORjib, TWS = TWSvVORjib))
      prediction.nnVORjib_ <-
        prediction.nnVORjib$net.result * (max(dataVORjib$V) - min(dataVORjib$V)) +
        min(dataVORjib$V)
      pred[1] <- prediction.nnVORjib_
      prediction.nnVORspi <-
        compute(nnVORspi, data.frame(TWA = TWAvVORspi, TWS = TWSvVORspi))
      prediction.nnVORspi_ <-
        prediction.nnVORspi$net.result * (max(dataVORspi$V) - min(dataVORspi$V)) +
        min(dataVORspi$V)
      pred[2] <- prediction.nnVORspi_
      #prediction.nnstay <- compute(nnstay,data.frame(TWA=TWAvstay,TWS=TWSvstay))
      #prediction.nnstay_ <- prediction.nnstay$net.result*(max(datastay$V)-min(datastay$V))+min(datastay$V)
      #pred[3] <- prediction.nnstay_
      prediction.nnVORcode0 <-
        compute(nnVORcode0,
                data.frame(TWA = TWAvVORcode0, TWS = TWSvVORcode0))
      prediction.nnVORcode0_ <-
        prediction.nnVORcode0$net.result * (max(dataVORcode0$V) - min(dataVORcode0$V)) +
        min(dataVORcode0$V)
      pred[5] <- prediction.nnVORcode0_
      #pred[5] <- 0
      
      DistanceSailed = as.double(pred[which.max(pred)]) * Rate * 1852
      DistanceSailed
      
      p <- cbind(PLo, PLa)
      d <- destPoint(p, as.double(x[i]), DistanceSailed)
      de[i, 1] <- d[1]
      de[i, 2] <- d[2]
      de[i, 3] <- as.double(angle)
      de[i, 4] <- as.double(twind[3])
      de[i, 5] <- as.double(twind[4])
      de[i, 6] <- as.double(x[i])
      de[i, 7] <- as.double(pred[which.max(pred)])
      de[i, 8] <- colnames(pred)[which.max(pred)]
      
      
      if ((d[2] > OffLimits[1]) &
          (d[2] < OffLimits[2]) &
          (d[1] > OffLimits[3]) & (d[1] < OffLimits[4])) {
        
      }    else    {
        PLa <- d[2]
        PLo <- d[1]
      }
      
      dtm <-
        strptime(paste(TiSt[3], TiSt[2], TiSt[1], TiSt[4], "00"),
                 format = "%d %m %Y %H %M",
                 tz = "GMT") + 3600 * Rate
      TiSt[2] <- month(dtm)
      TiSt[1] <- year(dtm)
      TiSt[3] <- day(dtm)
      TiSt[4] <- hour(dtm)
      
      print(c(i, PLa, DLa, PLo, DLo, x[i]))
      # update GUI console
      flush.console()
    } else {
      if ((TiSt[4] == 12 | TiSt[4] == 21 | TiSt[4] == 3) & i > 1) {
        angle = abs(as.double(x[i - 1]) - twind[3])
        if (angle > 180) {
          angle = 360 - angle
        }
        
        TWAvVORjib = scale(angle,
                           center = minsVORjib[1],
                           scale = maxsVORjib[1] - minsVORjib[1])
        TWSvVORjib = scale(twind[4],
                           center = minsVORjib[2],
                           scale = maxsVORjib[2] - minsVORjib[2])
        
        TWAvVORspi = scale(angle,
                           center = minsVORspi[1],
                           scale = maxsVORspi[1] - minsVORspi[1])
        TWSvVORspi = scale(twind[4],
                           center = minsVORspi[2],
                           scale = maxsVORspi[2] - minsVORspi[2])
        
        TWAvVORcode0 = scale(angle,
                             center = minsVORcode0[1],
                             scale = maxsVORcode0[1] - minsVORcode0[1])
        TWSvVORcode0 = scale(twind[4],
                             center = minsVORcode0[2],
                             scale = maxsVORcode0[2] - minsVORcode0[2])
        
        prediction.nnVORjib <-
          compute(nnVORjib, data.frame(TWA = TWAvVORjib, TWS = TWSvVORjib))
        prediction.nnVORjib_ <-
          prediction.nnVORjib$net.result * (max(dataVORjib$V) - min(dataVORjib$V)) +
          min(dataVORjib$V)
        pred[1] <- prediction.nnVORjib_
        prediction.nnVORspi <-
          compute(nnVORspi, data.frame(TWA = TWAvVORspi, TWS = TWSvVORspi))
        prediction.nnVORspi_ <-
          prediction.nnVORspi$net.result * (max(dataVORspi$V) - min(dataVORspi$V)) +
          min(dataVORspi$V)
        pred[2] <- prediction.nnVORspi_
        #prediction.nnstay <- compute(nnstay,data.frame(TWA=TWAvstay,TWS=TWSvstay))
        #prediction.nnstay_ <- prediction.nnstay$net.result*(max(datastay$V)-min(datastay$V))+min(datastay$V)
        #pred[3] <- prediction.nnstay_
        prediction.nnVORcode0 <-
          compute(nnVORcode0,
                  data.frame(TWA = TWAvVORcode0, TWS = TWSvVORcode0))
        prediction.nnVORcode0_ <-
          prediction.nnVORcode0$net.result * (max(dataVORcode0$V) - min(dataVORcode0$V)) +
          min(dataVORcode0$V)
        pred[5] <- prediction.nnVORcode0_
        #pred[5] <- 0
        
        DistanceSailed = as.double(pred[which.max(pred)]) * Rate * 1852
        DistanceSailed
        
        p <- cbind(PLo, PLa)
        d <- destPoint(p, as.double(x[i - 1]), DistanceSailed)
        de[i, 1] <- d[1]
        de[i, 2] <- d[2]
        de[i, 3] <- as.double(angle)
        de[i, 4] <- as.double(twind[3])
        de[i, 5] <- as.double(twind[4])
        de[i, 6] <- as.double(x[i - 1])
        de[i, 7] <- as.double(pred[which.max(pred)])
        de[i, 8] <- colnames(pred)[which.max(pred)]
        
        
        if ((d[2] > OffLimits[1]) &
            (d[2] < OffLimits[2]) &
            (d[1] > OffLimits[3]) & (d[1] < OffLimits[4])) {
          
        }    else    {
          PLa <- d[2]
          PLo <- d[1]
        }
        
        dtm <-
          strptime(paste(TiSt[3], TiSt[2], TiSt[1], TiSt[4], "00"),
                   format = "%d %m %Y %H %M",
                   tz = "GMT") + 3600 * Rate
        TiSt[2] <- month(dtm)
        TiSt[1] <- year(dtm)
        TiSt[3] <- day(dtm)
        TiSt[4] <- hour(dtm)
        
        print(c(i, PLa, DLa, PLo, DLo, x[i - 1]))
        # update GUI console
        flush.console()
      }
     else {
      if ((TiSt[4] == 15 | TiSt[4] == 6) & i > 2) {
        angle = abs(as.double(x[i - 2]) - twind[3])
        if (angle > 180) {
          angle = 360 - angle
        }
        
        TWAvVORjib = scale(angle,
                           center = minsVORjib[1],
                           scale = maxsVORjib[1] - minsVORjib[1])
        TWSvVORjib = scale(twind[4],
                           center = minsVORjib[2],
                           scale = maxsVORjib[2] - minsVORjib[2])
        
        TWAvVORspi = scale(angle,
                           center = minsVORspi[1],
                           scale = maxsVORspi[1] - minsVORspi[1])
        TWSvVORspi = scale(twind[4],
                           center = minsVORspi[2],
                           scale = maxsVORspi[2] - minsVORspi[2])
        
        TWAvVORcode0 = scale(angle,
                             center = minsVORcode0[1],
                             scale = maxsVORcode0[1] - minsVORcode0[1])
        TWSvVORcode0 = scale(twind[4],
                             center = minsVORcode0[2],
                             scale = maxsVORcode0[2] - minsVORcode0[2])
        
        prediction.nnVORjib <-
          compute(nnVORjib, data.frame(TWA = TWAvVORjib, TWS = TWSvVORjib))
        pr.lmVORcode0prediction.nnVORjib_ <-
          prediction.nnVORjib$net.result * (max(dataVORjib$V) - min(dataVORjib$V)) +
          min(dataVORjib$V)
        pred[1] <- prediction.nnVORjib_
        prediction.nnVORspi <-
          compute(nnVORspi, data.frame(TWA = TWAvVORspi, TWS = TWSvVORspi))
        prediction.nnVORspi_ <-
          prediction.nnVORspi$net.result * (max(dataVORspi$V) - min(dataVORspi$V)) +
          min(dataVORspi$V)
        pred[2] <- prediction.nnVORspi_
        #prediction.nnstay <- compute(nnstay,data.frame(TWA=TWAvstay,TWS=TWSvstay))
        #prediction.nnstay_ <- prediction.nnstay$net.result*(max(datastay$V)-min(datastay$V))+min(datastay$V)
        #pred[3] <- prediction.nnstay_
        prediction.nnVORcode0 <-
          compute(nnVORcode0,
                  data.frame(TWA = TWAvVORcode0, TWS = TWSvVORcode0))
        prediction.nnVORcode0_ <-
          prediction.nnVORcode0$net.result * (max(dataVORcode0$V) - min(dataVORcode0$V)) +
          min(dataVORcode0$V)
        pred[5] <- prediction.nnVORcode0_
        #pred[5] <- 0
        
        DistanceSailed = as.double(pred[which.max(pred)]) * Rate * 1852
        DistanceSailed
        
        p <- cbind(PLo, PLa)
        d <- destPoint(p, as.double(x[i - 2]), DistanceSailed)
        de[i, 1] <- d[1]
        de[i, 2] <- d[2]
        de[i, 3] <- as.double(angle)
        de[i, 4] <- as.double(twind[3])
        de[i, 5] <- as.double(twind[4])
        de[i, 6] <- as.double(x[i - 1])
        de[i, 7] <- as.double(pred[which.max(pred)])
        de[i, 8] <- colnames(pred)[which.max(pred)]
        
        
        if ((d[2] > OffLimits[1]) &
            (d[2] < OffLimits[2]) &
            (d[1] > OffLimits[3]) & (d[1] < OffLimits[4])) {
          
        }    else    {
          PLa <- d[2]
          PLo <- d[1]
        }
        
        dtm <-
          strptime(paste(TiSt[3], TiSt[2], TiSt[1], TiSt[4], "00"),
                   format = "%d %m %Y %H %M",
                   tz = "GMT") + 3600 * Rate
        TiSt[2] <- month(dtm)
        TiSt[1] <- year(dtm)
        TiSt[3] <- day(dtm)
        TiSt[4] <- hour(dtm)
        
        print(c(i, PLa, DLa, PLo, DLo, x[i - 2]))
        # update GUI console
        flush.console()
      }
     }
    }
  }
  result <- distHaversine(c(PLo, PLa), c(DLo, DLa)) / 10000
  print(result)
  # update GUI console
  flush.console()
  
  return(result)
  
}

#a <- target(c(50,70,50,61,61,61,61,61,61,64,64,64,64,64,64, 132, 132, 132, 132, 132, 132, 132, 132, 132))
b <- targetS(BeOp)


for(uh in 1:24)
{
  BeOp[uh] <- BeOp[uh]+uh
}
#a <- target(c(70,70,45,100,100,100,100,113,113,113,113,113,113,113,113, 132, 132, 132, 132, 132, 132, 144, 144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,128,128,128,128,180, 195, 157 ))
#a

#optCou
#a
#difi <- opm(BeOp, target, method = "Nelder-Mead", control = list(maxit = 5, trace = 6, REPORT = 1, fnscale = 100, parscale= c(2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3)))


#didi <- opm(BeOp, target, lower = BeOp-90, upper = BeOp+90, method = "L-BFGS-B", control = list(maxit = 5, trace = 6, REPORT = 1, fnscale = 100, parscale= c(2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3)))


#difu <- nloptr(x0=BeOp, eval_f=target, lb = BeOp-90, ub = BeOp+90, opts = list("algorithm"="NLOPT_GN_ISRES", maxeval = 1000, trace = 6, REPORT = 1, fnscale = 100, parscale= c(2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3)))

boundyS <- matrix(, nrow=2, ncol=TL)
boundyS[1,] <- BeOp-90
boundyS[2,] <- BeOp+90
boundy <- t(boundy)
fiduS <-  genoud(targetS, max.generations = 100, print.level = 3, hard.generation.limit = TRUE, data.type.int=TRUE, pop.size = 100, Domains = boundy, boundary.enforcement=2, starting.values=BeOp, nvars=TL,max=FALSE)


#d <- opm(BeOp, target, method = "Rvmmin", control = list(maxit = 5, trace = 6, REPORT = 1, fnscale = 100, parscale= c(2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3, 2e3, 2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3,2e3)))
#optCou2 <- difu[1,1:TL]

optCouS2 <- fiduS$solution

PLa <- PLaR
PLo <- PLoR
TiSt <- TiStR




course <- function(x) {
  
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
    
    
    twind <- wind.fit(uuu[which((uuu$`latitude (degrees_north)` == round(PLa/0.5)*0.5) & (uuu$`longitude (degrees_east)` == round(PLo/0.5)*0.5)),])
    if (twind[4] < 4){
      twind[4] = 4
    } else
    {
      twind[4] = twind[4]*1.9438
    }
    if (twind[3] > 180){
      twind[3] = twind[3]-180
    } else
    {twind[3] = twind[3]+180
    }
    
    angle = abs(x[i]-twind[3])
    if (angle > 180){
      angle = 360 - angle
    }
    
    TWAvVORjib = scale(angle, center = minsVORjib[1], scale = maxsVORjib[1] - minsVORjib[1])
    TWSvVORjib = scale(twind[4], center = minsVORjib[2], scale = maxsVORjib[2] - minsVORjib[2])
    
    TWAvVORspi = scale(angle, center = minsVORspi[1], scale = maxsVORspi[1] - minsVORspi[1])
    TWSvVORspi = scale(twind[4], center = minsVORspi[2], scale = maxsVORspi[2] - minsVORspi[2])
    
    TWAvVORcode0 = scale(angle, center = minsVORcode0[1], scale = maxsVORcode0[1] - minsVORcode0[1])
    TWSvVORcode0 = scale(twind[4], center = minsVORcode0[2], scale = maxsVORcode0[2] - minsVORcode0[2])
    
    prediction.nnVORjib <- compute(nnVORjib,data.frame(TWA=TWAvVORjib,TWS=TWSvVORjib))
    prediction.nnVORjib_ <- prediction.nnVORjib$net.result*(max(dataVORjib$V)-min(dataVORjib$V))+min(dataVORjib$V)
    pred[1] <- prediction.nnVORjib_
    prediction.nnVORspi <- compute(nnVORspi,data.frame(TWA=TWAvVORspi,TWS=TWSvVORspi))
    prediction.nnVORspi_ <- prediction.nnVORspi$net.result*(max(dataVORspi$V)-min(dataVORspi$V))+min(dataVORspi$V)
    pred[2] <- prediction.nnVORspi_
    #prediction.nnstay <- compute(nnstay,data.frame(TWA=TWAvstay,TWS=TWSvstay))
    #prediction.nnstay_ <- prediction.nnstay$net.result*(max(datastay$V)-min(datastay$V))+min(datastay$V)
    #pred[3] <- prediction.nnstay_
    prediction.nnVORcode0 <- compute(nnVORcode0,data.frame(TWA=TWAvVORcode0,TWS=TWSvVORcode0))
    prediction.nnVORcode0_ <- prediction.nnVORcode0$net.result*(max(dataVORcode0$V)-min(dataVORcode0$V))+min(dataVORcode0$V)
    pred[5] <- prediction.nnVORcode0_
    #pred[5] <- 0
    
    DistanceSailed=as.double(pred[which.max(pred)])*Rate*1852
    DistanceSailed

    p <- cbind(PLo,PLa)
    d <- destPoint(p,x[i],DistanceSailed)
    de[i,1] <- as.double(d[1])
    de[i,2] <- as.double(d[2])
    de[i,3] <- as.double(angle)
    de[i,4] <- as.double(twind[3])
    de[i,5] <- as.double(twind[4])
    de[i,6] <- as.double(x[i])
    de[i,7] <- as.double(pred[which.max(pred)])
    de[i,8] <- colnames(pred)[which.max(pred)]
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
    
    dtm <- strptime(paste(TiSt[3], TiSt[2], TiSt[1], TiSt[4],"00"), format = "%d %m %Y %H %M", tz = "GMT") + 3600*Rate
    TiSt[2]<-month(dtm)
    TiSt[1]<-year(dtm)
    TiSt[3]<-day(dtm)
    TiSt[4]<-hour(dtm)
    
    #Sys.sleep(0.01)
    #print(c(PLa, DLa, PLo, DLo, x[i]))
    # update GUI console
    #flush.console()
    
  }  
  return(try2w)

}

#optCou <- c(optCou[1], optCou[2], optCou[3], optCou[4], optCou[5], optCou[6], optCou[7], optCou[8], optCou[9], optCou[10], optCou[11], optCou[12], optCou[13], optCou[14], optCou[15], optCou[16], optCou[17], optCou[18], optCou[19], optCou[20], optCou[21], optCou[22], optCou[23], optCou[24] )
#course(optCou2[1:TL])



#lon <- c(PLo-.5,PLo+.5)
#lat <- c(PLa-.5, PLa+.5)
#df <- as.data.frame(cbind(lon,lat))

# getting the map
#mapgilbert <- get_map(location = c(lon = mean(df$lon), lat = mean(df$lat)), zoom = 5,
#                      maptype = "satellite", scale = 2)

PLa <- PLaR
PLo <- PLoR
TiSt <- TiStR


#Alternative map
lon <- c(DLo,PLo)
lat <- c(PLa, DLa)
df <- as.data.frame(cbind(lon,lat))

# getting the map
mapgilbert <- get_map(location = c(lon = mean(df$lon), lat = mean(df$lat)), zoom = 4,
                      maptype = "satellite", scale = 2)

pointers <- as.data.frame(course(BeOp)[,c(3,4)])

#course(optCou)

pointers <- matrix(as.double(matrix(unlist(pointers), nrow = TL, ncol=2)), nrow = TL, ncol=2)
colnames(pointers) <- c("Lon", "Lat")
#pointers
pointers <- as.data.frame(pointers)

##
#printers <- as.data.frame(course(c(70,70,45,100,100,100,100,113,113,113,113,113,113,113,113, 132, 132, 132, 132, 132, 132, 144, 144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,128,128,128,128,180, 195, 157 ))[,c(3,4)])

#course(optCou)

#printers <- matrix(as.double(matrix(unlist(printers), nrow = TL, ncol=2)), nrow = TL, ncol=2)
#colnames(printers) <- c("Lon", "Lat")
#pointers
#printers <- as.data.frame(printers)

#printers <- as.data.frame(course(c(70,70,45,100,100,100,100,113,113,113,113,113,113,113,113, 132, 132, 132, 132, 132, 132, 144, 144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,144,128,128,128,128,180, 195, 157 ))[,c(3,4)])

#course(optCou)

painters <- as.data.frame(course(fidu$par)[,c(3,4)])

painters <- matrix(as.double(matrix(unlist(painters), nrow = TL, ncol=2)), nrow = TL, ncol=2)
colnames(painters) <- c("Lon", "Lat")
#pointers
painters <- as.data.frame(painters)


#rbind(pointers,printers, painters)

#as.data.frame(c(pointers, printers))
mytheme <- gridExtra::ttheme_default(
  core = list(fg_params=list(cex = 0.8)),
  colhead = list(fg_params=list(cex = 0.8)),
  rowhead = list(fg_params=list(cex = 0.8)))

#pdf("C:/Personal/VOR/plot.pdf",width=6,height=4,paper='special') 
grid.arrange(tableGrob(course(fidu$par)[1:12, c(1, 5, 6, 7)], theme = mytheme), ggmap(mapgilbert) +
               geom_point(data = as.data.frame(rbind(painters)), aes(x = as.double(Lon), y = as.double(Lat)), color = 4, fill = 4, size = 2, alpha=0.8)+
               geom_point(data = as.data.frame(rbind(pointers)), aes(x = as.double(Lon), y = as.double(Lat)), color = 3, fill = 3, size = 2, alpha=0.8)+
               geom_point(data = as.data.frame(c(DLo, DLa)), aes(x = DLo, y = DLa), color = 2, fill = 2, size = 2, alpha=0.8)  
             , ncol=2)

#  annotate("text", x=180, y=15, label = course(fidu$par),         colour = I("red"), size = 3.5)
#dev.off()

 
