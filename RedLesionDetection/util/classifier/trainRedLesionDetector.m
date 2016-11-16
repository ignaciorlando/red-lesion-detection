    
function [ma_detector, quality] = trainRedLesionDetector(imdb, method)
    
    % retrieve training/validation data from IMDB
    training_ma_features = imdb.images.data(imdb.images.set==1, :);
    training_ma_labels = imdb.images.labels(imdb.images.set==1);
    validation_ma_features = imdb.images.data(imdb.images.set==2, :);
    validation_ma_labels = imdb.images.labels(imdb.images.set==2);

    % ---------------------------------------------------------------------
    % PREPROCESS TRAINING/VALIDATION SETS
    % ---------------------------------------------------------------------

    % normalize the features in the training set and in the validation set
    [training_ma_features, mu, sigma2] = standardizeCols(training_ma_features);
    validation_ma_features = standardizeCols(validation_ma_features, mu, sigma2);

    % add a bias term
    training_ma_features = cat(2, training_ma_features, ones(size(training_ma_features,1),1));
    validation_ma_features = cat(2, validation_ma_features, ones(size(validation_ma_features,1),1));

    % ---------------------------------------------------------------------
    % LEARN THE RED LESION DETECTOR
    % ---------------------------------------------------------------------
    
    % find the lambda value in this set
    lambda_vals = 10.^(-6:1:10);
        
    % METHOD = K SUPPORT REGULARIZED LOGISTIC REGRESSION
    if (strcmp(method, 'k-support'))
        
        % find the k value in this set
        k_vals = 2.^(1:1:floor(log2(size(training_ma_features, 2))));
        
        % quality values and models
        quality_values = zeros(length(lambda_vals), length(k_vals));
        models_per_quality_value = cell(size(quality_values));
        
        % for each k value
        for kk = 1 : length(k_vals)
            % for each lambda value
            for ll = 1 : length(lambda_vals)
    
                fprintf('Training with lambda=%d and k=%d\n', lambda_vals(ll), k_vals(kk));
                % train the model with the given configuration
                [w,~] = ksupLogisticRegression(training_ma_features, training_ma_labels, lambda_vals(ll), k_vals(kk));
                % compute the scores
                scores = w' * validation_ma_features';
                % evaluate the auc and save in the quality_values matrix
                % and in the model matrix
                [quality_values(ll, kk)] =  evaluateResults(validation_ma_labels, scores, 'f1-score');
                %[~, ~, quality_values(ll, kk)] = froc(scores, validation_ma_labels, validation_image_ids, validation_ground_truth_num_mas, false);
                
                fprintf('Quality = %d\n', quality_values(ll, kk));
                models_per_quality_value{kk,ll} = w;
                
            end
        end
        
        % Retrieve the best performance
        [quality, index] = max(quality_values(:));
        fprintf('Best performance: %d\n', quality);
        [ll,kk] = ind2sub(size(quality_values), index);
        fprintf('Lambda=%d, k=%d \n', lambda_vals(ll), k_vals(kk));
        
        % Retrieve the best model
        ma_detector.w = models_per_quality_value{kk,ll};
        
    elseif (strcmp(method, 'random-forests'))

        % initialize an array of different number of trees
        number_of_trees = 20:20:200;
        
        % quality values and models
        quality_values = zeros(length(number_of_trees), 1);
        models_per_quality_value = cell(size(quality_values));
        
        % for each tree
        for n_tree = 1 : length(number_of_trees)
            
            fprintf('Training with number of trees=%d\n', number_of_trees(n_tree));
            % train a RF from the training set
            ma_detector.model = classRF_train(training_ma_features, training_ma_labels, number_of_trees(n_tree), sqrt(size(training_ma_features,2)));
            % retrive current OOB error
            quality_values(n_tree) = ma_detector.model.errtr(end,1);
            
            fprintf('OOB error rate = %d\n', quality_values(n_tree));
            models_per_quality_value{n_tree} = ma_detector.model;
            
        end

        % Retrieve the best performance
        [quality, index] = min(quality_values(:));
        fprintf('Best OOB error: %d\n', quality);
        fprintf('Number of trees=%d\n', number_of_trees(index));
        % and the best model
        ma_detector.model = models_per_quality_value{index};
        
        % predict the classes in the validation set
        [scores, ~] = classRF_predict_probabilities(validation_ma_features, ma_detector.model);
        % evaluate the auc and save in the quality_values matrix
        % and in the model matrix
        [quality] =  evaluateResults(validation_ma_labels, scores, 'f1-score');
        
    else
                
        % METHOD = L1 REGULARIZED LOGISTIC REGRESSION
        if (strcmp(method, 'l1'))
            % k = 1
            k = 1;
        % METHOD = L2 REGULARIZED LOGISTIC REGRESSION
        elseif (strcmp(method, 'l2'))
            % k = dimension of the features
            k = size(training_ma_features, 2);
        end
               
        % quality values and models
        quality_values = zeros(length(lambda_vals), 1);
        models_per_quality_value = cell(size(quality_values));

        % for each lambda value
        for ll = 1 : length(lambda_vals)
            
            fprintf('Training with lambda=%d\n', lambda_vals(ll));
            
            % train the model with the given configuration
            [w,~] = ksupLogisticRegression(training_ma_features,training_ma_labels,lambda_vals(ll),k);
            
            % compute the scores
            scores = w' * validation_ma_features';
            
            % evaluate the auc and save in the quality_values matrix
            % and in the model matrix
            %[~, ~, quality_values(ll)] = froc(scores, validation_ma_labels, validation_image_ids, validation_ground_truth_num_mas, false);
            quality_values(ll) =  evaluateResults(validation_ma_labels, scores, 'f1-score');
            
            fprintf('Quality = %d\n', quality_values(ll));
            models_per_quality_value{ll} = w;
                
        end
        
        % Retrieve the best performance
        [quality, ll] = max(quality_values(:));
        fprintf('Best performance: %d\n', quality);
        fprintf('Lambda=%d \n', lambda_vals(ll));
        
        % Retrieve the best model
        ma_detector.w = models_per_quality_value{ll};
        
    end
    
    % save training set mean and standard deviation
    ma_detector.mu = mu;
    ma_detector.std = sigma2;
    % save method name
    ma_detector.method = method;
    
end