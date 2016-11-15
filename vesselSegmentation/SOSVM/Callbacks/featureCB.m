
function [phi] = featureCB(config, x, y)
% featureCB  Compute the feature map. 
% [phi] = featureCB(config, x, y)
% OUTPUT: phi: feature map
% INPUT: config: configuration structure
%        x: cell-array with the training data
%        y: cell-array with a labeling.

    % Put both the unary and the pairwise features into a matrix
    phi_u = getfeatures(x, y);
    
    % Generate a matrix with the labels in the FOV positions.
    mask = x{2};
    y_copy = double(mask);
    y_copy(logical(mask)) = y;
    
    % Get the pairwise energy according to the corresponding CRF
    if strcmp(config.crfVersion,'local-neighborhood-based')
        % Local neighborhoood based
        pairwiseEnergy = getLocalNeighborhoodBasedPairwisePotentials(x{4}, y_copy);
    else    
        % Fully-connected
        pairwiseEnergy = pairwisePotentials(config, x, y_copy);
    end
    
    % Get only the region inside the mask
    X = x{3};
    phi_p = zeros(size(X, 1), size(pairwiseEnergy, 3));
    for i = 1 : size(phi_p, 2)
        singlePairwiseEnergy = pairwiseEnergy(:,:,i);
        phi_p(:,i) = double(singlePairwiseEnergy(logical(mask(:))));
    end

    phi = double(sum(cat(2, phi_u, phi_p))');   
    
    % Encode phi as a sparse vector
    phi = sparse(phi);
    
end