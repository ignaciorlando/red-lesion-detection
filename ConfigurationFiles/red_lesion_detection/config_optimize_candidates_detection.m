
% CONFIG_OPTIMIZE_CANDIDATES_DETECTION
% -------------------------------------------------------------------------
% This code is called by script_optimize_candidates_detection to configure
% itself.
% -------------------------------------------------------------------------

% Data set name
%datasetName = fullfile('DIARETDB1', 'train');
datasetName = fullfile('DIARETDB1-ROCh', 'train');

% Path where the data is stored
root_path = 'C:\_diabetic_retinopathy';

% Type of lesion to be segmented
type_of_lesion = 'red-lesions';

% Scale ranges to be used (L in the paper)
scale_ranges = 3:3:30;
% K values to be tested
Ks = 60:20:200;

% Output filename
outputfilename = 'trying k=';