library(dplyr)
library(raster)
library(stringi)

# Set working directory to path of the script
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Get the list of country names
countries <- list.files(path = '../results/', pattern = '[A-Z]{3}')

# Get the scenarios
scenarios <- list.dirs(path = file.path('..', 'results', countries[1]), recursive = F, full.names = F)

# Get the years
years <- list.files(path = file.path('..', 'results', countries[1], scenarios[1]))

# Loop through scenarios
for (scenario in scenarios) {
  # Loop through years
  for (year in years) {
    # Ensemble mean file name
    filename_mean <- stringi::stri_c(scenario, '_', year, '.tif')
    # List of results of all countries
    list_rst_mean <- list()
    for (i in 1:length(countries)) {
      rst_mean <- raster(file.path('..', 'results', countries[i], filename_mean))
      raster::crs(rst_mean) <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0"
      list_rst_mean[i] <- rst_mean
    }
    # Mosaic results of all countries
    rst_mean_world <- do.call(raster::merge, list_rst_mean)
    # Export mosaic
    raster::writeRaster(rst_mean_world, file.path('..', 'results', filename_mean))
  }
}
