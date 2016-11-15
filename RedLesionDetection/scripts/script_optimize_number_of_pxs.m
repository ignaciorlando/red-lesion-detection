
% CONFIG_OPTIMIZE_NUMBER_OF_PXS
% -------------------------------------------------------------------------
% This code is used to compute FPI and per lesion sensitivity for different
% values of pxs. You have to edit config_optimize_number_of_pxs
% to choose the values you want to explore. 
% -------------------------------------------------------------------------

config_optimize_number_of_pxs;

% prepare root path of data sets
root_path = fullfile(root_path, datasetName);

% get image filenames
img_names = getMultipleImagesFileNames(fullfile(root_path, 'images'));
% get labels filenames
lbl_names = getMultipleImagesFileNames(fullfile(root_path, type_of_lesion));
% get masks filenames
mask_names = getMultipleImagesFileNames(fullfile(root_path, 'masks'));

% initialize an array of per lesion sensitivities
tp_lesions = zeros(length(pxs), length(img_names));
% and false positives per images
fps_candidates = zeros(length(pxs), length(img_names));
% initialize an array of number of lesions
n_lesions = zeros(size(img_names));

for ii = 1 : length(pxs);

    px = pxs(ii);
    fprintf('\nTrying with px=%d\n', px);
    
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

        % get lesion candidates
        fprintf('Analyzing image %i/%i (n = %d)\n', i, length(img_names), n_lesions(i));
        [ candidates ] = getLesionCandidates(I, fov_mask, scales, K, px);

        % find the intersection between candidates and gt_labels
        true_intersection = logical(candidates .* gt_label);
        % now count the number of true positives
        tp_lesions(ii, i) = length(unique(ground_truth_labeled(true_intersection)));
        fprintf('Found %d/%d.', tp_lesions(ii, i), n_lesions(i));
        % and false positives
        [candidates_labeled, n_candidates] = bwlabel(candidates);
        fps_candidates(ii, i) = n_candidates - length(unique(candidates_labeled(true_intersection)));

        fprintf('\n');
    end

    total_lesions = sum(n_lesions);
    per_lesion_sensitivity = sum(tp_lesions, 2) / total_lesions;
    fpi = mean(fps_candidates, 2);

    save(strcat(outputfilename, num2str(px)), 'fpi', 'per_lesion_sensitivity', 'total_lesions', 'px');
    
end

figure
plot(pxs(2:end), per_lesion_sensitivity(2:end), '-o', 'LineWidth', 1.5);
grid on
xlim([pxs(2) pxs(end)])
ylim([0.8 1])
hold on
plot(pxs, ones(size(pxs)) * per_lesion_sensitivity(1), '--', 'LineWidth', 1.5);
xlabel('Number of pixels')
ylabel('Per lesion sensitivity')
legend('Removing small candidates with px pixels','Without removing small candidates', 'Location','southeast');

figure
plot(pxs(2:end), fpi(2:end), '-o', 'LineWidth', 1.5)
grid on
xlim([pxs(2) pxs(end)])
hold on
plot(pxs, ones(size(pxs)) * fpi(1), '--', 'LineWidth', 1.5);
xlabel('Number of pixels')
ylabel('FPI')
legend('Removing small candidates with px pixels','Without removing small candidates', 'Location','southeast');