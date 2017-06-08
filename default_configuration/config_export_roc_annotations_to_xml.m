
% Specify the data set segmented
%dataset_name = fullfile('DIARETDB1', 'train');
dataset_name = fullfile('DIARETDB1', 'test');
%dataset_name = 'e-ophtha';

%features_source = 'hand-crafted';
%features_source = 'cnn-transfer';
features_source = 'cnn-from-scratch';
%features_source = 'cnn-fine-tune';

% Classifier
%classifier = 'l1';
%classifier = 'l2';
%classifier = 'k-support';
classifier = 'random-forests';

type_of_lesion = 'ma';
%type_of_lesion = 'hemorrhages';
%type_of_lesion = 'red-lesions';

% Root path from the test data (test_data_path contains features,
% test_images_path contains images)
test_data_path = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\drscreening2016paper\data';