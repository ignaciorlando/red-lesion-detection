
function [training_ma_features, training_ma_labels, validation_ma_features, validation_ma_labels] = get_hand_crafted_training_set(training_path, dataset_name)

    % prepare paths for features and labels
    ma_features_file = fullfile(training_path, dataset_name, 'ma_candidates_features', 'ma_features_training.mat');
    ma_labels_file = fullfile(training_path, dataset_name, 'ma_candidates_labels', 'ma_labels_training.mat');

    % if the output path
    output_path_model = fullfile(training_path, 'ma-detection-model');
    if (exist(output_path_model, 'dir') == 0)
        mkdir(output_path_model);
    end

    % load the features, the labels, the ids and the number of true MA from the
    % training set
    load(ma_features_file);
    load(ma_labels_file);

    % -------------------------------------------------------------------------
    % GENERATE TRAINING/VALIDATION SETS
    % -------------------------------------------------------------------------

    % retrieve unique image ids
    unique_image_ids = unique(ma_image_id_training);

    % get training/validation split
    options.trainingFraction = 0.7;
    [splits, sorting] = train_val_splits(length(unique_image_ids), [], options);
    splits = splits{1};
    splits.trainingIndices = unique_image_ids(sort(splits.trainingIndices));
    splits.validationIndices = unique_image_ids(sort(splits.validationIndices));

    % get training data
    [training_ma_features, training_ma_labels] = get_subset_of_images_data(...
        splits.trainingIndices, ma_features_training, ma_labels_training);
    % get validation data
    [validation_ma_features, validation_ma_labels] = get_subset_of_images_data(...
        splits.validationIndices, ma_features_training, ma_labels_training);
    
end