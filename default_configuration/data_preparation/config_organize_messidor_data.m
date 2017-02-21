
% CONFIG_ORGANIZE_MESSIDOR_DATA
% -------------------------------------------------------------------------
% This script is called by script_organize_messidor_data to set up the
% corresponding parameters to organize MESSIDOR data.
% -------------------------------------------------------------------------

% Folder where MESSIDOR data set is. We assume that there is a folder
% MESSIDOR/images inside this root folder, with the 3 folders from each
% hospital inside.
root_folder = '';

% Output folder where files will be saved
output_folder = 'data';

% We always set this in true to avoid computing outside the FOV
perform_cropping = true;