
function [result] = evaluateOverTestData(param, model, testset)

    % Get results
    [result.segmentations, result.qualityMeasures] = getBunchSegmentations(param, testset, model);

end