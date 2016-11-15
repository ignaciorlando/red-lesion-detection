
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
    % Get each color band
    if (size(I,3)>1)
        R = I(:,:,1);
        G = I(:,:,2);
        B = I(:,:,3);
    else
        R = I;
        G = I;
        B = I;
    end

    % Get the CIELab color representation
    [L,a,b] = RGB2Lab(R,G,B);
    L = L./100;
    
    % Threshold it
    mask = logical((1- (L < threshold)) > 0);
    
    % If the resulting mask has only ones, then sum up the RGB bands and
    % threshold it
    if length(unique(mask(:)))==1
        mask = sum(I, 3) > 150;
    end
    
    % Fill holes and apply median filter
    mask = imfill(mask,'holes');
    mask = medfilt2(mask, [5 5]);
    
    % Get connected components
    CC = bwconncomp(mask);
    
    % The largest connected component is the mask
    componentsLength = cellfun(@length, CC.PixelIdxList);
    [~, indexes] = sort(componentsLength, 'descend');
    mask = bwareaopen(mask,componentsLength(indexes(1))-1);
    
    % Save the mask
    imwrite(mask, fullfile(folder_masks, strcat(strtok(file_names{i}, '.'), '_mask', '.gif')));
    
end