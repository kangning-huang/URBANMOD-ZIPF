clear; clc;

%% Parameters
winsize = 3;
times   = 100;

%% Read data
path   = strcat(cd, '\\regions_SSP_prob\\CHN\\');
[os ~] = computer;
if strcmp(os, 'MACI64')
    path = strrep(path, '\\', '//');
end
[urban, header] = importmap(strcat(path, 'urban.txt'));
urban(urban == -9999) = 0;
suit  = importmap(strcat(path, 'suitability.txt'));
suit( suit  == -9999) = nan;

%% Read control
[nyr, nurban] = importctrl(strcat(path, 'control.txt'));
% number of new urban pixels per year
nnew = ceil((nurban - sum(urban(:))) / nyr);

%% Create grid
[nrow, ncol] = size(urban);
[cols, rows] = meshgrid(1:ncol, 1:nrow);

%% Suitability distribution of urbanized pixels
nbins = 20;
[prob, ctrs] = suitability_distribution(urban, suit, nbins);

%% Main loop
urban_prob = zeros(nrow, ncol, times);    
parfor tt = 1:times
    disp(strcat('Running...', num2str(tt)));
    urban_new = urban;
    for t = 1:nyr    

        % pixels remain to urbanized
        nremain = nnew;

        %% keep urbanizing pixels until number is met
        while nremain > 0                

            % gather neighbor pixels as candidates
%             neighbor     = logical(neighbor_pixels(urban_new, winsize));
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
    urban_prob(:,:,tt) = urban_new;
end
urban_prob = mean(urban_prob, 3);
writemap(strcat(path, 'urban-ssp1.txt'), urban_prob, header);