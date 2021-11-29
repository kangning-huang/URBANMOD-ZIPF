# URBANMOD-ZIPF
This repository contains codes and sample data to run the urban land expansion model that preserves the zipf-law of urban cluster sizes--URBANMO-ZIPF. Detailed descriptions of this model can be found in Huang et al (2019).

## How to run URBANMOD-ZIPF
Open "main.m" in Matlab.

## Urban land areas
The areas of urban land (km^2) for each country under five Shared Socioeconomic Pathways (SSPs) are stored in "results/urban_land.csv". These areas are calculated based on the panel regression coefficients listed in the Supplementary Table 2 in Huang et al (2019). To perform the calculation, run "functions/urban_land_quantities.R" in R.

## Urban land covers in 2015
The urban land covers in 2015 are based on the Global Human Settlement Layer - Settlement Model (GHSL-SMOD; Florczyk et al 2019). Grid cells labeled as "urban center (30)" or "dense urban cluster (23)" are considered urban lands. Both of these two types of grid cells have >50% impervious surface and >1,500 people/km^2 population density. Run script "functions/urban_land_setup.R" in R to crop urban land covers in 2015 for each country. The cropped rasters are stored in "results/{country_ISO3_code}/urban_2015.tif".

## System requirements
- Matlab R2021b or above;
- RStudio v1.4.1717 or above;
- R v4.1.0 or above;

## References
1. Huang, Kangning, Xia Li, Xiaoping Liu, Karen C. Seto. "Projecting global urban land expansion and heat island intensification through 2050." Environmental Research Letters 14.11 (2019): 114037.
2. Seto, Karen C., Burak Güneralp, and Lucy R. Hutyra. "Global forecasts of urban expansion to 2030 and direct impacts on biodiversity and carbon pools." Proceedings of the National Academy of Sciences 109.40 (2012): 16083-16088.
3. Florczyk A.J., Corbane C., Ehrlich D., Freire S., Kemper T., Maffenini L., Melchiorri M., Pesaresi M., Politis P., Schiavina M., Sabo F., Zanchetta L., GHSL Data Package 2019, EUR 29788 EN, Publications Office of the European Union, Luxembourg, 2019, ISBN 978-92-76-13186-1, doi:10.2760/290498, JRC 117104.