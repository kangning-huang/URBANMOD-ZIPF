function urbanmod( path, control )
%URBANMOD 
%   Simulates urban expansion
%   INPUT:
%       path   -- path to the folder
%       cotrol -- filename of the 'control.txt'

    %% Model parameter
    winsize = 3;
    
    %% Read data
    [os ~] = computer;
    if strcmp(os, 'MACI64')
        path = strrep(path, '\\', '//');
        path = strrep(path, '\', '/');
    end
    [urban, header] = importmap(strcat(path, 'urban.txt'));
    urban(urban == -9999) = 0;
    [suit,  header] = importmap(strcat(path, 'suitability.txt'));
    suit( suit  == -9999) = nan;
    [nyr, nurban]   = importctrl(strcat(path, control));
    % number of new urban pixels per year
    nnew = ceil((nurban - sum(urban(:))) / nyr);
    
    %% Create grid
    [nrow, ncol] = size(urban);
    [cols, rows] = meshgrid(1:ncol, 1:nrow);

    %% Suitability distribution of urbanized pixels
    nbins = 20;
    [prob, ctrs] = suitability_distribution(urban, suit, nbins);
    
    %% Main loop
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

    %% Output result
    urban_new(urban_new == 0) = header.nodat;
    writemap(strcat(path, 'urban-', control), urban_new, header);
end

