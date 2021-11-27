function writectrl( filename, nyear, nurban )
%WRITECTRL 
%   Writes control file

    filename = path_os(filename);

    fid = fopen(filename, 'w');
    fprintf(fid, '%s\t%s\n', 'nyear', 'nurban');
    fprintf(fid, '%d\t%d\n',  nyear,   nurban);
    fclose(fid);

end

