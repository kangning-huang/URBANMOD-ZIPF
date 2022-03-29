% Add necessary functions to paths
addpath("functions/");
addpath("utils/");

% ntimes is the number of runs in Monte Carlo simulation, if ntimes is
% large, the simulations will be VERY SLOW on personal computers
ntimes = 4;

% Activate parallel computing
ncores = 4; % number of cores
parpool(ncores); % activate the cores

% Loop through all scenarios and countries
urban_land = readtable("results/urban_land.csv");
countries  = unique(urban_land.REGION);
scenarios  = unique(urban_land.SCENARIO);
for i = 1:size(countries,1)
    country  = countries{i};
    for j = 1:size(scenarios,1)
        scenario = scenarios{j};
        urbanmod_prob_new(country, scenario, ntimes);
    end
end
