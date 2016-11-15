clear
clc

config_optimize_candidates_detection;

% prepare root path of data sets
root_path = fullfile(root_path, datasetName);
% prepare dataset path
dataset_path = fullfile(segm_path, datasetName);
% prepare output path
output_path = fullfile(dataset_path, 'ma_candidates');
if (exist(output_path, 'dir') == 0)
    mkdir(output_path);
end

% get image filenames
img_names = getMultipleImagesFileNames(fullfile(root_path, 'images'));
% get labels filenames
lbl_names = getMultipleImagesFileNames(fullfile(root_path, type_of_lesion));
% get masks filenames
mask_names = getMultipleImagesFileNames(fullfile(root_path, 'masks'));
% get OD segmentations filenames
od_names = getMultipleImagesFileNames(fullfile(dataset_path, 'manual-annotations', 'od-masks'));
% get vessel segmentation nales
segm_names = getMultipleImagesFileNames(fullfile(dataset_path, 'segmentations'));

% initialize an array of per lesion sensitivities
tp_lesions = zeros(length(scale_ranges), length(img_names));
% and false positives per images
fps_candidates = zeros(length(scale_ranges), length(img_names));
% initialize an array of number of lesions
n_lesions = zeros(size(img_names));

for ii = 1 : length(Ks);

    K = Ks(ii);
    fprintf('\nTrying with K=%d\n', K);
    
    % for each image on the training set
    for i = 1 : length(img_names)

        % ---------------------------------------------------------------------
        % PREPARE DATA
        % ---------------------------------------------------------------------

        % open i-th image and its corresponding FOV mask, OD and vessel
        % segmentation
        I = imread(fullfile(root_path, 'images', img_names{i}));
        fov_mask = imread(fullfile(root_path, 'masks', mask_names{i})) > 0;
        % also open the ground truth labeling
        gt_label = imread(fullfile(root_path, type_of_lesion, lbl_names{i})) > 0;

        % transform image to doubles
        [I] = contrastEqualization(I, fov_mask);
        I = im2double(I);
        % if given image is in color, get only the green band
        if size(I,3)>1
            I = I(:,:,2);
        end

        % ---------------------------------------------------------------------
        % TRY DIFFERENT SCALES AND EVALUATE PER LESION SENSITIVITY
        % ---------------------------------------------------------------------

        % and label each individual region with a name
        [ground_truth_labeled, n_lesions(i)] = bwlabel(gt_label);

        fprintf('Analyzing image %i/%i (n = %d)\n', i, length(img_names), n_lesions(i));

        % for each scale
        for l_idx = 1 : length(scale_ranges)

            % retrieve current scale
            l = scale_ranges(l_idx);

            % retrieve initial guesses for this scale
            [initial_guess] = getInitialGuessesOfLesions(I, fov_mask, l, K);
            %[initial_guess] = getInitialGuessesOfLesions(I, fov_mask, od_mask, vessel_segm, l);

            % if there are previous candidates...
            if (exist('previous_candidates','var')~=0)            
                % candidates will be the maximum across the previous scales and
                % the new ones
                candidates = max(cat(3, previous_candidates, initial_guess), [], 3) > 0;
            else
                % candidates will be this first initial guess
                candidates = initial_guess;
            end

            true_intersection = logical(candidates .* gt_label);

            % now count the number of true positives
            tp_lesions(l_idx, i) = length(unique(ground_truth_labeled(true_intersection)));
            fprintf('%d.', tp_lesions(l_idx, i));
            % and false positives
            [candidates_labeled, n_candidates] = bwlabel(candidates);
            fps_candidates(l_idx, i) = n_candidates - length(unique(candidates_labeled(true_intersection)));

            % current candidates will be the previous candidates
            previous_candidates = candidates;

        end
        fprintf('\n');
        clear previous_candidates
    end

    total_lesions = sum(n_lesions);
    per_lesion_sensitivity = sum(tp_lesions, 2) / total_lesions;
    fpi = mean(fps_candidates, 2);

    save(strcat(outputfilename, num2str(K)), 'fpi', 'per_lesion_sensitivity', 'total_lesions', 'scale_ranges');
    
end