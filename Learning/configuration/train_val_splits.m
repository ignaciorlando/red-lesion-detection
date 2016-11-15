
function [splits, sorting] = train_val_splits(sizeSet, sorting, options)

    % If the parameter sorting is an empty array, generate an array of 
    % numbers from 1 to sizeSet to represent the indices, and permute it
    % randomly
    indices = 1:1:sizeSet;
    if (isempty(sorting))
        sorting = indices(randperm(length(indices)));
    end
    
    splits = cell(1,1);

    % The validation size will be equal to 
    validationSize = floor((1 - options.trainingFraction) * sizeSet);

    % The remaining images will correspond to the training data
    splits{1}.validationIndices = sorting(1:validationSize);
    
    % The remaining images will correspond to the training data
    splits{1}.trainingIndices = sorting(validationSize+1:end);

end