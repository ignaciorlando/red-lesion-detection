
% CONFIG_SEGMENT_VESSELS
% -------------------------------------------------------------------------
% This code is called by script_segment_vessels to set up the segmentation
% parameters.
% -------------------------------------------------------------------------

% datasets to segment
dataset_names = {...
%     'e-ophtha', ...
%     fullfile('DIARETDB1', 'train'), ...
%     fullfile('DIARETDB1', 'test'), ...
%     fullfile('ROCh', 'train'), ...
%     fullfile('ROCh', 'test'), ...
    'MESSIDOR', ...
};

scale_values = [ ...
%     0.867549669, ... % e-optha
%     0.740112994, ... % DIARETDB1 training set
%     0.740112994, ... % DIARETDB1 test set
%     1.073770492, ... % ROCh training set
%     0.963235294, ... % ROCh test set
    0.81875, ...     % MESSIDOR
];


% folder where images, masks and stuff are stored
image_folder = 'C:\_diabetic_retinopathy';

% folder where vessel segmentations will be saved
output_segmentations_folder = 'C:\_diabetic_retinopathy';

% The segmentation model has to be located in this folder
modelLocation = 'C:\_diabetic_retinopathy\segmentation-model';

