% Add necessary functions to paths
addpath("functions/");
addpath("utils/");

% Read urban land areas
ul_areas = readtable("results/urban_land.csv");

% Subset urban land areas in 2100 under SSP5
ul_areas_2100_ssp5 = ul_areas(strcmp(ul_areas.SCENARIO,'SSP5') & ul_areas.year==2100,:);

% Number of runs in Monte Carlo simulation
ntimes = 100;

% Run URBANMOD in China, India, and United Stated
countries = {'CHN', 'IND', 'USA'};
for i = 1:length(countries)
    ul_areas = ul_areas_2100_ssp5(strcmp(ul_areas_2100_ssp5.REGION,countries(i)),:);
    country  = ul_areas.REGION;
    year     = ul_areas.year;
    ssp      = ul_areas.SCENARIO;
    ul_area  = ul_areas.urban_land;
end
