
% SCRIPT_ORGANIZE_EOPHTHA_MA_DATA
% -------------------------------------------------------------------------
% This script is used to organize e-ophtha MA data. You must modify
% config_organize_eophtha_MA_data before executing this script.
% -------------------------------------------------------------------------

config_organize_eophtha_MA_data;

% prepare paths from the original data set 
ma_labels_root = fullfile(root_path, 'e_ophtha_MA', 'Annotation_MA');
healthy_set_root = fullfile(root_path, 'e_ophtha_MA', 'healthy');
ma_set_root = fullfile(root_path, 'e_ophtha_MA', 'MA');

% prepare paths for the outputs
ma_labels_output = fullfile(output_folder, 'e-ophtha', 'red-lesions');
images_output = fullfile(output_folder, 'e-ophtha', 'images');
mkdir(ma_labels_output);
mkdir(images_output);

% copy all the healthy images to a new folder, including a label mask with
% all zeros
healthy_dir_names = getMultipleImagesFileNames(healthy_set_root);
counting_healthy_images = 0;
for i = 1 : length(healthy_dir_names)
    % fetch the folder
    current_folder = fullfile(healthy_set_root, healthy_dir_names{i});
    % get inner images
    image_names = getMultipleImagesFileNames(current_folder);
    % copy each image to the new folder
    for j = 1 : length(image_names)
        counting_healthy_images = counting_healthy_images + 1;
        fprintf('Processing healthy image %d\n', counting_healthy_images);
        
        % read the image
        I = imread(fullfile(current_folder, image_names{j}));
        % retrieve the first part of the name
        [~, current_image_name, ext] = fileparts(image_names{j}) ;
        if (strcmpi(ext, '.jpg') || strcmpi(ext, '.jpeg'))
            ext = '.png';
        end
        % save the image
        imwrite(I, fullfile(images_output, strcat(current_image_name, ext)));
        
        try
            % create an empty mask
            label = false(size(I,1), size(I,2));
            % save the image
            imwrite(label, fullfile(ma_labels_output, strcat(current_image_name, ext)));
        catch exception
        end
    end
    
end

%% now, copy all the other images and their labels

% images
ma_set_names = getMultipleImagesFileNames(ma_set_root);
% labels
ma_labels_names = getMultipleImagesFileNames(ma_labels_root);

% initialize the list of all the sick images
all_sick_images = {};
number_of_mas = [];

counting_sick_images = 0;
for i = 1 : length(ma_set_names)
    % fetch the folder
    current_folder = fullfile(ma_set_root, ma_set_names{i});
    current_folder_label = fullfile(ma_labels_root, ma_set_names{i});
    % get inner images and labels
    sick_images_names = getMultipleImagesFileNames(current_folder);
    sick_label_names = getMultipleImagesFileNames(current_folder_label);
    % initialize the list of MAs
    current_number_of_mas = zeros(size(sick_images_names));
    % copy each image to the new folder
    for j = 1 : length(sick_images_names);
        counting_sick_images = counting_sick_images + 1;
        fprintf('Processing sick image %d\n', counting_sick_images);
        
        % read the image
        I = imread(fullfile(current_folder, sick_images_names{j}));
        % retrieve the first part of the name
        [~, current_image_name, ext] = fileparts(sick_images_names{j}) ;
        if (strcmpi(ext, '.jpg') || strcmpi(ext, '.jpeg'))
            ext = '.png';
        end
        % save the image
        imwrite(I, fullfile(images_output, strcat(current_image_name, ext)));
        
        % copy the labels
        % retrieve the first part of the name
        [~, current_label_name, ext] = fileparts(sick_label_names{j}) ;
        if (strcmpi(ext, '.jpg') || strcmpi(ext, '.jpeg'))
            ext = '.png';
        end
        copyfile(fullfile(current_folder_label, sick_label_names{j}), fullfile(ma_labels_output, strcat(current_label_name, ext)), 'f');
        
        % add images to the list
        all_sick_images = cat(2, all_sick_images, strcat(current_label_name, ext));
        
        % open the labels
        my_ma_binary_mask = imread(fullfile(current_folder_label, sick_label_names{j}));
        % get the number of MAs
        conn_comp = bwconncomp(my_ma_binary_mask);
        current_number_of_mas(j) = conn_comp.NumObjects;
    end
    number_of_mas = cat(2, number_of_mas, current_number_of_mas);
end

%% and also generate labels

% retrieve image filenames
new_images_filenames = getMultipleImagesFileNames(images_output);
% initialize the array of labels
labels.dr = zeros(size(new_images_filenames))';

% for each image
for i = 1 : length(new_images_filenames)
    
    % check if it is an image with MAs
    idx = find(not(cellfun('isempty', strfind(all_sick_images, new_images_filenames{i}))));
    if ~isempty(idx)
        
        % Assign labels following the same criterion than MESSIDOR
        if (number_of_mas(idx) <= 5)
            labels.dr(i) = 1;
        elseif (number_of_mas(idx) <= 15)
            labels.dr(i) = 2;
        else
            labels.dr(i) = 3;
        end
        
    end
    
end 
mkdir(fullfile(output_folder, 'e-ophtha', 'labels'));
save(fullfile(output_folder, 'e-ophtha', 'labels', 'labels.mat'), 'labels');

%%

% now, generate fov masks
root = fullfile(output_folder, 'e-ophtha');
threshold = 0.15;
GenerateFOVMasks;


%% crop every mask

if perform_cropping

    % cropping training data set
    fprintf('Cropping data set...\n');
    % - path where the images to crop are
    sourcePaths = { ...
        fullfile(output_folder, 'e-ophtha','images'), ...
        fullfile(output_folder, 'e-ophtha','red-lesions'), ...
        fullfile(output_folder, 'e-ophtha','masks') ...
    };
    % - paths where the images to be cropped will be saved
    outputPaths = { ...
        fullfile(output_folder, 'e-ophtha','images'), ...
        fullfile(output_folder, 'e-ophtha','red-lesions'), ...
        fullfile(output_folder, 'e-ophtha','masks') ...
    };
    % - masks to be used to crop the images
    maskPaths = fullfile(output_folder, 'e-ophtha','masks');
    % crop!!
    script_cropFOVSet;
    
end