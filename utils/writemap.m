function writemap( filename, data, header )
%WRITEMAP Summary of this function goes here
%   Detailed explanation goes here

    filename = path_os(filename);

    fid = fopen(filename, 'w');
    
    %% Write header
    fprintf(fid, '%14s%d\n',   'ncols         ', header.ncols);
    fprintf(fid, '%14s%d\n',   'nrows         ', header.nrows);

    fprintf(fid, '%14s%s\n', 'xllcorner     ', header.xllcn);
    fprintf(fid, '%14s%s\n', 'yllcorner     ', header.yllcn);

    fprintf(fid, '%14s%d\n',   'cellsize      ', header.cells);
    fprintf(fid, '%14s%d\n',   'NODATA_value  ', header.nodat);
    
    for r = 1:header.nrows
        format = strcat(repmat('%f ', 1, header.ncols), '\n');
        fprintf(fid, format, data(r,:));
    end
    
    fclose(fid);
end

