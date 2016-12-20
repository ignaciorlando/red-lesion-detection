
warning('off','all');

% % data sets to segment
% datasets_names = {...
%     'ROCh\train', ...
%     'ROCh\test' ...
% };
% % scale to downsample (it is expected that all the images in the data sets
% % has approximately the same resolution)
% scale_to_downsample = [ ...
%     0.74011, ...
%     0.74011 ...
% ];
% % Root dir where the data sets are located
% rootDatasets = 'C:\_diabetic_retinopathy';
% % Root folder where the results are going to be stored
% resultsPath = 'C:\_diabetic_retinopathy\segmentations';
% % Model location
% modelLocation = 'C:\_diabetic_retinopathy\segmentation-model';

thereAreLabelsInTheTestData = 0 * zeros(size(datasets_names));

load(fullfile(modelLocation, 'model.mat'));
load(fullfile(modelLocation, 'config.mat'));

% For each of the data sets
for i = 1 : length(datasets_names)
              
    % Set the test path
    config.test_data_path = fullfile(rootDatasets, datasets_names{i});
    if isfield(config.features, 'saveFeatures')==0
        config.features.saveFeatures = 1;
    end
    
    % Set the results path
    config.resultsPath = resultsPath;

    % Assign downsample factor
    config.downsample_factor = scale_to_downsample(i);
    
    % Determine if there are test data
    config.thereAreLabelsInTheTestData = thereAreLabelsInTheTestData(i);
    
    % Run vessel segmentation!
    runVesselSegmentationUsingExistingModel(config, model)
    
end
        