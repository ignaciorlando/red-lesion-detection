
function [qualityMeasures, averageQualityMeasures] = compareGivenSegmentations(segmentations, masks, groundtruth)
% compareGivenSegmentation Compare a list of given segmentations with
% respect to the ground truth labellings
% [qualityMeasures, averageQualityMeasures] = compareGivenSegmentations(segmentations, masks, groundtruth)
% OUTPUT: qualityMeasures: all the quality measures
%         averageQualityMeasures: average quality measures
% INPUT: segmentations: cell-array with all the segmentations
%        masks: cell-array with FOV masks
%        groundtruth: cell-array with all the labellings
   
    qualityMeasures.se = [];
    qualityMeasures.sp = [];
    qualityMeasures.acc = [];
    qualityMeasures.precision = [];
    qualityMeasures.recall = [];
    qualityMeasures.fMeasure = [];
    qualityMeasures.matthews = [];
    qualityMeasures.dice = [];
    
    % For each given segmentation
    for i = 1:length(segmentations)

        disp(i);
        
        mask = masks{i};
        if (size(mask,3)>0)
            mask = mask(:,:,1);
        end
        mask(mask>0) = 1;
        mask(mask<=0) = 0;
        masks{i} = logical(mask);
        
        % Get the evaluation metrics 
        segm = logical(segmentations{i});
        gt = logical(groundtruth{i});
        currentQualityMeasures = getQualityMeasures(segm(logical(masks{i})), logical(gt(logical(masks{i}))));
        
        % Concatenate quality measures
        qualityMeasures.se = [qualityMeasures.se, currentQualityMeasures.se];
        qualityMeasures.sp = [qualityMeasures.sp, currentQualityMeasures.sp];
        qualityMeasures.acc = [qualityMeasures.acc, currentQualityMeasures.acc];
        qualityMeasures.precision = [qualityMeasures.precision, currentQualityMeasures.precision];
        qualityMeasures.recall = [qualityMeasures.recall, currentQualityMeasures.recall];
        qualityMeasures.fMeasure = [qualityMeasures.fMeasure, currentQualityMeasures.fMeasure];
        qualityMeasures.matthews = [qualityMeasures.matthews, currentQualityMeasures.matthews];
        qualityMeasures.dice = [qualityMeasures.dice, currentQualityMeasures.dice];

    end
    
    % Put all the metric into a single table
    qualityMeasures.table = [qualityMeasures.se; qualityMeasures.sp; qualityMeasures.acc; qualityMeasures.precision; qualityMeasures.recall; qualityMeasures.fMeasure; qualityMeasures.matthews];
    qualityMeasures.table = qualityMeasures.table';
    
    [averageQualityMeasures] = getAverageMeasures2(qualityMeasures);

end


