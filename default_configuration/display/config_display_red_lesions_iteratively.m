
% Assign a data set name
%dataset_name = 'MESSIDOR';
dataset_name = fullfile('DIARETDB1', 'test');
%dataset_name = 'e-ophtha';

% Assign the root path
root_path = 'C:\_dr_tbme';

% Make a list of methods
methods_to_compare = {'cnn-from-scratch/softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128', ...
                      'hand-crafted/random-forests', ...
                      'combined/random-forests/cnn-from-scratch/softmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128'};
thresholds = [0.9989, ...
              0.6450, ...
              0.6444];
                  
% methods_to_compare = {'cnn-from-scratch/classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128', ...
%                       'hand-crafted/random-forests', ...
%                       'combined/random-forests/cnn-from-scratch/classbalancingsoftmax-lr=0.05-ceps=0.0001-lreps=0.01-wd=0.005-batch=100-N=10-dp=0.01-fc=128'};

methods_names = {'CNN probabilities', ...
                 'RF trained with hand crafted features', ...
                 'RF trained with CNN and hand crafted features'};
             
             

% Preprocess the image
preprocess_image = true;

% Folder to save results
save_results_path = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\redlesions2017paper\paper\qualitative';