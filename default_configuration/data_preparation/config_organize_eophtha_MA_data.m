
% CONFIG_ORGANIZE_EOPHTHA_MA_DATA
% -------------------------------------------------------------------------
% This code is called by script_organize_eophtha_MA_data to organize the
% e-ophtha MA data set in order to be able to process it using our approach.
% -------------------------------------------------------------------------

% Root folder where the e-ophtha MA images are saved.
% We expect to find a e_optha_MA folder as downloaded from: 
% http://www.adcis.net/en/Download-Third-Party/E-Ophtha.html
root_path = '';

% Output folder where the processed data set will be saved
output_folder = 'data/e-ophtha';

perform_cropping = true;