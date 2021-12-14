library(sf)
library(rgdal)
library(dplyr)
library(raster)
library(fasterize)
library(rstudioapi)
library(rnaturalearth)

# Set working directory to path of the script
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Download country boundaries from Natural Earth
countries <- ne_download(scale = 10, returnclass = 'sf') %>%
  dplyr::select(ADM0_A3, ADMIN)

# Load urban land cover in 2015 from GHSL
smod_2015 <- raster(file.path('..', 'data', 'GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V2_0', 'GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V2_0.tif'))

# Load urban suitability (global coverage)
suitability <- raster(file.path('..', 'data', 'suitability', 'suitability_pca2_excluded.tif'))

# Load Urban Land (km2) projections
tbl_urban_land <- readr::read_csv(file.path('..', 'results', 'urban_land.csv'), show_col_types = F)

# List of countries available in urban land projections
lst_countries <- unique(tbl_urban_land$REGION)

# Only China, India, US for demo
lst_countries <- c('CHN', 'IND', 'USA')

# Loop through countries
for (iso in lst_countries) {
  # Print country name
  print(paste('Processing', iso))
  # Select and re-project country polygons
  country <- countries %>% 
    dplyr::filter(ADM0_A3==iso) %>%
    sf::st_transform(crs='+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs')
  if(nrow(country)>0) {
    # Create mask for the country
    mask_ctry <- country %>%
      fasterize::fasterize(smod_2015) %>%
      raster::crop(country)
    # Crop the global SMOD layer to the country
    smod_ctry_2015 <- smod_2015 %>%
      raster::crop(mask_ctry) %>%
      raster::mask(mask_ctry)
    # Mark urban center (30) and dense urban cluster (23) as urban lands
    urban_ctry_2015 <- (smod_ctry_2015>=23)
    # Interpolate suitability to the country
    suit_ctry <- suitability %>%
      raster::resample(urban_ctry_2015, method='bilinear') %>%
      # raster::mask(suitability) %>%
      raster::mask(mask_ctry)
    # Create directory for the country
    dir.create(file.path('..', 'results', iso))
    # Export urban land of the country in 2015
    raster::writeRaster(urban_ctry_2015, overwrite=T,
                        filename=file.path('..', 'results', iso, 'urban_2015.tif'))
    # Export urban suitability of the country
    raster::writeRaster(suit_ctry, overwrite=T,
                        filename=file.path('..', 'results', iso, 'suitability.tif'))
  }
}