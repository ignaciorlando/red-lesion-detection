
% SCRIPT_ORGANIZE_MESSIDOR_DATA
% -------------------------------------------------------------------------
% This script is used to organize MESSIDOR data. You must modify
% config_organize_messidor_data before executing this script.
% -------------------------------------------------------------------------

config_organize_messidor_data

% prepare paths from the original data set 
main_messidor_folder = fullfile(root_folder, 'MESSIDOR', 'images');

% prepare paths for the outputs
main_messidor_folder_output = fullfile(output_folder, 'MESSIDOR', 'images');
mkdir(main_messidor_folder_output);

% copying images
fprintf('Copying images...\n');

% iterate on each of the hospital folders to copy all the files
hospital_folders = getOnlyFolders(main_messidor_folder);
for i = 1 : length(hospital_folders)
    
    % get all the subfolders from this hospital
    current_subfolder = fullfile(main_messidor_folder, hospital_folders{i});
    sub_base_folders = getOnlyFolders(current_subfolder);
    
    % for each of the basis
    for j = 1 : length(sub_base_folders)
        
        % get current sub base folder
        current_base = fullfile(current_subfolder, sub_base_folders{j});
        % get all images on current base
        image_names = getMultipleImagesFileNames(current_base);
        % copy each image to the new folder
        for k = 1 : length(image_names)
            % retrieve the first part of the name
            [~, current_image_name, ext] = fileparts(image_names{k}) ;
            if (strcmpi(ext, '.jpg') || strcmpi(ext, '.jpeg'))
                ext = '.png';
            end
            % copy the file, changing the extension to PNG if the image in in
            % JPG format
            if ~strcmp(ext, '.xls')
                copyfile(fullfile(current_base, image_names{k}), fullfile(main_messidor_folder_output, strcat(current_image_name, ext)));
            end
        end
        
    end
    
end


%% now, generate fov masks
root = fullfile(output_folder, 'MESSIDOR');
threshold = 0.15;
GenerateFOVMasks;


%% crop every mask

if perform_cropping

    % cropping training data set
    fprintf('Cropping data set...\n');
    % - path where the images to crop are
    sourcePaths = { ...
        fullfile(output_folder, 'MESSIDOR', 'images'), ...
        fullfile(output_folder, 'MESSIDOR', 'masks'), ...
    };
    % - paths where the images to be cropped will be saved
    outputPaths = { ...
        fullfile(output_folder, 'MESSIDOR', 'images'), ...
        fullfile(output_folder, 'MESSIDOR', 'masks'), ...    
    };
    % - masks to be used to crop the images
    maskPaths = fullfile(output_folder, 'MESSIDOR', 'masks');
    % crop!!
    script_cropFOVSet;
    
end
