
function [yhat] = constraintCB(config, model, x, y)
% constraintCB Compute the most violated constraint
% [yhat] = constraintCB(config, model, x, y)
% OUTPUT: yhat: estimated labelling
% INPUT: config: configuration structure
%        model: learned model
%        x: a cell array containing the FOV mask, the unary and pairwise
%        features
%        y: ground truth labelling
        
    % Get the image and the mask
    mask = x{2};

    % Separate the weights among unaries, pairwises and bias
    [W_unary, W_pairwises, W_bias] = getWeights(model.w, config);
        
    % Find the most violated constraint
    % 1) Get the unary features

    % Encode the unary features
    nonPairwiseFeatures = getfeatures(x, y); % Take only the unary features and the bias, and ignore the pairwise
    unaryFeatures = reshape(nonPairwiseFeatures, size(nonPairwiseFeatures, 1), 2, config.features.unary.unaryDimensionality + 1);
    unaryFeatures = permute(unaryFeatures, [3 1 2]);
    unaryFeatures = unaryFeatures(1 : end - 1, :, :); % Ignore the bias term
    
    % 2) Get the pairwise features
    pairwiseFeatures = x{4};
    
    % 3) Include the penalizations into the unary features
    
    % If the class has to be 0 but we classify it as 1, then we penalize (false positives)
    penalizationBackground = zeros(size(y));
    penalizationBackground(y==1) = 1;
    % If the class has to be 1 but we classify it as 0, then we penalize (false negatives)
    penalizationForeground = zeros(size(y));
    penalizationForeground(y==0) = 1;
       
    
    % 4) Compute the scores and multiply them by -1 to get the unary energy
    unaryPotentials = zeros(size(mask, 1), size(mask, 2), 2);
    
    background = double(mask);
    foreground = double(mask);
    
    scoresBackground = -(W_unary(1, :) * unaryFeatures(:,:,1) + W_bias(1) * config.biasMultiplier)' - penalizationBackground; % background
    scoresForeground = -(W_unary(2, :) * unaryFeatures(:,:,2) + W_bias(2) * config.biasMultiplier)' - penalizationForeground; % foreground    
    
    background(~logical(mask)) = min(scoresBackground(y==0));
    foreground(~logical(mask)) = max(scoresForeground(y==0));
    
    background(logical(mask)) = scoresBackground;
    foreground(logical(mask)) = scoresForeground;
    
    unaryPotentials(:,:,1) = background;
    unaryPotentials(:,:,2) = foreground;

    % 5) Get the most violated prediction   
    mvp = CRFInference(config, unaryPotentials, mask, pairwiseFeatures, W_pairwises);
    
    % 6) Get only the pixels inside the mask
    yhat = mvp(logical(mask));
    
end
