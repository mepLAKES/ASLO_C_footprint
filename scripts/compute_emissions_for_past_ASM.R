# emissions for all ASLO conferences since 2004

##necessary packages, functions and Data
###libraries
install.packages("devtools")
devtools::install_github("IDEMSInternational/carbonr")

library(tidygeocoder)
library("airportr")
library("footprint")
library("carbonr")
library(readxl)
library(dplyr, warn.conflicts = FALSE)
library(ggmap)
library(geosphere)
library(ggplot2)



###required function
####read multiple sheets of attendance

source("/Users/mperga/Documents/GitHub/ASLO_C_footprint/scripts/function_travel-related_emissions.R")
source("/Users/mperga/Documents/GitHub/ASLO_C_footprint/scripts/function_Multiple_sheets.R")

###Data
#### import all sheets from the ASLO meeting data
path <- "./Data/ASLO Carbon Footprint Meeting Data.xlsx"
data_all_ASLO<-multiplesheets(path)
str(data_all_ASLO)


#### data for conference location, from 2004 to 2023
load("./Rdata/df_loc.RData")


##Data analysis
### extract coordinates for attendees and find closest airport
key="API Google key"
register_google(key=key)
n=length(data_all_ASLO)
data_all_ASLO_coords<-list()
for (i in 1:n) {
   
df <- data_all_ASLO[[i]]
LonLat<-geocode(paste(df$City, df$Country))
df2<-cbind(df,LonLat)
airport<-c()
for (j in 1:nrow(df2)) {
  X<-data.frame(airports_around(df$lat[j],df$lon[j],distance =100))
  airport_code[j]<-subset(X,IATA!="\\N")[1,]}
data_all_ASLO_coords[[i]]<-cbind(df2,airport_code)
}



####final data files (as the run takes quite some time, and money for the geolocalization on Google maps)
data_all_ASLO_coords2<-load("./RData/data_all_ASLO_coords2.rdata")


###Compute airplane emissions, and potential land-bound report
data_all_ASLO_emissions<-list()

for (i in 1:n) {
  df <- data_all_ASLO_coords2[[i]]
  loc<-df_loc[i,]
  df_C<-conf_C_footprint (conf_loc_iata=loc$airport_code,conf_loc_coord=c(loc$lon,loc$lat),origin_iata=df$airport_code,origin_coord=cbind(df$lon,df$lat),distance_landbasedTransport=1000,conversion_train=30)
  df$airplanes_emissions<-df_C$Ind_emissions_all_flying
  df$travelled_distance<-df_C$Ind_travelled_distance
  df_loc$Total_emissions[i]<-df_C$Total_emissions_all_flying
  df_loc$Total_kmtravelled[i]<-df_C$Total_kmtravelled
  df_loc$percent_saved_by_landbound_transport[i]<-df_C$percent_saved_by_landbound_transport
  data_all_ASLO_emissions[[i]]<-df
}

save(data_all_ASLO_emissions,file="RData/data_all_ASLO_emissions.rdata")
