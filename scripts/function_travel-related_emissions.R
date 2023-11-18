#function to compute airplane emissions and potential landbased emissions 
#Compute emissions for any location

library(tidygeocoder)
library("airportr")
library("footprint")
library("carbonr")
library(readxl)
library(dplyr, warn.conflicts = FALSE)
library(ggmap)
library(geosphere)
library(ggplot2)

install.packages("devtools")
devtools::install_github("IDEMSInternational/carbonr")


#conf_loc_iata
#conf_loc_coord (lon, lat)
#origin_iata
#n_per_origi
#origin_coord (lon, lat)
#distance_landbasedTransport
#conversion_train
#NAs=number of nas
#requires geosphere,airportr,footprint,carbonr

conf_C_footprint <- function(conf_loc_iata,conf_loc_coord,origin_iata,n_per_origin,origin_coord,distance_landbasedTransport,conversion_train,NAs){
  t<-length(origin_iata)
  for (i in 1:t) {
    to<-origin_iata[i]
    emissions_1[i]<-airplane_emissions(from=conf_loc_iata,to=to,
                                       num_people = n_per_origin[i],
                                       radiative_force = TRUE,
                                       include_WTT = TRUE,
                                       round_trip = TRUE,
                                       class = c("Economy class")
    )
  }
  
  
  for (i in 1:t) {
    p1<-c(origin_coord$lon[i],origin_coord$lat[i])
    travelled_distance[i]<-distHaversine(p1,conf_loc_coord)/1000
  }
  
  
  Total_emissions<-sum(emissions_1)+NAs*mean(emissions_1,na.rm=TRUE)
  Total_kmtravelled<-2*(sum(travelled_distance*n_per_origin)+NAs*2*mean(travelled_distance,na.rm=TRUE))
  
  
  N<-which(travelled_distance<=distance_landbasedTransport)
  
  emissions_2<-emissions_1
  emissions_2[N]<-(1.2*travelled_distance[N]*2*conversion_train/1000*n_per_origin[N])/1000
  landbound<-sum(emissions_2)
  all_flying<-sum(emissions_2)
  percent_saved_by_landbound_transport<-((all_flying-landbound)/all_flying)*100
  results_df<-data.frame(origin_iata,n_per_origin,origin_coord,travelled_distance,emissions_1,emissions_2)
  
  print(paste("Total emissions without landbound transport=", round(Total_emissions,digits=0), "tCO2_eq"))
  print(paste("Total travelled distance=", round(Total_kmtravelled,digits=0), "km"))
  print(paste("percent that can be saved by landbound transport=", round(percent_saved_by_landbound_transport,digits=2), "%"))
}