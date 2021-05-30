Genner <- read_table2("gen.csv", col_names = FALSE, skip = 1, guess_max = 20, na = "0")


# Genner <- read_excel("gen.xlsx", col_names = FALSE)

for(i in 1:dim(Genner)[1])
{
  if(!is.na(Genner[i,1])){
  if(Genner[i,1]==1){
pointers <- as.data.frame(course(Genner[i,3:34])[,c(3,4)])
print(i)
#course(optCou)

pointers <- matrix(as.double(matrix(unlist(pointers), nrow = TL, ncol=2)), nrow = TL, ncol=2)
#pointers <-cbind(lapply(pointers[,1], EaMe), pointers[,2])
colnames(pointers) <- c("Lon", "Lat")
#pointers


pointers <- as.data.frame(pointers)


name <- paste("plot/",i,"plot.png", sep="")
png(name) 
print(ggplot(data = world) +
  geom_sf() +
  coord_sf(xlim = c(min(PLo, DLo)-1 , max(PLo, DLo)+1), ylim = c(min(PLa, DLa)-1, max(PLa, DLa)+7), expand = FALSE) +
                geom_point(data = as.data.frame(rbind(painters)), aes(x = as.double(Lon), y = as.double(Lat)), color = 4, fill = 4, size = 2, alpha=0.8)+
                geom_point(data = as.data.frame(rbind(pointers)), aes(x = as.double(Lon), y = as.double(Lat)), color = 3, fill = 3, size = 2, alpha=0.8)+
                #geom_polygon(data=sodo1S, aes(x=long, y=lat, group=group), color="red", alpha=0)+
                # geom_polygon(data=sodo2S, aes(x=long, y=lat, group=group), color="red", alpha=0)+
                geom_point(data = as.data.frame(c(DLo, DLa)), aes(x = DLo, y = DLa), color = 2, fill = 2, size = 2, alpha=0.8)  +
                geom_point(data = as.data.frame(c(PLo, PLa)), aes(x = PLo, y = PLa), color = 2, fill = 2, size = 2, alpha=0.8)
)
# Sys.sleep(5)
dev.off()
# Sys.sleep(2)
  }
}
}
