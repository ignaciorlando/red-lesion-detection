
config_display_red_lesions_iteratively;

% Retrieve the data set path
dataset_path = fullfile(root_path, dataset_name);

% Prepare the path of...
% ... images
image_path = fullfile(dataset_path, 'images');
% ... fov masks
fov_masks_path = fullfile(dataset_path, 'masks');
% ... segmentations
red_lesion_segmentation_paths = cell(length(methods_to_compare), 1);
for i = 1 : length(methods_to_compare)
    red_lesion_segmentation_paths{i} = fullfile(dataset_path, 'red-lesions-segmentations', methods_to_compare{i});
end
% ... and ground truth
if exist(fullfile(dataset_path, 'red-lesions'), 'dir')
    ground_truth_labels_path = fullfile(dataset_path, 'red-lesions');
end

% decide the image file extension according to the data set name
switch dataset_name
    case 'MESSIDOR'
        extension = '.tif';
        extension_masks = '*.gif';
    case fullfile('DIARETDB1', 'test')
        extension = '.png';
    case fullfile('e-ophtha')
        extension = '.png';
        extension_masks = '*.png';
end

% Now, lets take all the image names, their ground truth labels and the
% segmentations
allFiles = dir(fullfile(image_path, strcat('*', extension)));
image_filenames = {allFiles.name};
allFiles = dir(fullfile(fov_masks_path, '*.gif'));
fov_masks_filenames = {allFiles.name};
allFiles = dir(fullfile(red_lesion_segmentation_paths{1}, '*.gif'));
red_lesion_names = {allFiles.name};
if exist('ground_truth_labels_path', 'var') ~= 0
    allFiles = dir(fullfile(ground_truth_labels_path, extension_masks));
    ground_truth_labels_names = {allFiles.name};
end

% For each of the images
for i = 1 : length(image_filenames)
    
    disp(i);
    
    % Read the image
    I = imread(fullfile(image_path, image_filenames{i}));
    % Read the mask
    fov_mask = imread(fullfile(fov_masks_path, fov_masks_filenames{i})) > 0;
    % If exist...
    if exist('ground_truth_labels_names', 'var') ~= 0
        gt = imread(fullfile(ground_truth_labels_path, ground_truth_labels_names{i})) > 0;
    end
    
    % If preprocess_image, lets equalize it
    if preprocess_image
        % Preprocess the image
        I = contrastEqualization(I, fov_mask);
    end
    
    % For each method to compare
    for j = 1 : length(methods_to_compare)
        
        % Read the red lesion segmentation
        current_red_lesion_segmentation = imread(fullfile(red_lesion_segmentation_paths{j}, red_lesion_names{i})) > 0;
        
        % If there is a ground truth labelling...
        figure
        if exist('gt','var')==0
            imshowMA(I, current_red_lesion_segmentation, 'circles');
        else
            imshowMA_with_ground_truth(I, gt, current_red_lesion_segmentation);
        end
        title(methods_names{j})
        
    end
    
    % Pause for a while
    k = waitforbuttonpress;
    
    if k==0
        for j = 1 : length(methods_to_compare)
            savefig(fullfile(save_results_path, num2str(length(methods_to_compare)+1-j)));
            saveas(gcf, fullfile(save_results_path, strcat(num2str(length(methods_to_compare)+1-j), '.svg')));
            close
        end
    else
        close all
    end

    
end




