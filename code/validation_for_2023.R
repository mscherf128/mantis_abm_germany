# Clear the workspace
rm(list=ls())
getwd()

################################# Packages #####################################
# Load the mapview package for interactive mapping
library(sf)
library(ggplot2)

# Load the 2022 data
gottan_2022_sf <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_2022")

# Load the observed 2023 data
gottan_2023_obs <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_2023")

# Load the predicted 2023 data from a shapefile
gottan_2023_pred <- st_read("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/mantis_2023_modeled.shp")
# Set the coordinate reference system (CRS) for the predicted data
st_crs(gottan_2023_pred) <- st_crs(32632)

# Extract the geometry of the predicted data
gottan_2023_predicted <- gottan_2023_pred["geometry"]
# Convert the extracted geometry to an sf object with specified CRS
gottan_2023_predicted_sf <- st_as_sf(gottan_2023_predicted, coords = coordinates, crs = 4326)

# Set the CRS for the observed data
st_crs(gottan_2023_obs) <- st_crs(4326)

# Nearest neighbour
# Transform the observed data to match the CRS of the predicted data
gottan_2023_obs_proj <- st_transform(gottan_2023_obs, st_crs(gottan_2023_predicted))
# Calculate the nearest neighbor distances between observed and predicted points
nndist <- FNN::knnx.dist(data = st_coordinates(gottan_2023_obs_proj), query = st_coordinates(gottan_2023_predicted))

# Create a dataframe to store the distances and their mean
distances_df_for_2023_pred <- data.frame(nndist, mean=rowMeans(nndist))
# Add the mean nearest neighbor distance to the predicted data
gottan_2023_predicted$mean_10_nnd <- distances_df_for_2023_pred$mean

# Plot a histogram of the mean nearest neighbor distances
hist(gottan_2023_predicted$mean_10_nnd, breaks=50)

# Plot the empirical cumulative distribution function (ECDF) of the mean nearest neighbor distances
plot(ecdf(gottan_2023_predicted$mean_10_nnd),
     do.points = FALSE,
     main = "Empirical cumulative distribution function of mean NND",
     xlab = "",
     ylab = "relative cumulative frequency",
     xaxt = "n")
abline(h = 0.8, col = "red", lwd = 2, lty = 2)

# Create the ECDF function for the mean nearest neighbor distances
ecdf_function <- ecdf(gottan_2023_predicted$mean_10_nnd)

# Determine the x-value corresponding to the y-value of 0.8 in the ECDF
x_value <- min(gottan_2023_predicted$mean_10_nnd[ecdf_function(gottan_2023_predicted$mean_10_nnd) >= 0.8])
x_value

# Add a vertical line at the x-value
abline(v = x_value, col = "black", lwd = 2, lty = 2)

# Rotate the x-axis labels
par(las = 2) # las = 2 rotates the axis labels vertically
axis(1, at = seq(0, max(gottan_2023_predicted$mean_10_nnd), by = 10000))
par(las = 1) # Reset the axis labels to the default orientation

# Add a label to the x-axis with a larger distance from the axis
mtext("mean NND [m]", side = 1, line = 4)  # line = 4 sets the distance, the larger the value, the further down

# Load administrative boundaries for Germany
DEgadmsf <- readRDS("C:/Users/scher/Documents/2_Semester/Fernerkundung/mantis_abm_germany/data/DEgadmsf")

# Plot the observed and predicted mantis occurrences for 2023 on a map of Germany
ggplot() +
  geom_sf(data = DEgadmsf, fill = "snow2") +
  geom_sf(data = gottan_2023_obs_proj, aes(color = "mantis occurrence 2023, observed"), size = 2, pch = 20) +
  geom_sf(data = gottan_2023_predicted, aes(color = "mantis occurrence 2023, predicted"), size = 2, pch = 20) +
  scale_color_manual(name = "", 
                     values = c("mantis occurrence 2023, observed" = "blue", "mantis occurrence 2023, predicted" = "red"),
                     labels = c("mantis occurrence\n2023, observed", "mantis occurrence\n2023, predicted")) +
  theme_minimal() +
  theme(
    axis.text = element_text(size = 12),       # Font size for axis labels
    axis.title = element_text(size = 14),      # Font size for axis titles
    legend.text = element_text(size = 11),     # Font size for legend text
    legend.title = element_text(size = 12)     # Font size for legend title
  )

# Plot the observed mantis occurrences for 2022 on a map of Germany
ggplot() +
  geom_sf(data = DEgadmsf, fill = "lightyellow") +
  geom_sf(data = gottan_2022_sf, aes(color = "mantis occurrence 2022, observed"), size = 2, pch = 20) +
  scale_color_manual(name = "", 
                     values = c("mantis occurrence 2022, observed" = "darkgrey"),
                     labels = c("mantis occurrence\n2022, observed")) +
  theme_minimal() +
  theme(
    axis.text = element_text(size = 12),       # Font size for axis labels
    axis.title = element_text(size = 14),      # Font size for axis titles
    legend.text = element_text(size = 11),     # Font size for legend text
    legend.title = element_text(size = 12)     # Font size for legend title
  )

# Plot the predicted mantis occurrences for 2023 on a map of Germany, colored by mean nearest neighbor distance
ggplot() +
  geom_sf(data = DEgadmsf, fill = "snow2") +
  geom_sf(data = gottan_2023_predicted, aes(color = mean_10_nnd), size = 2, pch = 20) +
  scale_color_viridis_c(name = "mean 10 NND [meter]",
                        breaks = c(20000, 40000, 60000, 80000),
                        labels = c("20,000","40,000", "60,000","80,000"),
                        begin = 0,
                        end = 1) +
  theme_minimal() +
  theme(
    axis.text = element_text(size = 12),       # Font size for axis labels
    axis.title = element_text(size = 14),      # Font size for axis titles
    legend.text = element_text(size = 11),     # Font size for legend text
    legend.title = element_text(size = 12)     # Font size for legend title
  )