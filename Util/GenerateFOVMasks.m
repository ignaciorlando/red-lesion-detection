
% GENERATEFOVMASKS
% -------------------------------------------------------------------------
% This script is used to generate FOV masks for a given data set. It
% requires to initialize the following variables:
%   root: data set root path
%   threshold: value used to threshold the Luminosity plane of the CIELab
%              version.
% -------------------------------------------------------------------------

% Assign the folder names
folder = fullfile(root, 'images');
folder_masks = fullfile(root, 'masks');
if (exist(folder_masks, 'dir') == 0)
    mkdir(folder_masks)
end

% Get filenames
file_names = getMultipleImagesFileNames(folder);

% For each image
for i = 1 : length(file_names)

    fprintf('Processing image %d/%d\n', i, length(file_names));
    
    % Open the image
    I = imread(fullfile(folder, file_names{i}));
    % Get the image FOV mask
    mask = get_fov_mask(I, threshold);
    
    % Save the mask
    imwrite(mask, fullfile(folder_masks, strcat(strtok(file_names{i}, '.'), '_mask', '.gif')));
    
end