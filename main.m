% Add necessary functions to paths
addpath("functions/");
addpath("utils/");

% ntimes is the number of runs in Monte Carlo simulation, if ntimes is
% large, the simulations will be VERY SLOW on personal computers
ntimes = 10;

% Choose country and scenario to run
% To setup for other coutries/regions, run script "functions/urban_land_setup.R" in R.
urbanmod_prob_new('SLB', 'SSP5', ntimes);
urbanmod_prob_new('MWI', 'SSP5', ntimes);
urbanmod_prob_new('MDG', 'SSP5', ntimes);
