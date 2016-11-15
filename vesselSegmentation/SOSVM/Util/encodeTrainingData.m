
function [patterns, labels] = encodeTrainingData(config, trainingdata) 

    % Preallocate memory for the patterns and labels arrays
    patterns = cell(size(trainingdata.unaryFeatures));
    labels = cell(size(trainingdata.unaryFeatures));
    
    % For each image in the training set
    for i = 1:length(patterns)
        
        % Encode unary features including a bias term
        featureVectors = trainingdata.unaryFeatures{i};
        X = zeros(size(featureVectors, 1), size(featureVectors, 2) + 1);
        X(:, 1 : end - 1) = featureVectors;
        X(:, end) = ones(size(X,1), 1) * config.biasMultiplier;  % Add a bias term
        
        % Encode pairwise features
        mask = trainingdata.masks{i};
        oldPairwises = trainingdata.pairwiseKernels{i};
        newPairwises = zeros(size(mask, 1), size(mask, 2), config.features.pairwise.pairwiseDimensionality);
        for j = 1 : size(oldPairwises,2)
            p = single(mask);
            p(p==1) = oldPairwises(:,j);
            newPairwises(:,:,j) = p;
        end
        
        % Create the patterns
        patterns{i} = {trainingdata.masks{i} trainingdata.masks{i} X newPairwises};
        
        % Create the labels
        y = trainingdata.labels{i};
        mask = trainingdata.masks{i};
        labels{i} = y(mask);
        
    end
    
end