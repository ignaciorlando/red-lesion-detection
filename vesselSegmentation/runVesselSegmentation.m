
function [results] = runVesselSegmentation(config)

    % Open training data labels
    [trainingdata.labels] = openVesselLabels(strcat(config.training_data_path, filesep, 'labels'));
    % Open training data labels
    [validationdata.labels] = openVesselLabels(strcat(config.validation_data_path, filesep, 'labels'));

    % Code name of the expected files
    pairwisedeviations = strcat(config.training_data_path, filesep, 'pairwisedeviations.mat');
    % If the pairwise deviation file does not exist
    if (exist(pairwisedeviations, 'file')~=2)
        % Compute all possible features
        [allfeatures, numberOfDeviations, ~, ~, ~] = extractFeatures(strcat(config.training_data_path, filesep, 'images'), ...
                                                            strcat(config.training_data_path, filesep, 'masks'), ...
                                                            config, ...
                                                            ones(size(config.features.numberFeatures)), ...
                                                            false);
        % Compute pairwise deviations
        pairwiseDeviations = getPairwiseDeviations(allfeatures, numberOfDeviations);
        % Save pairwise deviations
        save(pairwisedeviations, 'pairwiseDeviations');
    else
        % Load pairwise deviations
        load(pairwisedeviations); 
    end

    % Assign precomputed deviations to the param struct
    config.features.pairwise.pairwiseDeviations = pairwiseDeviations;
    clear 'pairwiseDeviations';

    
    
    if (~config.learn.modelSelection)
        % Don't do model selection
        [model, config.qualityOverValidation, config] = learnConfiguredCRF(trainingdata, validationdata, config);
    else
        % Do model selection
        [model, config.C.value, config.qualityOverValidation, config] = completeModelSelection(trainingdata, validationdata, config);
    end
    
    % Evaluate the learned model on the test data    
    [results] = runVesselSegmentationUsingExistingModel(config, model);
    
end