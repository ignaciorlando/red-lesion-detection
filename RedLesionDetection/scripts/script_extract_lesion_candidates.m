
% SCRIPT_EXTRACT_LESION_CANDIDATES
% -------------------------------------------------------------------------
% This code is used for extracting red lesion candidates from a given data
% set. You must modify config_extract_lesion_candidates first.
% -------------------------------------------------------------------------

config_extract_lesion_candidates;

% prepare root path of data sets
root_path = fullfile(root_path, datasetName);
% prepare dataset path
dataset_path = fullfile(data_path, datasetName);
% prepare output path
output_path = fullfile(dataset_path, strcat(type_of_lesion, '_candidates'));
if (exist(output_path, 'dir') == 0)
    mkdir(output_path);
end

% get image filenames
img_names = getMultipleImagesFileNames(fullfile(root_path, 'images'));
% get masks filenames
mask_names = getMultipleImagesFileNames(fullfile(root_path, 'masks'));

% For each of the images
for i = 1 : length(img_names)

    fprintf('Extracting candidates from image %i/%i\n', i, length(img_names));
    
    % open i-th image and its corresponding FOV mask, OD and vessel
    % segmentation
    I = imread(fullfile(root_path, 'images', img_names{i}));
    mask = imread(fullfile(root_path, 'masks', mask_names{i}));
    
    % get candidates
    [ current_candidates ] = getLesionCandidates(I, mask, L0, step, L, K, px);
    
    % get only the image name
    [~, filename, extension] = fileparts(img_names{i});
    if (~strcmp(extension, '.gif'))
        filename = strcat(filename, '.gif');
    end
    
    % save the image
    imwrite(current_candidates, fullfile(output_path, strcat(filename)));

end