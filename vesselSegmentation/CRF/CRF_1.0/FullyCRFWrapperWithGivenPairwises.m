
function y = FullyCRFWrapperWithGivenPairwises(config, unaryPotentials, mask, pairwiseFeatures, weights)
% FullyCRFWrapperWithGivenPairwises This function wrapps the MEX-function
% that implements the fully connected CRF inference
% y = FullyCRFWrapperWithGivenPairwises(config, unaryPotentials, mask, pairwiseFeatures, weights)
% OUTPUT: y: labeling
% INPUT: config: configuration structure
%        unaryPotentials: a 3D matrix with the unary potentials for each of
%        the 2 clases.
%        mask: a binary mask representing the FOV
%        pairwiseFeatures: a 3D matrix with the pairwise features
%        weights: weights for the pairwise features
    
    % Permute dimensions of the unary potentials
    unaryPotentials = permute(unaryPotentials,[3 1 2]);
    pairwiseFeatures = permute(pairwiseFeatures, [1 2 3]);

    % Get the segmentation
    y = (fullyCRFwithGivenPairwises(int32(size(mask, 1)), int32(size(mask, 2)), ...
           single(unaryPotentials), single(pairwiseFeatures), ...
           single(weights), int32(size(pairwiseFeatures, 3)), ...
           single(2 * config.theta_p.finalValues.^2)))>0;

end