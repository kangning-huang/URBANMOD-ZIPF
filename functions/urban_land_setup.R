library(sf)
library(dplyr)
library(raster)
library(spData)
library(rnaturalearth)

# Set working directory to path of the script
setwd(dirname(getSourceEditorContext()$path))

countries <- ne_download(scale = 10, returnclass = 'sf')

countries %>% filter(ADM0_A3=='USA') %>% st_geometry() %>% plot()
