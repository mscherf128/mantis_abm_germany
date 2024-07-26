rm(list=ls())
getwd()

#### Packages ####
# library(ggplot2)
# library(tmap)
# 
# library(sf)
# library(sp)
# library(terra)
# library(geodata)
# 
# library(gridExtra)
# library(getSpatialData)
# library(mapview)
# library(abind)
# library(stars)
# library(viridis)
# library(viridisLite)
# library(cowplot)
# library(dplyr)
# library(tidyr)
# library(lubridate)


# Mantis GBIF Daten von 2010 bis 2024 einlesen
mantis <- read.table("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/0016517-240626123714530_GBIF_2010_2024.csv", header = TRUE, sep = "\t")

# Beobachtungspunkte ohne Koordinaten entfernen
mantis <- mantis[!(mantis$decimalLongitude == "" | is.na(mantis$decimalLongitude)) & 
                                 !(mantis$decimalLatitude == "" | is.na(mantis$decimalLatitude)), ]


# Der Gottesanbeterin-Datensatz soll in mehrere Datensätze, aufgeteilt nach dem Beobachtungsjahr, gegliedert werden.

# einen Vektor erstellen, der jede Jahreszahl, für die mindestens eine Beobachtung vorliegt, enthält
Jahre <- unique(gottan_latest$year)
data_Jahre <- c()

# for-Schleife zur Erstellung eines Datensatzes für jedes Jahr
for (i in Jahre){
  # Setze den Namen des Datensatzes entsprechend dem Jahr
  dataset_name <- paste("gottan_", i, sep = "")
  
  # Filtere die Zeilen für das aktuelle Jahr
  gottan_i<- subset(gottan_latest, year == i)
  
  # Weise den gefilterten Datenrahmen einem neuen Objekt mit dem entsprechenden Namen zu
  assign(dataset_name, gottan_i)
  
  # einen Vektor erstellen, der die Namen der einzelnen data-frames enthält
  # wird später für die Visualisierung benötigt
  data_Jahre <- c(data_Jahre, dataset_name)
}

# mantis shape für 2022 für NetLogo rausschreiben
gottan_2022_sf <- st_as_sf(gottan_2022, coords = c("decimalLongitude","decimalLatitude"), crs = 4326)

st_write(gottan_2022_sf, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_2022.shp")

# Herunterladen GADM-Daten
DE <- gadm("Germany", level = 0,
           path = "C:/Users/scher/Documents/2_Semester/mantis_abm_germany/data")

DEgadm <- gadm("Germany", level = 1,
               path = "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data")

