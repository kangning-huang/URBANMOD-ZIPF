% This script plots the rank-size distribution of forecast results

times = 100;

%% Read .csv file
filename   = '/urban_pixels.csv';
delimiter  = ',';
startRow   = 2;
formatSpec = '%s%f%f%f%f%f%[^\n\r]';
fileID     = fopen(filename,'r');
dataArray  = textscan(fileID, formatSpec, 'Delimiter', ...
    delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
region      = dataArray{:, 1};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% Gather resulting sizes of all forecasts
size_ssp1 = cell(times, 1);
size_ssp2 = cell(times, 1);
size_ssp3 = cell(times, 1);
size_ssp4 = cell(times, 1);
size_ssp5 = cell(times, 1);

for ii = 1:length(region)
    path = strcat(pwd, '\regions_SSP_prob\', region{ii});
    load(strcat(path, '\size-ssp1.mat'));    
    for tt = 1:times
        size_ssp1{tt} = [size_ssp1{tt}, sizes{tt}];
    end
    
    load(strcat(path, '\size-ssp2.mat'));
    for tt = 1:times
        size_ssp2{tt} = [size_ssp2{tt}, sizes{tt}];
    end
    
    load(strcat(path, '\size-ssp3.mat'));
    for tt = 1:times
        size_ssp3{tt} = [size_ssp3{tt}, sizes{tt}];
    end
    
    load(strcat(path, '\size-ssp4.mat'));
    for tt = 1:times
        size_ssp4{tt} = [size_ssp4{tt}, sizes{tt}];
    end
    
    load(strcat(path, '\size-ssp5.mat'));
    for tt = 1:times
        size_ssp5{tt} = [size_ssp5{tt}, sizes{tt}];
    end
end

%% Plot rank-size distribution
rank_ssp1 = cell(times, 1);
rank_ssp2 = cell(times, 1);
rank_ssp3 = cell(times, 1);
rank_ssp4 = cell(times, 1);
rank_ssp5 = cell(times, 1);

figure;
for tt = 1:times
    rank_ssp1{tt} = floor(tiedrank(-size_ssp1{tt}));    
%     loglog(rank_ssp1{tt}, size_ssp1{tt} * 25, 'k.'), hold on;
    scatter(rank_ssp1{tt}, size_ssp1{tt} * 25, 'k.', 'MarkerEdgeAlpha', .01), hold on;
end
set(gca, 'xscale', 'log');
set(gca, 'yscale', 'log');
xlabel('Rank',        'FontSize', 16);
ylabel('Area (km^2)', 'FontSize', 16);

% for tt = 1:times
%     rank_ssp2{tt} = floor(tiedrank(-size_ssp2{tt}));    
%     scatter(rank_ssp2{tt}, size_ssp2{tt} * 25, 'r.', 'MarkerEdgeAlpha', .01), hold on;
% end
% 
% for tt = 1:times
%     rank_ssp3{tt} = floor(tiedrank(-size_ssp3{tt}));    
%     scatter(rank_ssp3{tt}, size_ssp3{tt} * 25, 'b.', 'MarkerEdgeAlpha', .01), hold on;
% end
% 
% for tt = 1:times
%     rank_ssp4{tt} = floor(tiedrank(-size_ssp4{tt}));    
%     scatter(rank_ssp4{tt}, size_ssp4{tt} * 25, 'g.', 'MarkerEdgeAlpha', .01), hold on;
% end
% 
% for tt = 1:times
%     rank_ssp5{tt} = floor(tiedrank(-size_ssp5{tt}));    
%     scatter(rank_ssp5{tt}, size_ssp5{tt} * 25, 'm.', 'MarkerEdgeAlpha', .01), hold on;
% end

hold off;