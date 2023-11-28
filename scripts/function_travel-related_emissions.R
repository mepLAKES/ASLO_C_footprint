
#function to compute airplane emissions and potential landbased emissions 
#conf_C_footprint compute CO2e attributed to attendees' transport to a conference venue by air-travel (in tCO2e), the total travelled distance (km), and how much of total emission (%) can saved by switch on landbound transport

#required packages


library("carbonr")
library(geosphere)

#function parameters

#conf_loc_iata: IATA code for the closest airport of the conference location 
#conf_loc_coord (lon, lat) : coordinates for the conference location
#origin_iata: IATA code for the closest airport to the attendees' city of origin (vector)
#origin_coord (lon, lat): coordinates for the attendee's origin (data.frame with lon in the first column and lat as the 2nd column)
#distance_landbasedTransport : max distance at which landbound transport can substitute air-travel in km _single number
#conversion_train : conversion factor for landbound transport ( in gCo2e/km)_ single number

#requires geosphere,airportr,footprint,carbonr

conf_C_footprint <- function(conf_loc_iata,conf_loc_coord,origin_iata,origin_coord,distance_landbasedTransport,conversion_train){
t<-length(origin_iata)
emissions_1<-c()
for (i in 1:t) {
to<-origin_iata[i]
emissions_1[i]<-ifelse(is.na(to),NA,airplane_emissions(from=conf_loc_iata,to=to,
num_people = 1,
radiative_force = TRUE,
include_WTT = TRUE,
round_trip = TRUE,
class = c("Economy class"))
)
}
emissions_1<<-emissions_1
travelled_distance<-c()
for (i in 1:t) {
p1<-c(origin_coord[i,1],origin_coord[i,2])
travelled_distance[i]<-distHaversine(p1,conf_loc_coord)/1000
}
travelled_distance<<-travelled_distance
NAs<-length(which(is.na(to)))
Total_emissions<-sum(emissions_1,na.rm=TRUE)+NAs*mean(emissions_1,na.rm=TRUE)
Total_kmtravelled<-2*(sum(travelled_distance)+NAs*2*mean(travelled_distance,na.rm=TRUE))
N<-which(travelled_distance<=distance_landbasedTransport)
emissions_2<-emissions_1
emissions_2[N]<-(1.2*travelled_distance[N]*2*conversion_train/1000)/1000
landbound<-sum(emissions_2,na.rm=TRUE)
all_flying<-sum(emissions_1,na.rm=TRUE)
percent_saved_by_landbound_transport<-((all_flying-landbound)/all_flying)*100
return(list(Ind_emissions_all_flying=emissions_1,Ind_travelled_distance=travelled_distance,Total_emissions_all_flying=Total_emissions,Total_kmtravelled=Total_kmtravelled,percent_saved_by_landbound_transport=percent_saved_by_landbound_transport))
}

#returns a list with
#Ind_emissions_all_flying: individual CO2e emissions in tCO2e for flying back and forth, direct flight, economy class
#Ind_travelled_distance: individual travelled distance in km
#Total_emissions_all_flying: total CO2e emissions for all attendees, if they were all flying (tCO2e)
#Total_kmtravelled: total travelled distance in km
#percent_saved_by_landbound_transport: percent of total emissions that can be saved by report on landbound transport, in %

