**Project Title**

ASLO_C_footprint

Computation of the carbon footprint of ASM (ASLO) and tests of alternative options

**Project information**

1.  **Automated text analysis on abstracts from the ASM 2023.**

    The database for this analysis is Abstract.csv. a series of terms connected to climate change research is automatically detected for each of the 2029 abstracts, and occurrence is reported.

2.  **Estimated CO`2eq` emissions from travel for past ASM (2004-2003)**

    The initial dataset "ASLO Carbon footprint Meeting data" is an excel folder with 18 sheets providing City and Country for the attendees for all ASM since 2004. Data are anonymised.

    The data file df_loc provides the ASM venue for the 18 years (2004-2023), gps coords (lat, lon), with the IATA code of the closest airport.

    After importation (function_Multiple_sheets), GPS coordinates for the origin of attendees are extracted from Googlemaps using the ggmap package (API key required).

    GPS coords are used to extract the code for the closest airport from the attendees'origin (from the airport package), and then to compute carbon emissions either from the carbonr package, or by computing the travelled distance from the great-circle distance (from the geosphere package) between the origin and the conference venue (back and forth), and multiplying the distance by the conversion factor (average value for direct, economic flight of 163 gCO`2eq`/km, Department for Energy Security and Net Zero and Department for Business, E. I. S. 2022). Both are strictly equivalent.

    For attendees who are \<1000 km from the conference venue, we considered they could travel using land-based transport. We considered that landbound transportation would be 20% longer than the great circle distance, et we use the average conversion factor for Worldwide train or regular-size shared car (30 gCO`2eq`/km, Department for Energy Security and Net Zero and Department for Business, E. I. S. 2022).

3.  **Estimating CO`2eq` emissions for multi-hub models**

    Herein we chose Vienna, Madison and Hong-Kong as potential hubs, and used attendance for ASM 2023 as the base data.

    For a single hub, emissions are computed as in 2.

    For multiple hubs, the great circle distances between the attendees'origin and the possible venue are computed as in 2, and the shortest distance determines the proximal hub. Once the proximal hub determined, the emissions are computed as in 2.

4.  **References**

Department for Energy Security and Net Zero and Department for Business, E. I. S. 2022. Greenhouse gas reporting: conversion factors 2022, p. These emission conversion factors are for use by UK and international organisations to report on 2022 greenhouse gas emissions. *In* E. I. S. Department for Energy Security and Net Zero and Department for Business [ed.]. GOV.UK.

**How to run the code**

This R code is available for Mac, Windows and Linux OS.
To run the code, first clone this repository:
``` git clone https://github.com/mepLAKES/ASLO_C_footprint ```

Install the required packages:
```
install.packages("devtools")
devtools::install_github("IDEMSInternational/carbonr")
install.packages(c("tidygeocoder","airportr","footprint","carbonr","readxl","dplyr","ggmap","geosphere","ggplot2","rlist","config"))
```

You will need an API key to extract coordinates on googlemaps

**Credits Marie-Elodie Perga**

[marie-elodie.perga\@unil.ch](mailto:marie-elodie.perga@unil.ch){.email} 
Perga, M. E., T. Dittmar, D. Bouffard, and E. Kritzberg. submitted. The elephant in the conference room:
Reducing the Carbon Footprint of Aquatic Science Meetings (submitted)

**Licence MIT licence **

see Licence.txt
