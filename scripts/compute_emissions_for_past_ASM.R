# emissions for all ASLO conferences since 2004
getwd()
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

source("./scripts/function_travel-related_emissions.R")
source("./function_travel-related_emissions.R")



###Data
#### import all sheets from the ASLO meeting data
path <- "./Data/ASLO Carbon Footprint Meeting Data.xlsx"
data_all_ASLO<-multiplesheets(path)
str(data_all_ASLO)


#### data for conference location, from 2004 to 2023
df_loc<-load("./Rdata/df_loc.RData")


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
  loc<-df_loc[i]
  Nas<-length(which(is.na(df$airport_code)))
  df_C<-conf_C_footprint (conf_loc_iata=loc$airport_code,conf_loc_coord=c(loc$lon,loc$lat),origin_iata=df$airport_code,n_per_origin=1,origin_coord=c(df$lon,df$lon),distance_landbasedTransport=TRUE,conversion_train=30,NAs=Nas)
  df$airplanes_emissions<-Total_emissions
  df$airplanes_distance<-Total_kmtravelled
  df$percent_saved_by_landbound_transport<-percent_saved_by_landbound_transport
  data_all_ASLO_emissions[[i]]<-df
}

