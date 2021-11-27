function [data, header] = importmap(filename)
%IMPORTFILE Import numeric data from a text file as a matrix.
%   SUITABILITY = IMPORTFILE(FILENAME) Reads data from text file FILENAME
%   for the default selection.
%
%   SUITABILITY = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from
%   rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   suitability = importfile('suitability.txt', 7, 783);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2016/07/11 16:04:01

filename = path_os(filename);

%% Open the text file.
fid = fopen(filename, 'r');

%% Read header
fscanf(fid, '%c', 14); ncols = fscanf(fid, '%d\n', 1);
fscanf(fid, '%c', 14); nrows = fscanf(fid, '%d\n', 1);
fscanf(fid, '%c', 14); xllcn = fscanf(fid, '%s', 1); 
fscanf(fid, '%c', 14); yllcn = fscanf(fid, '%s', 1);
fscanf(fid, '%c', 14); cells = fscanf(fid, '%d\n', 1);
fscanf(fid, '%c', 14); nodat = fscanf(fid, '%d\n', 1);
header = struct('ncols', ncols, 'nrows', nrows, ...
                'xllcn', xllcn, 'yllcn', yllcn, ...
                'cells', cells, 'nodat', nodat);

data = zeros(nrows, ncols);

for r = 1:nrows
    row = fscanf(fid, '%f', ncols);
    data(r, :) = row;
end

%% Close the text file.
fclose(fid);


