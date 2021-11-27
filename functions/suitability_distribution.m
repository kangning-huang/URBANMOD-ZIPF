function [prob, xctr] = suitability_distribution( urban, suit, nbins )
%SUITABILITY_DISTRIBUTION Generate suitability distribution of urban lands
%   INPUT
%       urban -- matrix of urban pixels;
%       suit  -- matrix of suitability pixels;
%       nbins -- number of bins;
%   OUTPUT
%       prob  -- probability distribution;

    % read pixels of suitability >= 0
    urban      = logical(urban);
    suit_urban = suit(urban);
    suit_urban = suit_urban(suit_urban >= 0);
        
    [prob, xctr] = hist(suit_urban, nbins);
    prob = prob ./ (sum(prob));    

end