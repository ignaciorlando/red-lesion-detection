
function [segmentation] = CRFInference(config, unaryPotentials, mask, pairwiseFeatures, weights)
% CRFInference Obtain the segmentation by minimizing the overall energy of
% the CRF.
% [segmentation] = CRFInference(config, unaryPotentials, mask, pairwiseFeatures, weights)
% OUTPUT: segmentation: binary segmentation
% INPUT: config: configuration structure
%        unaryPotentials: a 3D matrix representing the unary potentials
%        mask: a binary mask indicating where the FOV is
%        pairwiseFeatures: a 3D matrix representing the pairwise features
%        weights: an array of weights for the pairwise potentials
      
     % Check what version of the CRF it is going to be utilized 
     if strcmp(config.crfVersion,'local-neighborhood-based')
        segmentation = logical(LocalNeighborhoodBasedCRF(unaryPotentials, mask, pairwiseFeatures, weights));
     else
        segmentation = logical(FullyCRFWrapperWithGivenPairwises(config, unaryPotentials, mask, pairwiseFeatures, weights));
     end
    
end