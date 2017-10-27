
function [imdb] = augment_dataset(original_imdb, augmentation_angles)

    % Initialize a matrix to store the augmented data set
    number_of_images_in_the_augmented_set = size(original_imdb.images.data,4) * 2 * length(augmentation_angles);

    % Initialize the training data structure
    imdb.images.data = zeros(32, 32, 3, number_of_images_in_the_augmented_set);
    imdb.images.labels = zeros(number_of_images_in_the_augmented_set, 1);
    imdb.images.image_id = zeros(number_of_images_in_the_augmented_set, 1);
    imdb.images.set = zeros(number_of_images_in_the_augmented_set, 1);
    imdb.images.candidates_pxs = cell(length(original_imdb.images.candidates_pxs) * 2 * length(augmentation_angles), 1);

    % For each patch
    iterator = 1;
    for i = 1 : size(original_imdb.images.data, 4)

        % Announce the number of patch being processed
        fprintf('Augmenting patch %i/%i\n', i, size(original_imdb.images.data, 4));
        % Retrieve i-th window
        current_window = original_imdb.images.data(:,:,:,i);
        % For each augmentation angle
        for angle = 1 : length(augmentation_angles)
            % Rotate window using current augmentation angle
            imdb.images.data(:,:,:,iterator) = imrotate(current_window, augmentation_angles(angle));
            imdb.images.labels(iterator) = original_imdb.images.labels(i);
            iterator = iterator + 1;
            % Flip horizontally the rotated window
            imdb.images.data(:,:,:,iterator) = fliplr(imdb.images.data(:,:,:,iterator-1));
            imdb.images.labels(iterator) = original_imdb.images.labels(i);
            iterator = iterator + 1;
        end

    end


end