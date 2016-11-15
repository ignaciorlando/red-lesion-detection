
function [qualityMeasures, averageQualityMeasures] = compareSegmentations(segmentationRoot, groundtruthRoot, masksRoot)
% compareSegmentation Compare segmentations
% [qualityMeasures, averageQualityMeasures] = compareSegmentations(segmentationRoot, groundtruthRoot, masksRoot)
% OUTPUT: qualityMeasures: all the quality measures
%         averageQualityMeasures: average quality measures
% INPUT: segmentationRoot: root directory where the segmentations are stored
%        groundtruthRoot: root directory where the ground truth segmentations are
%        masksRoot: root directory where the FOV masks are


    segmentations = openMultipleGroundTruths(segmentationRoot);
    masks = openMultipleGroundTruths(masksRoot);
    groundtruth = openMultipleGroundTruths(groundtruthRoot);
    
    qualityMeasures.se = [];
    qualityMeasures.sp = [];
    qualityMeasures.acc = [];
    qualityMeasures.precision = [];
    qualityMeasures.recall = [];
    qualityMeasures.fMeasure = [];
    qualityMeasures.matthews = [];
    qualityMeasures.dice = [];
    
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
        %figure, imshow(segm);
        %figure, imshow(gt);
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
    
    [averageQualityMeasures] = getAverageMeasures2(qualityMeasures);

end

function [images] = openMultipleGroundTruths(directory)
    % Get all file names
    allFiles = dir(directory);
    % Get only the names of the images inside the folder
    allNames = cell({allFiles.name});
    allNames = (filterFileNames(allNames));
    % Get all the images in the directory and count the number of pixels
    images = cell(length(allNames), 1);
    for i = 1:length(allNames)
      currentfilename = strtrim(allNames{i});
      currentfilename = strrep(currentfilename, '''', '');
      currentImage = imread(strcat(directory, filesep, currentfilename));
      images{i} = (currentImage); % Assign the image
    end
end

