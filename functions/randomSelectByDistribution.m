function idx = randomSelectByDistribution( suit_can, prob, ctrs, nremain )
%RANDOMSELECTBYDISTRIBUTION 
%   This function randomly selects pixels in array 'suit', according to
%   probability distribution 'prob'.
%   INPUT:
%       suit_can -- array of suitability;
%       prob     -- probability distribution;
%       ctrs     -- center points of suitability for each probability;
%       nremain  -- the number of pixels to select;
%   OUTPUT:
%       idx      -- indices of the selected pixels
    
    idx = [];

    % indices of all suitability pixels
    suit_idx = 1:length(suit_can);

    % number of bins
    nbins = length(prob);

    % numbers of pixels for each bin
    npxls = ceil(prob * nremain);

    % interval of distribution
    interv = (ctrs(2) - ctrs(1)) / 2;

    % loop through each bin
    for ii = 1:nbins
        if npxls(ii) > 0
            % lower boundary of this bin
            lb = ctrs(ii) - interv;
            % upper boundary of this bin
            ub = ctrs(ii) + interv;
            % indices for suit pixels that fall into this bin
            suit_idx_this = suit_idx( suit_can>=lb & suit_can<ub);
            % randomly choose from available indices
            if npxls(ii) <= length(suit_idx_this)
                idx = [idx, datasample(suit_idx_this, npxls(ii), 'Replace', false)];
            else
                idx = [idx, suit_idx_this];
            end
        end
    end
    
end