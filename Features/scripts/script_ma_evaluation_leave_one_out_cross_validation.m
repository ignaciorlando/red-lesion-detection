
config_ma_evaluation_leave_one_out_cross_validation;

% prepare paths for features and labels
ma_features_file = fullfile(training_path, dataset_name, 'ma_candidates_features', 'ma_features_training.mat');
ma_labels_file = fullfile(training_path, dataset_name, 'ma_candidates_labels', 'ma_labels_training.mat');
ma_image_id_file = fullfile(training_path, dataset_name, 'ma_candidates_labels', 'ma_image_id_training.mat');
ma_candidates_data_file = fullfile(training_path, dataset_name, 'ma_candidates_data', 'ma_candidates_data.mat');
ma_ground_truth_num_mas_file = fullfile(training_path, dataset_name, 'ma_candidates_labels', 'ma_ground_truth_num_mas.mat');

% prepare path for images
images_path = fullfile(root_images_path, dataset_name, 'images');

% if the output path
output_path_segmentations = fullfile(output_path_segmentations, dataset_name, strcat('ma_segmentations-', classifier));
if (exist(output_path_segmentations, 'dir') == 0)
    mkdir(output_path_segmentations);
end

% load the features, the labels, the ids and additional data from training
load(ma_features_file);
load(ma_labels_file);
load(ma_image_id_file);
load(ma_candidates_data_file);
load(ma_ground_truth_num_mas_file);

% ---------------------------------------------------------------------
% PREPARE DATA FOR LEAVE ONE IMAGE OUT CROSS VALIDATION
% ---------------------------------------------------------------------

% generate indices for the training/validation sets
options.trainingFraction = 0.7;
% retrieve image ids
unique_image_ids = unique(ma_image_id_training);
% retrieve images names
img_names = getMultipleImagesFileNames(images_path);
% prepare test folds
test_folds = cell(length(unique_image_ids), 1);


% ---------------------------------------------------------------------
% RUN LEAVE ONE IMAGE OUT CROSS VALIDATION
% ---------------------------------------------------------------------
all_scores = [];
all_labels = [];
all_ids = [];
all_ground_truth_num_mas = [];

% for each of the images
for im = 1 : length(unique_image_ids)

    % current image id will be for the test set
    test_idxs = (ma_image_id_training == im);
    test.ma_features = ma_features_training(test_idxs, :);
    test.ma_labels = ma_labels_training(test_idxs);
    test.image_id = ma_image_id_training(test_idxs);
    test.ma_candidates_data_pxs = ma_candidates_data{im}.pxs;
    test.ma_ground_truth_num_mas = ma_ground_truth_num_mas(im);
    
    % the remaining images will be for the training set
    training_idxs = (ma_image_id_training ~= im);
    current.ma_features_training = ma_features_training(training_idxs, :);
    current.ma_labels_training = ma_labels_training(training_idxs);
    current.ma_image_id_training = ma_image_id_training(training_idxs);
    current.ma_ground_truth_num_mas = ma_ground_truth_num_mas(unique_image_ids~=im);
    
    % divide training set in training and validation
    [splits, sorting] = train_val_splits(length(find(unique_image_ids~=im)), [], options);
    splits = splits{1};
    splits.trainingIndices = current.ma_image_id_training(sort(splits.trainingIndices));
    splits.validationIndices = current.ma_image_id_training(sort(splits.validationIndices));

    % get training data
    [training_image_ids, training_ma_features, training_ma_labels] = get_subset_of_images_data(...
        splits.trainingIndices, current.ma_image_id_training, current.ma_features_training, current.ma_labels_training);
    % get validation data
    [validation_image_ids, validation_ma_features, validation_ma_labels] = get_subset_of_images_data(...
        splits.validationIndices, current.ma_image_id_training, current.ma_features_training, current.ma_labels_training);
    % get validation ground truth ma labels
    validation_ground_truth_num_mas = current.ma_ground_truth_num_mas(splits.validationIndices);
    
    % train the model
    [ma_detector, quality] = trainMaDetector(training_ma_features, training_ma_labels, ...
        validation_ma_features, validation_ma_labels, validation_image_ids, validation_ground_truth_num_mas, classifier);
    quality
    
    % generate scores on the test set:
    
    % open image
    I = imread(fullfile(images_path, img_names{im}));
    
    % Get the segmentations and the score map for the given image
    [test.ma_segmentation, test.ma_score_map, test.current_scores] = segmentMA(ma_detector, I, test.ma_features, test.ma_candidates_data_pxs);
    
    % save training, validation & test
    test_folds{im} = test;
    
    % concatenate results so we can compute the FROC curve
    all_scores = cat(1, all_scores, test.current_scores);
    all_labels = cat(1, all_labels, test.ma_labels);
    all_ids = cat(1, all_ids, ones(length(test.ma_labels),1) * im);
    all_ground_truth_num_mas = cat(1, all_ground_truth_num_mas, test.ma_ground_truth_num_mas);
    
end

% save it
k = strfind(dataset_name, filesep);
if (~isempty(k))
    dataset_name(k) = '_';
end

% show FROC curve
figure
[fpi, per_lesion_sensitivity, froc_score] = froc(all_scores, all_labels, all_ids, all_ground_truth_num_mas);
title(strcat(classifier, '-', dataset_name));

% % save all the segmentations and score maps
% for im = 1 : length(unique_image_ids)
%     % save the segmentation and the score map
%     imwrite(test_folds{im}.ma_segmentation, fullfile(output_path_segmentations, strcat(img_names{im}, '.gif')));
%     ma_score_map = test_folds{im}.ma_score_map;
%     save(fullfile(output_path_segmentations, strcat(img_names{im}, '.mat')), 'ma_score_map');
% end

%save(fullfile(output_path_model, strcat('ma_detector_model_', dataset_name, '-', classifier, '.mat')), 'ma_detector');