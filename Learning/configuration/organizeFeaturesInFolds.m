function [folds] = organizeFeaturesInFolds(folds_indices, labels, filenames, options)
       
    % Open features and organize all the data in the folds
    folds = cell(length(folds_indices), 1);
    
    % Retrieve features
    [subfeatures_matricial, subfeatures_bag] = retrieveFeatures(options, filenames);

    % prepare training, validation and test data
    for i = 1 : length(folds)
        % Training data
        folds{i}.trainingdata = generateStructOfDataKernels(folds_indices{i}.trainingIndices, subfeatures_matricial, subfeatures_bag, labels.dr, options);
        % Validation data
        folds{i}.validationdata = generateStructOfDataKernels(folds_indices{i}.validationIndices, subfeatures_matricial, subfeatures_bag, labels.dr, options);
        % Test data
        folds{i}.testdata = generateStructOfDataKernels(folds_indices{i}.testIndices, subfeatures_matricial, subfeatures_bag, labels.dr, options);
    end
    
end