
config_run_experiment_parameters;

% /////////////////////////////////////////////////////////////////////////

if (strcmp(options.typeProblem, 'dr-detection'))
    options.resultsFolder = strcat(options.resultsFolder, filesep, 'classification-results');
elseif (strcmp(options.typeProblem, 'need-to-referral'))
    options.resultsFolder = strcat(options.resultsFolder, filesep, 'need-to-referral');
elseif (strcmp(options.typeProblem, 'pdr-detection'))
    options.resultsFolder = strcat(options.resultsFolder, filesep, 'pdr-detection-results');
elseif (strcmp(options.typeProblem, 'dr-grading'))
    options.resultsFolder = strcat(options.resultsFolder, filesep, 'grading-results');
    options.measure = 'ranking-loss';
    %options.measure = 'overall-accuracy';
elseif (strcmp(options.typeProblem, 'multinomial-dr'))
    options.resultsFolder = strcat(options.resultsFolder, filesep, 'multinomial-grading-results');
    options.measure = 'overall-accuracy';
elseif (strcmp(options.typeProblem, 'one-vs-all'))
    options.resultsFolder = strcat(options.resultsFolder, filesep, 'one-vs-all');
    options.measure = 'auc';
end

if (options.kernel==0)
    [results_per_regularizer] = configureAndRunExperiment(options);
else
    if (strcmp(options.typeProblem, 'one-vs-all'))
        [results_kernel] = configureAndRunOneVsAllWithKernels(options);
    else
        [results_kernel] = configureAndRunExperimentWithKernels(options);
    end
end





