
warning('off','all');

% % data sets to segment
% datasets_names = {...
%     'DIARETDB1\train' ...
%     'DIARETDB1\test' ...
%     'e-ophtha' ...
%     'MESSIDOR' ...
% };
% datasets_names = {...
%     'ROCh\train', ...
%     'ROCh\test' ...
% };
% % scale to downsample (it is expected that all the images in the data sets
% % has approximately the same resolution)
% % scale_to_downsample = [ ...
% %     0.74011, ...
% %     0.74011, ...
% %     0.96324, ...
% %     0.81875, ...
% % ];
% scale_to_downsample = [ ...
%     0.74011, ...
%     0.74011 ...
% ];
% % Root dir where the data sets are located
% rootDatasets = 'C:\_diabetic_retinopathy';
% % Root folder where the results are going to be stored
% rootResults = 'C:\_diabetic_retinopathy\segmentations';
% % Model location
% modelLocation = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\drscreening2016paper\data\segmentation-model';

thereAreLabelsInTheTestData = 0 * zeros(size(datasets_names));

load(fullfile(modelLocation, 'model.mat'));
load(fullfile(modelLocation, 'config.mat'));

% For each of the data sets
for i = 1 : length(datasets_names)
              
    % Set the test path
    config.test_data_path = fullfile(rootDatasets, datasets_names{i});
    config.features.saveFeatures = 1;
    
    % Set the results path
    if (~strcmp(rootResults, 'training'));
        if strcmp(config.crfVersion, 'up')
            resultsPath = fullfile(rootResults, datasets_names{i});
        else
            resultsPath = fullfile(rootResults, datasets_names{i});
        end
        if (~exist(resultsPath,'dir'))
            config.output_path = resultsPath;
            mkdir(resultsPath);
        end
    end
    config.resultsPath = resultsPath;

    % Assign downsample factor
    config.downsample_factor = scale_to_downsample(i);
    
    % Determine if there are test data
    config.thereAreLabelsInTheTestData = thereAreLabelsInTheTestData(i);
    
    % Run vessel segmentation!
    runVesselSegmentationUsingExistingModel(config, model)
    
end
        