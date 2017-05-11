
% SCRIPT_SEGMENT_RED_LESIONS
% -------------------------------------------------------------------------
% This code is used for segmenting red lesions on new images from a given
% folder. You have to edit config_segment_red_lesions to fix parameters.
% -------------------------------------------------------------------------

config_segment_red_lesions;

% -------------------------------------------------------------------------
% prepare folder and filenames
% -------------------------------------------------------------------------

% reassign results path
results_path = fullfile(results_path, dataset_name, strcat(type_of_lesion, '-segmentations'));

% replace bars in the name of the training and test sets
[training_set] = generate_dataset_tag(training_set);
[dataset_tag_name] = generate_dataset_tag(dataset_name);

% prepare other paths depending on the type of features source
if strcmp(features_source, 'combined')
    trained_model_file = fullfile(trained_model_path, training_set, features_source, cnn_filename, strcat(trained_model_name, '.mat'));
else
    trained_model_file = fullfile(trained_model_path, training_set, features_source, strcat(trained_model_name, '.mat'));
end
switch features_source
    case 'hand-crafted' 
        cnn_fullpath = [];
    case 'combined'
        cnn_fullpath = fullfile(trained_model_path, training_set, strcat(cnn_filename, '.mat'));
    case 'cnn-transfer'
        cnn_fullpath = fullfile(trained_model_path, training_set, strcat(cnn_filename, '.mat'));
    otherwise
        cnn_fullpath = trained_model_file;
end
output_path = fullfile(results_path, features_source, trained_model_name);
if strcmp(features_source, 'combined')
    output_path = fullfile(output_path, cnn_filename);
end


% retrieve images/labels names
images_path = fullfile(test_images_path, dataset_name, 'images');
labels_path = fullfile(test_images_path, dataset_name, type_of_lesion);
img_names = getMultipleImagesFileNames(images_path);
labels_names = getMultipleImagesFileNames(labels_path);


% -------------------------------------------------------------------------
% compute features and prepare test set
% -------------------------------------------------------------------------
imdb = get_red_lesion_data_to_classify(dataset_name, features_source, type_of_lesion, false, test_data_path, test_images_path, cnn_fullpath);


% -----------------------------------------------------------------
% segment red lesions
% -----------------------------------------------------------------

% load the trained model
load(trained_model_file);

% prepare cell arrays of score maps and labels
score_maps = cell(length(img_names), 1);
gt_labels = cell(length(labels_names), 1);
mkdir(output_path);

% for each image
for i = 1 : length(img_names)
    
    fprintf('Segmenting MA from image %i/%i\n', i, length(img_names));
    
    % open image
    I = imread(fullfile(images_path, img_names{i}));
    
    % Get the segmentations and the score map for the given image
    [segmentation, score_map, current_scores] = segmentRedLesions(detector, I, double(imdb.images.data{i}), imdb.images.candidates_pxs{i});
    score_maps{i} = score_map;
    
    % save the segmentation and the score map
    imwrite(segmentation, fullfile(output_path, strcat(img_names{i}, '.gif')));
    save(fullfile(output_path, strcat(img_names{i}, '.mat')), 'score_map');
    
    % if there are labels, then plug all the labels into an array of labels
    if (exist('labels_names', 'var') ~= 0) && ~isempty(labels_names)
        % open ground truth labels
        gt_labels{i} = imread(fullfile(labels_path, labels_names{i})) > 0;
    end
    
end

% if there are labels, plot the FROC curve
if (~isempty(gt_labels)) && generate_froc_curve
    
    if (ishandle(1))
        hold on;
    else
        figure(1);
    end
    [fpi, per_lesion_sensitivity, froc_score, reference_se_vals, thresholds] = froc(score_maps, gt_labels, true);
    
    save(fullfile(output_path, 'froc_data.mat'), ...
        'fpi','per_lesion_sensitivity','froc_score','reference_se_vals','thresholds');
    savefig(fullfile(output_path, 'froc_fig.fig'));

end
