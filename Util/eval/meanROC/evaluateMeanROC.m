
npts = [];
if (isfield(results, 'searches'))
    numTrials = size(results.searches,3);
else
    numTrials = 200;
end
preds = results.scores;
labelsVals = results.labelsVals;

% compute the index to separate each trial vector
threshold = length(labelsVals)/numTrials;
% for each trial
for i=1:numTrials
    % compute the ROC curve
    [rocTMP, aucTMP, scoreTmp] = calculateAUC(preds((i-1)*threshold+1:i*threshold), ...
                                              labelsVals((i-1)*threshold+1:i*threshold), false);
    % concatenate the ROC curve
    ROCS{i} = rocTMP;
    score{i} = scoreTmp;
    npts = [npts, length(rocTMP)];
end
[AUC, AVR_X, AVR_Y, MCC, SCORE] =  calculateAverageThresholdROC(30, numTrials, ROCS, npts, score, false);
figure, plot(AVR_X, AVR_Y);