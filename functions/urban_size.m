function [ sizes ] = urban_size( urban, winsize )
%URBAN_SIZE Summary of this function goes here
%   Detailed explanation goes here

    kernel = ones(winsize, winsize);  
%     kernel = [0 1 0; 1 1 1; 0 1 0];

    % connceted component
    cc = bwconncomp(urban, kernel);
    sizes = cellfun(@numel, cc.PixelIdxList);
    

end