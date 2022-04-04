library(sf)
library(readr)
library(dplyr)
library(tidyr)
library(tibble)
library(readxl)
library(stringr)
library(rstudioapi)

# Set working directory to path of the script
setwd(dirname(getSourceEditorContext()$path))

# Download urban population statistics from UN
download.file('https://population.un.org/wup/Download/Files/WUP2018-F03-Urban_Population.xls',
              destfile = file.path('..', 'data', 'WUP2018-F03-Urban_Population.xls'))

countries <- ne_download(scale = 10, returnclass = 'sf') %>%
  dplyr::select(REGION = ADM0_A3, ADMIN, UN_A3) %>%
  sf::st_set_geometry(NULL)

tbl_pop_urb_2015 <- readxl::read_xls(
  file.path('..', 'data', 'WUP2018-F03-Urban_Population.xls'), skip = 16) %>% 
  dplyr::select(`Country\ncode`, urban_pop_2015 = `2015`) %>%
  dplyr::mutate(UN_A3 = stringr::str_pad(`Country\ncode`, 3, pad = '0')) %>%
  # Convert urban population from thousands to millions
  dplyr::mutate(urban_pop_2015 = urban_pop_2015 / 1000) %>%
  merge(countries, by = 'UN_A3')

# Lookup table (LUT) of country names, ISO3 codes, and 32 regions
tbl_iso_reg32 <- readr::read_csv(
  file.path('..', 'data', 'ISO3_countryname_32regions.csv'), show_col_types = F)

# Coefficients of panel regression: 
# Urban Land per capita (km2 / mil persons) ~ GDP per capita ($ / person)
tbl_coef <- readr::read_csv(
  file.path('..', 'data', 'ulc_vs_gdpc_32regions.csv'), show_col_types = F) %>%
  tibble::column_to_rownames('Coefficients')

coef_intercept <- tbl_coef['Intercept', 'Estimate']
coef_gdpc      <- tbl_coef['GDPC',      'Estimate']

# Shared Socioeconomic Pathways (SSPs) forecasts of countries from IIASA
tbl_ssps <- readr::read_csv(
  file.path('..', 'data', 'SspDb_country_data_2013-06-12.csv'), show_col_types = F)

# Filter population (million)
tbl_pop <- tbl_ssps %>% 
  dplyr::filter(VARIABLE=='Population' & MODEL=='OECD Env-Growth') %>%
  dplyr::mutate(SCENARIO = stringr::str_sub(SCENARIO, 1, 4)) %>%
  dplyr::select(-MODEL, -VARIABLE, -UNIT) %>% 
  tidyr::pivot_longer(cols = `1950`:`2150`, names_to = 'year', values_to = 'population') %>%
  dplyr::mutate(year = as.integer(year)) %>%
  dplyr::filter(year>=2010 & year<=2100)

# Calculate urban population (million)
tbl_pop_urb <- tbl_ssps %>%
  dplyr::filter(VARIABLE=='Population|Urban|Share') %>%
  dplyr::mutate(SCENARIO = stringr::str_sub(SCENARIO, 1, 4)) %>%
  dplyr::select(-MODEL, -VARIABLE, -UNIT) %>% 
  tidyr::pivot_longer(cols = `1950`:`2150`, names_to = 'year', values_to = 'urban_share') %>%
  dplyr::mutate(year = as.integer(year)) %>%
  dplyr::filter(year>=2015 & year<=2100 & year%%10==0) %>%
  merge(tbl_pop, by=c('SCENARIO', 'REGION', 'year')) %>%
  dplyr::mutate(urban_pop = population * urban_share / 100) %>%
  dplyr::select(-population)

# Filter GDP (billion US$)
tbl_gdp <- tbl_ssps %>%
  dplyr::filter(VARIABLE=='GDP|PPP' & MODEL=='OECD Env-Growth') %>%
  dplyr::mutate(SCENARIO = stringr::str_sub(SCENARIO, 1, 4)) %>%
  dplyr::select(-MODEL, -VARIABLE, -UNIT) %>% 
  tidyr::pivot_longer(cols = `1950`:`2150`, names_to = 'year', values_to = 'GDP') %>%
  dplyr::mutate(year = as.integer(year)) %>%
  dplyr::filter(year>=2015 & year<=2100)

# Calculate GDP per capita ($ / person)
tbl_gdpc <- merge(tbl_gdp, tbl_pop, by = c('SCENARIO', 'REGION', 'year')) %>%
  dplyr::mutate(GDPC = (GDP * 10^9) / (population * 10^6)) %>%
  dplyr::select(-GDP, -population)

tbl_gdpc_2015 <- tbl_gdpc %>%
  dplyr::filter(SCENARIO=='SSP3' & year=='2015') %>%
  dplyr::select(REGION, GDPC_2015 = GDPC)

# Load urban population density in 2015 in (persons/km2)
tbl_urb_pop_dens_2015 <- readr::read_csv(
  file.path('..', 'results', 'urban_pop_dens.csv')) %>%
  tidyr::drop_na()

tbl_urban_land_2015 <- tbl_urb_pop_dens_2015 %>%
  dplyr::select(REGION, urb_land_2015 = urb_land)

# Convert urban population density (persons/km2) to urban land / cap (km2/mil)
tbl_ulc_2015 <- tbl_urb_pop_dens_2015 %>%
  dplyr::mutate(ULC_2015 = 10^6/urb_pop_dens,
                urban_land_2015 = urb_land) %>%
  dplyr::select(REGION, ends_with('_2015')) %>%
  tidyr::drop_na()

# Calculate Urban Land (km2) resulting from increases in GDPC and Urban Pop
tbl_urban_pop_incrs <- merge(tbl_pop_urb_2015, tbl_pop_urb, by = 'REGION') %>% 
  dplyr::mutate(urban_pop_incrs = urban_pop - urban_pop_2015) %>%
  dplyr::select(-UN_A3, -ADMIN)

tbl_ULC_incrs <- merge(tbl_gdpc_2015, tbl_gdpc, by = 'REGION') %>%
  dplyr::mutate(GDPC_incrs = GDPC - GDPC_2015) %>%
  dplyr::mutate(ULC_incrs = GDPC_incrs * coef_gdpc)

tbl_ULC_incrs %>% head()
tbl_urban_pop_incrs %>% head()

tbl_urban_land <- tbl_urban_land_2015 %>% 
  merge(tbl_ulc_2015, by = 'REGION') %>%
  merge(tbl_urban_pop_incrs, by = 'REGION') %>% 
  merge(tbl_ULC_incrs, by = c('REGION','SCENARIO','year')) %>% 
  dplyr::mutate(
    urban_land_incrs = (ULC_2015+ULC_incrs) * (urban_pop_2015+urban_pop_incrs)) %>%
  dplyr::mutate(urban_land = urb_land_2015 + urban_land_incrs)

# Calculate Urban Land (km2)
# tbl_urban_land <- tbl_gdpc %>% 
#   merge(tbl_iso_reg32, by.x='REGION', by.y='ISO') %>%
#   merge(tbl_coef %>% rownames_to_column('Region32'), 
#         by='Region32', all.y = T) %>%
#   dplyr::mutate(ULC = GDPC * coef_gdpc + Estimate + coef_intercept) %>%
#   merge(tbl_pop_urb, by = c('SCENARIO', 'REGION', 'year')) %>%
#   dplyr::mutate(urban_land = as.integer(ULC * urban_pop)) %>%
#   dplyr::select(-Estimate, -urban_share)

# Output Urban Land (km2)
tbl_urban_land %>%
  readr::write_csv(file.path('..', 'results', 'urban_land.csv'))
