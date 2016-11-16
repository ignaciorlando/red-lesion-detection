
% SCRIPT_TRAIN_LESION_CLASSIFIER
% -------------------------------------------------------------------------
% This code is used for training a classifier based on a combination of CNN
% and hand-crafted features. First you have to edit 
% config_train_lesion_classifier.
% -------------------------------------------------------------------------

config_train_lesion_classifier;

% Initialize variables
detector = struct();
detector.method = classifier;

% -------------------------------------------------------------------------
% compute features and prepare training/validation sets
% -------------------------------------------------------------------------

% prepare data set tag
[datasetTag] = generate_dataset_tag(dataset_name);
% prepare cnn filename
cnn_full_path = fullfile(data_path, strcat(type_of_lesion, '-detection-model'), datasetTag, strcat(cnn_filename, '.mat'));
% and now extract features
[imdb] = get_red_lesion_data_to_classify(dataset_name, features_source, type_of_lesion, true, data_path, root_path, cnn_full_path);   

% -------------------------------------------------------------------------
% train a classifier for red lesion detection
% -------------------------------------------------------------------------
[learned_model, quality] = trainRedLesionDetector(imdb, classifier);
switch features_source
    case 'cnn-transfer'
        detector.net = load(cnn_full_path);
        detector.classifier = learned_model;
    otherwise
        detector = learned_model;
end

% -------------------------------------------------------------------------
% save the learned model
% -------------------------------------------------------------------------
if strcmp(features_source, 'combined')
    current_folder = fullfile(data_path, strcat(type_of_lesion, '-detection-model'), datasetTag, features_source, cnn_filename);
else
    current_folder = fullfile(data_path, strcat(type_of_lesion, '-detection-model'), datasetTag, features_source);
end
mkdir(current_folder);

save(fullfile(current_folder, strcat(detector.method, '.mat')), 'detector');

