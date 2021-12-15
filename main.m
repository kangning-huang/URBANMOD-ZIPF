% Add necessary functions to paths
addpath("functions/");
addpath("utils/");

% Read urban land areas
ul_areas = readtable("results/urban_land.csv");

% Subset urban land areas in 2100 under SSP5
ul_areas_2100_ssp5 = ul_areas(strcmp(ul_areas.SCENARIO,'SSP5') & ul_areas.year==2100,:);

% Run URBANMOD in China, India, and United Stated
ul_areas_chn =  ul_areas_2100_ssp5(strcmp(ul_areas_2100_ssp5.REGION,'CHN'),:);
ul_areas_ind =  ul_areas_2100_ssp5(strcmp(ul_areas_2100_ssp5.REGION,'IND'),:);
ul_areas_usa =  ul_areas_2100_ssp5(strcmp(ul_areas_2100_ssp5.REGION,'USA'),:);