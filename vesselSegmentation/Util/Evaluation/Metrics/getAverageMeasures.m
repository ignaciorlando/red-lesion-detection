
function [averageQualityMeasures] = getAverageMeasures(qualityMeasures)
    
    averageQualityMeasures.se = mean(qualityMeasures.se);
    averageQualityMeasures.sp = mean(qualityMeasures.sp);
    averageQualityMeasures.acc = mean(qualityMeasures.acc);
    averageQualityMeasures.precision = mean(qualityMeasures.precision);
    averageQualityMeasures.recall = mean(qualityMeasures.recall);
    averageQualityMeasures.fMeasure = mean(qualityMeasures.fMeasure);
    averageQualityMeasures.matthews = mean(qualityMeasures.matthews);

end