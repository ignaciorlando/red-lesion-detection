
function [data] = generateStructOfData(indices, matricial_features, bag_of_features, labels, options)
% generateStructOfData Generate a data struct with indices, features and
% labels, retrieved from the features matrix and the labels array


    % generate data struct extracting the corresponding data from features
    % and labels
    
    % copy indices
    data.indices = indices;
    
    % Get only the features indicated on indices
    data.features = matricial_features(indices, :);

    % retrieve only the bag of features assigned to the current split
    data.pre_bag_features = cell(length(indices), length(bag_of_features));
    for i = 1 : length(bag_of_features)
        current_bag = bag_of_features{i};
        data.pre_bag_features(:,i) = current_bag(indices);
    end
    
    % Get only the labels indicated on indices
    data.labels = labels(indices);
    
    if (strcmp(options.typeProblem,'dr-detection'))
        % If it is a dr detection problem, then all the labels
        % corresponding to different types of dr will be set to 1 and
        % healthy patients will be 0.
        data.labels = double(data.labels > 0);
        % Rearrange the labels so -1 represents the negative class and +1
        % represents the positive one
        data.labels = 2 * data.labels - 1;
    end

end