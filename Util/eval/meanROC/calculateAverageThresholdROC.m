% The algorithm is described in Tom Fawcett, 'An introduction to ROC
% analysis', Pattern Recognition Letters 27 (2006) 861�874

% Threshold averaging of ROC curves
%Input: 
%       
%       samples:    the number of threshold samples
%       nrocs:      the number of ROC curves to be sampled
%       rocs:       a cell of nrocs ROC curves sorted by score.
%       npts:       the number of points in each ROC curve.
%       scores:     a cell of scores from ROC curves sorted descending
%       bplot:      true/false to plot to ROC
%Output: AUC:       the value of the Area Under the ROC


function [AUC, AVR_X, AVR_Y, std_X, std_Y,  ACC, MCC,SCORE] = calculateAverageThresholdROC(samples, nrocs, rocs, npts, scores, bplot, c)

if nargin < 7
    c = 1;
end

if nargin < 6
    bplot = false;
end

% initialize an array containing all scores of all ROC points
score_array = [];
for i=1:nrocs
    score_array = [score_array scores{i}];
end
scores_sorted = sort(score_array, 'descend');



s = 1;

scores_len = length(scores_sorted);
score_step = floor(scores_len/samples);
score_index = 1:score_step:scores_len;
index_length = length(score_index);
AVR_X = zeros(1, index_length+1);
std_X = zeros(1, index_length+1);
AVR_Y = zeros(1, index_length+1);
std_Y = zeros(1, index_length+1);
MCC = zeros(1, index_length);
ACC = zeros(1, index_length);
SCORE = zeros(1, index_length);
AUC = 0;
for sInd = 1:score_step:scores_len
    fpr_sum = zeros(1, nrocs);
    tpr_sum = zeros(1, nrocs);
    mcc_sum = zeros(1, nrocs);
    
    for i = 1:nrocs
        roc_point = find_roc_point_at_threshold(rocs{i}, npts(i), scores_sorted(sInd));
        fpr_sum(i) = roc_point.fpr;
        tpr_sum(i) = roc_point.tpr;
        mcc_sum(i) = roc_point.mcc;
    end
    AVR_X(s) = mean(fpr_sum);
    std_X(s) = std(fpr_sum);
    AVR_Y(s) = mean(tpr_sum);
    std_Y(s) = std(tpr_sum);
    MCC(s) = mean(mcc_sum);
    ACC(s) = (AVR_Y(s) + c*(1 - AVR_X(s)))/(1+c);
    SCORE(s) = scores_sorted(sInd);
    AVR_X(s);
    AVR_Y(s);
    SCORE(s);
    s = s+1;
end
AVR_X(end) = 1;
AVR_Y(end) = 1;
std_X(end) = mean(std_X);
std_Y(end) = mean(std_Y);
AUC = trapz(AVR_X, AVR_Y);

if (bplot)
    figure;
    errorbar(AVR_X, AVR_Y,std_Y);
    xlabel('FP rate');
    ylabel('TP rate');
    mytext = sprintf('ROC with AUC = %.3f', AUC);
    title(mytext);
end
return;


function [roc_point] = find_roc_point_at_threshold(ROC, npts, thresh)


i = 1;
while i < npts && ROC(i).score > thresh
    i = i+1;
end
if length(ROC) < i
    roc_point = ROC(end);
else
    roc_point = ROC(i);
end
return;

% For calling this function...
% c = 1;
% npts = [];
% for i=1:10
% num = sprintf('%d', i);
% file = strcat('../Statistics/Features_37/CombSeqStrFold_', num, '.txt');
% data = load(file);
% [rocTMP, aucTMP, scoreTmp] = calculateAUC(data(:, 1), data(:, 2), false);
% ROCS{i} = rocTMP;
% score{i} = scoreTmp;
% npts = [npts, length(rocTMP)];
% end
% [AUC, AVR_X, AVR_Y, MCC, SCORE] =  calculateAverageThresholdROC(1000, 10, ROCS, npts, score, true, c);
