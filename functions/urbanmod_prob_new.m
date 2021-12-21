function urbanmod_prob_new(region, scenario, ntimes)
%URBANMOD 
%   Simulates urban expansion
%   INPUT:
%       region     -- Ending year of the simulation
%       scenario   -- The scenario of the simulation
%       nurban     -- Total number of urban pixels at the end of simulation
%       nntimes    -- Number of runs in Monte Carlo simulation
%   OUTPUT: every 10 years
%       Ensemble    -- results/{region}/{scenario}/{yr1}/*.tif
%       Probability -- results/{region}/{scenario}_{yr1}.tif 

    %% Testing
    region   = 'CHN';
    scenario = 'SSP5';
    ntimes   = 5;
    
    % Test parallel computing
    parpool('local', ntimes);

    %% Read data
    path = fullfile('results', region);
    % Read urban land areas
    ul_areas = readtable("results/urban_land.csv");
    ul_area_sub = ul_areas(...
        strcmp(ul_areas.REGION, region) & ...
        strcmp(ul_areas.SCENARIO,scenario),:);
    % Initial urban land cover
    [urban, header] = readgeoraster(fullfile(path, 'urban_2015.tif'));
    info = geotiffinfo(path);
    info.GeoTIFFTags.GeoKeyDirectoryTag.GTModelTypeGeoKey     = 1;
    info.GeoTIFFTags.GeoKeyDirectoryTag.GTRasterTypeGeoKey    = 1;
    info.GeoTIFFTags.GeoKeyDirectoryTag.ProjectedCSTypeGeoKey = 32767;
    urban(urban < 0) = 0;
    % Suitability for urban expansion
    [suit, ~] = readgeoraster(fullfile(path, 'suitability.tif'));
    suit(suit < 0) = nan;
    
    %% Main loop
    urban_start = urban;
    year_start  = 2015;
    % Loop through years
    for i = 1:length(ul_area_sub.year)
        % Read year and urban land area
        year_end = ul_area_sub.year(i);
        nyr = year_end - year_start;
        % Output filepath for ensemble
        path_out = fullfile('results', region, scenario, year_end);
        mkdir(path_out);
        % Output filename for ensemble mean
        file_out = fullfile('results', region, strcat(scenario,'_',year_end,'.tif'));
        % Ensemble mean
        urban_prob = zeros(nrow, ncol, times);
        % Parallel loop through n times of simulations
        parfor tt = 1:ntimes
            urban_end = urbanmod_new(urban_start, suit, )
            urban_prob(:,:,tt) = urban_end;
        end
        
    end
end

