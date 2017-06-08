
% CONFIG_SEGMENT_RED_LESIONS
% -------------------------------------------------------------------------
% This code is called by script_segment_red_lesions to set up the basic
% parameters for segmenting lesions on a given data set.
% -------------------------------------------------------------------------

% Specify the data set used for training
training_set = fullfile('DIARETDB1', 'train');
%training_set = fullfile('DIARETDB1-ROCh', 'train');

% Specify the data set to be segmented
dataset_name = fullfile('DIARETDB1', 'test');
%dataset_name = 'MESSIDOR';
%dataset_name = 'e-ophtha';
%dataset_name = 'DR2';

% Select the features source
%features_source = 'hand-crafted';
%features_source = 'cnn-from-scratch';
features_source = 'combined';

% Select the classifier (by default, random forests)
classifier = 'random-forests';

% Select type of lesion
type_of_lesion = 'red-lesions';


% Folder where the trained model is saved and the name of the model
trained_model_path = strcat('C:\_dr_tbme\', type_of_lesion, '-detection-model');

    % RF trained on combined or hand-crafted features
    trained_model_name = 'random-forests';
    
    % CNN trained on DIARETDB1 training set
    %trained_model_name = 'softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128';
        
    % CNN trained on DIARETDB1-ROCh training set
    %trained_model_name = 'classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128';

% CNN path
cnn_path = strcat('C:\_dr_tbme\', type_of_lesion, '-detection-model');

    % DIARETDB1 training set
    cnn_filename = fullfile('cnn-from-scratch', 'softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128');  
    
    % DIARETDB1-ROCh training set
    %cnn_filename = fullfile('cnn-from-scratch', 'classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128');


% Root path from the test data (test_data_path contains features,
% test_images_path contains images)
test_data_path = 'C:\_dr_tbme';
test_images_path = 'C:\_dr_tbme';

% Path were results will be saved
results_path = 'C:\_dr_tbme';

% Generate FROC curve
generate_froc_curve = true;