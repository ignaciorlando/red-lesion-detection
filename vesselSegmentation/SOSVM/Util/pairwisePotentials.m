
function [phi_p] = pairwisePotentials(config, x, y)
    
    % Get the mask
    mask = x{2};

    % Get the pairwise features
    pairwiseFeatures = x{4};
    
    % Get the pairwises using the MEX implementation
    phi_p = - pairwisePart(int32(size(mask, 2)), int32(size(mask, 1)), ... 
        int16(y), (single(pairwiseFeatures)), int32(size(pairwiseFeatures, 3)), ...
        single(config.theta_p.finalValues));
    
    if (~isempty(phi_p))
        phi_p = permute(phi_p,[2 1 3]);
    end
    
end