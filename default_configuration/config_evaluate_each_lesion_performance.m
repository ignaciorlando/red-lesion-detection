
% CONFIG_EVALUATE_EACH_LESION_PERFORMANCE
% -------------------------------------------------------------------------
% This code is called by script_evaluate_each_lesion_performance 
% to set up the basic parameters for plotting a FROC curve per each of the
% lesions.
% -------------------------------------------------------------------------

% Specify the data set used for training
training_set = fullfile('DIARETDB1', 'train');

% Specify the data set to be segmented
dataset_name = fullfile('DIARETDB1', 'test');

% Type of lesion to evaluate
lesion_to_evaluate = 'ma';
%lesion_to_evaluate = 'hemorrhages';

% Type of lesion to remove
lesion_to_remove = 'hemorrhages';
%lesion_to_remove = 'ma';

% Segmented lesion
type_of_lesion_segmented = 'red-lesions';



% Folder where the trained model is saved and the name of the model
trained_model_path = strcat('C:\_dr_tbme\', type_of_lesion_segmented, '-detection-model');

% List of score maps paths
score_maps_paths = ...
    {fullfile('combined', 'random-forests', 'cnn-from-scratch', 'softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128'), ...
     fullfile('hand-crafted', 'random-forests'), ...
     fullfile('cnn-from-scratch', 'softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128')};


% Root path from the test data (test_data_path contains features,
% test_images_path contains images)
test_data_path = 'C:\_dr_tbme';
test_images_path = 'C:\_dr_tbme';

% Path were results will be saved
results_path = 'C:\_dr_tbme';

