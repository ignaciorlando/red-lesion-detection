
% CONFIG_CROPFOVSET
% -------------------------------------------------------------------------
% This script is called by setup_config_cropFOVSet to configure variables.
% -------------------------------------------------------------------------

% Uncomment the data set you want to crop.
% We provide names for all the data sets used in our experiments. If you
% want to use your own set, set dataset_filename with a string representing
% your data set.

%dataset_filename = fullfile('DIARETDB1-ROCh','train');
%dataset_filename = fullfile('DIARETDB1','train');
%dataset_filename = fullfile('DIARETDB1','test');
%dataset_filename = 'e-ophtha';
dataset_filename = 'MESSIDOR';


% Setup paths where the images to be cropped are stored
sourcePaths = { ...
    fullfile('data', dataset_filename, 'images') ...
    fullfile('data', dataset_filename, 'labels') ...
    fullfile('data', dataset_filename, 'masks') ...    
};
% Setup paths where the images to be cropped will be saved
outputPaths = { ... 
    fullfile('data', dataset_filename, 'images') ...
    fullfile('data', dataset_filename, 'labels') ...
    fullfile('data', dataset_filename, 'masks') ...        
};
% Path with the masks to be used to crop the images
maskPaths = fullfile('data', dataset_filename, 'masks');

