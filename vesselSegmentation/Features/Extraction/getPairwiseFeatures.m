
function [pairwiseKernels] = getPairwiseFeatures(pairwiseFeatures, deviations)
% getPairwiseFeatures Divide the pairwise features by the given deviations
% [pairwiseKernels] = getPairwiseFeatures(pairwiseFeatures, deviations)
% OUTPUT: pairwiseKernels: pairwise kernels.
% INPUT: pairwiseFeatures: a cell array containing all the pairwise
%               features
%        deviations: pairwise deviations

    % Copy pairwise features in pairwise kernels
    pairwiseKernels = pairwiseFeatures;
    
    % For each image
    for i = 1:length(pairwiseFeatures)
        
        % Divide features by the standard deviation.
        pairwiseKernels{i} = bsxfun(@rdivide, pairwiseFeatures{i}, deviations');
        
    end

end