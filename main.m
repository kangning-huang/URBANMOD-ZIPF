% Add necessary functions to paths
addpath("functions/");
addpath("utils/");

% Read urban land areas
ul_areas = readtable("results/urban_land.csv");

% Subset urban land areas in 2050 under SSP5
ul_areas_2050_ssp5 = ul_areas(strcmp(ul_areas.SCENARIO,'SSP5') & ul_areas.year==2050,:);

% Number of runs in Monte Carlo simulation
ntimes = 100;

% Read model parameters
country  = 'CHN'; % Change here to run in another country/region
ul_areas = ul_areas_2050_ssp5(strcmp(ul_areas_2050_ssp5.REGION, country),:);
year     = ul_areas.year;
ssp      = ul_areas.SCENARIO;
ul_area  = ul_areas.urban_land;
