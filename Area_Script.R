require(sp)
require(rgdal)
require(raster)
require(ncdf)

#load data, plot area of interest in green
Altitude=raster("alt.bil") #altitude data from worldclim
Maize=raster("maize_AreaYieldProduction.nc",level=1) #maize cultivation data from earthstat; first level is percent land cultivated
e<-extent(c(-89.82036,-28.74251,-56.5066,12.90124)) #defines extent of South America
SAAlt<-crop(Altitude,e) #apply extent to altitude layer
SAMaize<-crop(Maize,e) #apply extent to maize layer
a<-SAAlt>1700 #define threshold for altitude
m<-SAMaize>0 #define threshold for proportion of pixel under maize cultivation
intersect<-a+m #add layers with raster algebra; layers meeting both criteria (altitude and maize cultivation have value of "2")
plot(intersect, main="Intersect of Maize Cultivation > 0 and Altitude >1700m")

#calculation of total area of grids with maize above 1700m
ivals<-values(intersect) #creates an object with just the values from the intersect
length(subset(ivals,ivals==2))*100 #gives the area in km^2 of intersect assuming 5 arc-minute resolution--100km^2/pixel

#calculation of extent of area currently under maize cultivation in grids
projection(SAAlt)<-"+proj=utm +zone=48 +datum=WGS84" #to stack layer each must be in the same geographic projection
projection(SAMaize)<-"+proj=utm +zone=48 +datum=WGS84" #to stack layer each must be in the same geographic projection
ST<-stack(SAAlt,SAMaize) #stacking altitude and maize layers so attributes can be retained in a query
STM<-as.matrix(ST) #converting S4 object to matrix
STD<-data.frame(STM) #converting matrix to data.frame for subset query
sub<-subset(STD, alt > 1700 & maizeData > 0) # identifying subset of grids with maize cultivation and >1700m
sum(sub$maizeData)*100 #calculating area