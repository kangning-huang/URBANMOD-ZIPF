clc; clear;

%% Read .csv file
filename   = '/urban_pixels.csv';
delimiter  = ',';
startRow   = 2;
formatSpec = '%s%f%f%f%[^\n\r]';
fileID     = fopen(filename,'r');
dataArray  = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
region      = dataArray{:, 1};
nurban_ssp1 = dataArray{:, 2};
nurban_ssp2 = dataArray{:, 3};
nurban_ssp3 = dataArray{:, 4};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% Write control files
for ii = 1:length(region)
    path = strcat(pwd, '\regions_SSP\', region{ii});
    writectrl(strcat(path, '\ssp1.txt'), 50, nurban_ssp1(ii));
    writectrl(strcat(path, '\ssp2.txt'), 50, nurban_ssp2(ii));
    writectrl(strcat(path, '\ssp3.txt'), 50, nurban_ssp3(ii));
end

%% Run model in each region under each scenario
parfor ii = 1:length(region)
    path = strcat(pwd, '\regions_SSP\', region{ii}, '\\');
    disp(strcat('Running...', region{ii}, ', scenario: SSP1...'));    
    urbanmod(path, 'ssp1.txt');
    disp(strcat('Running...', region{ii}, ', scenario: SSP2...'));
    urbanmod(path, 'ssp2.txt');
    disp(strcat('Running...', region{ii}, ', scenario: SSP3...'));
    urbanmod(path, 'ssp3.txt');
end