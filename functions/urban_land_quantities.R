library(readr)
library(dplyr)
library(tidyr)
library(rstudioapi)

# Set working directory to path of the script
setwd(dirname(getSourceEditorContext()$path))

# Lookup table (LUT) of country names, ISO3 codes, and 32 regions
tbl_iso_reg32 <- readr::read_csv(file.path('..', 'data', 'ISO3_countryname_32regions.csv'), show_col_types = F)

# Coefficients of panel regression: Urban Land per capita (km2 / mil persons) ~ GDP per capita ($ / person)
tbl_coef <- readr::read_csv(file.path('..', 'data', 'ulc_vs_gdpc_32regions.csv'), show_col_types = F)

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
  dplyr::mutate(urb_pop = population * urban_share / 100)

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
  dplyr::mutate(GDPC = (GDP * 10^9) / (population * 10^6))

# Calculate Urban Land (km2)
