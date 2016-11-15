
function [folds, options] = prepareExperiments(options)

    % ---------------------------------------------------------------------
    % LOAD THE LABELS
    % ---------------------------------------------------------------------
    % Open the labels
    load(strcat(options.dataFolder, filesep, 'labels', filesep, 'labels.mat'));

    % ---------------------------------------------------------------------
    % PREPARE THE FOLDS: Load the file with the folds OR Prepare the folds
    % ---------------------------------------------------------------------
    
    % Get idx number on each fold
    [folds_indices, filenames] = getIdxForEachFold(labels, options);
    
    % ---------------------------------------------------------------------
    % ORGANIZE DATA IN FOLDS
    % ---------------------------------------------------------------------    
    
    % Organize folds
    [folds] = organizeFeaturesInFolds(folds_indices, labels, filenames, options);

    % ---------------------------------------------------------------------
    % NORMALIZE, CREATE KERNELS AND PLAY AROUND
    % ---------------------------------------------------------------------
       
    [folds] = preprocessFeaturesInFold(folds, options);
    
    % ---------------------------------------------------------------------
    % PREPARE THE EXPERIMENT AND THE RESULTS FILE
    % ---------------------------------------------------------------------
    
    % Save the results
    options.saveResultsPath = strcat(options.resultsFolder, filesep, 'kernel', filesep, strjoin(options.features.tags));
    options.filenameToSave = strcat(options.saveResultsPath, filesep, 'results_kernel-', num2str(options.numFolds), 'folds.mat');

end

