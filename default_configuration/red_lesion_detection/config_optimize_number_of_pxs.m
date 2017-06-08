
% CONFIG_OPTIMIZE_NUMBER_OF_PXS
% -------------------------------------------------------------------------
% This code is called by script_optimize_number_of_pxs to configure
% itself.
% -------------------------------------------------------------------------

% Data set name
%datasetName = fullfile('DIARETDB1', 'train');
datasetName = fullfile('DIARETDB1-ROCh', 'train');

% Path where the data is stored
root_path = 'C:\_diabetic_retinopathy';

% Type of lesion
type_of_lesion = 'red-lesions';

% Output filename
outputfilename = 'removing lesions with less than pxs=';

% Default K and L values
K = 180;
scales = 3:3:30;

% Pxs values to be explored
pxs = [0, 3:10];

