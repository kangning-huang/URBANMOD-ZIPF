clc; clear;

parpool;

%% Read .csv file
filename   = 'urban_pixels.csv';
delimiter  = ',';
startRow   = 2;
formatSpec = '%s%f%f%f%f%f%[^\n\r]';
fileID     = fopen(filename,'r');
dataArray  = textscan(fileID, formatSpec, 'Delimiter', ...
    delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
region      = dataArray{:, 1};
nurban_ssp1 = dataArray{:, 2};
nurban_ssp2 = dataArray{:, 3};
nurban_ssp3 = dataArray{:, 4};
nurban_ssp4 = dataArray{:, 5};
nurban_ssp5 = dataArray{:, 6};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% Write control files
for ii = 1:length(region)
    path = strcat(pwd, '\regions_SSP_tif\', region{ii});
    writectrl(strcat(path, '\ssp1.txt'), 35, nurban_ssp1(ii));
    writectrl(strcat(path, '\ssp2.txt'), 35, nurban_ssp2(ii));
    writectrl(strcat(path, '\ssp3.txt'), 35, nurban_ssp3(ii));
    writectrl(strcat(path, '\ssp4.txt'), 35, nurban_ssp4(ii));
    writectrl(strcat(path, '\ssp5.txt'), 35, nurban_ssp5(ii));
end

%% Run model in each region under each scenario
for ii = 1:length(region)
    path = strcat(pwd, '\regions_SSP_tif\', region{ii}, '\');
    disp(strcat('Running...', region{ii}));
    disp('scenario: SSP1...');
    urbanmod_prob_tif(path, 'ssp1.txt');
    disp('scenario: SSP2...');
    urbanmod_prob_tif(path, 'ssp2.txt');
    disp('scenario: SSP3...');
    urbanmod_prob_tif(path, 'ssp3.txt');
    disp('scenario: SSP4...');
    urbanmod_prob_tif(path, 'ssp4.txt');
    disp('scenario: SSP5...');
    urbanmod_prob_tif(path, 'ssp5.txt');
end