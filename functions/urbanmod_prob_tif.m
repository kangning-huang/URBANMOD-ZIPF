function urbanmod_prob_tif( in_path, control )
%URBANMOD 
%   Simulates urban expansion
%   INPUT:
%       in_path -- path to the folder
%       cotrol  -- filename of the 'control.txt'

    %% Model parameter
    winsize = 3;
    times   = 100;
    
    %% Read data
    [os ~] = computer;
    in_path = path_os(in_path);
	filename_urban = strcat(in_path, 'urban.tif');
    [urban, header] = geotiffread(filename_urban);
    info = geotiffinfo(filename_urban);
    info.GeoTIFFTags.GeoKeyDirectoryTag.GTModelTypeGeoKey     = 1;
    info.GeoTIFFTags.GeoKeyDirectoryTag.GTRasterTypeGeoKey    = 1;
    info.GeoTIFFTags.GeoKeyDirectoryTag.ProjectedCSTypeGeoKey = 32767;
    urban = double(urban);
    urban(urban == 0) = 0;
%     [suit,  header] = importmap(strcat(in_path, 'suitability.txt'));
    [suit, ~] = geotiffread(strcat(in_path, 'suitability.tif'));
    suit( suit  == -realmax('single')) = nan;
    [nyr, nurban]   = importctrl(strcat(in_path, control));
    % number of new urban pixels per year
    nnew = ceil((nurban - sum(urban(:))) / nyr);
    
    %% Create grid
    [nrow, ncol] = size(urban);
    [cols, rows] = meshgrid(1:ncol, 1:nrow);

    %% Suitability distribution of urbanized pixels
    nbins = 20;
    [prob, ctrs] = suitability_distribution(urban, suit, nbins);
    
    %% Main loop
    sizes = cell(times, 1);
    urban_prob = zeros(nrow, ncol, times);    
    for tt = 1:times
%     parfor tt = 1:times    
        disp(strcat(num2str(tt, '%d'), 'th time;'));
        urban_new = urban;
        for t = 1:nyr    
            % debug print
            fprintf(1, '%2dth year, ', t); if(mod(t,5)==0), fprintf(1, '\n'); end
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
        path_eachtime = strcat(in_path, 'urban-', control(1:4), '\');
        path_eachtime = path_os(path_eachtime);
        geotiffwrite(strcat(path_eachtime, num2str(tt, '%04d'), '.tif'), ...
            logical(urban_new), header, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
        urban_prob(:,:,tt) = urban_new;
        sizes{tt} = urban_size(urban_new, winsize);
    end
    
    % calculate probability   
    urban_new = mean(urban_prob, 3);
%     urban_new(urban_new == 0) = header.nodat;
        
    %% Output result
%     urban_prob_file = strcat(in_path, 'urban-', control(1:4), '.mat');
%     save(urban_prob_file, 'urban_prob', '-v7.3');
    urban_size_file = strcat(in_path, 'size-',  control(1:4), '.mat');
    save(urban_size_file, 'sizes',      '-v7.3');
%     writemap(strcat(in_path, 'urban-', control), urban_new, header);
    geotiffwrite(strcat(in_path, 'urban-', control(1:4), '.tif'), urban_new, header, ...
        'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
end

