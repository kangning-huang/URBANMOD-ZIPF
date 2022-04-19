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
    
    suit_max = max(suit(:));
    suit_all_step = suit_max/(nbins-1);
    suit_all = 0:suit_all_step:suit_max;

    [prob, xctr] = hist([suit_urban;suit_all'], nbins);
    prob = prob ./ (sum(prob));

end