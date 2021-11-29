library(readr)
library(dplyr)
library(tidyr)
library(tibble)
library(rstudioapi)

# Set working directory to path of the script
setwd(dirname(getSourceEditorContext()$path))

# Lookup table (LUT) of country names, ISO3 codes, and 32 regions
tbl_iso_reg32 <- readr::read_csv(file.path('..', 'data', 'ISO3_countryname_32regions.csv'), show_col_types = F)

# Coefficients of panel regression: Urban Land per capita (km2 / mil persons) ~ GDP per capita ($ / person)
tbl_coef <- readr::read_csv(file.path('..', 'data', 'ulc_vs_gdpc_32regions.csv'), show_col_types = F) %>%
  tibble::column_to_rownames('Coefficients')

coef_intercept <- tbl_coef['Intercept', 'Estimate']
coef_gdpc      <- tbl_coef['GDPC',      'Estimate']

# Shared Socioeconomic Pathways (SSPs) forecasts of countries from IIASA
tbl_ssps <- readr::read_csv(file.path('..', 'data', 'SspDb_country_data_2013-06-12.csv'), show_col_types = F)

# Filter population (million)
tbl_pop <- tbl_ssps %>% 
  dplyr::filter(VARIABLE=='Population' & MODEL=='OECD Env-Growth') %>%
  dplyr::mutate(SCENARIO = stringr::str_sub(SCENARIO, 1, 4)) %>%
  dplyr::select(-MODEL, -VARIABLE, -UNIT) %>% 
  tidyr::pivot_longer(cols = `1950`:`2150`, names_to = 'year', values_to = 'population') %>%
  dplyr::mutate(year = as.integer(year)) %>%
  dplyr::filter(year>=2030 & year<=2100 & year%%10==0)

# Calculate urban population (million)
tbl_pop_urb <- tbl_ssps %>%
  dplyr::filter(VARIABLE=='Population|Urban|Share') %>%
  dplyr::mutate(SCENARIO = stringr::str_sub(SCENARIO, 1, 4)) %>%
  dplyr::select(-MODEL, -VARIABLE, -UNIT) %>% 
  tidyr::pivot_longer(cols = `1950`:`2150`, names_to = 'year', values_to = 'urban_share') %>%
  dplyr::mutate(year = as.integer(year)) %>%
  dplyr::filter(year>=2030 & year<=2100 & year%%10==0) %>%
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
  dplyr::filter(year>=2030 & year<=2100 & year%%10==0)

# Calculate GDP per capita ($ / person)
tbl_gdpc <- merge(tbl_gdp, tbl_pop, by = c('SCENARIO', 'REGION', 'year')) %>%
  dplyr::mutate(GDPC = (GDP * 10^9) / (population * 10^6)) %>%
  dplyr::select(-GDP, -population)

# Calculate Urban Land (km2)
tbl_urban_land <- tbl_gdpc %>% 
  merge(tbl_iso_reg32, by.x='REGION', by.y='ISO') %>%
  merge(tbl_coef %>% rownames_to_column('REGION'), by='REGION') %>%
  dplyr::mutate(ULC = GDPC * coef_gdpc + Estimate + coef_intercept) %>%
  merge(tbl_pop_urb, by = c('SCENARIO', 'REGION', 'year')) %>%
  dplyr::mutate(urban_land = as.integer(ULC * urban_pop)) %>%
  dplyr::select(-Estimate, -urban_share)

# Output Urban Land (km2)
tbl_urban_land %>%
  readr::write_csv(file.path('..', 'results', 'urban_land.csv'))