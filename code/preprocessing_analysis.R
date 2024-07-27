rm(list=ls())
getwd()

################################# Packages #####################################
library(ggplot2)
library(sf)
library(terra)
library(geodata)
library(stars)
library(dplyr)
library(tidyr)

######################### Mantis data preprocessing ############################

# Import Mantis GBIF data from 2010 to 2024
mantis <- read.table("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/0016517-240626123714530_GBIF_2010_2024.csv", header = TRUE, sep = "\t")

# Remove observation points without coordinates
mantis <- mantis[!(mantis$decimalLongitude == "" | is.na(mantis$decimalLongitude)) & 
                                 !(mantis$decimalLatitude == "" | is.na(mantis$decimalLatitude)), ]

# Filter the data for the years 2010-2022 and save them in a new variable
mantis_2010_2022 <- mantis %>% dplyr::filter(mantis$year >= 2010 & mantis$year <= 2022)

# The praying mantis dataset should be divided into several datasets according to the year of observation.
# create a vector containing every year for which at least one observation is available
Jahre <- unique(mantis$year)
data_Jahre <- c()

# for-loop to create a data set for each year
for (i in Jahre){
  # Set the name of the data record according to the year
  dataset_name <- paste("gottan_", i, sep = "")
  
  # Filter the rows for the current year
  gottan_i<- subset(mantis, year == i)
  
  # Assign the filtered data frame to a new object with the corresponding name
  assign(dataset_name, gottan_i)
  
  # Create a vector containing the names of the individual data frames
  # will be needed later for the visualization
  data_Jahre <- c(data_Jahre, dataset_name)
}

# write mantis shape for 2022 for NetLogo
gottan_2022_sf <- st_as_sf(gottan_2022, coords = c("decimalLongitude","decimalLatitude"), crs = 4326)
st_write(gottan_2022_sf, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_2022.shp")

# write mantis shape for 2022 and 2023 for validation
saveRDS(gottan_2022_sf, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_2022")
gottan_2023_sf <- st_as_sf(gottan_2023, coords = c("decimalLongitude","decimalLatitude"), crs = 4326)
saveRDS(gottan_2023_sf, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_2023")

################################### GADM data ##################################

# Download GADM data
DE <- gadm("Germany", level = 0,
           path = "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data")

DEgadm <- gadm("Germany", level = 1,
               path = "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data")

#################### Plot mantis observations 2010, 2016, 2022 #################
gottan_2010_sf <- st_as_sf(gottan_2010, coords = c("decimalLongitude","decimalLatitude"), crs = 4326)
gottan_2016_sf <- st_as_sf(gottan_2016, coords = c("decimalLongitude","decimalLatitude"), crs = 4326)
DEgadmsf <- st_as_sf(DEgadm, crs = 4326)
saveRDS(DEgadmsf, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/DEgadmsf")

# Plot observations 2010
ggplot()+
  geom_sf(data = DEgadmsf, fill = "white")+
  geom_sf(data = gottan_2010_sf, aes(color = "observation of praying mantises"), show.legend = FALSE)+
  scale_color_manual(name = "", 
                     values = c("observation of praying mantises" = "darkred"),
                     labels = c("observation of\npraying mantises"))+
  theme_minimal()+
  ggtitle("2010") + 
  theme(
    plot.title = element_text(hjust = 0, vjust = -8, size = 14), # Position and size of the title
    plot.title.position = "plot"  # Position the title to be within the plot area
  )

# Plot observations 2016
ggplot()+
  geom_sf(data = DEgadmsf, fill = "white")+
  geom_sf(data = gottan_2016_sf, aes(color = "observation of praying mantises"), show.legend = FALSE)+
  scale_color_manual(name = "", 
                     values = c("observation of praying mantises" = "darkred"),
                     labels = c("observation of\npraying mantises"))+
  theme_minimal()+
  ggtitle("2016") + 
  theme(
    plot.title = element_text(hjust = 0, vjust = -8, size = 14), # Position and size of the title
    plot.title.position = "plot"  # Position the title to be within the plot area
  )

# Plot observations 2022
ggplot()+
  geom_sf(data = DEgadmsf, fill = "white")+
  geom_sf(data = gottan_2022_sf, aes(color = "observation of praying mantises"))+#, show.legend = FALSE)+
  scale_color_manual(name = "", 
                     values = c("observation of praying mantises" = "darkred"),
                     labels = c("observation of\npraying mantises"))+
  theme_minimal()+
  ggtitle("2022") + 
  theme(
    plot.title = element_text(hjust = 0, vjust = -8, size = 14), # Position and size of the title
    plot.title.position = "plot"  # Position the title to be within the plot area
  )+
  theme(
    legend.text = element_text(size = 11),     # Schriftgröße des Legendentextes
    legend.title = element_text(size = 12)     # Schriftgröße des Legendentitels
  )

############################### CORINE landcover data ##########################

# Import Landcover classification
LC_18 <- rast("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/CORINE Landcover 2018_100 m/U2018_CLC2018_V2020_20u1/U2018_CLC2018_V2020_20u1/U2018_CLC2018_V2020_20u1.tif")
LC_18_shp <- read_sf("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/CORINE_2018.shp")
LC_IB <- rast("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/Impervious Built up_10 m/IBU_2018_010m_03035_V1_0/IBU_2018_010m_03035_V1_0/IBU_2018_010m_03035_V1_0.tif")

class_value <- unique(LC_18_shp$Code_18)
class_text <- unique(LC_18_shp$LABEL3)
class_legend <- as.data.frame(class_value, class_text)

plot(LC_18)

# Raster stacken
# Checking the expansions
ext(LC_18)
ext(LC_IB)

## for LC_IB categorical values, therefore select nearest neighbor when resampling
LC_IB_resample <- resample(LC_IB, LC_18, method = "near")

new_extent <- ext(4031400, 4672500, 2684070, 3551420)

LC_18_extended <- extend(LC_18, new_extent)
LC_IB_extended <- extend(LC_IB_resample, new_extent)

ext(LC_18_extended)
ext(LC_IB_extended)

# Make a predictor set from both grids
predictors_LC <- c(LC_18_extended, LC_IB_extended)
saveRDS(predictors_LC, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/predictors_LC")
predictors_LC <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/predictors_LC")

################################## Elevation data ##############################
# Download elevation data
elev <- elevation_30s(country = "Germany",
                      path = "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data", res = 10)
plot(elev, main = "elevation")

# check at which points the elevation is zero, would be relevant for loading the data into NetLogo
is0 <- elev$DEU_elv_msk == 0
table(is0[])
plot(is0)

# Write grid as asc-file
terra::writeRaster(elev,
                   filename = "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/elevation.asc", NAflag = -9999,
                   overwrite = TRUE)

# Stack elevation and land cover to a raster
elev_reproject <- project(elev, predictors_LC)
elev_extended <- extend(elev_reproject, new_extent)

# Make predictor set from Landcover and elevation
predictors_LC_elev <- c(elev_extended, predictors_LC)
saveRDS(predictors_LC_elev, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/predictors_LC_elev")
predictors_LC_elev <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/predictors_LC_elev")

########################### surface temperature data ###########################

# Load relevant surface temperature files
file_names <- list.files("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/MPI_rcp_26/")
file_names <- file_names[1:3]

# Path to the directory with the files
path <- "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/MPI_rcp_26/"

# List for saving the imported data
ST <- list()

# Loop for reading the files
for (file_name in file_names) {
  file_path <- paste0(path, file_name)  # Erstelle den vollständigen Dateipfad
  data <- read_ncdf(file_path, var = "ts")  # Lese die NetCDF-Datei ein
  ST[[file_name]] <- data  # Speichere die Daten in der Liste
}

ST_unlist <- do.call("c", ST)
st_get_dimension_values(ST_unlist, "time")

# Tailoring data to the period 2010-2022
ST_timecrop <- ST_unlist[,,,50:205]
st_get_dimension_values(ST_timecrop, "time")
ST_timecrop_terra <- as(ST_timecrop, "SpatRaster")

# stack surface temperature with other predictor grids
ST_timecrop_terra_reproject <- project(ST_timecrop_terra, predictors_LC_elev)
saveRDS(ST_timecrop_terra_reproject, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/ST_timecrop_terra_reproject")
ST_timecrop_terra_reproject <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/ST_timecrop_terra_reproject")

ST_timecrop_terra_extended <- extend(ST_timecrop_terra_reproject, new_extent)
saveRDS(ST_timecrop_terra_extended, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/ST_timecrop_terra_extended")
ST_timecrop_terra_extended <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/ST_timecrop_terra_extended")

predictors_all <- c(predictors_LC_elev, ST_timecrop_terra_extended)
saveRDS(predictors_all, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/predictors_all")
predictors_all <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/predictors_all")

# Preparing surface temperature for NetLogo
file_names <- list.files("C:/Users/scher/Documents/2_Semester/Fernerkundung/Daten/Mantis_LST_scenarios/MPI_rcp_26/")
file_names <- file_names[3:6]

# Path to the directory with the files
path <- "C:/Users/scher/Documents/2_Semester/Fernerkundung/Daten/Mantis_LST_scenarios/MPI_rcp_26/"

# List for saving the imported data
ST <- list()

# Loop for reading the files
for (file_name in file_names) {
  file_path <- paste0(path, file_name)  # Erstelle den vollständigen Dateipfad
  data <- read_ncdf(file_path, var = "ts")  # Lese die NetCDF-Datei ein
  ST[[file_name]] <- data  # Speichere die Daten in der Liste
}

ST_unlist <- do.call("c", ST)
st_get_dimension_values(ST_unlist, "time")

# Tailoring data to the period 2023-2054
ST_timecrop <- ST_unlist[,,,25:408]
st_get_dimension_values(ST_timecrop, "time")
ST_timecrop_terra <- as(ST_timecrop, "SpatRaster")

##### data only for 2023
file_names <- list.files("C:/Users/scher/Documents/2_Semester/Fernerkundung/Daten/Mantis_LST_scenarios/MPI_rcp_26/")
file_names <- file_names[3]

# Path to the directory with the files
path <- "C:/Users/scher/Documents/2_Semester/Fernerkundung/Daten/Mantis_LST_scenarios/MPI_rcp_26/"

# List for saving the imported data
ST <- list()

# Loop for reading the files
for (file_name in file_names) {
  file_path <- paste0(path, file_name)  # Erstelle den vollständigen Dateipfad
  data <- read_ncdf(file_path, var = "ts")  # Lese die NetCDF-Datei ein
  ST[[file_name]] <- data  # Speichere die Daten in der Liste
}

ST_unlist <- do.call("c", ST)
st_get_dimension_values(ST_unlist, "time")

# Tailoring data to 2023
ST_timecrop <- ST_unlist[,,,28]
st_get_dimension_values(ST_timecrop, "time")
ST_timecrop_terra <- as(ST_timecrop, "SpatRaster")

ST_timecrop_terra_reproject_23 <- project(ST_timecrop_terra, predictors_all)

# save as asc-File
writeRaster(ST_timecrop_terra_reproject_23, filename = "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/ST_2023.asc", NAflag = -9999,
                   overwrite = TRUE)

############################# Statistical analysis #############################
mantis_2010_2022_sf <- st_as_sf(mantis_2010_2022, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)
mantis_2010_2022_sf <- st_transform(mantis_2010_2022_sf, crs(predictors_all))

# Extrahiere die x- und y-Koordinaten aus dem Punktdatensatz
coords <- st_coordinates(mantis_2010_2022_sf)

# Extrahiere Werte aus dem Raster an den Punktpositionen
mantis_values <- extract(predictors_all, coords)

saveRDS(mantis_values, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_values")
mantis_values <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_values")

############################## landcover class 2018 ############################
LC_18_gottan <- mantis_values[ , "LABEL3"]
saveRDS(LC_18_gottan, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/LC_18_gottan")
LC_18_gottan <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/LC_18_gottan")

LC_counts <- table(LC_18_gottan)

# Landnutzungsklassen mit einer Häufigkeit von über 100 filtern
LC_100 <- LC_counts[LC_counts > 100]
# Namen der Landnutzungsklassen mit einer Häufigkeit von über 100
names(LC_100)

# Landnutzungsklassen mit einer Häufigkeit von über 200 filtern
LC_200 <- LC_counts[LC_counts > 200]
# Namen der Landnutzungsklassen mit einer Häufigkeit von über 200
names(LC_200)

# Landnutzungsklassen mit einer Häufigkeit von über 300 filtern
LC_300 <- LC_counts[LC_counts > 300]
# Namen der Landnutzungsklassen mit einer Häufigkeit von über 300
names(LC_300)

# Landnutzungsklassen mit einer Häufigkeit von über 350 filtern
LC_350 <- LC_counts[LC_counts > 350]
# Namen der Landnutzungsklassen mit einer Häufigkeit von über 350
names(LC_350)

#Read Corine classes
clc_classes <- foreign::read.dbf("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/CORINE_2018.dbf",
                                 as.is = TRUE) %>%dplyr::select(value = Code_18,landcov = LABEL3)

# Zusammenfassung der Daten
summary(LC_18_gottan)

# Häufigkeiten berechnen
freq_table <- table(LC_18_gottan)
cat("Absolut Häufigkeit:\n")
print(freq_table)

relative_freq <- prop.table(freq_table)
cat("\nRelative Häufigkeit:\n")
print(relative_freq)

# Häufigkeitstabelle erstellen
freq_table_df <- as.data.frame(freq_table)
names(freq_table_df) <- c("Kategorie", "Häufigkeit")
freq_table_df$Relative_Häufigkeit <- relative_freq
print("\nHäufigkeitstabelle:")
print(freq_table_df)

# Balkendiagramm für Häufigkeiten
par(mar = c(3, 20, 3, 2) + 0.1) # Rand einstellen: unten, links, oben, rechts

barplot(freq_table, 
        #xlab = "Kategorie",
        #ylab = "frequency",
        col = "grey",
        las = 1, cex.names = 0.58,
        horiz = TRUE,
        xlim = c(0, 400))  # las = 1 dreht die Beschriftungen um 90 Grad

# Anpassung der Position des xlab
mtext("frequency", side = 1, line = 2, cex = 0.8)  # line anpassen je nach Bedarf

# Anpassung der Position des ylab
mtext("land cover class", side = 2, line = 0, cex = 0.8)

# Horizontale Linien einfügen
abline(v = 100, col = "green", lwd = 2, lty = 2)  # Höhe 100, grün, Breite 2, gestrichelt
abline(v = 200, col = "blue", lwd = 2, lty = 2)  # Höhe 200, blau, Breite 2, gestrichelt
abline(v = 300, col = "purple", lwd = 2, lty = 2)  # Höhe 300, lila, Breite 2, gestrichelt
abline(v = 350, col = "red", lwd = 2, lty = 2)  # Höhe 350, rot, Breite 2, gestrichelt

########################### landcover impervious built-up ######################
LC_IB_gottan <- mantis_values[ , "IBU_2018_010m_03035_V1_0"]
saveRDS(LC_IB_gottan, "C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/LC_IB_gottan")
LC_IB_gottan <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/LC_IB_gottan")

# Zusammenfassung der Daten
summary(LC_IB_gottan)
mean_value <- mean(LC_IB_gottan)
median_value <- median(LC_IB_gottan)
variance_value <- var(LC_IB_gottan)
sd_value <- sd(LC_IB_gottan)
freq_table <- table(LC_IB_gottan)

cat("Mittelwert:", mean_value, "\n")
cat("Median:", median_value, "\n")
cat("Varianz:", variance_value, "\n")
cat("Standardabweichung:", sd_value, "\n")
print(freq_table)

# Relative Häufigkeiten berechnen
relative_freq <- prop.table(freq_table)
print(relative_freq)

# Häufigkeitstabelle
freq_table_df <- as.data.frame(freq_table)
names(freq_table_df) <- c("Wert", "Häufigkeit")
freq_table_df$Relative_Häufigkeit <- relative_freq
print(freq_table_df)

# Balkendiagramm für Häufigkeiten
par(mar = c(5.1, 4.1, 4.1, 2.1))
barplot(freq_table, main = "Frequency of impervious built-up values\nat the mantis observation points",
        ylab = "frequency", col = "grey",
        names.arg = c("impervious built-up absent", "impervious built-up present"))

############################### elevation ######################################
elev_gottan <- mantis_values[ , "DEU_elv_msk"]
elev_gottan <- na.omit(elev_gottan)

# Statistische Auswertung
mean_elev <- mean(elev_gottan)
sd_elev <- sd(elev_gottan)
median_elev <- median(elev_gottan)
min_elev <- min(elev_gottan)
max_elev <- max(elev_gottan)
q1_elev <- quantile(elev_gottan, 0.25)
q3_elev <- quantile(elev_gottan, 0.75)

# Ausgabe der Statistiken
cat("Statistische Auswertung von elev_gottan:\n")
cat("mean:", mean_elev, "\n")
cat("standard deviation:", sd_elev, "\n")
cat("median:", median_elev, "\n")
cat("minimum:", min_elev, "\n")
cat("maximum:", max_elev, "\n")
cat("1. Quartil (Q1):", q1_elev, "\n")
cat("3. Quartil (Q3):", q3_elev, "\n")

# Boxplot zur Darstellung der Verteilung
boxplot(elev_gottan, main = "Boxplot of elevation values at the\nmantis observation points ", ylab = "elevation in m")

############################ surface temperature ###############################
surftemp_gottan <- mantis_values[ , 4:159]
# von Kelvin in °C umrechnen
surftemp_gottan <- surftemp_gottan - 273.15
summary(surftemp_gottan)

# Zuerst die Spaltennamen extrahieren
column_names <- colnames(surftemp_gottan)

# Mai-Daten der Jahre auswählen: Frühjahrstemperaturen sind entscheidend für die Entwicklung der Mantis
# Die Spaltennamen filtern, die den Monat März und die Jahre 2010-2022 enthalten
may_columns <- grep("time20(1[0-9]|2[0-2])-05", column_names, value = TRUE)

# Die gefilterten Spalten aus dem Datensatz extrahieren
may_data <- surftemp_gottan[, may_columns]

# Minima für jede Spalte berechnen
min_may_values <- apply(may_data, 2, min, na.rm = TRUE)

# Mittelwerte für jede Spalte berechnen
mean_may_values <- apply(may_data, 2, mean, na.rm = TRUE)

# Jahre aus den Spaltennamen extrahieren
years_may <- sub("time(\\d{4})-05.*", "\\1", colnames(may_data))

# Minima und Mittelwerte in DataFrames zusammenführen
min_may_data <- data.frame(Year = as.numeric(years_may), Min = min_may_values)
mean_may_data <- data.frame(Year = as.numeric(years_may), Mean = mean_may_values)

# Diagramme erstellen
# Minima in einem Diagramm darstellen
ggplot(min_may_data, aes(x = Year, y = Min)) +
  geom_line() +
  geom_point() +
  labs(title = "Minima der Rasterdaten für Mai 2010-2022",
       x = "Jahr",
       y = "Minimum") +
  theme_minimal()

# Mittelwerte in einem Diagramm darstellen
ggplot(mean_may_data, aes(x = Year, y = Mean)) +
  geom_line() +
  geom_point() +
  labs(title = "Mean raster surface temperature for May",
       x = "year",
       y = "mean temperature [°C]") +
  scale_x_continuous(breaks = seq(min(mean_may_data$Year), max(mean_may_data$Year), by = 1), minor_breaks = NULL) +
  scale_y_continuous(breaks = seq(floor(min(mean_may_data$Mean)), ceiling(max(mean_may_data$Mean)), by = 1)) +
  theme_minimal()+
  theme(plot.title = element_text(hjust = 0.5))

# Datenrahmen für den Boxplot erstellen
mean_mai_df <- data.frame(
  Year = rep("", length(mean_may_values)),
  Mean = mean_may_values
)

# Boxplot für die Mittelwerte der Oberflächentemperatur im Mai erstellen
ggplot(mean_mai_df, aes(x = Year, y = Mean)) +
  geom_boxplot() +
  scale_y_continuous(breaks = seq(floor(min(mean_mai_df$Mean)), ceiling(max(mean_mai_df$Mean)), by = 1)) +
  labs(title = "Boxplot of mean may surface\ntemperature from 2010-2022",
       x = "",
       y = "mean surface temperature [°C]") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

