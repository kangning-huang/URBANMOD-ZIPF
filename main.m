% Add necessary functions to paths
addpath("functions/");
addpath("utils/");

% Read urban land areas
ul_areas = readtable("results/urban_land.csv");

% Number of runs in Monte Carlo simulation
ntimes = 100;

% Read model parameters
% Change here to run in another country/region, scenario, year
country  = 'CHN'; 
scenario = 'SSP5';
year     = 2050;
% Subset urban land areas
ul_areas_sub = ul_areas(strcmp(ul_areas.SCENARIO,scenario) & ul_areas.year==year,:);
ul_areas = ul_areas_sub(strcmp(ul_areas_sub.REGION, country),:);
year     = ul_areas.year;
ssp      = ul_areas.SCENARIO;
ul_area  = ul_areas.urban_land;

path = fullfile('results/', country);
urbanmod_prof_new(path, year_start, year_end, scenario, nurban, nntimes)