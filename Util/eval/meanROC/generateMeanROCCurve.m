
function [AUC, AVR_X, AVR_Y, auc_std, SCORE] = generateMeanROCCurve(preds, labelsVals, numTrials)
% generateMeanROCCurve
% INPUT: 
%   preds = scores
%   labelsVals = labels
%   numTrials = number of trials
% OUTPUT:
%   AUC = area under the ROC curve
%   AVR_X = false positive rate
%   AVR_Y = true positive rate
%   auc_std = AUC standard deviation
%   SCORE = scores

    npts = [];

    % compute the index to separate each trial vector
    threshold = length(labelsVals)/numTrials;
    % for each trial
    aucTMP = zeros(numTrials, 1);
    for i=1:numTrials
        % compute the ROC curve
        [rocTMP, aucTMP(i), scoreTmp] = calculateAUC(preds((i-1)*threshold+1:i*threshold), ...
                                                  labelsVals((i-1)*threshold+1:i*threshold), false);
        % concatenate the ROC curve
        ROCS{i} = rocTMP;
        score{i} = scoreTmp;
        npts = [npts, length(rocTMP)];
    end
    auc_std = std(aucTMP);
    [AUC, AVR_X, AVR_Y, ~, SCORE] =  calculateAverageThresholdROC(100, numTrials, ROCS, npts, score, false);

end