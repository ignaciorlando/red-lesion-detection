
config_get_red_lesion_detection_training_set;

fprintf(strcat('Dataset: ', dataset_name, '\n'));

% -------------------------------------------------------------------------
% compute features and prepare the training set
% -------------------------------------------------------------------------
original_imdb = get_red_lesion_data_to_classify(dataset_name, 'cnn-from-scratch', type_of_lesion, true, data_path, root_path, '');

% -------------------------------------------------------------------------
% augment data set
% -------------------------------------------------------------------------

% augment windows ---------------------------------------------------------
number_of_images_in_the_augmented_set = size(original_imdb.images.data,4) * 2 * length(augmentation_angles);

imdb.images.data = zeros(32, 32, 3, number_of_images_in_the_augmented_set);
imdb.images.labels = zeros(number_of_images_in_the_augmented_set, 1);
imdb.images.image_id = zeros(number_of_images_in_the_augmented_set, 1);
imdb.images.set = zeros(number_of_images_in_the_augmented_set, 1);
imdb.images.candidates_pxs = cell(length(original_imdb.images.candidates_pxs) * 2 * length(augmentation_angles), 1);

% for each window
iterator = 1;
for i = 1 : size(original_imdb.images.data, 4)
    
    fprintf('Augmenting window %i/%i\n', i, size(original_imdb.images.data, 4));
    
    % retrieve i-th window
    current_window = original_imdb.images.data(:,:,:,i);
    
    % for each angle
    for angle = 1 : length(augmentation_angles)
        
        % rotate window
        imdb.images.data(:,:,:,iterator) = imrotate(current_window, augmentation_angles(angle));
        imdb.images.labels(iterator) = original_imdb.images.labels(i);
        iterator = iterator + 1;
        % flip horizontally the rotated window
        imdb.images.data(:,:,:,iterator) = fliplr(imdb.images.data(:,:,:,iterator-1));
        imdb.images.labels(iterator) = original_imdb.images.labels(i);
        iterator = iterator + 1;
        
    end

end

red_lesion_data_path = fullfile(data_path, dataset_name, strcat(type_of_lesion, '_candidates_data'));
mkdir(red_lesion_data_path)
save(fullfile(red_lesion_data_path, strcat('imdb-red-lesions-windows-', type_of_lesion, '-augmented.mat')), 'imdb', '-v7.3');