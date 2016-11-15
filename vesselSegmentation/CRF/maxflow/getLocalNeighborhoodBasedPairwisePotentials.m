
function [potentials] = getLocalNeighborhoodBasedPairwisePotentials(pairwiseFeatures, labels)
% getLocalNeighborhoodBasedPairwisePotentials This function computes
% efficiently the pairwise potentials.
% [potentials] = getLocalNeighborhoodBasedPairwisePotentials(pairwiseFeatures, labels)
% OUTPUT: potentials: pairwise potentials
% INPUT: pairwiseFeatures: a 3D matrix with the pairwise features
%        labels: labelling

    % Initialize the vector to be returned
    potentials = zeros(size(pairwiseFeatures));
    
    % Estimate pairwise potentials
    for i = 1 : size(pairwiseFeatures, 3)
        
        % Get single pairwise feature
        singlePairwise = pairwiseFeatures(:,:,i);
        
        % Shift images up, down, left and right to compute the pairwise
        % differences
        shL = zeros(size(singlePairwise));
        shL_labels = zeros(size(labels));
        shL(1:end,1:end-1) = singlePairwise(1:end,2:end);
        shL_labels(1:end,1:end-1) = labels(1:end,2:end);
        LEFT = abs(singlePairwise - shL) .* abs(labels - shL_labels);
        
        shR = zeros(size(singlePairwise));
        shR_labels = zeros(size(labels));
        shR(1:end,2:end) = singlePairwise(1:end,1:end-1);
        shR_labels(1:end,2:end) = labels(1:end,1:end-1);
        RIGHT = abs(singlePairwise - shR) .* abs(labels - shR_labels);
        
        shD = zeros(size(singlePairwise));
        shD_labels = zeros(size(labels));
        shD(2:end,1:end) = singlePairwise(1:end-1, 1:end);
        shD_labels(2:end,1:end) = labels(1:end-1, 1:end);
        DOWN = abs(singlePairwise - shD) .* abs(labels - shD_labels);
        
        shU = zeros(size(singlePairwise));
        shU_labels = zeros(size(labels));
        shU(1:end-1,1:end) = singlePairwise(2:end,1:end);
        shU_labels(1:end-1,1:end) = labels(2:end, 1:end);
        UP = abs(singlePairwise - shU) .* abs(labels - shU_labels);
        
        % Get the pairwise potentials for each point
        potentials(:,:,i) = (LEFT + RIGHT + DOWN + UP) * 2;

    end


end