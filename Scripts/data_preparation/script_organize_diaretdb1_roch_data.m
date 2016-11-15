
% SCRIPT_ORGANIZE_DIARETDB1_ROCH_DATA
% -------------------------------------------------------------------------
% This script is used to organize DIARETDB1-ROCh data. You must modify
% config_organize_diaretdb1_roch_data before executing this script. If
% DIARETDB1 and ROCh were not organized before, this script is going to
% organize them for you.
% -------------------------------------------------------------------------

config_organize_diaretdb1_roch_data

%% preparing input and output folders

% ROCh training set
roch_training_set_input_folders = fullfile(root_folder, 'ROCh', 'train');
% DIARETDB1 training set
diaretdb1_training_set_input_folders = fullfile(root_folder, 'DIARETDB1', 'train');

% output folders
output_folder = fullfile(root_folder, 'DIARETDB1-ROCh', 'train');
mkdir(output_folder);
mkdir(fullfile(output_folder, 'images'));
mkdir(fullfile(output_folder, 'red-lesions'));
mkdir(fullfile(output_folder, 'masks'));

%% copy all ROCh training data. if it is not available, generate it

% check if ROCh was already organized
if exist(roch_training_set_input_folders, 'dir')==0
    script_organize_roch_data;
end

% retrieve image names
roch_training_file_names = dir(fullfile(roch_training_set_input_folders, 'images', '*.png'));
roch_training_file_names = {roch_training_file_names.name};

% now, copy all the data to the output folder
for i = 1 : length(roch_training_file_names)
    % copy images
    copyfile(fullfile(roch_training_set_input_folders, 'images', roch_training_file_names{i}), ...
             fullfile(output_folder, 'images', roch_training_file_names{i}), 'f');
    % copy MA annotations
    copyfile(fullfile(roch_training_set_input_folders, 'ma', roch_training_file_names{i}), ...
             fullfile(output_folder, 'red-lesions', roch_training_file_names{i}), 'f');
end

% retrieve mask names
roch_training_masks_names = dir(fullfile(roch_training_set_input_folders, 'masks', '*.gif'));
roch_training_masks_names = {roch_training_masks_names.name};

% now, copy all the data to the output folder
for i = 1 : length(roch_training_masks_names)
    % copy masks
    copyfile(fullfile(roch_training_set_input_folders, 'masks', roch_training_masks_names{i}), ...
             fullfile(output_folder, 'masks', roch_training_masks_names{i}), 'f');
end


%% copy all DIARETDB1 training data. if it is not available, generate it

% check if DIARETDB1 was already organized
if exist(diaretdb1_training_set_input_folders, 'dir')==0
    script_organize_diaretdb1_data;
end

% retrieve image names
diaretdb1_training_file_names = dir(fullfile(diaretdb1_training_set_input_folders, 'images', '*.png'));
diaretdb1_training_file_names = {diaretdb1_training_file_names.name};

% now, copy all the data to the output folder
for i = 1 : length(diaretdb1_training_file_names)
    % copy images
    copyfile(fullfile(diaretdb1_training_set_input_folders, 'images', diaretdb1_training_file_names{i}), ...
             fullfile(output_folder, 'images', diaretdb1_training_file_names{i}), 'f');
    % copy MA annotations
    copyfile(fullfile(diaretdb1_training_set_input_folders, 'ma', diaretdb1_training_file_names{i}), ...
             fullfile(output_folder, 'red-lesions', diaretdb1_training_file_names{i}), 'f');
end

% retrieve mask names
diaretdb1_training_masks_names = dir(fullfile(diaretdb1_training_set_input_folders, 'masks', '*.gif'));
diaretdb1_training_masks_names = {diaretdb1_training_masks_names.name};

% now, copy all the data to the output folder
for i = 1 : length(diaretdb1_training_masks_names)
    % copy masks
    copyfile(fullfile(diaretdb1_training_set_input_folders, 'masks', diaretdb1_training_masks_names{i}), ...
             fullfile(output_folder, 'masks', diaretdb1_training_masks_names{i}), 'f');
end