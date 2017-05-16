
% SCRIPT_EVALUATE_EACH_LESION_PERFORMANCE
% -------------------------------------------------------------------------
% This code is used for ploting FROC curves for each type of lesion (HEs
% and MAs). This will only run for DIARETDB1, as DIARETDB1 is the only data
% set with annotations for each type of lesion.
% -------------------------------------------------------------------------

config_evaluate_each_lesion_performance;

% By default, we will always use DIARETDB1 test set
dataset_name = fullfile('DIARETDB1','test');

% -------------------------------------------------------------------------
% prepare folder and filenames
% -------------------------------------------------------------------------

% reassign results path
results_path = fullfile(results_path, dataset_name, strcat(type_of_lesion_segmented, '-segmentations'));

% replace bars in the name of the training and test sets
[training_set] = generate_dataset_tag(training_set);
[dataset_tag_name] = generate_dataset_tag(dataset_name);

% Initialize an array of FROC scores
froc_scores = zeros(size(score_maps_paths));

for k = 1 : length(score_maps_paths)
    
    % Get current score
    score_maps_path = fullfile(results_path, score_maps_paths{k});

    % Retrieve all scores names
    score_maps_names = dir(fullfile(score_maps_path, '*.mat'));
    score_maps_names = {score_maps_names.name}';
    score_maps_names(strcmp(score_maps_names, 'froc_data.mat')) = [];
    score_maps_names(strcmp(score_maps_names, 'ma-froc_data.mat')) = [];
    score_maps_names(strcmp(score_maps_names, 'hemorrhages-froc_data.mat')) = [];

    % retrieve images/labels names from the lesion to evaluate
    true_labels_path = fullfile(test_images_path, dataset_name, lesion_to_evaluate);
    true_labels_names = getMultipleImagesFileNames(true_labels_path);
    % same but for the lesion to remove
    false_labels_path = fullfile(test_images_path, dataset_name, lesion_to_remove);
    false_labels_names = getMultipleImagesFileNames(false_labels_path);

    % for each image
    for i = 1 : length(score_maps_names)

        fprintf('Loading from image %i/%i\n', i, length(score_maps_names));

        % load the score map
        load(fullfile(score_maps_path, score_maps_names{i}));
        % open the gt label
        gt_labels{i} = imread(fullfile(true_labels_path, true_labels_names{i})) > 0;
        
        % open the gt label of the lesions to remove, but be carefull of
        % not removing lesions that are actually part of the ground truth
        % labelling of the other lesion
        lesions_to_remove = imread(fullfile(false_labels_path, false_labels_names{i})) > 0;
        lesions_to_remove = (lesions_to_remove - gt_labels{i}) > 0;
        
        % remove these lesions from the score map
        score_map(lesions_to_remove) = 0;
        % assign to the score map array
        score_maps{i} = score_map;

    end

    if (ishandle(1))
        hold on;
    else
        figure(1);
    end
    [fpi, per_lesion_sensitivity, froc_score, reference_se_vals, thresholds] = froc(score_maps, gt_labels, true);
    froc_scores(k) = froc_score;
    drawnow
    save(fullfile(score_maps_path, strcat(lesion_to_evaluate, '-froc_data.mat')), ...
        'fpi','per_lesion_sensitivity','froc_score','reference_se_vals','thresholds');
    
end
