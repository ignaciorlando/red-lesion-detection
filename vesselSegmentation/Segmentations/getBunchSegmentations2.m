
function [segmentations, qualityMeasures] = getBunchSegmentations2(config, data, model)
% getBunchSegmentations2 Segment a number of given images
% [segmentations, qualityMeasures] = getBunchSegmentations2(config, data, model)
% OUTPUT: segmentations: a cell array containing all the segmentations
%         qualityMeasures: a struct containing all the quality measures
% INPUT: config: configuration structure
%        data: a struct containing images, masks, known labels, unary
%        features and pairwise kernels
%        model: learned model

    % Memory allocation
    segmentations = cell(size(data.masks));
    
    % Preallocate quality measures
    %if (isfield(data, 'labels'))
    if (config.thereAreLabelsInTheTestData)
        qualityMeasures.se = zeros(length(data.masks),1);
        qualityMeasures.sp = zeros(length(data.masks),1);
        qualityMeasures.acc = zeros(length(data.masks),1);
        qualityMeasures.precision = zeros(length(data.masks),1);
        qualityMeasures.recall = zeros(length(data.masks),1);
        qualityMeasures.fMeasure = zeros(length(data.masks),1);
        qualityMeasures.matthews = zeros(length(data.masks),1);
        qualityMeasures.dice = zeros(length(data.masks),1);
        qualityMeasures.arias = zeros(length(data.masks),1);
        qualityMeasures.unaryPotentials = [];
        qualityMeasures.aucUP = zeros(length(data.masks),1);
        qualityMeasures.aucUP_pr = zeros(length(data.masks),1);
        qualityMeasures.scores = [];
        qualityMeasures.auc = zeros(length(data.masks),1);
        qualityMeasures.auc_pr = zeros(length(data.masks),1);
    end
    qualityMeasures.time = zeros(length(data.masks),1);
    
    % Segment each individual image in data
    for i = 1:length(data.masks)

        % Print the name of the image being processed
        fprintf('Segmenting image number %i/%i\n', i, length(data.masks));

        if (config.thereAreLabelsInTheTestData)
        %if (isfield(data, 'labels')) && (~isempty(data.labels))

            % Get image, mask, annotations, ground truth and features
            mask = data.masks{i};
            y = data.labels{i};
            X = data.unaryFeatures{i};
            pairwiseKernels = data.pairwiseKernels{i};

            % Get the segmentation and the evaluation metrics 
            [segmentations{i}, currentQualityMeasures] = getSegmentationFromData2(config, mask, y, X, pairwiseKernels, model);

            % Concatenate quality measures
            qualityMeasures.se(i) = currentQualityMeasures.se;
            qualityMeasures.sp(i) = currentQualityMeasures.sp;
            qualityMeasures.acc(i) = currentQualityMeasures.acc;
            qualityMeasures.precision(i) = currentQualityMeasures.precision;
            qualityMeasures.recall(i) = currentQualityMeasures.recall;
            qualityMeasures.fMeasure(i) = currentQualityMeasures.fMeasure;
            qualityMeasures.matthews(i) = currentQualityMeasures.matthews;
            qualityMeasures.dice(i) = currentQualityMeasures.dice;
            qualityMeasures.arias(i) = currentQualityMeasures.arias;
            qualityMeasures.time(i) = currentQualityMeasures.time;

            % Concatenate the unary potentials
            qualityMeasures.unaryPotentials = [qualityMeasures.unaryPotentials; currentQualityMeasures.unaryPotentials];
            if (~isempty(currentQualityMeasures.aucUP))
                qualityMeasures.aucUP(i) = currentQualityMeasures.aucUP;
                qualityMeasures.aucUP_pr(i) = currentQualityMeasures.aucUP_pr;
            else
                qualityMeasures.aucUP(i) = NaN;
                qualityMeasures.aucUP_pr(i) = NaN;
            end

            % Concatenate the pairwise potentials
            qualityMeasures.scores = [qualityMeasures.scores; currentQualityMeasures.scores];
            if (~isempty(currentQualityMeasures.auc))
                qualityMeasures.auc(i) = currentQualityMeasures.auc;
                qualityMeasures.auc_pr(i) = currentQualityMeasures.auc_pr;
            else
                qualityMeasures.auc(i) = NaN;
                qualityMeasures.auc_pr(i) = NaN;
            end
            
        else
            
            % Get image, mask, annotations, ground truth and features
            mask = data.masks{i};
            y = Inf;
            X = data.unaryFeatures{i};
            pairwiseKernels = data.pairwiseKernels{i};

            % Get the segmentation and the evaluation metrics 
            [segmentations{i}, currentQualityMeasures] = getSegmentationFromData2(config, mask, y, X, pairwiseKernels, model);
            
            % Concatenate quality measures
            qualityMeasures.time(i) = currentQualityMeasures.time;
            
        end

    end
    
end