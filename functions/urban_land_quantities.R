library(readr)
library(dplyr)
library(tidyr)
library(rstudioapi)

# Set working directory to path of the script
setwd(dirname(getSourceEditorContext()$path))

# Lookup table (LUT) of country names, ISO3 codes, and 32 regions
tbl_iso_reg32 <- readr::read_csv(file.path('..', 'data', 'ISO3_countryname_32regions.csv'), show_col_types = F)

# Shared Socioeconomic Pathways (SSPs) forecasts of countries from IIASA
tbl_ssps <- readr::read_csv(file.path('..', 'data', 'SspDb_country_data_2013-06-12.csv'), show_col_types = F)

# Coefficients of panel regression: Urban Land per Capita (km2 / mil persons) ~ GDP per Capita ($ / person)
tbl_coef <- readr::read_csv(file.path('..', 'data', 'ulc_vs_gdpc_32regions.csv'), show_col_types = F)
