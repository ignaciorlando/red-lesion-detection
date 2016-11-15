
function [config] = getConfiguration_GenericDataset(datasetName, datasetPath, resultsPath, learnC, crfVersion, cValue)
% getConfiguration_GenericDataset  Get a generic configuration structure 
%   [config] = getConfiguration_GenericDataset(datasetName, datasetPath, resultsPath, learnC, crfVersion, cValue)
%   datasetName: name of the data set
%   datasetPath: path where the data set is stored
%   resultsPath: path where the results are going to be stored
%   learnC: a boolean value indicating if C is going to be learned or not
%   crfVersion: CRF version (up, local-neighborhood-based, fully-connected)
%   cValue: default C value (it will be only used if learnC=0)

    % ---------------------------------------------------------------------

    % Identify data set
    config.dataset = datasetName;

    % Configure paths
    config.dataset_path = datasetPath;   
    
    % image, labels and masks original folder
    config.training_data_path = strcat(config.dataset_path, filesep, 'training');
    config.validation_data_path = strcat(config.dataset_path, filesep, 'validation');
    config.test_data_path = strcat(config.dataset_path, filesep, 'test');

    % ---------------------------------------------------------------------
    % Scale factor   
    if (strcmp(datasetName,'DRIVE-MESSIDORsmall'))
        config.scale_factor = 1;
    elseif (strcmp(datasetName,'DRIVE-MESSIDORsmall-scale'))
        config.scale_factor = 1.221374046;
    else
        config.scale_factor = 1;
    end
    
    % ---------------------------------------------------------------------
    % Parameters to learn
    config.learn.theta_p = 0;
    config.learn.unaryFeatures = 0;
    config.learn.pairwiseFeatures = 0;
    config.learn.modelSelection = config.learn.theta_p || config.learn.unaryFeatures || config.learn.pairwiseFeatures;
    config.learn.C = learnC;
    
    % ---------------------------------------------------------------------
    % CRF configuration
    % CRF version
    if strcmp(crfVersion, 'up')
        config.crfVersion = 'fully-connected';
    else
        config.crfVersion=crfVersion;
    end
    config.experiment = crfVersion;

    config.theta_p.initialValue = 1;
    config.theta_p.increment = 2;
    config.theta_p.lastValue = 15;

    % ---------------------------------------------------------------------
    % SOSVM configuration
    config.C.initialPower = 0;
    config.C.lastPower = 3;
    if (~config.learn.C)
        config.C.value = cValue;
    end
    
    % ---------------------------------------------------------------------
    % General configuration
    [config] = getGeneralConfiguration(config);
    config.compute_scores = 1;
    
    % ---------------------------------------------------------------------
    config.features.saveFeatures = 0;
    
    % Unary features
    config.features.unary.unaryFeatures = zeros(config.features.numberFeatures, 1);
    config.features.unary.unaryFeatures(1) = 1;     % Nguyen
    %config.features.unary.unaryFeatures(2) = 1;     % Soares
    %config.features.unary.unaryFeatures(3) = 1;     % Zana
    config.features.unary.unaryFeatures(4) = 1;     % Azzopardi

    % Pairwise features
    config.features.pairwise.pairwiseFeatures = zeros(config.features.numberFeatures, 1);
    config.features.pairwise.pairwiseFeaturesDimensions = ones(length(config.features.features),1);
    if ~strcmp(crfVersion, 'up')
        %config.features.pairwise.pairwiseFeatures(1) = 1;  % Nguyen
        %config.features.pairwise.pairwiseFeatures(2) = 1;  % Soares
        config.features.pairwise.pairwiseFeatures(3) = 1;  % Zana
        %config.features.pairwise.pairwiseFeatures(4) = 1;  % Azzopardi
    end
    
    
    % Results path
    if (~strcmp(resultsPath, 'training'));
        if strcmp(crfVersion, 'up')
            resultsPath = strcat(resultsPath, filesep, crfVersion, filesep, 'uf=', mat2str(config.features.unary.unaryFeatures));
        else
            resultsPath = strcat(resultsPath, filesep, crfVersion, filesep, 'uf=', mat2str(config.features.unary.unaryFeatures), '---pf=', mat2str(config.features.pairwise.pairwiseFeatures));
        end
        if (~exist(resultsPath,'dir'))
            config.output_path = resultsPath;
            mkdir(resultsPath);
        end
    end
    config.resultsPath = resultsPath;
    
    % output path
    config.output_path = strcat(resultsPath);
    if (~exist(config.output_path,'dir'))
        mkdir(config.output_path);
    end

end