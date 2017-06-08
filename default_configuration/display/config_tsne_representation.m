
features = 'all';
% features = 'hand-crafted';
% features = 'cnn';

% Always include this, we need the CNN to add the average image to the
% patches
cnn_filename = 'C:\_dr_tbme\red-lesions-detection-model\DIARETDB1_train\cnn-from-scratch\softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128.mat';

% Load the hand crafted features
imdb_hand_crafted_filename = 'C:\_dr_tbme\DIARETDB1\test\red-lesions_candidates_data\imdb-hand-crafted-red-lesions.mat';
% Load the CNN features
imdb_cnn_filename = 'C:\_dr_tbme\DIARETDB1\test\red-lesions_candidates_data\imdb-cnn-features-softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128.mat-red-lesions.mat';

% Load the windows
windows_filenames = 'C:\_dr_tbme\DIARETDB1\test\red-lesions_candidates_data\imdb-red-lesions-windows-red-lesions.mat';