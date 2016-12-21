
function [min_x, image_names_per_size] = getMinimumImageSize(images_path)

    % initialize variables
    sizes_scalar = [];
    sizes = [];
    image_names_per_size = {};

    % retrieve image filenames
    image_names = getMultipleImagesFileNames(images_path);
    
    % for each image
    for i = 1 : length(image_names)

        try
            % open the image
            I = imread(fullfile(images_path, image_names{i}));
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
        catch exception
        end

    end

    % remove all sizes smaller than 500
    sizes_scalar(sizes_scalar < 500) = [];
    % return the minimum size
    [min_x] = min(sizes_scalar);

end