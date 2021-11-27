function neighbors = neighbor_pixels( urban, winsize )
%NEIGHBOR_PIXELS Obtain neighbor pixels of existing urban lands
%   INPUT
%       urban     -- matrix of urban pixels
%       winsize   -- size of the smooth window
%   OUTPUT
%       neighbors -- matrix of neighbors of input urban pixels, excluding
%                    the existing urban pixels     

    % find neighbors through 3x3 window    
    kernel    = ones(winsize, winsize);    
    
    %% order-statistics filter
    neighbors = ordfilt2(urban, 9, kernel);

    %% convolution fileter
%     neighbors = conv2(urban, kernel);    
%     [nrow, ncol] = size(urban);
%     neighbors = neighbors(2:nrow+1, 2:ncol+1);
        
    
    neighbors(urban == 1)    = 0;
    neighbors(neighbors > 1) = 1;

end

