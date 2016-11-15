
%script_segment_vessels

config_segment_vessels


% for each data set
for d = 1 : length(dataset_names)
    
    % get current data set name and scale factor
    current_dataset = dataset_names{d};
    current_scale_factor = scale_values(d);
    
    % analyzing data set
    fprintf('Processing data set %s\n', current_dataset);
    
    % prepare current folder for image data
    current_image_data_folder = fullfile(image_folder, current_dataset);
    % prepare current folder for outputs
    current_output_data_folder = fullfile(output_segmentations_folder, current_dataset, 'segmentations');
    
    % copy all images to a new folder
    fprintf('Copy all images\n');
    standardized_size_dataset_folder = fullfile(current_image_data_folder, '_aux');
    mkdir(standardized_size_dataset_folder);
    copyfile(current_image_data_folder, standardized_size_dataset_folder, 'f');
    
    % retrieve minimum image size
    fprintf('Retrieving smallest image size\n');
    standardized_size_images_folder = fullfile(standardized_size_dataset_folder, 'images');
    standardized_size_masks_folder = fullfile(standardized_size_dataset_folder, 'masks');
    [min_x, image_names_per_size] = getMinimumImageSize(standardized_size_images_folder);
    fprintf('-- Smallest size is %i\n', min_x);
    
    % standardize image sizes
    fprintf('Standardizing images\n');
    standardizeDatasetSize(standardized_size_images_folder, standardized_size_masks_folder, min_x);
    
    % Segment!!
    fprintf('Segmenting images\n');
    datasets_names = {fullfile(current_dataset, '_aux')};   
    scale_to_downsample = current_scale_factor;
    rootDatasets = 'C:\_diabetic_retinopathy';
    rootResults = 'C:\_diabetic_retinopathy\segmentations';
    script_evaluate_existing_model;
    
    % Copy results to a new folder
    copyfile(config.resultsPath, fullfile(output_segmentations_folder, current_dataset, 'segmentations'), 'f');
    
    % Delete all auxiliar folder
    try rmdir(config.resultsPath,'s'); catch end
    try rmdir(config.test_data_path,'s'); catch end
    
end