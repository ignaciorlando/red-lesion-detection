
function [averageQualityMeasures] = getAverageMeasures2(qualityMeasures)
% getAverageMeasures2 Compute the average measures
% [averageQualityMeasures] = getAverageMeasures2(qualityMeasures)
% OUTPUT: averageQualityMeasures: average quality measures
% INPUT: qualityMeasures: struct with arrays for each specific quality
%        measure
    
    averageQualityMeasures.se = mean(qualityMeasures.se);
    averageQualityMeasures.sp = mean(qualityMeasures.sp);
    averageQualityMeasures.acc = mean(qualityMeasures.acc);
    averageQualityMeasures.precision = mean(qualityMeasures.precision);
    averageQualityMeasures.recall = mean(qualityMeasures.recall);
    averageQualityMeasures.fMeasure = mean(qualityMeasures.fMeasure);
    averageQualityMeasures.matthews = mean(qualityMeasures.matthews);
    averageQualityMeasures.dice = mean(qualityMeasures.dice);
    
    if (isfield(qualityMeasures,'arias'))
        averageQualityMeasures.arias = mean(qualityMeasures.arias);
    end

    if (isfield(qualityMeasures,'scores'))
        averageQualityMeasures.scores = qualityMeasures.scores;
    end
    
    if (isfield(qualityMeasures,'auc'))
        averageQualityMeasures.auc = mean(qualityMeasures.auc);
    end
    
    if (isfield(qualityMeasures,'auc_pr'))
        averageQualityMeasures.auc_pr = mean(qualityMeasures.auc_pr);
    end
    
    if (isfield(qualityMeasures,'unaryPotentials'))
        averageQualityMeasures.unaryPotentials = qualityMeasures.unaryPotentials;
    end
    
    if (isfield(qualityMeasures,'aucUP'))
        averageQualityMeasures.aucUP = mean(qualityMeasures.aucUP);
    end
    
    if (isfield(qualityMeasures,'aucUP_pr'))
        averageQualityMeasures.aucUP_pr = mean(qualityMeasures.aucUP_pr);
    end
    
    if (isfield(averageQualityMeasures,'auc'))
        averageQualityMeasures.qualities = [averageQualityMeasures.se; ...
                                            averageQualityMeasures.sp; ...
                                            averageQualityMeasures.acc; ...
                                            averageQualityMeasures.auc; ...
                                            averageQualityMeasures.matthews; ...
                                            averageQualityMeasures.precision; ...
                                            averageQualityMeasures.recall; ...
                                            averageQualityMeasures.fMeasure; ...
                                            ];
    else
        averageQualityMeasures.qualities = [averageQualityMeasures.se; ...
                                        averageQualityMeasures.sp; ...
                                        averageQualityMeasures.acc; ...
                                        averageQualityMeasures.matthews; ...
                                        averageQualityMeasures.precision; ...
                                        averageQualityMeasures.recall; ...
                                        averageQualityMeasures.fMeasure; ...
                                        ];
    end

end