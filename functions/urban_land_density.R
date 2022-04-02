# This script calculates the average population density in urban areas for each country.

library(sf)
library(rgdal)
library(dplyr)
library(raster)
library(rnaturalearth)

# Set working directory to path of the script
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Download GHS-POP layer
download.file('https://cidportal.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_MT_GLOBE_R2019A/GHS_POP_E2015_GLOBE_R2019A_54009_1K/V1-0/GHS_POP_E2015_GLOBE_R2019A_54009_1K_V1_0.zip',
              destfile = file.path('..', 'data', 'GHS_POP_E2015_GLOBE_R2019A_54009_1K_V1_0.zip'))

dir.create(file.path('..', 'data', 'GHS_POP_E2015_GLOBE_R2019A_54009_1K_V1_0'))

unzip(file.path('..', 'data', 'GHS_POP_E2015_GLOBE_R2019A_54009_1K_V1_0.zip'),
      exdir = file.path('..', 'data', 'GHS_POP_E2015_GLOBE_R2019A_54009_1K_V1_0'))

# Download country boundaries from Natural Earth
countries <- ne_download(scale = 10, returnclass = 'sf') %>%
  dplyr::select(ADM0_A3, ADMIN)

# Create the data frame for urban pop density
lst_countries <- countries$ADM0_A3
tbl_urb_pop_dens <- data.frame(
  REGION = lst_countries,
  urb_pop_dens = NA,
  urb_land = NA
)
row.names(tbl_urb_pop_dens) <- tbl_urb_pop_dens$REGION

# Load urban land cover in 2015 from GHSL
smod_2015 <- raster(
  file.path('..', 'data', 
            'GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V2_0', 
            'GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V2_0.tif'))

# Load population in 2015 from GHSL
pop_2015 <- raster(
  file.path('..', 'data',
            'GHS_POP_E2015_GLOBE_R2019A_54009_1K_V1_0',
            'GHS_POP_E2015_GLOBE_R2019A_54009_1K_V1_0.tif'))


# Loop through countries
for (iso in lst_countries) {
  # Print country name
  print(paste('Processing', iso))
  
  # Select and re-project country polygons
  country <- countries %>% 
    dplyr::filter(ADM0_A3==iso) %>%
    sf::st_transform(
      crs='+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs')
  
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
  
  # Sum up urban land in 2015 in (km2)
  tbl_urb_pop_dens[iso, 'urb_land'] <- 
    sum(raster::values(urban_ctry_2015), na.rm = T)
  
  # Crop the global population layer to the country
  pop_ctry_2015 <- pop_2015 %>%
    raster::crop(mask_ctry) %>%
    raster::mask(mask_ctry)
  # Mask population by urban land cover
  urban_pop_ctry_2015 <- pop_2015 * urban_ctry_2015
  urban_pop_ctry_2015[urban_pop_ctry_2015==0] <- NA
  
  # Calculate urban population density in (persons/km2)
  tbl_urb_pop_dens[iso, 'urb_pop_dens'] <- 
    mean(raster::values(urban_pop_ctry_2015), na.rm = T)
}

# Output Urban Land (km2)
tbl_urb_pop_dens %>%
  readr::write_csv(file.path('..', 'results', 'urban_pop_dens.csv'))

# Delete POP layers
unlink(file.path('..', 'data', 'GHS_POP_E2015_GLOBE_R2019A_54009_1K_V1_0.zip'))
unlink(file.path('..', 'data', 'GHS_POP_E2015_GLOBE_R2019A_54009_1K_V1_0'), recursive = T)
