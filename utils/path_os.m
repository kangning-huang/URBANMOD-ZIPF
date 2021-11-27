function [ o_path ] = path_os( i_path )
%PATH_OS Summary of this function goes here
%   Detailed explanation goes here
        
    if ~strcmp(computer, 'PCWIN64')
        o_path = strrep(i_path, '\', '/');
    else
        o_path = i_path;
    end
    
end