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
  dplyr::select(ADM0_A3, ADMIN, UN_A3)

# Load urban land cover in 2015 from GHSL
smod_2015 <- raster(
  file.path('..', 'data', 
            'GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V2_0', 
            'GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V2_0.tif'))

# Load urban suitability (global coverage)
suitability <- raster(file.path('..', 'data', 'suitability', 'suitability_pca2_excluded.tif'))
suitability[is.na(suitability)] <- 0

# Load Urban Land (km2) projections
tbl_urban_land <- readr::read_csv(file.path('..', 'results', 'urban_land.csv'), show_col_types = F)

# List of countries available in urban land projections
lst_countries <- unique(tbl_urban_land$REGION)

# Select countries for demo
lst_countries <- c('CHN', 'IND', 'USA', 'FRA', 'RUS')
# Select countries for debug
lst_countries <- c('ARE', 'ISR', 'NGA', 'PSE', 'QAT', 'BGD', 'NZL')
# lst_countries <- c('SLB')

# Loop through countries
for (iso in lst_countries) {
  # Print country name
  print(paste('Processing', iso))
  
  # Select and re-project country polygons
  country <- countries %>% 
    dplyr::filter(ADM0_A3==iso) %>%
    sf::st_transform(
      crs='+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs')
  
  # Remove eastern pacific islands from Russia
  if(iso=='RUS') {
    rus_polygons <- country %>% 
      sf::st_cast('POLYGON') %>%
      sf::st_transform(crs = 'WGS84')
    usa_centroids <- sf::st_centroid(rus_polygons)
    rus_polygons$ct_long <- sf::st_coordinates(usa_centroids)[,1]
    country <- rus_polygons %>%
      dplyr::filter(ct_long > 0) %>%
      sf::st_transform(
        crs='+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs') %>%
      dplyr::group_by(ADM0_A3) %>%
      dplyr::summarise()
  }
  
  # Remove French Guiana from France
  if(iso=='FRA') {
    fra_polygons <- country %>% 
      sf::st_cast('POLYGON') %>%
      sf::st_transform(crs = 'WGS84')
    usa_centroids <- sf::st_centroid(fra_polygons)
    fra_polygons$ct_long <- sf::st_coordinates(usa_centroids)[,1]
    fra_polygons$ct_lat  <- sf::st_coordinates(usa_centroids)[,2]
    country <- fra_polygons %>%
      dplyr::filter(ct_long > 0 & ct_lat > 0) %>%
      sf::st_transform(
        crs='+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs') %>%
      dplyr::group_by(ADM0_A3) %>%
      dplyr::summarise()
  }
  
  # Remove eastern pacific parts from USA
  if(iso=='USA') {
    usa_polygons <- country %>% 
      sf::st_cast('POLYGON') %>%
      sf::st_transform(crs = 'WGS84')
    usa_centroids <- sf::st_centroid(usa_polygons)
    usa_polygons$ct_long <- sf::st_coordinates(usa_centroids)[,1]
    country <- usa_polygons %>%
      dplyr::filter(ct_long < 0) %>%
      sf::st_transform(
        crs='+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs') %>%
      dplyr::group_by(ADM0_A3) %>%
      dplyr::summarise()
  }
  
  # Remove islands in western hemisphere from New Zealand
  if(iso=='NZL') {
    nzl_polygons <- country %>% 
      sf::st_cast('POLYGON') %>%
      sf::st_transform(crs = 'WGS84')
    usa_centroids <- sf::st_centroid(nzl_polygons)
    nzl_polygons$ct_long <- sf::st_coordinates(usa_centroids)[,1]
    country <- nzl_polygons %>%
      dplyr::filter(ct_long > 0) %>%
      sf::st_transform(
        crs='+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs') %>%
      dplyr::group_by(ADM0_A3) %>%
      dplyr::summarise()
  }
  
  # Add Hong Kong, Macau, Taiwan to China
  if(iso=='CHN') {
    country <- countries %>% 
      dplyr::filter(ADM0_A3 %in% c('CHN','MAC','HKG','TWN')) %>%
      dplyr::summarise() %>%
      sf::st_transform(
        crs='+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs')
  }
  
  # Buffer Solomon Islands by 1km
  if(iso=='SLB') {
    country <- st_buffer(country, dist = 1000)
  }
  
  # Output folder
  path_ctry <- file.path('..', 'results', iso)
  
  if(nrow(country)>0 & !dir.exists(path_ctry)) {
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