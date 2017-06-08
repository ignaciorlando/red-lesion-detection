
% CONFIG_ORGANIZE_MESSIDOR_2_DATA
% -------------------------------------------------------------------------
% This script is called by script_organize_messidor_2_data to set up the
% corresponding parameters to organize MESSIDOR-2 data.
% -------------------------------------------------------------------------

% Folder where MESSIDOR-2 data set is. We assume that there is a folder
% MESSIDOR-2/IMAGES inside this root folder.
root_folder = 'C:\Users\USUARIO\Documents\RetinalImageDatasets';

% Output folder where files will be saved
output_folder = 'C:\_dr_tbme';

% We always set this in true to avoid computing outside the FOV
perform_cropping = true;