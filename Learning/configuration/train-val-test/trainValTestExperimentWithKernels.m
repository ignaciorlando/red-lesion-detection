
function [results_kernel] = trainValTestExperimentWithKernels(options)

    % ---------------------------------------------------------------------
    % PREPARE THE EXPERIMENT AND THE RESULTS FILE
    % ---------------------------------------------------------------------

    % Prepare the experiment
    [folds] = prepareExperiments(options);    
    
    % Save the results
    saveResultsPath = strcat(options.resultsFolder, filesep, 'kernel', filesep, strjoin(options.features.tags));
    filenameToSave = strcat(saveResultsPath, filesep, 'results_kernel-', num2str(options.numFolds), 'folds.mat');
    
    % ---------------------------------------------------------------------
    % TRAIN THE MODEL ON TRAINING KERNEL, MODEL SELECTION ON VALIDATION 
    % DATA, EVALUATE ON TEST DATA
    % ---------------------------------------------------------------------

    if (options.verbose)
        if (strcmp(options.typeProblem, 'dr-detection')) || (strcmp(options.typeProblem, 'one-vs-all')) || (strcmp(options.typeProblem, 'need-to-referral'))
            fprintf(strcat('EVALUATING USING KERNEL LOGISTIC REGRESSION\n\n'));
        end
    end

    % And now we are ready to run!
    results_per_fold = cell(options.numFolds, 1);

    % For each fold
    for f = 1 : options.numFolds

        % Set the hyperparameters lambda and k according to the validation set
        if (options.verbose)
            fprintf('Starting experiment on fold %i\n', f);
        end
        options.kValues = size(folds{f}.trainingdata.features, 2);
        [sub_results, results_per_fold{f}.searches] = estimateHyperParametersByGridSearch(folds{f}.trainingdata, folds{f}.validationdata, options);

        % Learn logistic regression model based on the parameters

        if (strcmp(options.typeProblem, 'dr-detection')) || (strcmp(options.typeProblem, 'one-vs-all')) || (strcmp(options.typeProblem, 'need-to-referral'))

            if (options.verbose)
                fprintf('Learning kernel logistic regression using lambda=%d\n', sub_results.model.lambda);
            end
            % Train logistic regresion with the kernels
            funObj = @(u)LogisticLoss(u, folds{f}.trainingdata.features, folds{f}.trainingdata.labels);
            new_options.Display = 0;
            new_options.useMex = 0;
            alpha = minFunc(@penalizedKernelL2, zeros(size(folds{f}.trainingdata.features,1),1), new_options, folds{f}.trainingdata.features, funObj, sub_results.model.lambda); 
            mod_w = folds{f}.trainingdata.original_features' * alpha;
        
        end
        
        % Evaluate on the test set
        if (options.verbose)
            disp('Evaluating on the test set');
        end
        if (strcmp(options.typeProblem, 'dr-detection')) || (strcmp(options.typeProblem, 'one-vs-all'))  || (strcmp(options.typeProblem, 'need-to-referral'))
            
            currentScores = mod_w' * folds{f}.testdata.features';                       % Compute the scores
            results_per_fold{f}.quality = evaluateResults(folds{f}.testdata.labels, ... % Evaluate using the performance measure as indicated in options
                                                      currentScores, ...
                                                      options.measure);          
        end
        
        results_per_fold{f}.mod_w = mod_w;                                          % Save the model
        results_per_fold{f}.scores = currentScores;                                % Save all the probabilities
        results_per_fold{f}.labelsVals = folds{f}.testdata.labels;                        % Save the labels...
        
    end

    % Save the results
    results_kernel = results_per_fold;

    if (exist(saveResultsPath,'dir')==0) && logical(options.save)
        mkdir(saveResultsPath);
    end
    if (options.save)
        save(filenameToSave, 'results_kernel', 'options');
    end

end