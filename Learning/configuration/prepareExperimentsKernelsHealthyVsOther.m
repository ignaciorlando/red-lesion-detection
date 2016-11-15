
function [folds] = prepareExperimentsKernelsHealthyVsOther(options)

    % ---------------------------------------------------------------------
    % PREPARE THE FOLDS: Load the file with the folds OR Prepare the folds
    % ---------------------------------------------------------------------
    
    % Get idx number on each fold
    [splits, subsets_filenames] = getIdxForEachFold(options);
    
    % ---------------------------------------------------------------------
    % LOAD FEATURES AND ORGANIZE THEM IN TRAINING/VALIDATION/TEST
    % ---------------------------------------------------------------------    
    
    % Open the labels
    load(strcat(options.dataFolder, filesep, 'labels', filesep, 'labels.mat'));
    
    new_splits = cell(options.numFolds, 1);
    for i = 1 : length(new_splits)
        
        current_split = splits{i};
        for j = 1 : length(current_split)
            
            currentLabels = labels_messidor{j}.dr;
            to_preserve = logical((currentLabels==0) + (currentLabels==options.healthy_vs_r));
            currentLabels = currentLabels(to_preserve);
            
            
            
        end
        
    end
    
    % Open features and organize all the data in the cell array
    % data_per_split
    data_per_split = cell(length(options.subsetsNames), 1);
    % for each subset of data
    for j = 1 : length(options.subsetsNames)
    
        % initialize the matrix with the subfeatures (only those in
        % matricial format)
        if (options.with_bias)
            subfeatures_matricial = ones(length(subsets_filenames{j}), options.features.totalDimension + 1) * 1000;
        else
            subfeatures_matricial = zeros(length(subsets_filenames{j}), options.features.totalDimension);
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
            features_path = strcat(options.dataFolder, filesep, 'features', filesep, options.features.names{i}, filesep, options.subsetsNames{j}, filesep, 'features.mat');
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
        
        % prepare training, validation and test data
        subfolds = cell(options.numFolds, 1);
        currentsplits = splits{j};
        for i = 1 : options.numFolds
            % Training data
            subfolds{i}.trainingdata = generateStructOfDataKernels(currentsplits{i}.trainingIndices, subfeatures_matricial, subfeatures_bag, labels_messidor{j}.dr, options);
            % Validation data
            subfolds{i}.validationdata = generateStructOfDataKernels(currentsplits{i}.validationIndices, subfeatures_matricial, subfeatures_bag, labels_messidor{j}.dr, options);
            % Test data
            subfolds{i}.testdata = generateStructOfDataKernels(currentsplits{i}.testIndices, subfeatures_matricial, subfeatures_bag, labels_messidor{j}.dr, options);
        end
        
        % At this point, I have organized all the features and labels in
        % training, validation and test data
        data_per_split{j} = subfolds;
        
    end
    
    % ---------------------------------------------------------------------
    % ORGANIZE DATA IN FOLDS
    % ---------------------------------------------------------------------
    
    % And now, lets create the folds array that we will return
    folds = cell(options.numFolds, 1);
    for i = 1 : length(folds)
        
        % copy the fold corresponding to the first split
        first_two_folds = data_per_split{1};
        folds{i} = first_two_folds{i};
        % and now, for each split, lets add the remaining information
        for j = 2 : length(data_per_split)
            % take the j-th split
            withinsplit = data_per_split{j};
            % cumulate features, indices and labels in the training data
            [folds{i}.trainingdata] = cumulateData(folds{i}.trainingdata, withinsplit{i}.trainingdata);
            % cumulate features, indices and labels in the validation data
            [folds{i}.validationdata] = cumulateData(folds{i}.validationdata, withinsplit{i}.validationdata);
            % cumulate features, indices and labels in the test data
            [folds{i}.testdata] = cumulateData(folds{i}.testdata, withinsplit{i}.testdata);
        end
        
%         % sort the data so we can see better kernel figures
%         [folds{i}.trainingdata.labels, idx] = sort(folds{i}.trainingdata.labels);
%         folds{i}.trainingdata.features = folds{i}.trainingdata.features(idx,:);
%         if (size(folds{i}.trainingdata.pre_bag_features,2)>0)
%             folds{i}.trainingdata.pre_bag_features = folds{i}.trainingdata.pre_bag_features(idx);
%         end
%         folds{i}.trainingdata.indices = folds{i}.trainingdata.indices(idx);
        
        if (options.with_bias)
            if (strcmp(options.features.normalization,'zero-mean'))
                % standardize training data
                [folds{i}.trainingdata.features(:,1:end-1), current_mean, current_std2] = standardizeCols(folds{i}.trainingdata.features(:,1:end-1));
                % standardize validation data
                [folds{i}.validationdata.features(:,1:end-1)] = standardizeCols(folds{i}.validationdata.features(:,1:end-1), current_mean, current_std2);
                % standardize test data
                [folds{i}.testdata.features(:,1:end-1)] = standardizeCols(folds{i}.testdata.features(:,1:end-1), current_mean, current_std2);
            elseif (strcmp(options.features.normalization,'l2'))
                % standardize training data
                folds{i}.trainingdata.features(:,1:end-1) = normr(folds{i}.trainingdata.features(:,1:end-1));
                % standardize validation data
                folds{i}.validationdata.features(:,1:end-1) = normr(folds{i}.validationdata.features(:,1:end-1));
                % standardize test data
                folds{i}.testdata.features(:,1:end-1) = normr(folds{i}.testdata.features(:,1:end-1));
            end
        else
            if (strcmp(options.features.normalization,'zero-mean'))
                % standardize training data
                [folds{i}.trainingdata.features, current_mean, current_std2] = standardizeCols(folds{i}.trainingdata.features);
                % standardize validation data
                [folds{i}.validationdata.features] = standardizeCols(folds{i}.validationdata.features, current_mean, current_std2);
                % standardize test data
                [folds{i}.testdata.features] = standardizeCols(folds{i}.testdata.features, current_mean, current_std2);
            elseif (strcmp(options.features.normalization,'l2'))
                % standardize training data
                folds{i}.trainingdata.features = normr(folds{i}.trainingdata.features);
                % standardize validation data
                folds{i}.validationdata.features = normr(folds{i}.validationdata.features);
                % standardize test data
                folds{i}.testdata.features = normr(folds{i}.testdata.features);
            end
        end

        
        % compute the linear kernel from Overfeat features
        if ~isempty(folds{i}.trainingdata.features)
            training_overfeat_kernel = kernelLinear(folds{i}.trainingdata.features, folds{i}.trainingdata.features);
        end
        
        % compute the chi-squared distance from bags of vessel features
        if ~isempty(folds{i}.trainingdata.pre_bag_features)
        
            % for each feature
            folds{i}.trainingdata.bag_features = [];
            folds{i}.validationdata.bag_features = [];
            folds{i}.testdata.bag_features = [];
            for j = 1 : size(folds{i}.trainingdata.pre_bag_features, 2)
                rng(1,'twister');
                % identify the centroids
                [centers] = computeBagOfFeaturesCenters(folds{i}.trainingdata.pre_bag_features(:,j), folds{i}.trainingdata.labels, options.features.k, options.features.discriminative);
                % compute the bag of features on training data
                [bags_of_features] = computeBagOfFeatures(folds{i}.trainingdata.pre_bag_features(:,j), centers, options.features.discriminative, options.features.hard_assignment);
                % cumulate the bag of features
                folds{i}.trainingdata.bag_features = cat(2, folds{i}.trainingdata.bag_features, bags_of_features);

                % compute the bag of features on validation data
                [bags_of_features] = computeBagOfFeatures(folds{i}.validationdata.pre_bag_features(:,j), centers, options.features.discriminative, options.features.hard_assignment);
                % cumulate the bag of features
                folds{i}.validationdata.bag_features = cat(2, folds{i}.validationdata.bag_features, bags_of_features);

                % compute the bag of features on test data
                [bags_of_features] = computeBagOfFeatures(folds{i}.testdata.pre_bag_features(:,j), centers, options.features.discriminative, options.features.hard_assignment);
                % cumulate the bag of features
                folds{i}.testdata.bag_features = cat(2, folds{i}.testdata.bag_features, bags_of_features);

            end

            % now, remove the old fields 
            folds{i}.trainingdata = rmfield(folds{i}.trainingdata, 'pre_bag_features');
            folds{i}.validationdata = rmfield(folds{i}.validationdata, 'pre_bag_features');
            folds{i}.testdata = rmfield(folds{i}.testdata, 'pre_bag_features');

            % compute the histogram kernel on the training data
            training_histogram_kernel = histogramKernel(folds{i}.trainingdata.bag_features);
            
        end
        
        % center the kernels and assign them to the features
        n = size(folds{i}.trainingdata.features,1);
        H = eye(n) - ones(n,n)./n;
        % if there are both Overfeat and vascular features
        if (exist('training_histogram_kernel','var')~=0) && (exist('training_overfeat_kernel','var')~=0)
            % center both kernels
            K1 = H * training_overfeat_kernel * H;
            K2 = H * training_histogram_kernel * H;
            folds{i}.trainingdata.original_features = cat(2, folds{i}.trainingdata.features, folds{i}.trainingdata.bag_features);
            if strcmp(options.useEta, 'no')
                % concatenate the features in the original_features vector
                folds{i}.validationdata.features = cat(2, folds{i}.validationdata.features, folds{i}.validationdata.bag_features);
                folds{i}.testdata.features = cat(2, folds{i}.testdata.features, folds{i}.testdata.bag_features);
                % and now sum up both kernels
                folds{i}.trainingdata.features = (K1 / trace(K1)) + (K2 / trace(K2));
            else
                % concatenate the features in the original_features vector
                folds{i}.validationdata.features = cat(2, options.eta * folds{i}.validationdata.features, (1-options.eta) * folds{i}.validationdata.bag_features);
                folds{i}.testdata.features = cat(2, options.eta * folds{i}.testdata.features, (1-options.eta) * folds{i}.testdata.bag_features);
                % and now sum up both kernels
                folds{i}.trainingdata.features = options.eta * (K1 / trace(K1)) + (1-options.eta) * (K2 / trace(K2));
            end
        elseif (exist('training_histogram_kernel','var')~=0)
            % concatenate the features in the original_features vector
            folds{i}.trainingdata.original_features = folds{i}.trainingdata.bag_features;
            folds{i}.validationdata.features = folds{i}.validationdata.bag_features;
            folds{i}.testdata.features = folds{i}.testdata.bag_features;            
            % assign the kernel
            folds{i}.trainingdata.features = H * training_histogram_kernel * H;
        else
            % concatenate the features in the original_features vector
            folds{i}.trainingdata.original_features = folds{i}.trainingdata.features;       
            % assign the kernel
            folds{i}.trainingdata.features = H * training_overfeat_kernel * H;
        end
        
    end

end

