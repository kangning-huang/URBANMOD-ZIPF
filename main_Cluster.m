% Change current directory
cd '/scratch/kh3657/URBANMOD-ZIPF';

% Add necessary functions to paths
addpath("functions/");
addpath("utils/");

% ntimes is the number of runs in Monte Carlo simulation, if ntimes is
% large, the simulations will be VERY SLOW on personal computers
ntimes = 100;

% Activate parallel computing
c = parcluster;
c.AdditionalProperties.WallTime = '05:00:00';
c.AdditionalProperties.ProcsPerNode = 12;

% Loop through all scenarios and countries
urban_land = readtable("results/urban_land.csv");
countries  = unique(urban_land.REGION);
scenarios  = unique(urban_land.SCENARIO);
for i = 1:size(countries,1)
    country  = countries{i};
    for j = 1:size(scenarios,1)
        scenario = scenarios{j};
        % Check if the scenario is run
        if isfile(fullfile("results/",country,strcat(scenario,'_2100.tif')))
            continue;
        end
        % Submit batch job
        disp(strcat("Submitting job: ", country, " ", scenario));
        c.batch(@urbanmod_prob_new,0,{country,scenario,ntimes}, ...
            'Pool',11,'CurrentFolder','/scratch/kh3657/URBANMOD-ZIPF/');    
    end
end