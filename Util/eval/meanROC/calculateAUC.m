% The algorithm is described in Tom Fawcett, 'An introduction to ROC
% analysis', Pattern Recognition Letters 27 (2006) 861�874

%Input: dec_values: prediction vector
%       target:     target vector
%       bplot:      true/false to plot to ROC
%Output: AUC:       the value of the Area Under the ROC
%        ROC:       an array of ROC point that contains fpr, tpr and score
%                   feilds.

function [ROC, AUC, score, xplotelems, yplotelems] =  calculateAUC(dec_values, target, bplot)

% Boolean arrays with positive and negative classes
positives = length(find(target==1));
negatives = length(find(target==-1));
% Number of samples
samples = length(target);

% Sort all the scores and their corresponding labels
[sorted_dec_values, ind] = sort(dec_values, 'descend');
sorted_target = target(ind);

% Initialize variables
fp     = 0;
tp     = 0;
fprate = 0;
tprate = 0;
AUC    = 0;


dec_value_prev = 1+sorted_dec_values(1);

% For each sample
j = 1;
for i=1:samples
    
    if (sorted_dec_values(i) ~= dec_value_prev)
        
        xplotelems(j) = fprate;
        yplotelems(j) = tprate;
        % Matthews Correlation Coefficient
        mcc(j) = calculateStatistics(tp, positives-tp, negatives-fp, fp);
        % Accuracy
        acc(j) = (tp + negatives-fp)/(positives + negatives);
        score(j) = sorted_dec_values(i);
        
        dec_value_prev = sorted_dec_values(i);
        roc_point = struct('fpr', {xplotelems(j)}, 'tpr', {yplotelems(j)}, 'score', {score(j)}, 'mcc', {mcc(j)});
        ROC(j) = roc_point;
        j = j + 1;
    end
    
    % Compute the tp and fp rates
    if (sorted_target(i)==1)
        tp = tp+1;
        tprate = tp/positives;
    else
        fp = fp+1;
        fprate = fp/negatives;
    end 
end

xplotelems(j) = 1;
yplotelems(j) = 1;

AUC = trapz(xplotelems,yplotelems);

if (bplot)
    %figure;
    plot(xplotelems, yplotelems);
    xlabel('FP rate');
    ylabel('TP rate');
end
