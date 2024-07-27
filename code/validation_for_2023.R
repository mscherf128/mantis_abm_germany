rm(list=ls())
getwd()

################################# Packages #####################################
library(mapview)

# Data 2022
gottan_2022_sf <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_2022")

# observed Data
gottan_2023_obs <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_2023")

# predicted Data
gottan_2023_pred <- st_read("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_2023_modeled.shp")
st_crs(gottan_2023_pred) <- st_crs(32632)
mapview(gottan_2023_pred)

gottan_2023_predicted <- gottan_2023_pred["geometry"]
gottan_2023_predicted_sf <- st_as_sf(gottan_2023_predicted, coords = coordinates, crs = 4326)

st_crs(gottan_2023_obs) <- st_crs(4326)

# Nearest neighbour
gottan_2023_obs_proj <- st_transform(gottan_2023_obs, st_crs(gottan_2023_predicted))
nndist <- FNN::knnx.dist(data = st_coordinates(gottan_2023_obs_proj), query = st_coordinates(gottan_2023_predicted))

distances_df_for_2023_pred <- data.frame(nndist, mean=rowMeans(nndist))
gottan_2023_predicted$mean_10_nnd <- distances_df_for_2023_pred$mean

# Abbildungen results
hist(gottan_2023_predicted$mean_10_nnd, breaks=50)

plot(ecdf(gottan_2023_predicted$mean_10_nnd),
     do.points = FALSE,
     main = "Empirical cumulative distribution function of mean NND",
     xlab = "",
     ylab = "relative cumulative frequency",
     xaxt = "n")
abline(h = 0.8, col = "red", lwd = 2, lty = 2)

ecdf_function <- ecdf(gottan_2023_predicted$mean_10_nnd)

# Bestimme den x-Wert, der dem y-Wert 0.8 entspricht
# Finde den kleinsten x-Wert, für den die ecdf >= 0.8 ist
x_value <- min(gottan_2023_predicted$mean_10_nnd[ecdf_function(gottan_2023_predicted$mean_10_nnd) >= 0.8])
x_value

abline(v = x_value, col = "black", lwd = 2, lty = 2)

# Drehung der Beschriftung der x-Achse
par(las = 2) # las = 2 dreht die Achsenbeschriftung vertikal
axis(1, at = seq(0, max(gottan_2023_predicted$mean_10_nnd), by = 10000))
par(las = 1) # Zurücksetzen der Achsenbeschriftung zur Standardausrichtung

# Füge das x-Achsen-Label mit einem größeren Abstand hinzu
mtext("mean NND [m]", side = 1, line = 4)  # line = 4 legt den Abstand fest, je größer der Wert, desto weiter unten

DEgadmsf <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/DEgadmsf")

ggplot() +
  geom_sf(data = DEgadmsf, fill = "snow2") +
  geom_sf(data = gottan_2023_obs_proj, aes(color = "mantis occurrence 2023, observed"), size = 2, pch = 20) +
  geom_sf(data = gottan_2023_predicted, aes(color = "mantis occurrence 2023, predicted"), size = 2, pch = 20) +
  scale_color_manual(name = "", 
                     values = c("mantis occurrence 2023, observed" = "blue", "mantis occurrence 2023, predicted" = "red"),
                     labels = c("mantis occurrence\n2023, observed", "mantis occurrence\n2023, predicted")) +
  theme_minimal()+
  theme(
    axis.text = element_text(size = 12),       # Schriftgröße der Achsenbeschriftungen
    axis.title = element_text(size = 14),      # Schriftgröße der Achsentitel
    legend.text = element_text(size = 11),     # Schriftgröße des Legendentextes
    legend.title = element_text(size = 12)     # Schriftgröße des Legendentitels
  )

ggplot() +
  geom_sf(data = DEgadmsf, fill = "lightyellow") +
  geom_sf(data = gottan_2022_sf, aes(color = "mantis occurrence 2022, observed"), size = 2, pch = 20) +
  scale_color_manual(name = "", 
                     values = c("mantis occurrence 2022, observed" = "darkgrey"),
                     labels = c("mantis occurrence\n2022, observed")) +
  theme_minimal()+
  theme(
    axis.text = element_text(size = 12),       # Schriftgröße der Achsenbeschriftungen
    axis.title = element_text(size = 14),      # Schriftgröße der Achsentitel
    legend.text = element_text(size = 11),     # Schriftgröße des Legendentextes
    legend.title = element_text(size = 12)     # Schriftgröße des Legendentitels
  )

ggplot() +
  geom_sf(data = DEgadmsf, fill = "snow2") +
  geom_sf(data = gottan_2023_predicted, aes(color = mean_10_nnd), size = 2, pch = 20) +
  scale_color_viridis_c(name = "mean 10 NND [meter]",
                        breaks = c(20000, 40000, 60000, 80000),
                        labels = c("20.000","40.000", "60.000","80.000"),
                        begin = 0,
                        end = 1,
                        #trans = "log"
  ) +
  theme_minimal()+
  theme(
    axis.text = element_text(size = 12),       # Schriftgröße der Achsenbeschriftungen
    axis.title = element_text(size = 14),      # Schriftgröße der Achsentitel
    legend.text = element_text(size = 11),     # Schriftgröße des Legendentextes
    legend.title = element_text(size = 12)     # Schriftgröße des Legendentitels
  )