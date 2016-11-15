data_path = 'C:\_diabetic_retinopathy_backup\Kaggle-sub2\train';
image_path = fullfile(data_path, 'images');
mask_path = fullfile(data_path, 'masks');
image_names = getMultipleImagesFileNames(image_path);
mask_names = getMultipleImagesFileNames(mask_path);

sizes_scalar = [];
sizes = [];
image_names_per_size = {};

% for each image
for i = 1 : length(image_names)
    
    % open the image
    I = imread(fullfile(image_path, image_names{i}));
    I = I(:,:,2);
    
    % retrieve the size
    img_size = size(I);
    position = find(ismember(img_size(2), sizes_scalar));
    if (~isempty(position))
        other_img_names = image_names_per_size{position};
    else
        sizes_scalar = cat(1, sizes_scalar, img_size(2));
        sizes = cat(1, sizes, img_size);
        position = length(sizes_scalar);
        other_img_names = {};
    end 
    other_img_names = cat(1, other_img_names, image_names{i});
    image_names_per_size{position} = other_img_names;
    
end

[min_x] = min(sizes_scalar);

for i = 1 : length(image_names)
    
    % open the image
    I = imread(fullfile(image_path, image_names{i}));
    % open the mask
    mask = imread(fullfile(mask_path, mask_names{i}));
    % retrieve the mask
    mask = mask(:,:,1) > 0;
    % estimate the scale factor
    factor = min_x / size(I,2);
    % downscale the image
    I = imresize(I, factor);
    % downscale the mask
    mask = imresize(mask, factor);
    % save the new image and the mask
    imwrite(I, fullfile(image_path, image_names{i}));
    imwrite(mask, fullfile(mask_path, mask_names{i}));
    
end
% 
% data_path = 'C:\_diabetic_retinopathy_backup\Kaggle-sub2\test';
% image_path = fullfile(data_path, 'images');
% mask_path = fullfile(data_path, 'masks');
% image_names = getMultipleImagesFileNames(image_path);
% mask_names = getMultipleImagesFileNames(mask_path);
% 
% for i = 1 : length(image_names)
%     
%     % open the image
%     I = imread(fullfile(image_path, image_names{i}));
%     % open the mask
%     mask = imread(fullfile(mask_path, mask_names{i}));
%     % retrieve the mask
%     mask = mask(:,:,1) > 0;
%     % estimate the scale factor
%     factor = min_x / size(I,2);
%     % downscale the image
%     I = imresize(I, factor);
%     % downscale the mask
%     mask = imresize(mask, factor);
%     % save the new image and the mask
%     imwrite(I, fullfile(image_path, image_names{i}));
%     imwrite(mask, fullfile(mask_path, mask_names{i}));
%     
% end