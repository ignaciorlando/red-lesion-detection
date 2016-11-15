
warning('off','all');


[ret, hostname] = system('hostname');
hostname = strtrim(lower(hostname));
% Lab computer
if strcmp(hostname, 'orlando-pc')
    % Root dir where the data sets are located
    rootDatasets = 'C:\_vessels\';
    % Root folder where the results are going to be stored
    rootResults = 'C:\_vessels\results';
elseif strcmp(hostname, 'animas')
    % Root dir where the data sets are located
    rootDatasets = '/home/ignacioorlando/nacho-research/vessel2016characterization/_vessels/';
    % Root folder where the results are going to be stored
    rootResults = '/home/ignacioorlando/nacho-research/vessel2006characterization/_vessels/tests';
else
    % Root dir where the data sets are located
    rootDatasets = 'C:\_vessels\';
    % Root folder where the results are going to be stored
    rootResults = 'C:\_vessels\results';
end


% Datasets names
datasetsNames = {...
    'DRIVE-MESSIDORsmall' ...
};
thereAreLabelsInTheTestData = 0 * zeros(size(datasetsNames));

% Flag indicating if the value of C is going to be tuned according to the
% validation set
learnC = 1;
% CRF versions that are going to be evaluated
crfVersions = {'fully-connected'};

% C values
cValue = 10^2;


% For each of the data sets
results = cell(length(datasetsNames), length(crfVersions));
for experiment = 1 : length(datasetsNames)

    % For each version of the CRF
    for crfver = 1 : length(crfVersions)
               
        % Get the configuration
        [config] = getConfiguration_GenericDataset(datasetsNames{experiment}, ... % data set name
                                                   strcat(rootDatasets, datasetsNames{experiment}), ... % data set folder
                                                   strcat(rootResults, filesep, datasetsNames{experiment}), ... % results folder
                                                   learnC, ... % learn C?
                                                   crfVersions{crfver}, ... % crf version
                                                   cValue ... % default C value
                                           );
        config.thereAreLabelsInTheTestData = thereAreLabelsInTheTestData(experiment);
        % Run vessel segmentation!
        results{experiment,crfver} = runVesselSegmentation(config);
        
    end
    
end
        