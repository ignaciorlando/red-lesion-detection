
function [features_array] = extractFeaturesFromSingleImage(imagesPath, imgName, mask, config, isUnary)

    % Generic function to compute features
    computedFeature = cell(size(config.features.features));

    % for each of the features
    for k = 1 : length(config.features.features)

        % generate feature file name
        if (isUnary)
            filenameFeature = strcat(imagesPath, filesep, imgName, '_', config.features.featureNames{k}, '_unary.mat');
        else
            filenameFeature = strcat(imagesPath, filesep, imgName, '_', config.features.featureNames{k}, '_pairwise.mat');
        end

        % if the feature exist, retrieve it
        if (exist(filenameFeature, 'file'))

            % load the feature file
            load(filenameFeature);

        % if it doesn't exist, we should generate it
        else

            % open the image
            image = imread(fullfile(imagesPath, imgName));
            
            % MODIFIED: RESCALE IMAGE
            downsampled_image = uint8(zeros(size(mask, 1), size(mask, 2), 3));
            for i = 1 : size(image, 3)
                downsampled_image(:,:,i) = imresize(image(:,:,i), size(mask));
            end
            image = downsampled_image;
            
            % preprocess the image
            [image, biggerMask] = preprocessing(image, mask, config.preprocessing);
            % get the function
            g = @(myfunction) myfunction(image, biggerMask, isUnary, config.features.featureParameters{k});
            % feature computation
            feat = cellfun(g, config.features.features(k), 'UniformOutput', false);
            % save the feature file
            if (config.features.saveFeatures)
                save(filenameFeature, 'feat');
            end

        end

        % retrieve the computed feature
        computedFeature{k} = feat{1};

    end

    % extend the mask
    biggerMask = zeros(size(mask,1) + 2 * config.preprocessing.fakepad_extension, size(mask,2) + 2 * config.preprocessing.fakepad_extension);
    biggerMask(config.preprocessing.fakepad_extension:end-config.preprocessing.fakepad_extension-1, ...
        config.preprocessing.fakepad_extension:end-config.preprocessing.fakepad_extension-1) = mask;
    mask = biggerMask;

    % Get the amount of pixels and the dimension of the feature vector
    dim1 = length(find(mask(:)==1));
    dim2 = 0;
    for k = 1 : length(computedFeature)
        dim2 = dim2 + size(computedFeature{k},3);
    end;
    X = zeros(dim1, dim2);

    % Encode feature vectors
    count = 1;
    for k = 1 : length(computedFeature)
        % Take the feature vectors of the i-th image
        feat = computedFeature{k};
        % If the feature vectors have 1 dimensionality
        if size(computedFeature{k},3)==1
            % Recover the feature vector inside the mask
            X(:,count) = feat(mask==1);
            count = count + 1;
        else
            % For each single feature in the feature vector
            for j = 1 : size(computedFeature{k},3)
                % Recover the j-th feature
                f = feat(:,:,j);
                % Get only the feature vector inside the mask
                X(:,count) = f(mask==1);
                count = count + 1;
            end
        end
    end

    % feature scaling
    mu = mean(X);
    stds = std(X);
    stds(stds==0) = 1;
    X = bsxfun(@minus, X, mu);
    features_array = bsxfun(@rdivide, X, stds);
    
end