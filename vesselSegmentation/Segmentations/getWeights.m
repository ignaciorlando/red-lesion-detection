
function [W_unaries, W_pairwises, bias] = getWeights(W, config)
% getWeights Separates the weights for unary, pairwise and bias
% [W_unaries, W_pairwises, bias] = getWeights(W, config)
% OUTPUT: W_unaries: weights for the unary potentials
%         W_pairwises: weights for the pairwise potentials
%         bias: weights for the bias term
            
    % separate the pairwise weights
    W_pairwises = W(end - config.features.pairwise.pairwiseDimensionality + 1 : end);
    wNonPairwises = W(1 : end - config.features.pairwise.pairwiseDimensionality);

    % separate the weights of each class in such a way that i indicates the
    % number of class and j the number of feature
    wNonPairwises = reshape(wNonPairwises, 2, config.features.unary.unaryDimensionality + 1);

    % separate the bias term
    bias = wNonPairwises(:, end);

    % encode the weights for the unary potentials
    W_unaries = wNonPairwises(:, 1 : end - 1);
    
end