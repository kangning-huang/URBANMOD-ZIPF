library(sf)
library(dplyr)
library(raster)
library(spData)
library(rnaturalearth)

# Set working directory to path of the script
setwd(dirname(getSourceEditorContext()$path))

# Download country boundaries
countries <- ne_download(scale = 10, returnclass = 'sf')

# Load urban land cover in 2015 from GHSL
smod_2015 <- raster(file.path('..', 'data', 'GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V2_0', 'GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V2_0.tif'))

# Load Urban Land (km2) projections
tbl_urban_land <- readr::read_csv(file.path('..', 'results', 'urban_land.csv'), show_col_types = F)

# List of countries available in urban land projections
lst_countries <- unique(tbl_urban_land$REGION)

# Mark urban center (30) and dense urban cluster (23) as urban lands
urban_2015 <- (smod_2015>=23)
