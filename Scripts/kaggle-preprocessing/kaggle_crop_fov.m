
data_path = 'C:\_diabetic_retinopathy_backup\e-ophtha';
image_path = fullfile(data_path, 'images');
mask_path = fullfile(data_path, 'masks');
image_names = getMultipleImagesFileNames(image_path);
mask_names = getMultipleImagesFileNames(mask_path);

% for each image
for i = 1 : length(image_names)
    i
    % open the image
    I = imread(fullfile(image_path, image_names{i}));
    % open the mask
    mask = imread(fullfile(mask_path, mask_names{i})) > 0;
    
    % cropped the image
    [ croppedI, croppedMask ] = cropFOV( I, mask(:,:,1) );
    
    % write the image
    imwrite(croppedI, strcat(fullfile(image_path, image_names{i}),'.png'));
    % write the mask
    imwrite(croppedMask, fullfile(mask_path, mask_names{i}));
    
end