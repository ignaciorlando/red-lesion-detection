
config_froc_per_epoch;

% prepare paths for features and images in the test set
ma_candidates_data_file = fullfile(test_data_path, dataset_name, 'ma_candidates_data', 'ma_candidates_data.mat');
images_path = fullfile(test_images_path, dataset_name, 'images');
% and also for the labels (should they exists)
labels_path = fullfile(test_images_path, dataset_name, 'labels');
% and also for the ma candidates
ma_candidates_path = fullfile(test_data_path, dataset_name, 'ma_candidates');

% -----------------------------------------------------------------
% PREPARE THE TEST DATA
% -----------------------------------------------------------------

% retrieve images names
img_names = getMultipleImagesFileNames(images_path);
% retrieve labels names
if (exist(labels_path, 'dir')~=0)
    labels_names = getMultipleImagesFileNames(labels_path);
end
% retrieve candidates names
ma_candidates_names = getMultipleImagesFileNames(ma_candidates_path);
% load MA candidates data
load(ma_candidates_data_file);

% -----------------------------------------------------------------
% EVALUATE EACH EPOCH AND PLOT THE FROC CURVE
% -----------------------------------------------------------------

my_legends = {};
% for each epoch

epochs = [1, epoch_step:epoch_step:last_epoch];
for epoch = epochs

    fprintf('Evaluating epoch %i/%i\n', epoch, last_epoch);
    
    % load the net file
    load(fullfile(cnn_checkpoints_path, strcat('net-epoch-', num2str(epoch), '.mat')));
    ma_detector.net = net;
    ma_detector.method = 'cnn';
    
    % if there are labels, initialize an array of scores, image ids and labels
    if (exist('labels_names', 'var') ~= 0)
        all_scores = [];
        all_image_ids = [];
        all_labels = [];
        all_gt_num_mas = [];
    end    
    
    % for each image
    for i = 1 : length(img_names)

        % open image
        I = imread(fullfile(images_path, img_names{i}));

        % Get the segmentations and the score map for the given image
        [~, ma_score_map, current_scores] = segmentMA(ma_detector, I, double(ma_candidates_data{i}.features), ma_candidates_data{i}.pxs);

        % if there are labels, then plug all the labels into an array of labels
        if (exist('labels_names', 'var') ~= 0)
            % open candidates
            current_ma_candidates = imread(fullfile(ma_candidates_path, ma_candidates_names{i})) > 0;
            % open ground truth labels
            gt_labels = imread(fullfile(labels_path, labels_names{i})) > 0;
            % get current scores and labels for evaluation
            [data_ma_scores, data_ma_labels, gt_num_mas] = get_ma_data_for_evaluation(current_ma_candidates, gt_labels, ma_score_map);

            % Get image ids and concatenate them
            all_image_ids = cat(1, all_image_ids, ones(size(data_ma_labels)) * i);
            % Concatenate scores
            all_scores = cat(1, all_scores, data_ma_scores);
            % Concatenate labels
            all_labels = cat(1, all_labels, data_ma_labels);
            % Concatenate number of ground-truth MAs
            all_gt_num_mas = cat(1, all_gt_num_mas, gt_num_mas);
        end

    end
    
    % if there are labels, plot the FROC curve
    if (~isempty(all_labels))
        [fpi, per_lesion_sensitivity, froc_score] = froc(all_scores, all_labels, all_image_ids, all_gt_num_mas, true);
        box on
        hold on
        my_legends = cat(1, my_legends, {strcat('epoch #', num2str(epoch), '- score=', num2str(froc_score))});
        legend(my_legends);
        drawnow
    end
    
end
    
% replace bars in the name of the training set
k = strfind(dataset_name, filesep);
if (~isempty(k))
    dataset_name(k) = '-';
end

title(strcat('FROC curve per CNN epoch - ', dataset_name));