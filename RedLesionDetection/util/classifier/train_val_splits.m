
function splits = train_val_splits(labels)

    % generate an array of numbers from 1:length(labels) to represent the
    % indices, and permute it randomly
    indices = 1:1:length(labels);
    sorting = indices(randperm(length(indices)));
    
    % initialize a split array
    splits = cell(1,1);

    % the validation size will be equal to 
    validationSize = floor((1 - 0.7) * length(labels));

    % first 1:validatioSize will be used for validation
    splits{1}.validationIndices = sorting(1:validationSize);
    % the remaining images will correspond to the training data
    splits{1}.trainingIndices = sorting(validationSize+1:end);

end