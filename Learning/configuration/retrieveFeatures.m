
function [subfeatures_matricial, subfeatures_bag] = retrieveFeatures(options, filenames)

    % initialize the matrix with the subfeatures (only those in
    % matricial format)
    if (options.with_bias)
        subfeatures_matricial = ones(length(filenames), options.features.totalDimension + 1) * 1000;
    else
        subfeatures_matricial = zeros(length(filenames), options.features.totalDimension);
    end
    subfeatures_bag = cell(length(options.features.bag_of_features_filter),1);

    % fill the matrix with each corresponding feature set
    if ~isempty(options.features.dimensions_traditional)
        beginnings = cumsum([1, options.features.dimensions_traditional]);
        endings = cumsum(options.features.dimensions_traditional);
    end
    feature_bag_iterator = 1;
    feature_matricial_iterator  = 1;
    for i = 1 : length(options.features.names)

        % Generate the features path
        features_path = strcat(options.dataFolder, filesep, 'features', filesep, options.features.names{i}, filesep, 'features.mat');
        % Load each feature configuration
        load(features_path);

        % Check whether the features are bag or not
        if (ismember(i, options.features.bag_of_features_filter)) 
            subfeatures_bag{feature_bag_iterator} = features;
            feature_bag_iterator = feature_bag_iterator + 1;
        else
            % Assign the features
            subfeatures_matricial(:, beginnings(feature_matricial_iterator) : endings(feature_matricial_iterator)) = features;
            feature_matricial_iterator = feature_matricial_iterator + 1;
        end
        clear features;

    end

end