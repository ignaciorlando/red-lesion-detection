
% CONFIG_ORGANIZE_ROCH_DATA
% -------------------------------------------------------------------------
% This code is called by script_organize_roch_data to organize the
% ROC (Retinopathy Online Challenge) data set in order to be able to 
% process it using our approach.
% -------------------------------------------------------------------------

% Root folder where the ROC images are saved.
% We expect to find two folders inside: ROCtestImages and ROCtraining
% folder as downloaded from: 
% http://webeye.ophth.uiowa.edu/ROC/
root_folder = '';

% Output folder where the processed data set will be saved
output_folder = 'data';

% This value indicates if the ROC data set has to be cropped around the FOV
% or not. It is better to crop the data set as it significantly reduce the
% computational effort during processing, but in case you want to 
% submit results % to the ROC challenge you can avoid this part by setting
% it to false.
perform_cropping = false;

% Set up probability threshold
probability = 0.75;