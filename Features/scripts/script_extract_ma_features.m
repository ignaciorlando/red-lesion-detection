
config_extract_ma_features;

% Move rootData to the data set
rootData = strcat(rootData, filesep, datasetName);
% Root folder where the features are going to be stored
rootFeatures = strcat(rootData, filesep, 'features');

% Get images path
maSegmentationsPath = strcat(rootData, filesep, 'ma_segmentations');

% Retrieve image names...
maNames = dir(maSegmentationsPath);
maNames = {maNames.name};
maNames(strcmp(maNames, '..')) = [];
maNames(strcmp(maNames, '.')) = [];
maNames = removeFileNamesWithExtension(maNames, 'mat');

% For each type of feature
for k = 1 : length(type_of_features)

    % Get features path
    featuresPath = strcat(rootFeatures, filesep, type_of_features{k});
    if (exist(featuresPath,'dir')==0)
        mkdir(featuresPath);
    end

    % For each image, process it
    features = zeros(length(maNames), features_sizes(k));
    for j = 1 : length(maNames)

        [~, file_name, ~] = fileparts(maNames{j});

        % open the image
        ma_segmentation = imread(strcat(maSegmentationsPath, filesep, maNames{j}));
        % compute features
        if (strcmp(type_of_features_names{k}, 'ma-area'))
            features(j,:) = sum(ma_segmentation(:)>0);
        elseif (strcmp(type_of_features_names{k}, 'ma-number'))
            CC = bwconncomp(ma_segmentation > 0);
            features(j,:) = CC.NumObjects;
        elseif (strcmp(type_of_features_names{k}, 'ma-area-distribution'))

            ma_segmentation = imresize(ma_segmentation, [957 1440]);
            if (size(ma_segmentation,1) < size(ma_segmentation,2))
                n = floor(size(ma_segmentation,1) / 11);
            else
                n = floor(size(ma_segmentation,2) / 11);
            end
            sum_per_grid = blockproc(ma_segmentation,[n n],@(block_struct) sum(block_struct.data(:)));
            features(j,:) = sum_per_grid(:)';

        end

    end

    % Save features
    save(strcat(featuresPath, filesep, 'features.mat'), 'features');

end
    
