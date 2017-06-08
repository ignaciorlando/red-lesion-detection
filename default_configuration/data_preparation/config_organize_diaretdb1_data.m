
% CONFIG_ORGANIZE_DIARETDB1_DATA
% -------------------------------------------------------------------------
% This code is called by script_organize_diaretdb1_data to organize the
% DIARETDB1 data set in order to be able to process it using our approach.
% -------------------------------------------------------------------------

% Root folder where the DIARETDB1 images are saved.
% We expect to find a diaretdb1_v_1_1 folder as downloaded from: 
% http://www.it.lut.fi/project/imageret/diaretdb1/
root_folder = 'C:\Users\USUARIO\Documents\RetinalImageDatasets\DIARETDB1';

% Output folder where the processed data set will be saved
output_folder = 'C:\_diabetic_retinopathy_testing_software';

% Probability threshold used for MA and HE binary label generation. By
% default, red lesion folder will be generated using a 0.25 level of
% agreement threshold.
probability_threshold = 0.5;
