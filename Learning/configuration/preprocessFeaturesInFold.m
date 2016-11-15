function [folds] = preprocessFeaturesInFold(folds, options)

    % Without kernel
    if (~options.kernel)
    
        % And now, lets create the folds array that we will return
        for i = 1 : length(folds)

            % for each feature
            for j = 1 : size(folds{i}.trainingdata.pre_bag_features, 2)

                % identify the centroids
                [centers] = computeBagOfFeaturesCenters(folds{i}.trainingdata.pre_bag_features(:,j), options.features.k);
                % compute the bag of features on training data
                [bags_of_features] = computeBagOfFeatures(folds{i}.trainingdata.pre_bag_features(:,j), centers);
                % concatenate bags to the other matricial features
                folds{i}.trainingdata.features = cat(2,folds{i}.trainingdata.features,bags_of_features);
                % compute the bag of features on validation data
                [bags_of_features] = computeBagOfFeatures(folds{i}.validationdata.pre_bag_features(:,j), centers);
                % concatenate bags to the other matricial features
                folds{i}.validationdata.features = cat(2,folds{i}.validationdata.features,bags_of_features);
                % compute the bag of features on test data
                [bags_of_features] = computeBagOfFeatures(folds{i}.testdata.pre_bag_features(:,j), centers);
                % concatenate bags to the other matricial features
                folds{i}.testdata.features = cat(2,folds{i}.testdata.features,bags_of_features);

            end

            if (strcmp(options.features.normalization,'zero-mean'))
                % standardize training data
                [folds{i}.trainingdata.features, current_mean, current_std2] = standardizeCols(folds{i}.trainingdata.features);
                % standardize validation data
                [folds{i}.validationdata.features] = standardizeCols(folds{i}.validationdata.features, current_mean, current_std2);
                % standardize test data
                [folds{i}.testdata.features] = standardizeCols(folds{i}.testdata.features, current_mean, current_std2);
            end

            % and now, remove the old fields 
            folds{i}.trainingdata = rmfield(folds{i}.trainingdata, 'pre_bag_features');
            folds{i}.validationdata = rmfield(folds{i}.validationdata, 'pre_bag_features');
            folds{i}.testdata = rmfield(folds{i}.testdata, 'pre_bag_features');

        end
        
    % With kernel
    else
        
        % Normalize when necesary
        for i = 1 : length(folds)

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

end