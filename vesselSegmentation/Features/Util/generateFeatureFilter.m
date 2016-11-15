
function [featureFilter] = generateFeatureFilter(selectedFeatures, sizes)
% generateFeatureFilter Generate a binary array to filter the features
% [featureFilter] = generateFeatureFilter(selectedFeatures, sizes)
% OUTPUT: featureFilter: a binary array indicating which features are going
%         to be used
% INPUT: selectedFeatures: a list of the selected features
%        sizes: an array with the dimensions of each of the features

    featureFilter = [];
    for i = 1 : length(selectedFeatures)
        featureFilter = cat(1, featureFilter, ones(sizes(i),1) * selectedFeatures(i));
    end
    featureFilter = logical(featureFilter);

end