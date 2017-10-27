
% SCRIPT_GET_RED_LESION_DETECTION_TRAINING_SET
% -------------------------------------------------------------------------
% This code is used to prepare the patches that we need for training the
% CNN from scratch. You have to modify 
% config_get_red_lesion_detection_training_set first.
% -------------------------------------------------------------------------

config_get_red_lesion_detection_training_set;

% Announce the name of the data set
fprintf(strcat('Dataset: ', dataset_name, '\n'));

% prepare image and ground truth paths
image_path = fullfile(root_path, dataset_name, 'images');
fov_masks_path = fullfile(root_path, dataset_name, 'masks');
labels_path = fullfile(root_path, dataset_name, type_of_lesion);
% prepare data path and MA candidate path 
candidate_path = fullfile(data_path, dataset_name, strcat(type_of_lesion, '_candidates'));
red_lesion_data_path = fullfile(data_path, dataset_name, strcat(type_of_lesion, '_candidates_data'));   

% Extract patches for each of the red lesion candidates
original_imdb = get_red_lesion_data_to_classify(dataset_name, ...           % data set name
                                                image_path, ...             % image path
                                                fov_masks_path, ...         % FOV mask path
                                                labels_path, ...            % labels path
                                                candidate_path, ...         % candidates path
                                                red_lesion_data_path, ...   % path to save/load the data
                                                'cnn-from-scratch', ...     % type of feature
                                                type_of_lesion, ...         % type of lesion
                                                true, ...                   % is training?
                                                '');                        % cnn filename

% Perform data augmentation
[imdb] = augment_dataset(original_imdb, augmentation_angles);

% Save the huuuuuuge matrix on a .MAT file
mkdir(red_lesion_data_path)
save(fullfile(red_lesion_data_path, strcat('imdb-red-lesions-windows-', type_of_lesion, '-augmented.mat')), 'imdb', '-v7.3');