function urbanmod_prof_new(filepath, year_start, year_end, scenario, nurban, ntimes)
%URBANMOD 
%   Simulates urban expansion
%   INPUT:
%       filepath   -- Path to the region folder
%       year_start -- Starting year of the simulation
%       year_end   -- Ending year of the simulation
%       scenario   -- The scenario of the simulation
%       nurban     -- Total number of urban pixels at the end of simulation
%       ntimes     -- Number of runs in Monte Carlo simulation
%   OUTPUT:
%       Ensemble    -- filepath/{scenario}/{yr1}/*.tif
%       Probability -- filepath/{scenario}_{yr1}.tif

    %% Testing codes
    filepath   = fullfile(pwd, 'results', 'CHN');
    year_start = 2015;
    year_end   = 2100;
    scenario   = 'SSP5';
    nurban     = 445968;
    ntimes     = 100;

    %% Model parameter
    winsize = 3;

    %% Read data
	filename_urban = fullfile(filepath, strcat('urban', '_', num2str(year_start), '.tif'));
    [urban, header] = readgeoraster(filename_urban);
    info = geotiffinfo(filename_urban);
    info.GeoTIFFTags.GeoKeyDirectoryTag.GTModelTypeGeoKey     = 1;
    info.GeoTIFFTags.GeoKeyDirectoryTag.GTRasterTypeGeoKey    = 1;
    info.GeoTIFFTags.GeoKeyDirectoryTag.ProjectedCSTypeGeoKey = 32767;
    urban = double(urban);
    urban(urban == 0) = 0;
    [suit, ~] = readgeoraster(strcat(filepath, 'suitability.tif'));
    suit( suit  == -realmax('single')) = nan;
    [nyr, nurban]   = importctrl(strcat(filepath, control));
    % number of new urban pixels per year
    nnew = ceil((nurban - sum(urban(:))) / nyr);
end

