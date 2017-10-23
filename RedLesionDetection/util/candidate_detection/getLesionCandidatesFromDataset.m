
function getLesionCandidatesFromDataset(image_path, masks_path, output_path, L0, step, L, K, px)

% get image filenames
img_names = getMultipleImagesFileNames(image_path);
% get masks filenames
mask_names = getMultipleImagesFileNames(masks_path);

% For each of the images
for i = 1 : length(img_names)

    fprintf('Extracting candidates from image %i/%i\n', i, length(img_names));
    
    % open i-th image and its corresponding FOV mask, OD and vessel
    % segmentation
    I = imread(fullfile(image_path, img_names{i}));
    mask = imread(fullfile(masks_path, mask_names{i}));
    
    % get candidates
    tic
    [ current_candidates ] = getLesionCandidates(I, mask, L0, step, L, K, px);
    toc
    
    % get only the image name
    [~, filename, extension] = fileparts(img_names{i});
    if (~strcmp(extension, '.gif'))
        filename = strcat(filename, '.gif');
    end
    
    % save the image
    imwrite(current_candidates, fullfile(output_path, strcat(filename)));

end