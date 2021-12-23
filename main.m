% Add necessary functions to paths
addpath("functions/");
addpath("utils/");

% ntimes is the number of runs in Monte Carlo simulation, if ntimes is
% large, the simulations will be VERY SLOW on personal computers
ntimes = 10;

% Choose country and scenario to run
% This demo only provides setup data for China, India, and United States. 
% To setup for other coutries/regions, run script "functions/urban_land_setup.R" in R.
urbanmod_prob_new('CHN', 'SSP5', ntimes);
urbanmod_prob_new('IND', 'SSP5', ntimes);
urbanmod_prob_new('USA', 'SSP5', ntimes);