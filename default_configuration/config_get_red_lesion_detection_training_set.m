
% CONFIG_GET_RED_LESION_DETECTION_TRAINING_SET
% -------------------------------------------------------------------------
% This code is called by script_get_red_lesion_detection_cnn_training_set
% and is used to extract patched from each red lesion candidate.
% -------------------------------------------------------------------------

% Data set that is going to be used to extract the training set
dataset_name = fullfile('DIARETDB1', 'train');
%dataset_name = fullfile('DIARETDB1-ROCh', 'train');

% Path where the data set is saved
root_path = 'data';
% Path where the training set will be saved
data_path = 'data';

% A boolean flag indicating if the patch extraction method has to output
% also figures showing where the patches are located on each image.
show_windows_in_images = false;

% Type of lesion to extract
type_of_lesion = 'red-lesions';

% Augmentation angles
augmentation_angles = [0 90 180 270];