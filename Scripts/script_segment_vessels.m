
% SCRIPT_SEGMENT_VESSELS
% -------------------------------------------------------------------------
% This code is used for segmenting blood vessels in fundus images. It is
% based on our TBME paper (Orlando et al., 2016: A Discriminatively Trained
% Fully Connected Conditional Random Field Model for Blood Vessel
% Segmentation in Fundus Images). You have to edit config_segment_vessels
% before running this code.
% -------------------------------------------------------------------------

config_segment_vessels

% for each data set
for d = 1 : length(dataset_names)
    
    % get current data set name and scale factor
    current_dataset = dataset_names{d};
    %current_scale_factor = scale_values(d);
    
    % analyzing data set
    fprintf('Processing data set %s\n', current_dataset);
    
    % prepare current folder for image data
    current_image_data_folder = fullfile(image_folder, current_dataset);
    % prepare current folder for outputs
    current_output_data_folder = fullfile(output_segmentations_folder, current_dataset, 'segmentations');
    
    % copy all images to a new folder
    if exist(fullfile(current_image_data_folder, '_aux'), 'dir')==0
        standardized_size_dataset_folder = fullfile(current_image_data_folder, '_aux');
        mkdir(standardized_size_dataset_folder);
        fprintf('Copying all images\n');
        copyfile(fullfile(current_image_data_folder, 'images'), fullfile(standardized_size_dataset_folder, 'images'), 'f');
        fprintf('Copying all masks\n');
        copyfile(fullfile(current_image_data_folder, 'masks'), fullfile(standardized_size_dataset_folder, 'masks'), 'f');
    
        % retrieve minimum image size
        fprintf('Retrieving smallest image size\n');
        standardized_size_images_folder = fullfile(standardized_size_dataset_folder, 'images');
        standardized_size_masks_folder = fullfile(standardized_size_dataset_folder, 'masks');
        [min_x, image_names_per_size] = getMinimumImageSize(standardized_size_images_folder);
        fprintf('-- Smallest size is %i\n', min_x);
    
        % standardize image sizes
        fprintf('Standardizing images\n');
        standardizeDatasetSize(standardized_size_images_folder, standardized_size_masks_folder, min_x);

    end
    
    % Measure vessel calibre
    [calibers] = measure_vessel_calibre(fullfile(image_folder, current_dataset, '_aux'), 5, 3);
    % Take the average and estimate scale factor
    scale_to_downsample = vessel_of_interest / mean(mean(calibers,2));
    
    % Segment!!
    fprintf('Segmenting images\n');
    datasets_names = {fullfile(current_dataset, '_aux')};   
    rootDatasets = image_folder;
    resultsPath = fullfile(output_segmentations_folder, dataset_names{d}, 'segmentations');
    script_evaluate_existing_model;
    
    % Copy results to a new folder
    copyfile(config.resultsPath, fullfile(output_segmentations_folder, current_dataset, 'segmentations'), 'f');
    
    % Delete all auxiliar folder
    try rmdir(config.resultsPath,'s'); catch end
    try rmdir(config.test_data_path,'s'); catch end
    
end