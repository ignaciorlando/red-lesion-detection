
function [data] = generateStructOfDataKernels(indices, matricial_features, bag_of_features, labels, options)
% generateStructOfData Generate a data struct with indices, features and
% labels, retrieved from the features matrix and the labels array


    % generate data struct extracting the corresponding data from features
    % and labels
    
    % copy indices
    data.indices = indices;
    
    % Get only the features indicated on indices, normalize to 0 mean, 1
    % variance
    data.features = matricial_features(indices, :);
    data.features(isnan(data.features)) = 0;

    % retrieve only the bag of features assigned to the current split
    data.pre_bag_features = cell(length(indices), length(bag_of_features));
    for i = 1 : length(bag_of_features)
        current_bag = bag_of_features{i};
        data.pre_bag_features(:,i) = current_bag(indices);
    end
    
    % Get only the labels indicated on indices
    [data.labels] = prepareLabels(labels(indices), options);

end