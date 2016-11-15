
function [model, config, state] = sosvmCallback(config, trainingdata)
% sosvmCallback Configure the SOSVM and call it to learn the model
% [model, config, state] = sosvmCallback(config, trainingdata)
% OUTPUT: model: learned model
%         config: configuration structure
%         state: last state
% INPUT: config: configuration structure
%        trainingdata: training data
    
    % Assign functions
    config.SOSVM.findMostViolatedMarginFn = @findMostViolatedConstraint;
    config.SOSVM.lossFn = @lossComputing;
    config.SOSVM.psiFn = @featureComputing;
    
    % Normalize the value of C by the number of pixels
    %config.SOSVM.C = config.C.value; % We need to do this because of our SOSVM implementation
    config.SOSVM.C = config.C.value / trainingdata.numberOfPixels; % We need to do this because of our SOSVM implementation
    config.SOSVM.C
    
    % Size of the feature vector will be the sum of the size of the
    % unary feature vector and the pairwise feature vector
    config.SOSVM.sizePsi = 2 * (config.features.unary.unaryDimensionality + 1) + config.features.pairwise.pairwiseDimensionality ;

    % Assign additional parameters
    % Positivity contraints
    if (config.SOSVM.usePositivityConstraint)
        config.SOSVM.posindx = 2 * (config.features.unary.unaryDimensionality + 1) + 1 : 2 * (config.features.unary.unaryDimensionality + 1) + config.features.pairwise.pairwiseDimensionality; 
    else
        config.SOSVM.posindx = [];
    end
    
    % Encode the training data
    fprintf('Encoding training data\n');
    [patterns, labels] = encodeTrainingData(config, trainingdata);
    fprintf('Training data encoded\n');
    
    % Train the SOSVM
    [model, config, state] = sosvm(config, patterns, labels);
    
end

% callback to the most violated constraint
function [yhat] = findMostViolatedConstraint(param, model, x, y)
    yhat = constraintCB(param, model, x, y);
end

% callback to the loss function
function [loss] = lossComputing(param, y, tildey)
    loss = lossCB(param, y, tildey);
end

% callback to the feature map function
function [psi] = featureComputing(sparm, x, y)
    [psi] = featureCB(sparm, x, y);
end