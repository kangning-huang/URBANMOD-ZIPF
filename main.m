% Add necessary functions to paths
addpath("functions/");
addpath("utils/");

% Read urban land areas
ul_areas = readtable("results/urban_land.csv");

% Number of runs in Monte Carlo simulation
% The program will be VERY SLOW if ntimes is large
ntimes = 10;

% Choose country and scenario to run
% This demo only provides setup data for China, India, and United States. 
% To setup for other coutries/regions, run script "functions/urban_land_setup.R" in R.
urbanmod_prob_new('CHN', 'SSP5', ntimes);
urbanmod_prob_new('IND', 'SSP5', ntimes);
urbanmod_prob_new('USA', 'SSP5', ntimes);