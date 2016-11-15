
function [splits, sortings] = get_balanced_training_validation(labels, sortings, options)

    % create arrays of indices per each label
    indices_per_label = cell(length(unique(labels)), 1);
    unique_labels = unique(labels);
    for label_id = 1 : length(unique_labels)
        indices_per_label{label_id} = find(labels==unique_labels(label_id));
    end
    
    % if the cell array of sortings is empty...
    if (isempty(sortings))      
        % initialize the sortings cell array
        sortings = cell(length(unique(labels)), 1);
        % for each of the labels, create different sortings
        for label_id = 1 : length(sortings)
            % randomly sort the indices for the given label 
            current_indices = 1:1:length(indices_per_label{label_id});
            sortings{label_id} = current_indices(randperm(length(current_indices)));
        end
        
    end

    % initialize arrays of indices
    splits{1}.trainingIndices = [];
    splits{1}.validationIndices = [];
    
    % for each label
    for label_id = 1 : length(unique(labels))
        % split indices within training/validation
        [splits_per_label_id, ~] = train_val_splits(length(sortings{label_id}), sortings{label_id}, options);
        % now reorganize real indices
        real_indices = indices_per_label{label_id};
        splits{1}.trainingIndices = cat(1, splits{1}.trainingIndices, real_indices(splits_per_label_id{1}.trainingIndices));
        splits{1}.validationIndices = cat(1, splits{1}.validationIndices, real_indices(splits_per_label_id{1}.validationIndices));
    end

end