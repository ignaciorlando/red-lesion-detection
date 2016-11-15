
function [] = standardizeDatasetSize(images_folder, masks_folder, min_x)

    % get image filenames
    image_names = getMultipleImagesFileNames(images_folder);
    mask_names = getMultipleImagesFileNames(masks_folder);

    % for each of the images    
    for i = 1 : length(image_names)

        % open the image
        I = imread(fullfile(images_folder, image_names{i}));
        % open the mask
        mask = imread(fullfile(masks_folder, mask_names{i}));
        % retrieve the mask
        mask = mask(:,:,1) > 0;
        % estimate the scale factor
        factor = min_x / size(I,2);
        % downscale the image
        I = imresize(I, factor);
        % downscale the mask
        mask = imresize(mask, factor);
        % save the new image and the mask
        imwrite(I, fullfile(images_folder, image_names{i}));
        imwrite(mask, fullfile(masks_folder, mask_names{i}));

    end

end