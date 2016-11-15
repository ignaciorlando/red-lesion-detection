
function [folds, sorting] = stratifiedSampling(labels, nFolds, sorting, options)
    
    % fix the random state
    rng(1);
    
    %prepare labels
    [labels] = prepareLabels(labels, options);
    
    options.testFraction = 1 / nFolds;
    options.validationFraction = (1-options.trainingFraction) * options.trainingFraction;
    options.trainingFraction = options.trainingFraction * options.testFraction;
    
    % Determine distinct strata
    distinct_data = unique(labels);
    % Count distinct strata
    n_distinct_data = size(distinct_data,1);

    % Locate observations in each class
    idx_per_class = cell(n_distinct_data, 1);
    % And the number of elements in each class
    n_idx_per_class = zeros(size(distinct_data));
    % Training/test number of images that must be collected
    num_to_collect_training = zeros(size(distinct_data));
    num_to_collect_validation = zeros(size(distinct_data));
    num_to_collect_test = zeros(size(distinct_data));
    for i = 1 : n_distinct_data
        
        idx = find(labels == distinct_data(i));
        rnd_sort = randperm(length(idx));
        idx = idx(rnd_sort);
        
        idx_per_class{i} = idx;
        n_idx_per_class(i) = length(idx);
        
        num_to_collect_training(i) = round(n_idx_per_class(i) * (options.trainingFraction / nFolds));
        num_to_collect_validation(i) = round(n_idx_per_class(i) * (options.validationFraction) / nFolds);
        num_to_collect_test(i) = round(n_idx_per_class(i) * (options.testFraction) / nFolds);
        
    end

    % build each fold with approximately the same number of images on each
    % class
    folds = cell(nFolds, 1);
    for i = 1 : nFolds
        
        fold.trainingIndices = [];
        fold.validationIndices = [];
        fold.testIndices = [];

        % for each label
        for j = 1 : n_distinct_data
            
            % Recover image ids on the given class
            idx_per_class_j = idx_per_class{j};
            % Identify the images that have to be add to train and test
            to_add_training = 1:num_to_collect_training(j);
            to_add_validation = num_to_collect_training(j) + 1:num_to_collect_training(j) + num_to_collect_validation(j);
            to_add_test = num_to_collect_training(j) +num_to_collect_validation(j) + 1:num_to_collect_training(j) +num_to_collect_test(j) + num_to_collect_test(j);
            % Assign appropriate number of units to Training group
            fold.trainingIndices = cat(1, fold.trainingIndices, idx_per_class_j(to_add_training));
            % Assign an appropriate number of units to Validation group
            fold.validationIndices = cat(1, fold.validationIndices, idx_per_class_j(to_add_validation));
            % Assign an appropriate number of units to Test group
            fold.testIndices = cat(1, fold.testIndices, idx_per_class_j(to_add_test));
            % Remove the added elements
            idx_per_class_j(cat(2,to_add_training, to_add_validation, to_add_test)) = [];
            % Reassign to the cell array
            idx_per_class{j} = idx_per_class_j;
            
        end
        
        folds{i} = fold;

    end

end