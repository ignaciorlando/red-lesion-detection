
function qualityMeasures = getQualityMeasures(yhat, y)
% getQualityMeasures Compute quality measures
% qualityMeasures = getQualityMeasures(yhat, y)
% OUTPUT: qualityMeasures: quality measures
% INPUT: yhat: estimated labelling
%        y: ground truth labelling

    % Get the confusion matrix
    C = confusionmat(int8(y), int8(yhat));
    TP = double(C(2,2));
    FN = double(C(2,1));
    TN = double(C(1,1));
    FP = double(C(1,2));
    N = TP + TN + FN + FP;
    
    % Sensitivity
    qualityMeasures.se = TP / (FN + TP);
    % Specificity
    qualityMeasures.sp = TN / (FP + TN);
    % Precision
    qualityMeasures.precision = TP / (TP + FP);
    % Recall
    qualityMeasures.recall = qualityMeasures.se;
    % Accuracy
    qualityMeasures.acc = (TP + TN) / N;
    % F-measure
    beta = 1;
    qualityMeasures.fMeasure = (1 + beta^2) * (qualityMeasures.precision * qualityMeasures.recall) / (beta^2 * qualityMeasures.precision + qualityMeasures.recall);
    % Matthew's Correlation Coefficient
    qualityMeasures.matthews = ((TP * TN) - (FP * FN)) / sqrt((TP+FP) * (TP+FN) * (TN+FP) * (TN+FN));
    % Dice
    qualityMeasures.dice = (2 * TP) / (FP + FN + 2*TP);
    % Arias' measure
    arias = computeAriasQualityMeasure(y, yhat);
    qualityMeasures.arias = arias.cal;
    
end