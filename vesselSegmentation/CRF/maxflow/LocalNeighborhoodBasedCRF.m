
function [segmentation] = LocalNeighborhoodBasedCRF(unaryPotentials, mask, pairwiseFeatures, weights)
% LocalNeighborhoodBasedCRF This function wrapps the inference on local
% neighborhood based CRFs.
% [segmentation] = LocalNeighborhoodBasedCRF(unaryPotentials, mask, pairwiseFeatures, weights)
% OUTPUT: segmentation: resulting labelling
% INPUT: unaryPotentials: a 3D matrix with the unary potentials
%        mask: a binary mask indicating the FOV
%        pairwiseFeatures: a 3D matrix with the pairwise features
%        weights: weights for the pairwise potentials

    % Get the size of the image
    [height, width] = size(mask);
    N = height * width;
    
    % Get the number of pairwise features

    % Compute pairwise potentials as the product of the weights and the
    % pairwise features
    pairwiseFeatures = reshape(pairwiseFeatures,N,size(pairwiseFeatures,3));
    divider = 1; % DRIVE
    %divider = 1.24; % STARE
    %divider = 1.77; % CHASEDB
    pairwisePotentials = (weights' * pairwiseFeatures')';
    
    % Construct graph
    E = edges4connected(height, width);
    V = abs(pairwisePotentials(E(:,1)) - pairwisePotentials(E(:,2))) + eps;
    A = sparse(E(:,1),E(:,2),V,N,N,4*N);    

    % terminal weights
    % connect source to leftmost column.
    % connect rightmost column to target.
    unaryPotentials = reshape(unaryPotentials, N, 2);
    B = unaryPotentials(:,1);
    unaryPotentials(:,1) = unaryPotentials(:,2);
    unaryPotentials(:,2) = B;
    T = sparse(unaryPotentials);
    
    % Max-flow/min-cut calculation using the Boykov-Kolmogorov's algorithm
    [flow, segmentation] = maxflow(A,T);
    segmentation = reshape(segmentation,[height width]);

end