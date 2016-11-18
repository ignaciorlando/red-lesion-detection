
% CONFIG_TRAIN_LESION_CLASSIFIER
% -------------------------------------------------------------------------
% This code is called by script_train_lesion_classifier to set up the basic
% parameters for training a red lesion classifier.
% -------------------------------------------------------------------------

% Training set
dataset_name = fullfile('DIARETDB1', 'train');
%dataset_name = fullfile('DIARETDB1-ROCh', 'train');

% Path where images are saved
root_path = '_diabetic_retinopathy_testing_software';

% Path where data is saved
data_path = '_diabetic_retinopathy_testing_software';

% Show windows in images?
show_windows_in_images = false;

% Select the features source
features_source = 'hand-crafted';
%features_source = 'cnn-transfer';
%features_source = 'combined';

% Select the classifier (in Orlando et al., 2017 we use random forests'
%classifier = 'l1';
%classifier = 'l2';
%classifier = 'k-support';
classifier = 'random-forests';

% Type of lesion
type_of_lesion = 'red-lesions';

% CNN filename
% CNN trained on DIARETDB1 training set for red lesion detection
cnn_filename = fullfile('cnn-from-scratch', 'softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.05-fc=128');
% % CNN trained on DIARETDB1-ROC training set for small red lesion detection
% cnn_filename = fullfile('cnn-from-scratch', 'classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128');