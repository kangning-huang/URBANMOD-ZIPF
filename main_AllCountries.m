% Add necessary functions to paths
addpath("functions/");
addpath("utils/");

% ntimes is the number of runs in Monte Carlo simulation, if ntimes is
% large, the simulations will be VERY SLOW on personal computers
ntimes = 10;

% Loop through all scenarios and countries
urban_land = readtable("results/urban_land.csv");
for i = 1:size(urban_land,1)
    country  = urban_land{i,'REGION'}{1};
    scenario = urban_land{i,'SCENARIO'}{1};
    urbanmod_prob_new(country, scenario, ntimes);
end

