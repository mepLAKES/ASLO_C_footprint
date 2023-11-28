#Compute total emissions for multi-hub conferences
#one hub : Vienna
#two hubs : Vienna and Madison
# three hubs : Vienna, Madison and Hong Kong


#packages
library("carbonr")
library(geosphere)
library(rlist)

#datasets
list_all<-list.load(file="../Rdata/data_all_ASLO_emissions_continent.rdata")
DF<-list_all[[18]]


#Hubs coordinates and airport codes

Vienna<-c(16.56,48.10)
Vienna_airport<-"VIE"

Madison<-c(-89.40,43.07)
Madison_airport<-"MSN"

Hongkong<-c(113.91,22.30)
HK_airport<-"KIX"


#allocating Hubs
##Computing great-circle distance between attendees' origin and hubs
t<-nrow(DF)


new_DF<-data.frame(City=DF$City,Country=DF$Country,lon=DF$lon,lat=DF$lat,airport_code=DF$airport_code,emissions_all_palma=DF$airplanes_emissions_all,region=DF$Region)
for (i in 1:t) {
  new_DF$dist_vienna[i] <- distHaversine(Vienna, p2=c(new_DF$lon[i],new_DF$lat[i]))/1000
  new_DF$dist_madison[i] <- distHaversine(Madison, p2=c(new_DF$lon[i],new_DF$lat[i]))/1000
  new_DF$dist_hongkong[i]<- distHaversine(Hongkong, p2=c(new_DF$lon[i],new_DF$lat[i]))/1000
}

##Finding closest hubs for the 2- and 3- hub scenario

new_DF$one_hub<-"VIE"
two_hub<-c()
three_hub<-c()
  for (i in 1:t) {
    dist_2<-c(new_DF$dist_vienna[i],new_DF$dist_madison[i])
    HUB2<-c("VIE","MSN")
    dist_3<-c(new_DF$dist_vienna[i],new_DF$dist_madison[i],new_DF$dist_hongkong[i])
    HUB3<-c("VIE","MSN","KIX")
    two_hub[i]<-HUB2[order(dist_2)][1]
    dist_two_hub[i]<-min(c(new_DF$dist_vienna[i],new_DF$dist_madison[i]))
    three_hub[i]<-HUB3[order(dist_3)][1]
    dist_three_hub[i]<-min(c(new_DF$dist_vienna[i],new_DF$dist_madison[i],new_DF$dist_hongkong[i]))
  }


new_DF$two_hub<-two_hub  
new_DF$three_hub<-three_hub  
new_DF$dist_two_hub<-dist_two_hub
new_DF$dist_three_hub<-dist_three_hub

##Computing emissions for the 1-, 2- and 3- hub scenario
for (i in 1:t) {
  to_one_hub<-"VIE"
  to_two_hub<-new_DF$two_hub[i]
  to_three_hub<-new_DF$three_hub[i]
  from<-new_DF$airport_code[i]
  new_DF$airplanes_emissions_all_one_hub[i]<-ifelse(is.na(from),NA,airplane_emissions(from=from,to=to_one_hub,
                                                               num_people = 1,
                                                               radiative_force = TRUE,
                                                               include_WTT = TRUE,
                                                               round_trip = TRUE,
                                                               class = c("Economy class")))
 new_DF$airplanes_emissions_all_two_hub[i]<-ifelse(is.na(from),NA,airplane_emissions(from=from,to=to_two_hub,
                                                               num_people = 1,
                                                               radiative_force = TRUE,
                                                               include_WTT = TRUE,
                                                               round_trip = TRUE,
                                                               class = c("Economy class")))
new_DF$airplanes_emissions_all_three_hub[i]<-ifelse(is.na(from),NA,airplane_emissions(from=from,to=to_three_hub,
                                                              num_people = 1,
                                                              radiative_force = TRUE,
                                                              include_WTT = TRUE,
                                                              round_trip = TRUE,
                                                              class = c("Economy class")))

}
new_DF$airplanes_emissions_all_one_hub<-as.numeric(new_DF$airplanes_emissions_all_one_hub)
new_DF$airplanes_emissions_all_two_hub<-as.numeric(new_DF$airplanes_emissions_all_two_hub)
new_DF$airplanes_emissions_all_three_hub<-as.numeric(new_DF$airplanes_emissions_all_three_hub)

save(new_DF,file="RData/new_DF.RData")

