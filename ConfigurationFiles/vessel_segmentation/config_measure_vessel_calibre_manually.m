
% CONFIG_MEASURE_VESSEL_CALIBRE_MANUALLY
% -------------------------------------------------------------------------
% This code is called by script_measure_vessel_calibre_manually to set up
% some of the variables.
% -------------------------------------------------------------------------

% Name of the data set to measure
dataset_name = fullfile('DIARETDB1', 'train');
% dataset_name = fullfile('DIARETDB1', 'test');
% dataset_name = fullfile('ROCh', 'train');
% dataset_name = fullfile('ROCh', 'test');
% dataset_name = fullfile('e-ophtha');
% dataset_name = fullfile('MESSIDOR');

% Path where the images are
root = 'C:\_diabetic_retinopathy_testing_software';

% Number of images to measure (5 is fine)
numImages = 5;

% Number of profiles to measure (3 is fine)
numProf = 3;