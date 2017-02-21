
% CONFIG_EVALUATE_SCREENING_PERFORMANCE
% -------------------------------------------------------------------------
% This code is called by script_evaluate_screening_performance
% and is used to set up the parameters that are needed to evaluate a method
% for screening.
% -------------------------------------------------------------------------

% type of evaluation
type_of_evaluation = 'screening';
%type_of_evaluation = 'need-to-referral';

% folder where the scores are saved
root_scores_folder = 'data';

% Specify the data set to be segmented
dataset_name = 'MESSIDOR';
%dataset_name = 'e-ophtha';

% Specify the data set used for training
training_set = 'DIARETDB1_train';
%training_set = fullfile('DIARETDB1-ROCh', 'train');


% Specify feature source
%features_source = 'hand-crafted';
%features_source = 'cnn-from-scratch';
features_source = 'combined';

% Specify type of lesions
%type_of_lesion = 'ma';
%type_of_lesion = 'hemorrhages';
type_of_lesion = 'red-lesions';

% folder where the labels are stored
labels_file = fullfile('data', dataset_name, 'labels', 'labels.mat');

% Folder where the trained model is saved and the name of the model
trained_model_path = strcat('data', type_of_lesion, '-detection-model');
trained_model_name = 'random-forests';
%trained_model_name = 'softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.05-fc=128';
%trained_model_name = 'classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128';

%cnn_filename = 'cnn-from-scratch/softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.05-fc=128';
cnn_filename = 'cnn-from-scratch/classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128';

% Path were results will be saved
results_path = 'data/results';

