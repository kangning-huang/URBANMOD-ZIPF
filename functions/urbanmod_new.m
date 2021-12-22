function [urban_end] = urbanmod_new(urban_start, suit, nyr, nurban, year_start, tt)
%URBANMOD_NEW 
%   Simulate urban expansion
%   INPUT:
%       urban_start -- Urban land use at the start of the simulation
%       suit        -- Suitability layer
%       nyr         -- Number of years during the simulation
%       nurban      -- Number of urban pixels at the end of the simulation
%       year_start  -- Starting year
%       tt          -- The ensemble number
%   OUTPUT: 
%       urban_end   -- Urban land use at the end of the simulation

    %% Testing debug
%     nurban = 428120;
%     nyr    = 35;
%     path   = fullfile(pwd, 'results', 'CHN');
%     [urban_start, header] = readgeoraster(fullfile(path, 'urban_2015.tif'));
%     [suit,        ~]      = readgeoraster(fullfile(path, 'suitability.tif'));
%     urban_start(urban_start<0) = 0;

    %% Model parameter
    winsize = 3;

    %% Initialize and create grid
    urban = urban_start;
    [nrow, ncol] = size(urban);
    [cols, rows] = meshgrid(1:ncol, 1:nrow);
    % number of new urban pixels per year
    nnew = ceil((nurban - sum(urban(:))) / nyr);
    % The first iteration
    urban_new = urban;

    %% Suitability distribution of urbanized pixels
    nbins = 20;
    [prob, ctrs] = suitability_distribution(urban, suit, nbins);

    %% Main loop
    for t = 1:nyr    
        
        % Print progress
        if ~exist('year_start', 'var')
            fprintf('Running the %dth year;\n', t);
        elseif ~exist('tt', 'var')
            fprintf('Running year %d;\n', year_start+t);
        else
            fprintf('Running %dth ensemble, year %d;\n', year_start+t, tt);
        end
        
        % pixels remain to urbanized
        nremain = nnew;
        
        %% keep urbanizing pixels until number is met
        while nremain > 0                

            % gather neighbor pixels as candidates
            neighbor     = logical(neighbor_pixels_gibrats(urban_new, winsize));
            neighbor_row = rows(neighbor);
            neighbor_col = cols(neighbor);

            % gather suitability of candidates
            suit_can = suit(neighbor);

            % indices of selected pixels
            idx_sel  = randomSelectByDistribution(suit_can, prob, ctrs, nremain);

            % locations of selected pixels
            idx_rows_sel = neighbor_row(idx_sel);
            idx_cols_sel = neighbor_col(idx_sel);

            % turn selected pixels into urban
            for ii = 1:length(idx_sel)
                urban_new(idx_rows_sel(ii), idx_cols_sel(ii)) = 1;
            end

            % reduce number of remaining pixels
            nremain = nremain - length(idx_sel);
        end
    end
    urban_end = urban_new;
end

