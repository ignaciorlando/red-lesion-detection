
function [folds, sorting] = leaveOneOutCrossValidationSplit(labels, sorting, options)

    nFolds = length(labels);
    
    % Initialize the cell-array of splits
    folds = cell(nFolds, 1);
    for i = 1 : length(folds)
        folds{i}.trainingIndices = [];
        folds{i}.validationIndices = [];
        folds{i}.testIndices = [];
    end
    
    % The fold size will be 1 
    foldSize = 1;

    % The validation size will be equal to 
    validationSize = floor((1 - options.trainingFraction) * (length(labels) - foldSize));

    % If the parameter sorting is an empty array, generate an array of 
    % numbers from 1 to sizeSet to represent the indices, and permute it
    % randomly
    indices = 1:1:length(labels);
    sorting = indices(randperm(length(indices)));

    % For each fold (except the last one)
    prev = 1;
    next = foldSize;
    for i = 1 : nFolds

        fold = folds{i};

        % Initialize an array with the indices already sorted randomly
        currentIndices = sorting;

        % Retrieve the test fold
        if (i == nFolds)
            next = length(indices);
        end
        fold.testIndices = cat(1, fold.testIndices, currentIndices(prev : next));
        currentIndices(prev:next) = [];

        % Retrieve the validation set
        tempIndices = randsample(1:length(currentIndices), validationSize);
        fold.validationIndices = cat(1, fold.validationIndices, currentIndices(tempIndices));
        currentIndices(tempIndices) = [];

        % The remaining images will correspond to the training data
        fold.trainingIndices = cat(1, fold.trainingIndices, currentIndices);

        % Save the fold in the array
        folds{i} = fold;

        % Update prev and next
        prev = prev + foldSize;
        next = next + foldSize;

    end
    

end