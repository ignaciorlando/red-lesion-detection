
function [imdb] = prepareTrainingValidationSets(imdb)

    % identify training and validation sets of images
    options.trainingFraction = 0.7;
    [splits, ~] = train_val_splits(length(unique(imdb.images.image_id)), [], options);
    training_set_ids = zeros(length(imdb.images.labels), 1);
    validation_set_ids = zeros(length(imdb.images.labels), 1);

    % collect indices of training and validation images
    for i = 1 : length(splits{1}.trainingIndices)
        training_set_ids = training_set_ids + (imdb.images.image_id==splits{1}.trainingIndices(i));
    end
    training_set_ids = training_set_ids > 0;
    for i = 1 : length(splits{1}.validationIndices)
        validation_set_ids = validation_set_ids + (imdb.images.image_id==splits{1}.validationIndices(i));
    end
    validation_set_ids = validation_set_ids > 0;

    % assign training/validation sets
    imdb.images.set = training_set_ids + 2 * validation_set_ids; 

end