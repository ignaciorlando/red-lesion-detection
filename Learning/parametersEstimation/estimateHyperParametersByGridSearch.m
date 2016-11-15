
function [results, search] = estimateHyperParametersByGridSearch(trainingdata, validationdata, options)
% estimateHyperParametersByGridSearch This function estimate the
% hyperparameters for the k support logistic regression model (k and
% lambda) by grid search, training on trainingdata and evaluation on
% validationdata.
% INPUT: trainingdata = training data, organized as a struct with:
%           .features = a matrix where each row corresponds to the feature
%               vector of an image
%           .labels = a vector of labels (1 the positive, -1 the negative)
%        validationdata = training data, organized as the training data
%           struct.
%        options = a struct with the fields:
%           .kValues = an array with the values of k to be evaluated
%           .lambdaValues = an array with the values of lambda to be
%               evaluated.
%           .measure = metric to be optimized
%           .verbose = print the progress of the model selection
% OUTPUT: results = a struct with the following fields:
%           .validationset.qualvalues = results for each combination of k
%               and lambda on the validation set
%           .model.k = the best value of k
%           .model.lambda = the best value of lambda
%         search = a matrix with results at each iteration

    if (~isfield(options, 'verbose'))
        options.verbose = true;
    end

    % Set the hyperparameters lambda and k according to the validation set
    if (options.verbose)
        disp('Initializing grid search');
    end
    
    % Setting up the grid search of parameters
    results.validationset.qualvalues = zeros(length(options.kValues), length(options.lambdaValues));
    
    % Estimate the parameters using grid search
    for i = 1 : length(options.kValues)
        for j = 1 : length(options.lambdaValues)
            
            % Select the parameters k and lambda
            kval = options.kValues(i);
            lambda = options.lambdaValues(j);
            
            % if using the kernel classifier
            if (options.kernel==1)
                
                if (options.verbose)
                    fprintf('Trying parameters lambda=%d\n', lambda);
                end
                
                if (strcmp(options.typeProblem, 'dr-grading'))
                    
                    % Train kernel ordinal logistic regression
                    
                    % Set up problem
                    nTrain = length(trainingdata.labels);
                    nClasses = length(unique(trainingdata.labels));
                    w = zeros(nTrain,1);
                    gamma = ones(nClasses-2,1);
                    LB = [-inf(nTrain,1);zeros(nClasses-2,1)];
                    UB = inf(nTrain+nClasses-2,1);
                    funObj_sub = @(w)OrdinalLogisticLoss2(w,trainingdata.features,trainingdata.labels,nClasses);
                    funObj = @(w)penalizedKernelL2_subset(w,trainingdata.features,1:nTrain,funObj_sub,lambda);

                    % Solve optiamization
                    new_options.verbose=0;
                    new_options.maxIter=5000;
                    wGamma = minConf_TMP(funObj,[w;gamma],LB,UB,new_options);
                    alpha = wGamma(1:nTrain);
                    gamma = [-inf;0;cumsum(wGamma(nTrain+1:end));inf];
                    w = trainingdata.original_features' * alpha;
                    
                elseif (strcmp(options.typeProblem, 'dr-detection')) || (strcmp(options.typeProblem, 'one-vs-all'))  || (strcmp(options.typeProblem, 'need-to-referral'))
                
                    % Train kernel logistic regression
                    funObj = @(u)LogisticLoss(u,trainingdata.features,trainingdata.labels);
                    new_options.Display = 0;
                    new_options.useMex = 0;
                    alpha = minFunc(@penalizedKernelL2, zeros(size(trainingdata.features,2),1), new_options, trainingdata.features, funObj, lambda); 
                    w = trainingdata.original_features' * alpha;
                    
%                     % Train kernel ordinal logistic regression
%                     
%                     % Set up problem
%                     nTrain = length(trainingdata.labels);
%                     nClasses = length(unique(trainingdata.labels));
%                     w = zeros(nTrain,1);
%                     gamma = ones(nClasses-2,1);
%                     LB = [-inf(nTrain,1);zeros(nClasses-2,1)];
%                     UB = inf(nTrain+nClasses-2,1);
%                     funObj_sub = @(w)OrdinalLogisticLoss2(w,trainingdata.features,trainingdata.labels,nClasses);
%                     funObj = @(w)penalizedKernelL2_subset(w,trainingdata.features,1:nTrain,funObj_sub,lambda);
% 
%                     % Solve optiamization
%                     new_options.verbose=0;
%                     new_options.maxIter=5000;
%                     wGamma = minConf_TMP(funObj,[w;gamma],LB,UB,new_options);
%                     alpha = wGamma(1:nTrain);
%                     gamma = [-inf;0;cumsum(wGamma(nTrain+1:end));inf];
%                     w = trainingdata.original_features' * alpha;
                
                elseif (strcmp(options.typeProblem, 'multinomial-dr'))
                    
                    % Train multinomial logistic regression
                    nClasses = length(unique(trainingdata.labels));
                    nInstances = length(trainingdata.labels);
                    new_options.Display = 0; new_options.useMex = 0;
                    funObj = @(u)SoftmaxLoss2(u,trainingdata.features,trainingdata.labels,nClasses);
                    alpha = minFunc(@penalizedKernelL2_matrix,randn(nInstances*(nClasses-1),1),new_options,trainingdata.features,nClasses-1,funObj,lambda);
                    alpha = reshape(alpha,[nInstances nClasses-1]);
                    alpha = [alpha zeros(nInstances,1)];
                    w = trainingdata.original_features' * alpha;
                    
                end
                
            else
                
                if (kval==1)
                    if (options.verbose)
                        fprintf('Trying parameters k=%d, lambda=%d\n', kval, lambda);
                    end
                    % Train the k-support regularized logistic regresion
                    [w, costs] = ksupLogisticRegression(trainingdata.features, trainingdata.labels, lambda, kval);
                else
                    if strcmp(options.logRegImplementation,'markSchmidt')
                        if (options.verbose)
                            fprintf('Trying parameters lambda=%d\n', lambda);
                        end
                        % Train kernel logistic regression
                        funObj = @(w)LogisticLoss(w,trainingdata.features,trainingdata.labels);
                        new_options.Display = 0;
                        new_options.useMex = 0;
                        w = minFunc(@penalizedL2, zeros(size(trainingdata.features,2),1), new_options, funObj, lambda); 
                    else
                        if (options.verbose)
                            fprintf('Trying parameters k=%d, lambda=%d\n', kval, lambda);
                        end
                        % Train the k-support regularized logistic regresion
                        [w, costs] = ksupLogisticRegression(trainingdata.features, trainingdata.labels, lambda, kval);
                    end
                end
                
            end
            
            if strcmp(options.typeProblem,'dr-detection') || (strcmp(options.typeProblem, 'one-vs-all')) || (strcmp(options.typeProblem, 'need-to-referral'))
                
                % Generate scores on the validation data
                validationdata.scores = w' * validationdata.features';
                
                % Predict on validation data
                %z = w' * validationdata.features';
                %validationdata.scores = zeros(size(z));
                %for c = 1:length(unique(trainingdata.labels))
                %   validationdata.scores(z > gamma(c)) = c;
                %end
                
            elseif strcmp(options.typeProblem,'dr-grading')
                % Predict on validation data
                z = w' * validationdata.features';
                validationdata.scores = zeros(size(z));
                for c = 1:length(unique(trainingdata.labels))
                   validationdata.scores(z > gamma(c)) = c;
                end
            elseif strcmp(options.typeProblem,'multinomial-dr')
                % Generate scores on the validation data
                [~, validationdata.scores] = max(w' * validationdata.features');
            end
            % Evaluate using the performance measure as indicated in options
            if strcmp(options.typeProblem,'dr-grading')
                results.validationset.qualvalues(i,j) = evaluateResults(validationdata.labels, z, options.measure);
                q = evaluateResults(validationdata.labels, validationdata.scores, 'confusion-matrix')
            else
                results.validationset.qualvalues(i,j) = evaluateResults(validationdata.labels, validationdata.scores, options.measure);
            end
            if (options.verbose)
                fprintf('%s=%d\n\n', options.measure, results.validationset.qualvalues(i,j));
            end
        end
    end
    
    % Retrieve the higher quality value on the validation set
    [results.validationset.highqual, index] = max(results.validationset.qualvalues(:));
    % If there are several results with the same area under the ROC curve, just
    % retrieve the first parameters
    if (length(index)>1)
        index = index(1);
    end
    % Retrieve the values of k and lambda    
    [k_ind, lambda_ind] = ind2sub(size(results.validationset.qualvalues), index);
    % Assign the data to the model struct
    results.model.k = options.kValues(k_ind);
    results.model.lambda = options.lambdaValues(lambda_ind);
    
    % Reshape the array with the results of the search
    search = reshape(results.validationset.qualvalues, length(options.kValues), length(options.lambdaValues));

end